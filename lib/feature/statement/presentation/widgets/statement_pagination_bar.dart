part of 'statement_widgets.dart';

/// شريط التنقل بين صفحات الحركات — أرقام صفحات + سهمين.
///
/// بيظهر بس لو فيه أكتر من صفحة.
class StatementPaginationBar extends StatelessWidget {
  final int pageIndex;
  final int totalPages;

  /// إجمالي عدد الحركات — بيتعرض كنص توضيحي.
  final int count;

  /// جاري تحميل صفحة — بنعطّل الأزرار وقتها.
  final bool isLoading;

  final ValueChanged<int> onPageSelected;

  const StatementPaginationBar({
    super.key,
    required this.pageIndex,
    required this.totalPages,
    required this.count,
    required this.onPageSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final pages = _visiblePages(pageIndex, totalPages);
    final canGoBack = pageIndex > 1 && !isLoading;
    final canGoForward = pageIndex < totalPages && !isLoading;

    return Column(
      children: [
        // مع صفحات كتير الشريط بيزيد عن عرض الموبايل، فبيبقى قابل
        // للتمرير أفقيًا بدل ما يعمل overflow.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          // بيخلي الشريط متمركز لو المحتوى أصغر من الشاشة.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 32.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // في RTL السهم اللي على اليمين بيرجع للصفحة السابقة.
                _ArrowButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: canGoBack ? () => onPageSelected(pageIndex - 1) : null,
                ),
                Gap(6.w),
                for (final page in pages) ...[
                  if (page == _ellipsis)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        '…',
                        style: TextStyles.boldStyle(
                          14,
                          color: AppColors.textHint,
                          weight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: _PageButton(
                        page: page,
                        isCurrent: page == pageIndex,
                        onTap: isLoading || page == pageIndex
                            ? null
                            : () => onPageSelected(page),
                      ),
                    ),
                ],
                Gap(6.w),
                _ArrowButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: canGoForward
                      ? () => onPageSelected(pageIndex + 1)
                      : null,
                ),
              ],
            ),
          ),
        ),
        Gap(10.h),
        Text(
          'صفحة $pageIndex من $totalPages · ${StatementFormat.entriesCount(count)}',
          style: TextStyles.lightStyle(12, color: AppColors.textHint),
        ),
      ],
    );
  }

  /// علامة إن فيه صفحات متخطّية.
  static const int _ellipsis = -1;

  /// أرقام الصفحات اللي بتتعرض — بنحدّدها عشان ٢٠ صفحة ما تكسرش الشريط.
  ///
  /// الشكل: `1 … 4 5 6 … 20` — دايمًا أول وآخر صفحة، والصفحة الحالية
  /// وجيرانها.
  static List<int> _visiblePages(int current, int total) {
    if (total <= 7) {
      return [for (int i = 1; i <= total; i++) i];
    }

    final pages = <int>{1, total, current};
    if (current - 1 > 1) pages.add(current - 1);
    if (current + 1 < total) pages.add(current + 1);

    // قرب الحواف بنزوّد صفحة كمان عشان الشريط ما يرقصش في العرض.
    if (current <= 3) pages.addAll([2, 3, 4].where((p) => p < total));
    if (current >= total - 2) {
      pages.addAll([total - 3, total - 2, total - 1].where((p) => p > 1));
    }

    final sorted = pages.toList()..sort();

    final result = <int>[];
    for (int i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) result.add(_ellipsis);
      result.add(sorted[i]);
    }
    return result;
  }
}

class _PageButton extends StatelessWidget {
  final int page;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _PageButton({required this.page, required this.isCurrent, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        constraints: BoxConstraints(minWidth: 36.w),
        height: 36.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: isCurrent ? AppColors.mainAppColor : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isCurrent ? AppColors.mainAppColor : AppColors.border,
          ),
        ),
        // الأرقام دايمًا LTR.
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            '$page',
            style: TextStyles.boldStyle(
              13,
              color: isCurrent ? AppColors.whiteColor : AppColors.textSecondary,
              weight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 36.w,
        height: 36.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isEnabled
                ? AppColors.border
                : AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: isEnabled ? AppColors.mainAppColor : AppColors.textHint,
        ),
      ),
    );
  }
}
