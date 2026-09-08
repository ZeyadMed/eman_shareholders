part of 'statement_widgets.dart';

/// كارت الحركات — قائمة صفحة واحدة من حركات كشف الحساب.
///
/// التنقل بين الصفحات مسؤولية [StatementPaginationBar] اللي تحتها.
class StatementEntriesCard extends StatelessWidget {
  final PaginatedEntriesModel entries;

  /// جاري تحميل صفحة — بنعرض الليست باهتة مع لودينج فوقها عشان
  /// الطول ما يقفزش.
  final bool isLoading;

  /// فيه فلتر مفعّل — بيغيّر رسالة القائمة الفاضية.
  final bool isFiltered;

  /// بيتنادى من رسالة القائمة الفاضية لشيل الفلتر.
  final VoidCallback? onClearFilter;

  const StatementEntriesCard({
    super.key,
    required this.entries,
    this.isLoading = false,
    this.isFiltered = false,
    this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return StatementCard(
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: isLoading ? 0.35 : 1,
            duration: const Duration(milliseconds: 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entries.data.isEmpty)
                  _EmptyEntries(
                    isFiltered: isFiltered,
                    onClearFilter: onClearFilter,
                  )
                else
                  for (int i = 0; i < entries.data.length; i++) ...[
                    StatementEntryTile(entry: entries.data[i]),
                    if (i != entries.data.length - 1)
                      Divider(height: 1, color: AppColors.border),
                  ],
              ],
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: 26.w,
                  height: 26.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.mainAppColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// رسالة القائمة الفاضية — بتفرق بين "مفيش حركات" و"مفيش نتايج للفلتر".
class _EmptyEntries extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback? onClearFilter;

  const _EmptyEntries({required this.isFiltered, this.onClearFilter});

  @override
  Widget build(BuildContext context) {
    // ارتفاع أدنى عشان الرسالة تبان في نص مساحة محترمة مش في كارت
    // مضغوط على المحتوى. `double.infinity` بتاخد عرض الكارت كله فالنص
    // يبقى متمركز أفقيًا رغم إن الأب `CrossAxisAlignment.start`.
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 260.h),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isFiltered
                  ? Icons.filter_list_off_rounded
                  : Icons.receipt_long_outlined,
              size: 40.sp,
              color: AppColors.textHint,
            ),
            Gap(12.h),
            Text(
              isFiltered
                  ? 'مفيش حركات مطابقة للفلتر'
                  : 'مفيش حركات على حسابك لحد الآن',
              textAlign: TextAlign.center,
              style: TextStyles.lightStyle(14, color: AppColors.textHint),
            ),
            if (isFiltered && onClearFilter != null) ...[
              Gap(4.h),
              TextButton(
                onPressed: onClearFilter,
                child: Text(
                  'مسح الفلتر',
                  style: TextStyles.boldStyle(
                    13,
                    color: AppColors.mainAppColor,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// صف حركة واحدة — الأيقونة والنوع والتاريخ والمبلغ.
class StatementEntryTile extends StatelessWidget {
  final StatementEntryModel entry;

  const StatementEntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final style = _EntryStyle.of(entry.transactionType);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          // أيقونة النوع — لونها بيفرق بين الإيداع والسحب والأرباح.
          Container(
            width: 42.w,
            height: 42.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(style.icon, size: 20.sp, color: style.foreground),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.transactionType.label,
                  style: TextStyles.boldStyle(
                    14,
                    color: AppColors.textPrimary,
                    weight: FontWeight.w700,
                  ),
                ),
                Gap(4.h),
                Text(
                  StatementFormat.entrySubtitle(entry),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.lightStyle(12, color: AppColors.textHint),
                ),
                // رقم السند بيرجع فاضي في بعض الحركات فما نعرضهوش.
                if (entry.voucherNumber.isNotEmpty) ...[
                  Gap(3.h),
                  Text(
                    'سند: ${entry.voucherNumber}',
                    style: TextStyles.lightStyle(11, color: AppColors.textHint),
                  ),
                ],
              ],
            ),
          ),
          Gap(8.w),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              StatementFormat.signedCurrency(
                entry.displayAmount,
                isCredit: entry.transactionType.isCredit,
              ),
              style: TextStyles.boldStyle(
                14,
                color: style.amountColor,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ألوان وأيقونة كل نوع حركة.
class _EntryStyle {
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color amountColor;

  const _EntryStyle({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.amountColor,
  });

  factory _EntryStyle.of(TransactionType type) {
    switch (type) {
      case TransactionType.capitalDeposit:
        return const _EntryStyle(
          icon: Icons.arrow_downward_rounded,
          background: AppColors.greenLight,
          foreground: AppColors.success,
          amountColor: AppColors.success,
        );
      case TransactionType.capitalWithdrawal:
        return const _EntryStyle(
          icon: Icons.arrow_upward_rounded,
          background: AppColors.redLight,
          foreground: AppColors.error,
          amountColor: AppColors.error,
        );
      case TransactionType.profitCapitalization:
        return const _EntryStyle(
          icon: Icons.autorenew_rounded,
          background: AppColors.mainLight,
          foreground: AppColors.mainAppColor,
          amountColor: AppColors.mainAppColor,
        );
      case TransactionType.profitDistribution:
        return const _EntryStyle(
          icon: Icons.payments_outlined,
          background: AppColors.tealLight,
          foreground: AppColors.accentTeal,
          amountColor: AppColors.accentTeal,
        );
      case TransactionType.unknown:
        return const _EntryStyle(
          icon: Icons.receipt_long_outlined,
          background: AppColors.bgTertiary,
          foreground: AppColors.textSecondary,
          amountColor: AppColors.textPrimary,
        );
    }
  }
}
