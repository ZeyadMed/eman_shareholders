@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// اختبارات بتضرب على السيرفر الحقيقي — بتتخطى نفسها لو مفيش
/// `OTP` متمرر، عشان `flutter test` العادي ما يفشلش.
///
/// طريقة التشغيل:
///   flutter test test/auth_flow_live_test.dart --dart-define=OTP=123456
void main() {
  const phone = '01152220257';
  final otp = const String.fromEnvironment('OTP');

  late Dio dio;

  setUp(() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://amantheone.runasp.net',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (_) => true,
      ),
    );
  });

  test('request-otp بيرجع 200 ومعاه expiresAtUtc', () async {
    final res = await dio.post(
      '/api/shareholder/auth/request-otp',
      data: {'phoneNumber': phone},
    );

    expect(res.statusCode, 200);
    expect(res.data['statusCode'], 200);
    expect(res.data['data']['expiresAtUtc'], isNotNull);
    stdout.writeln('request-otp → ${res.data['message']}');
  });

  test('verify-otp بدون deviceToken بيفشل — بيثبت إنه مطلوب', () async {
    final res = await dio.post(
      '/api/shareholder/auth/verify-otp',
      data: {'phoneNumber': phone, 'otp': '123456'},
    );

    expect(res.statusCode, 400);
    expect(res.data['message'], contains('رمز الجهاز'));
  });

  test('verify-otp بـ deviceToken بيوصل لتحقق الرمز الحقيقي', () async {
    final res = await dio.post(
      '/api/shareholder/auth/verify-otp',
      data: {
        'phoneNumber': phone,
        'otp': '000000',
        'deviceToken': 'test-device',
        'rememberMe': true,
      },
    );

    expect(res.statusCode, 400);
    // الرسالة بقت عن الرمز نفسه مش عن حقل ناقص.
    expect(res.data['message'], contains('كود التحقق'));
  });

  test('refresh-token برمز غلط بيرجع 401', () async {
    final res = await dio.post(
      '/api/auth/refresh-token',
      data: {
        'refreshToken': 'nope',
        'deviceInfo': 'Android',
        'deviceId': 'test',
      },
    );

    expect(res.statusCode, 401);
  });

  test('statement بدون توكن بيرجع 401', () async {
    final res = await dio.get(
      '/api/shareholder/statement',
      queryParameters: {'PageIndex': 1, 'PageSize': 10},
    );
    expect(res.statusCode, 401);
  });

  test(
    'الدورة الكاملة: verify → statement → refresh → statement',
    () async {
      // بيتخطى لو مفيش OTP حقيقي متمرر.
      final verify = await dio.post(
        '/api/shareholder/auth/verify-otp',
        data: {
          'phoneNumber': phone,
          'otp': otp,
          'deviceToken': 'test-device-$phone',
          'rememberMe': true,
        },
      );

      expect(
        verify.statusCode,
        200,
        reason: 'الرمز غالبًا منتهي — شغّل الاختبار برمز جديد: ${verify.data}',
      );

      final accessToken = verify.data['accessToken'] as String;
      final refreshToken = verify.data['refreshToken'] as String;
      expect(accessToken, isNotEmpty);
      expect(refreshToken, isNotEmpty);
      stdout.writeln('verify-otp → user ${verify.data['userName']}');

      // كشف الحساب بالتوكن.
      final statement = await dio.get(
        '/api/shareholder/statement',
        queryParameters: {'PageIndex': 1, 'PageSize': 10},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      expect(statement.statusCode, 200);
      expect(statement.data['data']['shareholder'], isNotNull);
      stdout.writeln(
        'statement → ${statement.data['data']['shareholder']['name']}',
      );

      // تجديد التوكن.
      final refreshed = await dio.post(
        '/api/auth/refresh-token',
        data: {
          'refreshToken': refreshToken,
          'deviceInfo': 'Android',
          'deviceId': 'test-device-$phone',
        },
      );
      expect(refreshed.statusCode, 200, reason: '${refreshed.data}');
      final newAccess = refreshed.data['accessToken'] as String;
      expect(newAccess, isNotEmpty);
      stdout.writeln('refresh-token → جديد ومختلف: ${newAccess != accessToken}');

      // كشف الحساب بالتوكن الجديد.
      final afterRefresh = await dio.get(
        '/api/shareholder/statement',
        queryParameters: {'PageIndex': 1, 'PageSize': 10},
        options: Options(headers: {'Authorization': 'Bearer $newAccess'}),
      );
      expect(afterRefresh.statusCode, 200);
      stdout.writeln('statement بعد التجديد → OK');
    },
    skip: otp.isEmpty
        ? 'مرر رمز حقيقي: --dart-define=OTP=xxxxxx'
        : false,
  );
}
