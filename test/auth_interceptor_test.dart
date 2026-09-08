import 'dart:async';

import 'package:dio/dio.dart';
import 'package:eman_shareholders/core/http/http.dart';
import 'package:eman_shareholders/core/session/session_manager.dart';
import 'package:eman_shareholders/feature/auth/user_token.dart';
import 'package:flutter_test/flutter_test.dart';

/// جلسة في الميموري — بتغني عن Hive و SharedPreferences في الاختبار.
class FakeSessionManager implements SessionManager {
  UserToken? _token;
  int saveCount = 0;
  int clearCount = 0;

  FakeSessionManager(this._token);

  @override
  UserToken? get token => _token?.isValid == true ? _token : null;

  @override
  String? get accessToken => token?.accessToken;

  @override
  bool get isLoggedIn => token != null;

  @override
  Map<String, String> get authHeader {
    final value = accessToken;
    if (value == null || value.isEmpty) return const {};
    return {'Authorization': 'Bearer $value'};
  }

  @override
  Future<void> save(UserToken newToken) async {
    _token = newToken;
    saveCount++;
  }

  @override
  Future<void> update(UserToken refreshed) => save(refreshed);

  @override
  Future<void> clear() async {
    _token = null;
    clearCount++;
  }
}

UserToken _token({
  String access = 'old-access',
  String refresh = 'refresh-1',
}) {
  return UserToken(
    accessToken: access,
    refreshToken: refresh,
    message: '',
    userType: 'Shareholder',
    userId: '116',
    email: '',
    userName: 'test',
    expiresAtUtc: DateTime.now().toUtc().add(const Duration(minutes: 10)),
  );
}

