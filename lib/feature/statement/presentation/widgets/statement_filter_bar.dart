part of 'statement_widgets.dart';

/// شريط الفلتر فوق قائمة الحركات — زر الفلترة + الفلاتر المفعّلة.
class StatementFilterBar extends StatelessWidget {
  final StatementFilter filter;

  /// بيتنادى لما المستخدم يفتح شيت الفلترة.
  final VoidCallback onOpenFilter;

  /// بيتنادى بفلتر جديد بعد شيل واحد من الفلاتر المفعّلة.
  final ValueChanged<StatementFilter> onFilterChanged;

  const StatementFilterBar({
    super.key,
    required this.filter,
    required this.onOpenFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'الحركات',
                style: TextStyles.boldStyle(
                  16,
                  color: AppColors.brandBlueDeep,
                  weight: FontWeight.w800,
                ),
              ),
            ),
            _FilterButton(
              activeCount: filter.activeCount,
              onTap: onOpenFilter,
            ),
          ],
        ),
        // الفلاتر المفعّلة — كل واحد بيتشال لوحده.
        if (filter.isActive) ...[
          Gap(10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (filter.transactionType != null)
                _ActiveFilterChip(
                  label: filter.transactionType!.label,
                  onRemove: () => onFilterChanged(
                    filter.copyWith(clearTransactionType: true),
                  ),
                ),
              if (filter.fromDate != null)
                _ActiveFilterChip(
                  label: 'من ${StatementFormat.date(filter.fromDate)}',
                  onRemove: () =>
                      onFilterChanged(filter.copyWith(clearFromDate: true)),
                ),
              if (filter.toDate != null)
                _ActiveFilterChip(
                  label: 'إلى ${StatementFormat.date(filter.toDate)}',
                  onRemove: () =>
                      onFilterChanged(filter.copyWith(clearToDate: true)),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// زر فتح الفلترة — عليه badge بعدد الفلاتر المفعّلة.
class _FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;

  const _FilterButton({required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = activeCount > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.mainAppColor : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isActive ? AppColors.mainAppColor : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 18.sp,
              color: isActive ? AppColors.whiteColor : AppColors.mainAppColor,
            ),
            Gap(6.w),
            Text(
              isActive ? 'فلترة ($activeCount)' : 'فلترة',
              style: TextStyles.boldStyle(
                13,
                color: isActive ? AppColors.whiteColor : AppColors.mainAppColor,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شيب فلتر مفعّل مع زر شيله.
class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 6.w, right: 10.w, top: 6.h, bottom: 6.h),
      decoration: BoxDecoration(
        color: AppColors.mainLight,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyles.boldStyle(
              12,
              color: AppColors.mainAppColor,
              weight: FontWeight.w600,
            ),
          ),
          Gap(6.w),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(8.r),
            child: Icon(
              Icons.close_rounded,
              size: 14.sp,
              color: AppColors.mainAppColor,
            ),
          ),
        ],
      ),
    );
  }
}
