import 'package:eman_shareholders/core/enum/snack_bar_enum.dart';
import 'package:eman_shareholders/core/extensions/extensions.dart';
import 'package:eman_shareholders/core/router/app_router.dart';
import 'package:eman_shareholders/core/service_locator/service_locator.dart';
import 'package:eman_shareholders/core/theme/app_colors.dart';
import 'package:eman_shareholders/core/theme/text_styles.dart';
import 'package:eman_shareholders/core/widgets/common_widget/otp_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'view_model/verify_otp_cubit.dart';

/// اللي بيتمرر لشاشة التحقق — الرقم ومدة صلاحية الرمز.
class VerifyOtpArgs {
  final String phoneNumber;

  /// ثواني صلاحية الرمز جايه من `expiresAtUtc` (السيرفر بيرجع ٥ دقايق).
  final int expirySeconds;

  const VerifyOtpArgs({required this.phoneNumber, this.expirySeconds = 0});
}

class VerifyOtp extends StatelessWidget {
  /// الرقم اللي اتبعت عليه الرمز — بيتعرض تحت العنوان.
  final String phoneNumber;

  /// ثواني صلاحية الرمز.
  final int expirySeconds;

  const VerifyOtp({
    super.key,
    required this.phoneNumber,
    this.expirySeconds = 0,
  });

  /// قفل إعادة الإرسال — أقصر بكتير من صلاحية الرمز (٥ دقايق) عشان
  /// المستخدم ما يستناش الصلاحية كلها لو الرسالة ما وصلتش.
  static const int _resendCooldown = 60;

  @override
  Widget build(BuildContext context) {
    // لو الرمز بينتهي قبل الدقيقة، القفل بينتهي مع انتهاء الرمز.
    final cooldown = expirySeconds > 0 && expirySeconds < _resendCooldown
        ? expirySeconds
        : _resendCooldown;

    return BlocProvider<VerifyOtpCubit>(
      create: (_) =>
          getIt<VerifyOtpCubit>(param1: phoneNumber, param2: cooldown)
            ..startCooldown(cooldown),
      child: _VerifyOtpView(phoneNumber: phoneNumber),
    );
  }
}

class _VerifyOtpView extends StatefulWidget {
  final String phoneNumber;

  const _VerifyOtpView({required this.phoneNumber});

  @override
  State<_VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<_VerifyOtpView> {
  final TextEditingController _pinController = TextEditingController();

  /// طول الرمز — لازم يساوي `length` بتاعة الـ Pinput جوه [OtpTextField].
  static const int _otpLength = 6;

  bool _isCompleted = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onOtpChanged(String value) {
    final isCompleted = value.length == _otpLength;
    if (isCompleted != _isCompleted) {
      setState(() => _isCompleted = isCompleted);
    }
    // أول ما يعدّل الرمز نمسح الخطأ القديم.
    context.read<VerifyOtpCubit>().clearError();
  }

  void _onConfirm() {
    if (!_isCompleted) return;
    FocusScope.of(context).unfocus();
    context.read<VerifyOtpCubit>().verifyOtp(_pinController.text.trim());
  }

  void _onResend() {
    FocusScope.of(context).unfocus();
    _pinController.clear();
    setState(() => _isCompleted = false);
    context.read<VerifyOtpCubit>().resendOtp();
  }

  void _onStateChanged(BuildContext context, VerifyOtpState state) {
    if (state.isVerified) {
      // الجلسة اتخزنت في الكيوبت — بنستبدل الستاك عشان زر الرجوع
      // ما يرجّعهوش لشاشة الرمز بعد الدخول.
      context.go(AppRouter.statementScreen);
      return;
    }

    if (state.errorMessage != null) {
      context.showTopSnackBar(
        message: state.errorMessage!,
        type: SnackBarType.error,
      );
    }

    if (state.resendMessage != null) {
      _pinController.clear();
      setState(() => _isCompleted = false);
      context.showTopSnackBar(
        message: state.resendMessage!,
        type: SnackBarType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerifyOtpCubit, VerifyOtpState>(
      listenWhen: (previous, current) =>
          previous.verifyStatus != current.verifyStatus ||
          previous.errorMessage != current.errorMessage ||
          previous.resendMessage != current.resendMessage,
      listener: _onStateChanged,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Gap(8.h),
                  // ─── زر الرجوع ──────────────────────────────
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: state.isVerifying ? null : () => context.pop(),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 16.sp,
                        color: AppColors.mainAppColor,
                      ),
                      label: Text(
                        'رجوع',
                        style: TextStyles.boldStyle(
                          16,
                          color: AppColors.mainAppColor,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // ─── العنوان والنصوص ────────────────────────
                  Text(
                    'أدخل رمز التحقق',
                    textAlign: TextAlign.center,
                    style: TextStyles.boldStyle(
                      26,
                      color: AppColors.brandBlueDeep,
                      weight: FontWeight.w800,
                    ),
                  ),
                  Gap(12.h),
                  Text(
                    'تم إرسال رمز مكوَّن من $_otpLength أرقام إلى',
                    textAlign: TextAlign.center,
                    style: TextStyles.lightStyle(15, color: AppColors.textHint),
                  ),
                  Gap(6.h),
                  // الرقم دايمًا LTR حتى لو التطبيق عربي
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      widget.phoneNumber,
                      textAlign: TextAlign.center,
                      style: TextStyles.boldStyle(
                        16,
                        color: AppColors.brandBlueDeep,
                        weight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Gap(32.h),
                  // ─── خانات الرمز ────────────────────────────
                  OtpTextField(
                    pinController: _pinController,
                    length: _otpLength,
                    hasError: state.hasError,
                    onChanged: _onOtpChanged,
                    onCompleted: (_) {
                      _onOtpChanged(_pinController.text);
                      // أول ما الرمز يكتمل نتحقق على طول.
                      _onConfirm();
                    },
                  ),
                  Gap(24.h),
                  // ─── العد التنازلي / إعادة الإرسال ──────────
                  Center(
                    child: state.isResending
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.mainAppColor,
                            ),
                          )
                        : state.resendCooldown > 0
                            ? Text(
                                'إعادة إرسال الرمز خلال '
                                '${state.resendCooldown} ثانية',
                                textAlign: TextAlign.center,
                                style: TextStyles.lightStyle(
                                  14,
                                  color: AppColors.textHint,
                                ),
                              )
                            : TextButton(
                                onPressed: state.canResend ? _onResend : null,
                                child: Text(
                                  'إعادة إرسال الرمز',
                                  style: TextStyles.boldStyle(
                                    15,
                                    color: AppColors.mainAppColor,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ),
                  ),
                  const Spacer(flex: 2),
                  // ─── زر التأكيد ─────────────────────────────
                  SizedBox(
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _isCompleted && !state.isVerifying
                          ? _onConfirm
                          : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.mainAppColor,
                        foregroundColor: AppColors.whiteColor,
                        disabledBackgroundColor: AppColors.mainAppColor
                            .withValues(alpha: 0.45),
                        disabledForegroundColor: AppColors.whiteColor
                            .withValues(alpha: 0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: state.isVerifying
                          ? SizedBox(
                              height: 22.h,
                              width: 22.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Text('تأكيد', style: TextStyles.whiteText(17)),
                    ),
                  ),
                  Gap(24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
