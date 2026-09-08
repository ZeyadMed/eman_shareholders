import 'dart:async';

import 'package:dio/dio.dart';
import 'package:eman_shareholders/core/helpers/helpers.dart';
import 'package:eman_shareholders/core/http/http.dart';
import 'package:eman_shareholders/core/local_storage/local_storage.dart';
import 'package:eman_shareholders/core/session/session_manager.dart';
import 'package:eman_shareholders/feature/auth/user_token.dart';

/// بيحقن الـ access token في كل ريكوست، ولما السيرفر يرجّع 401 بيجدّد
/// التوكن مرة واحدة بس ويعيد الريكوست الأصلي.
///
/// كل الريكوستات اللي بتوقع في نفس الوقت بتستنى نفس عملية التجديد
/// (قفل واحد) عشان ما نبعتش عشرين ريكوست تجديد ونحرق الـ refresh token.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SessionManager _session;

  /// بيتنادى لما التجديد يفشل — الجلسة خلصت ولازم المستخدم يدخل تاني.
  final FutureOr<void> Function()? onSessionExpired;

  AuthInterceptor({
    required Dio dio,
    required SessionManager session,
    this.onSessionExpired,
  })  : _dio = dio,
        _session = session;

  /// المسارات اللي ما بتحتاجش توكن — لو 401 جت منها يبقى دي مشكلة
  /// بيانات دخول مش توكن منتهي، فما بنحاولش نجدد.
  static const Set<String> _publicPaths = {
    Endpoints.shareholderRequestOtp,
    Endpoints.shareholderResendOtp,
    Endpoints.shareholderVerifyOtp,
    Endpoints.refreshToken,
  };

  static bool _isPublic(String path) =>
      _publicPaths.any((public) => path.contains(public));

  /// علامة بنحطها على الريكوست المعاد إرساله عشان ما يدخلش في حلقة
  /// تجديد لا نهائية لو رجع 401 تاني.
  static const String _retriedKey = 'auth_retried';

  // قفل التجديد — مشترك بين كل الـ instances.
  static Completer<bool>? _refreshCompleter;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (!_isPublic(options.path)) {
      final header = _session.authHeader;
      if (header.isNotEmpty) {
        options.headers.addAll(header);
      }
    } else {
      // المسارات العامة لازم تتبعت بدون توكن قديم/منتهي.
      options.headers.remove('Authorization');
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final request = err.requestOptions;

    final shouldRefresh = response?.statusCode == 401 &&
        !_isPublic(request.path) &&
        request.extra[_retriedKey] != true &&
        _session.token?.hasRefreshToken == true;

    if (!shouldRefresh) {
      return handler.next(err);
    }

    final refreshed = await _refreshWithLock();
    if (!refreshed) {
      return handler.next(err);
    }

    try {
      // إعادة الريكوست الأصلي بالتوكن الجديد.
      request.extra[_retriedKey] = true;
      request.headers.addAll(_session.authHeader);

      final retried = await _dio.fetch(request);
      return handler.resolve(retried);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// بيجدّد التوكن مرة واحدة بس لو فيه أكتر من ريكوست بيطلب التجديد.
  Future<bool> _refreshWithLock() {
    final inFlight = _refreshCompleter;
    if (inFlight != null && !inFlight.isCompleted) {
      loggerInfo('Refresh already in flight — waiting for it');
      return inFlight.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    _refresh().then((result) {
      if (!completer.isCompleted) completer.complete(result);
    }).catchError((Object error) {
      loggerError('Refresh threw: $error');
      if (!completer.isCompleted) completer.complete(false);
    }).whenComplete(() {
      if (identical(_refreshCompleter, completer)) _refreshCompleter = null;
    });

    return completer.future;
  }

  Future<bool> _refresh() async {
    final current = _session.token;
    final refreshToken = current?.refreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      loggerWarn('No refresh token available');
      await _expireSession();
      return false;
    }

    final deviceId = await HiveServiceImpl.instance.getDeviceId();
    final deviceInfo = HiveServiceImpl.instance.getDeviceInfo();

    try {
      loggerInfo('Refreshing access token…');

      // بنستخدم نفس الـ Dio عشان نحتفظ بالـ adapter والـ baseUrl
      // والإعدادات؛ مسار التجديد موجود في `_publicPaths` فالـ interceptor
      // ده مش بيحقن توكن ومش بيحاول يجدد لو رجع 401.
      final response = await _dio.post(
        Endpoints.refreshToken,
        data: {
          'refreshToken': refreshToken,
          'deviceInfo': deviceInfo,
          'deviceId': deviceId,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final newToken = UserToken.fromJson(data);
        if (newToken.isValid) {
          await _session.update(newToken);
          loggerInfo('Token refreshed successfully');
          return true;
        }
      }

      loggerWarn('Refresh endpoint returned no access token');
      await _expireSession();
      return false;
    } on DioException catch (e) {
      // 401 من مسار التجديد = الـ refresh token نفسه مات، مفيش إعادة محاولة.
      loggerError('Token refresh failed (${e.response?.statusCode}): '
          '${e.response?.data ?? e.message}');
      await _expireSession();
      return false;
    }
  }

  Future<void> _expireSession() async {
    await _session.clear();
    _dio.options.headers.remove('Authorization');
    await onSessionExpired?.call();
  }
}
