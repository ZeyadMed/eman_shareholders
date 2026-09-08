part of 'statement_widgets.dart';

/// شريط الترحيب فوق الصفحة — اللوجو والاسم والحرف الأول.
class StatementGreeting extends StatelessWidget {
  final String name;

  const StatementGreeting({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          Assets.assetsImagesAppLogo,
          height: 42.h,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'أهلاً بيك',
              style: TextStyles.lightStyle(12, color: AppColors.textHint),
            ),
            Gap(2.h),
            Text(
              name.isEmpty ? '—' : name,
              style: TextStyles.boldStyle(
                15,
                color: AppColors.textPrimary,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Gap(10.w),
        // الحرف الأول من الاسم في دايرة — بديل صورة البروفايل.
        Container(
          width: 46.w,
          height: 46.w,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.mainGradient,
          ),
          child: Text(
            _initial,
            style: TextStyles.whiteText(18),
          ),
        ),
      ],
    );
  }

  /// أول حرف من الاسم — بيظهر جوه الدايرة.
  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '؟';
    return trimmed.characters.first.toUpperCase();
  }
}

/// الكارت الأزرق — إجمالي المساهمة في رأس المال + النسبة والأرباح المستحقة.
class StatementHeaderCard extends StatelessWidget {
  final double contributedAmount;
  final double companyPercentage;
  final double accruedProfit;

  const StatementHeaderCard({
    super.key,
    required this.contributedAmount,
    required this.companyPercentage,
    required this.accruedProfit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
      decoration: BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandBlueDeep.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجمالي مساهمتك في رأس المال',
            style: TextStyles.lightStyle(
              13,
              color: AppColors.whiteColor.withValues(alpha: 0.85),
            ),
          ),
          Gap(10.h),
          // المبلغ الكبير — بيتعرض LTR عشان الأرقام والفواصل تفضل مترتبة.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              StatementFormat.currency(contributedAmount),
              style: TextStyles.boldStyle(
                30,
                color: AppColors.whiteColor,
                weight: FontWeight.w800,
              ),
            ),
          ),
          Gap(18.h),
          Row(
            children: [
              _HeaderStat(
                label: 'نسبتك من الشركة',
                value: StatementFormat.percentage(companyPercentage),
              ),
              Container(
                width: 1,
                height: 34.h,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                color: AppColors.whiteColor.withValues(alpha: 0.25),
              ),
              _HeaderStat(
                label: 'الأرباح المستحقة',
                value: StatementFormat.currency(accruedProfit),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// عنصر واحد من إحصائيات الكارت الأزرق.
class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.lightStyle(
              12,
              color: AppColors.whiteColor.withValues(alpha: 0.8),
            ),
          ),
          Gap(6.h),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldStyle(
                15,
                color: AppColors.whiteColor,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
