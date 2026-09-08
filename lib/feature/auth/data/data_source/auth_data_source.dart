import 'package:eman_shareholders/core/helpers/helpers.dart';
import 'package:eman_shareholders/core/http/either.dart';
import 'package:eman_shareholders/core/http/failure.dart';
import 'package:eman_shareholders/core/http/http.dart';
import 'package:eman_shareholders/core/local_storage/local_storage.dart';
import 'package:eman_shareholders/feature/auth/user_token.dart';

import '../models/otp_request_result.dart';

abstract interface class AuthDataSource {
  /// إرسال رمز التحقق لرقم الهاتف.
  Future<Either<Failure, OtpRequestResult>> requestOtp(String phoneNumber);

  /// إعادة إرسال رمز التحقق لنفس الرقم.
  Future<Either<Failure, OtpRequestResult>> resendOtp(String phoneNumber);

  /// التحقق من الرمز — بترجع توكن الجلسة.
  Future<Either<Failure, UserToken>> verifyOtp({
    required String phoneNumber,
    required String otp,
  });
}

class AuthDataSourceImpl implements AuthDataSource {
  final ApiConsumer _apiConsumer;

  AuthDataSourceImpl(this._apiConsumer);

  @override
  Future<Either<Failure, OtpRequestResult>> requestOtp(String phoneNumber) {
    return _requestOtp(Endpoints.shareholderRequestOtp, phoneNumber);
  }

  @override
  Future<Either<Failure, OtpRequestResult>> resendOtp(String phoneNumber) {
    return _requestOtp(Endpoints.shareholderResendOtp, phoneNumber);
  }

  Future<Either<Failure, OtpRequestResult>> _requestOtp(
    String endpoint,
    String phoneNumber,
  ) async {
    final result = await _apiConsumer.post(
      endpoint,
      data: {'phoneNumber': phoneNumber},
      // مسار عام — أي 401 هنا مش معناها توكن منتهي.
      skipAuthRefresh: true,
    );

    return result.fold(Left.new, (response) {
      try {
        final data = response['data'];
        return Right(
          OtpRequestResult.fromJson({
            if (data is Map) ...Map<String, dynamic>.from(data),
            'message': response['message'],
          }),
        );
      } catch (e, stackTrace) {
        loggerError(stackTrace);
        loggerWarn(e.toString());
        return Left(ParsingFailure(message: e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, UserToken>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    // `deviceToken` مطلوب فعليًا من السيرفر (مش nullable زي ما الـ Swagger
    // بيقول) — لو مبعتوش بيرجع 400 "رقم الهاتف وكود التحقق ورمز الجهاز
    // مطلوبون". بنستخدم مُعرّف الجهاز الثابت لحد ما نضيف FCM.
    final deviceToken = await HiveServiceImpl.instance.getDeviceId();

    final result = await _apiConsumer.post(
      Endpoints.shareholderVerifyOtp,
      data: {
        'phoneNumber': phoneNumber,
        'otp': otp,
        'deviceToken': deviceToken,
        'rememberMe': true,
      },
      skipAuthRefresh: true,
    );

    return result.fold(Left.new, (response) {
      try {
        // ريسبونس التحقق بيرجع التوكن في الجذر مباشرة — مش ملفوف في `data`.
        final token = UserToken.fromJson(response);
        if (!token.isValid) {
          return Left(
            AuthFailure(
              message: response['message']?.toString().trim().isNotEmpty == true
                  ? response['message'].toString()
                  : 'تعذر تسجيل الدخول، حاول مرة أخرى',
            ),
          );
        }
        return Right(token);
      } catch (e, stackTrace) {
        loggerError(stackTrace);
        loggerWarn(e.toString());
        return Left(ParsingFailure(message: e.toString()));
      }
    });
  }
}