void main() {
  group('UserToken', () {
    test('بيقرأ التوكن من جذر الريسبونس (شكل verify-otp)', () {
      final token = UserToken.fromJson(const {
        'accessToken': 'abc',
        'refreshToken': 'def',
        'userType': 'Shareholder',
        'userId': '116',
        'email': null,
        'userName': 'test',
        'role': null,
        'permissions': [],
        'expiresAtUtc': '2026-09-02T12:51:34.1517992Z',
      });

      expect(token.accessToken, 'abc');
      expect(token.refreshToken, 'def');
      expect(token.userId, '116');
      // `email: null` ما يقعش الـ parsing.
      expect(token.email, '');
      expect(token.isValid, isTrue);
      expect(token.expiresAtUtc.isUtc, isTrue);
    });

    test('بيتعامل مع الوقت اللي جايي بدون Z كـ UTC', () {
      // السيرفر بيرجع كده في بعض الحقول.
      final token = UserToken.fromJson(const {
        'accessToken': 'abc',
        'refreshToken': 'd',
        'expiresAtUtc': '2026-09-02T12:20:43.2443566',
      });
      expect(token.expiresAtUtc.isUtc, isTrue);
      expect(token.expiresAtUtc.hour, 12);
    });

    test('التوكن المنتهي بيتعرف صح', () {
      final expired = _token().copyWith(
        expiresAtUtc: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
      );
      expect(expired.isExpired, isTrue);
      expect(_token().isExpired, isFalse);
    });
  });

  group('AuthInterceptor', () {
    test('بيحقن التوكن في الريكوستات المحمية بس', () async {
      final session = FakeSessionManager(_token());
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      final seen = <String, String?>{};

      dio.interceptors.add(
        AuthInterceptor(dio: dio, session: session),
      );
      dio.httpClientAdapter = _StubAdapter((options) {
        seen[options.path] = options.headers['Authorization'] as String?;
        return ResponseBody.fromString('{}', 200, headers: _jsonHeaders);
      });

      await dio.get('/api/shareholder/statement');
      await dio.post(Endpoints.shareholderRequestOtp, data: {});

      expect(seen['/api/shareholder/statement'], 'Bearer old-access');
      // المسار العام ما بياخدش توكن.
      expect(seen[Endpoints.shareholderRequestOtp], isNull);
    });

    test('لما 401 تيجي بيجدد التوكن ويعيد الريكوست مرة واحدة', () async {
      final session = FakeSessionManager(_token());
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      dio.interceptors.add(AuthInterceptor(dio: dio, session: session));

      var statementCalls = 0;
      var refreshCalls = 0;

      dio.httpClientAdapter = _StubAdapter((options) {
        if (options.path == Endpoints.refreshToken) {
          refreshCalls++;
          return ResponseBody.fromString(
            '{"accessToken":"new-access","refreshToken":"refresh-2",'
            '"expiresAtUtc":"2030-01-01T00:00:00Z"}',
            200,
            headers: _jsonHeaders,
          );
        }

        statementCalls++;
        // أول نداء 401، وبعد التجديد بينجح.
        if (options.headers['Authorization'] == 'Bearer new-access') {
          return ResponseBody.fromString(
            '{"statusCode":200,"message":"Success"}',
            200,
            headers: _jsonHeaders,
          );
        }
        return ResponseBody.fromString('', 401, headers: _jsonHeaders);
      });

      final response = await dio.get('/api/shareholder/statement');

      expect(response.statusCode, 200);
      expect(refreshCalls, 1, reason: 'لازم تجديد واحد بس');
      expect(statementCalls, 2, reason: 'نداء أصلي + إعادة واحدة');
      expect(session.accessToken, 'new-access');
    });

    test('كل الريكوستات المتوازية بتستنى نفس عملية التجديد', () async {
      final session = FakeSessionManager(_token());
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      dio.interceptors.add(AuthInterceptor(dio: dio, session: session));

      var refreshCalls = 0;

      dio.httpClientAdapter = _StubAdapter((options) async {
        if (options.path == Endpoints.refreshToken) {
          refreshCalls++;
          await Future.delayed(const Duration(milliseconds: 80));
          return ResponseBody.fromString(
            '{"accessToken":"new-access","refreshToken":"r2",'
            '"expiresAtUtc":"2030-01-01T00:00:00Z"}',
            200,
            headers: _jsonHeaders,
          );
        }
        if (options.headers['Authorization'] == 'Bearer new-access') {
          return ResponseBody.fromString('{}', 200, headers: _jsonHeaders);
        }
        return ResponseBody.fromString('', 401, headers: _jsonHeaders);
      });

      // ٥ ريكوستات بيقعوا في نفس الوقت بـ 401.
      final responses = await Future.wait([
        dio.get('/api/a'),
        dio.get('/api/b'),
        dio.get('/api/c'),
        dio.get('/api/d'),
        dio.get('/api/e'),
      ]);

      expect(responses.every((r) => r.statusCode == 200), isTrue);
      expect(refreshCalls, 1, reason: 'القفل لازم يمنع تجديد متكرر');
    });

    test('لو التجديد فشل بتُمسح الجلسة وبيتنادى onSessionExpired', () async {
      final session = FakeSessionManager(_token());
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      var expiredCalls = 0;

      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          session: session,
          onSessionExpired: () => expiredCalls++,
        ),
      );

      dio.httpClientAdapter = _StubAdapter((options) {
        if (options.path == Endpoints.refreshToken) {
          // زي السيرفر الحقيقي: 401 على refresh token ميت.
          return ResponseBody.fromString(
            '{"details":"Invalid refresh token","statusCode":401,'
            '"message":"رمز الدخول غير صالح أو انتهت صلاحيته."}',
            401,
            headers: _jsonHeaders,
          );
        }
        return ResponseBody.fromString('', 401, headers: _jsonHeaders);
      });

      await expectLater(
        dio.get('/api/shareholder/statement'),
        throwsA(isA<DioException>()),
      );

      expect(expiredCalls, 1);
      expect(session.clearCount, 1);
      expect(session.isLoggedIn, isFalse);
    });

    test('مفيش محاولة تجديد لو مفيش refresh token', () async {
      final session = FakeSessionManager(_token(refresh: ''));
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      dio.interceptors.add(AuthInterceptor(dio: dio, session: session));

      var refreshCalls = 0;
      dio.httpClientAdapter = _StubAdapter((options) {
        if (options.path == Endpoints.refreshToken) refreshCalls++;
        return ResponseBody.fromString('', 401, headers: _jsonHeaders);
      });

      await expectLater(
        dio.get('/api/shareholder/statement'),
        throwsA(isA<DioException>()),
      );
      expect(refreshCalls, 0);
    });

    test('401 من مسار عام ما بتشغلش التجديد', () async {
      final session = FakeSessionManager(_token());
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      dio.interceptors.add(AuthInterceptor(dio: dio, session: session));

      var refreshCalls = 0;
      dio.httpClientAdapter = _StubAdapter((options) {
        if (options.path == Endpoints.refreshToken) refreshCalls++;
        return ResponseBody.fromString('', 401, headers: _jsonHeaders);
      });

      await expectLater(
        dio.post(Endpoints.shareholderVerifyOtp, data: {}),
        throwsA(isA<DioException>()),
      );
      expect(refreshCalls, 0);
      // الجلسة ما اتمسحتش بسبب فشل تحقق رمز.
      expect(session.isLoggedIn, isTrue);
    });
  });
}

const _jsonHeaders = {
  Headers.contentTypeHeader: ['application/json'],
};

/// أدابتر بيرد من دالة بدل الشبكة.
class _StubAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) _handler;

  _StubAdapter(FutureOr<ResponseBody> Function(RequestOptions) handler)
      : _handler = ((options) async => await handler(options));

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      _handler(options);

  @override
  void close({bool force = false}) {}
}
