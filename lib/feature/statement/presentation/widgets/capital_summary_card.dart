part of 'statement_widgets.dart';

/// كارت "ملخص رأس المال" — الإجماليات الخمسة من الريسبونس.
class CapitalSummaryCard extends StatelessWidget {
  final StatementModel statement;

  const CapitalSummaryCard({super.key, required this.statement});

  @override
  Widget build(BuildContext context) {
    final rows = <({String label, double value})>[
      (label: 'إجمالي الإيداعات', value: statement.totalCapitalDeposited),
      (label: 'إجمالي السحوبات', value: statement.totalCapitalWithdrawn),
      (label: 'الأرباح المرسملة', value: statement.totalProfitCapitalized),
      (label: 'الأرباح الموزعة', value: statement.totalProfitDistributed),
      (label: 'الأرباح المستحقة', value: statement.accruedProfit),
    ];

    return StatementCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StatementSectionTitle(title: 'ملخص رأس المال'),
          Gap(4.h),
          for (int i = 0; i < rows.length; i++)
            StatementValueRow(
              label: rows[i].label,
              value: StatementFormat.currency(rows[i].value),
              showDivider: i != rows.length - 1,
            ),
        ],
      ),
    );
  }
}
