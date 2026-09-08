import 'package:eman_shareholders/core/helpers/helpers.dart';
import 'package:eman_shareholders/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:pinput/pinput.dart';

import 'dart:ui' as ui;

class OtpTextField extends StatefulWidget {
  final TextEditingController pinController;

  /// بيتنادى مع كل تغيير في الرمز — يفيد في تفعيل/تعطيل زر التأكيد.
  final ValueChanged<String>? onChanged;

  /// بيتنادى لما الرمز يكتمل.
  final ValueChanged<String>? onCompleted;

  /// لو `true` البوردر بيبقى أحمر (رمز غلط).
  final bool hasError;

  /// عدد خانات الرمز.
  final int length;

  const OtpTextField({
    super.key,
    required this.pinController,
    this.onChanged,
    this.onCompleted,
    this.hasError = false,
    this.length = 6,
  });

  @override
  State<OtpTextField> createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final pinBorderColor = isDarkMode
        ? Colors.white24
        : const Color(0xffcfdbec);
    final fillColor = isDarkMode ? const Color(0xFF1F1F1F) : Colors.white;
    final pinTextColor = isDarkMode ? Colors.white : AppColors.primaryColor;

    // مع 6 خانات الخانة العريضة بتطلع بره الشاشة، فبنضيّقها شوية.
    final isCompact = widget.length > 4;

    final defaultPinTheme = PinTheme(
      width: isCompact ? 46.w : 64.w,
      height: 56.h,
      textStyle: TextStyle(
        fontSize: 20.sp,
        color: pinTextColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.0),
        color: fillColor,
        border: Border.all(color: pinBorderColor, width: 1.2),
      ),
    );

    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Pinput(
              length: widget.length,
              controller: widget.pinController,
              defaultPinTheme: defaultPinTheme,
              keyboardType: TextInputType.number,
              separatorBuilder: (index) => Gap(isCompact ? 8.w : 14.w),
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              forceErrorState: widget.hasError,
              onCompleted: (pin) {
                logger('onCompleted: $pin');
                widget.onCompleted?.call(pin);
              },
              onChanged: (value) {
                logger('onChanged: $value');
                widget.onChanged?.call(value);
              },
              // كيرسر رأسي رفيع في نص الخانة زي الديزاين
              cursor: Center(
                child: Container(
                  width: 1.6,
                  height: 24.h,
                  color: AppColors.primaryColor,
                ),
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: AppColors.brandGreen, width: 1.6),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: AppColors.primaryColor, width: 1.2),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyWith(
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: Colors.redAccent, width: 1.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
