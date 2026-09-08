part of 'statement_widgets.dart';

/// كارت "بيانات الحساب" — العنوان والخزينة وتاريخ الانضمام.
class AccountInfoCard extends StatelessWidget {
  final ShareholderModel shareholder;

  const AccountInfoCard({super.key, required this.shareholder});

  @override
  Widget build(BuildContext context) {
    final rows = <({IconData icon, String value})>[
      if (shareholder.address.isNotEmpty)
        (icon: Icons.location_on_outlined, value: shareholder.address),
      if (shareholder.capitalTreasuryName.isNotEmpty)
        (
          icon: Icons.account_balance_outlined,
          value: shareholder.capitalTreasuryName,
        ),
      (
        icon: Icons.calendar_today_outlined,
        value: StatementFormat.memberSince(shareholder.createdAt),
      ),
      if (shareholder.phoneNumber.isNotEmpty)
        (icon: Icons.phone_outlined, value: shareholder.phoneNumber),
      if (shareholder.notes.isNotEmpty)
        (icon: Icons.sticky_note_2_outlined, value: shareholder.notes),
    ];

    return StatementCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StatementSectionTitle(title: 'بيانات الحساب'),
          Gap(14.h),
          for (int i = 0; i < rows.length; i++) ...[
            _InfoRow(icon: rows[i].icon, value: rows[i].value),
            if (i != rows.length - 1) Gap(12.h),
          ],
        ],
      ),
    );
  }
}

/// صف واحد من بيانات الحساب — أيقونة + نص.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30.w,
          height: 30.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.mainLight,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Icon(icon, size: 16.sp, color: AppColors.mainAppColor),
        ),
        Gap(10.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Text(
              value,
              style: TextStyles.lightStyle(14, color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
