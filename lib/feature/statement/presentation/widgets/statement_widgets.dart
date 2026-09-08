import 'package:eman_shareholders/core/style/assets.dart';
import 'package:eman_shareholders/core/theme/app_colors.dart';
import 'package:eman_shareholders/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../data/models/statement_model.dart';
import 'statement_formatters.dart';

part 'statement_header.dart';
part 'capital_summary_card.dart';
part 'account_info_card.dart';
part 'statement_entries_card.dart';
part 'statement_filter_sheet.dart';
part 'statement_pagination_bar.dart';
part 'statement_filter_bar.dart';

/// كارت أبيض بحواف دايرة — الشكل الأساسي لكل أقسام الصفحة.
class StatementCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const StatementCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// عنوان قسم — بيظهر في أول كل كارت، وممكن يكون جانبه نص تابع.
class StatementSectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const StatementSectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyles.boldStyle(
            16,
            color: AppColors.brandBlueDeep,
            weight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyles.lightStyle(12, color: AppColors.textHint),
          ),
      ],
    );
  }
}

/// صف "عنوان ← قيمة" — بيستخدم في ملخص رأس المال.
class StatementValueRow extends StatelessWidget {
  final String label;
  final String value;

  /// آخر صف في الكارت ما بيبقاش تحته فاصل.
  final bool showDivider;

  const StatementValueRow({
    super.key,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyles.lightStyle(14, color: AppColors.textHint),
                ),
              ),
              Gap(8.w),
              Text(
                value,
                style: TextStyles.boldStyle(
                  14,
                  color: AppColors.textPrimary,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
