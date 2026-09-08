import 'package:eman_shareholders/core/bloc/paginated_bloc/exports.dart';
import 'package:eman_shareholders/core/enum/snack_bar_enum.dart';
import 'package:eman_shareholders/core/extensions/extensions.dart';
import 'package:eman_shareholders/core/router/app_router.dart';
import 'package:eman_shareholders/core/service_locator/service_locator.dart';
import 'package:eman_shareholders/core/style/assets.dart';
import 'package:eman_shareholders/core/theme/app_colors.dart';
import 'package:eman_shareholders/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/otp_request_result.dart';
import '../../verify_otp/presentation/verify_otp.dart';
import 'view_model/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (_) => getIt<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final TextEditingController _phoneController = TextEditingController();

  /// أرقام المشغلين المصرية المسموح بها
  static const List<String> _allowedPrefixes = ['010', '011', '012', '015'];
  static const int _phoneLength = 11;

  bool _isValid = false;
  String? _errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// يتحقق أن الرقم ١١ خانة ويبدأ بـ 010 / 011 / 012 / 015
  static bool _isValidEgyptianPhone(String phone) {
    if (phone.length != _phoneLength) return false;
    return _allowedPrefixes.any(phone.startsWith);
  }

  String? _phoneValidator(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return 'من فضلك أدخل رقم الهاتف';
    }
    // نبص على البادئة الأول — دي غالبًا سبب الخطأ الحقيقي
    if (!_hasValidPrefixSoFar(phone)) {
      return 'رقم الهاتف يجب أن يبدأ بـ 010 أو 011 أو 012 أو 015';
    }
    if (phone.length != _phoneLength) {
      return 'رقم الهاتف يجب أن يكون $_phoneLength رقم';
    }
    return null;
  }

  void _onPhoneChanged(String value) {
    final phone = value.trim();
    final isValid = _isValidEgyptianPhone(phone);
    // ما نعرضش خطأ وهو لسه بيكتب الرقم — بس لو بدأ بأرقام مش صح
    final error = (isValid || phone.isEmpty || _hasValidPrefixSoFar(phone))
        ? null
        : _phoneValidator(phone);

    if (isValid != _isValid || error != _errorText) {
      setState(() {
        _isValid = isValid;
        _errorText = error;
      });
    }
  }

  /// هل اللي اتكتب لحد دلوقتي ممكن يكمّل لرقم صح؟
  static bool _hasValidPrefixSoFar(String phone) {
    return _allowedPrefixes.any(
      (prefix) => phone.length < prefix.length
          ? prefix.startsWith(phone)
          : phone.startsWith(prefix),
    );
  }

  void _onSendCode() {
    if (!_isValid) {
      setState(() => _errorText = _phoneValidator(_phoneController.text));
      return;
    }

    setState(() => _errorText = null);
    FocusScope.of(context).unfocus();
    context.read<LoginCubit>().requestOtp(_phoneController.text.trim());
  }

  void _onRequestOtpState(BuildContext context, BaseState<OtpRequestResult> state) {
    if (state.isFailure) {
      final message = state.errorMessage ?? 'تعذر إرسال رمز التحقق';
      // بنعرض الخطأ جوّه الكارت كمان عشان يفضل ظاهر قصاد الحقل.
      setState(() => _errorText = message);
      context.showTopSnackBar(message: message, type: SnackBarType.error);
      return;
    }

    if (state.isSuccess) {
      setState(() => _errorText = null);
      final result = state.data;
      if (result != null && result.message.isNotEmpty) {
        context.showTopSnackBar(
          message: result.message,
          type: SnackBarType.success,
        );
      }
      context.push(
        AppRouter.verifyOtp,
        extra: VerifyOtpArgs(
          phoneNumber: _phoneController.text.trim(),
          expirySeconds: result?.secondsUntilExpiry ?? 0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, BaseState<OtpRequestResult>>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onRequestOtpState,
      builder: (context, state) => _buildScaffold(context, state),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    BaseState<OtpRequestResult> state,
  ) {
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Gap(24.h),
              // ─── اللوجو ─────────────────────────────────
              Center(
                child: Image.asset(
                  Assets.assetsImagesAppLogo,
                  width: 260.w,
                  fit: BoxFit.contain,
                ),
              ),
              Gap(24.h),
              // ─── النصوص ─────────────────────────────────
              Text(
                'تسجيل الدخول',
                textAlign: TextAlign.center,
                style: TextStyles.boldStyle(
                  26,
                  color: AppColors.brandBlueDeep,
                  weight: FontWeight.w800,
                ),
              ),
              Gap(10.h),
              Text(
                'أدخل رقم هاتفك المسجَّل، وهنبعتلك رمز تحقق فورًا',
                textAlign: TextAlign.center,
                style: TextStyles.lightStyle(15, color: AppColors.textHint),
              ),
              Gap(28.h),
              // ─── كارت رقم الهاتف ────────────────────────
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackColor.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'رقم الهاتف',
                      style: TextStyles.boldStyle(
                        15,
                        color: AppColors.mainAppColor,
                        weight: FontWeight.w700,
                      ),
                    ),
                    Gap(12.h),
                    // الرقم دايمًا من الشمال لليمين حتى لو التطبيق عربي
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: TextField(
                        controller: _phoneController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        maxLength: _phoneLength,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(_phoneLength),
                        ],
                        style: TextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        onChanged: _onPhoneChanged,
                        onSubmitted: (_) => _onSendCode(),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '01XXXXXXXXX',
                          hintStyle: TextStyles.lightStyle(
                            16,
                            color: AppColors.textHint,
                          ),
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: AppColors.textHint,
                            size: 22.sp,
                          ),
                          filled: true,
                          fillColor: AppColors.bgSecondary,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 18.h,
                          ),
                          // البوردر بيبقى أحمر لو فيه خطأ
                          border: _fieldBorder(_borderColor),
                          enabledBorder: _fieldBorder(_borderColor),
                          focusedBorder: _fieldBorder(
                            _errorText != null
                                ? AppColors.error
                                : AppColors.mainAppColor,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    // رسالة الخطأ عربية فـ بتفضل من اليمين
                    if (_errorText != null) ...[
                      Gap(6.h),
                      Text(
                        _errorText!,
                        textAlign: TextAlign.right,
                        style: TextStyles.lightStyle(
                          12,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                    Gap(16.h),
                    // ─── زر إرسال رمز التحقق ──────────────
                    SizedBox(
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: _isValid && !isLoading ? _onSendCode : null,
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
                        child: isLoading
                            ? SizedBox(
                                height: 22.h,
                                width: 22.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'إرسال رمز التحقق',
                                style: TextStyles.whiteText(17),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(20.h),
              // ─── النص تحت الكارت ────────────────────────
              Text(
                'الرمز هيوصلك برسالة نصية على نفس الرقم',
                textAlign: TextAlign.center,
                style: TextStyles.lightStyle(13, color: AppColors.textHint),
              ),
              Gap(16.h),
            ],
          ),
        ),
      ),
    );
  }

  Color get _borderColor =>
      _errorText != null ? AppColors.error : AppColors.border;

  OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
