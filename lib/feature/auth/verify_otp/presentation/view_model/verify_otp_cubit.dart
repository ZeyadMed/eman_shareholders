import 'dart:async';

import 'package:eman_shareholders/core/enum/status.dart';
import 'package:eman_shareholders/core/session/session_manager.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_source/auth_data_source.dart';

/// حالة شاشة التحقق — بتفرّق بين التحقق نفسه وإعادة إرسال الرمز عشان
/// كل واحد يعرض لودينج ورسالة مستقلة.
class VerifyOtpState extends Equatable {
  /// حالة التحقق من الرمز.
  final Status verifyStatus;

  /// حالة إعادة إرسال الرمز.
  final Status resendStatus;

  /// رسالة الخطأ المعروضة (من التحقق أو من إعادة الإرسال).
  final String? errorMessage;

  /// رسالة نجاح إعادة الإرسال.
  final String? resendMessage;

  /// ثواني القفل قبل ما يقدر يطلب رمز جديد.
  final int resendCooldown;

  const VerifyOtpState({
    this.verifyStatus = Status.initial,
    this.resendStatus = Status.initial,
    this.errorMessage,
    this.resendMessage,
    this.resendCooldown = 0,
  });

  bool get isVerifying => verifyStatus == Status.loading;
  bool get isVerified => verifyStatus == Status.success;
  bool get isResending => resendStatus == Status.loading;
  bool get canResend => resendCooldown <= 0 && !isResending && !isVerifying;

  /// الرمز اللي المستخدم كتبه غلط — بيخلي خانات الرمز حمرا.
  bool get hasError => verifyStatus == Status.failure && errorMessage != null;

  VerifyOtpState copyWith({
    Status? verifyStatus,
    Status? resendStatus,
    String? errorMessage,
    String? resendMessage,
    int? resendCooldown,
    bool clearMessages = false,
  }) {
    return VerifyOtpState(
      verifyStatus: verifyStatus ?? this.verifyStatus,
      resendStatus: resendStatus ?? this.resendStatus,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      resendMessage:
          clearMessages ? null : (resendMessage ?? this.resendMessage),
      resendCooldown: resendCooldown ?? this.resendCooldown,
    );
  }

  @override
  List<Object?> get props => [
        verifyStatus,
        resendStatus,
        errorMessage,
        resendMessage,
        resendCooldown,
      ];
}

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  final AuthDataSource _dataSource;
  final SessionManager _session;

  /// رقم الهاتف اللي اتبعت عليه الرمز.
  final String phoneNumber;

  VerifyOtpCubit(
    this._dataSource,
    this._session, {
    required this.phoneNumber,
    int initialCooldown = _defaultCooldown,
  }) : super(VerifyOtpState(resendCooldown: initialCooldown));

  /// مدة القفل الافتراضية لإعادة الإرسال.
  static const int _defaultCooldown = 60;

  Timer? _cooldownTimer;

  /// بيبدأ العد التنازلي لإعادة الإرسال.
  void startCooldown([int seconds = _defaultCooldown]) {
    _cooldownTimer?.cancel();
    if (isClosed) return;

    emit(state.copyWith(resendCooldown: seconds));

    if (seconds <= 0) return;

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      final next = state.resendCooldown - 1;
      if (next <= 0) {
        timer.cancel();
        emit(state.copyWith(resendCooldown: 0));
        return;
      }
      emit(state.copyWith(resendCooldown: next));
    });
  }

  /// بيمسح الخطأ لما المستخدم يعدّل الرمز.
  void clearError() {
    if (state.errorMessage == null && state.resendMessage == null) return;
    emit(
      state.copyWith(
        verifyStatus: state.verifyStatus == Status.failure
            ? Status.initial
            : state.verifyStatus,
        clearMessages: true,
      ),
    );
  }

  Future<void> verifyOtp(String otp) async {
    if (state.isVerifying || state.isVerified) return;

    emit(
      state.copyWith(verifyStatus: Status.loading, clearMessages: true),
    );

    final result = await _dataSource.verifyOtp(
      phoneNumber: phoneNumber,
      otp: otp,
    );

    if (isClosed) return;

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            verifyStatus: Status.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (token) async {
        // نخزّن الجلسة قبل ما الشاشة تنتقل، عشان أول ريكوست في كشف
        // الحساب يلاقي التوكن جاهز.
        await _session.save(token);
        if (isClosed) return;
        _cooldownTimer?.cancel();
        emit(state.copyWith(verifyStatus: Status.success));
      },
    );
  }

  Future<void> resendOtp() async {
    if (!state.canResend) return;

    emit(
      state.copyWith(resendStatus: Status.loading, clearMessages: true),
    );

    final result = await _dataSource.resendOtp(phoneNumber);

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          resendStatus: Status.failure,
          errorMessage: failure.message,
        ),
      ),
      (otpResult) {
        emit(
          state.copyWith(
            resendStatus: Status.success,
            resendMessage: otpResult.message.isNotEmpty
                ? otpResult.message
                : 'تم إعادة إرسال رمز التحقق',
            // لو السيرفر قال الرمز بينتهي بعد قد إيه، نستخدم ده.
            verifyStatus: Status.initial,
          ),
        );
        startCooldown(_defaultCooldown);
      },
    );
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    return super.close();
  }
}
