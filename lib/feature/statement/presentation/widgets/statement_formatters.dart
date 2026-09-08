import 'package:intl/intl.dart';

import '../../data/models/statement_model.dart';

/// تنسيق الأرقام والتواريخ المعروضة في كشف الحساب.
abstract interface class StatementFormat {
  /// أسماء الشهور بالعربي — بنستخدمها بدل `DateFormat` العربي عشان تفضل
  /// ثابتة مهما كانت لغة الجهاز.
  static const List<String> _months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  static final NumberFormat _amount = NumberFormat('#,##0.00', 'en');
  static final NumberFormat _compact = NumberFormat('#,##0.##', 'en');

  /// مبلغ بالجنيه — مثال: `500,000.00 ج.م`
  static String currency(double value) => '${_amount.format(value)} ج.م';

  /// مبلغ بعلامة الحركة — مثال: `+500,000.00 ج.م`
  static String signedCurrency(double value, {required bool isCredit}) {
    final sign = isCredit ? '+' : '-';
    return '$sign${_amount.format(value.abs())} ج.م';
  }

  /// نسبة مئوية — مثال: `25%` أو `12.5%`
  static String percentage(double value) => '${_compact.format(value)}%';

  /// تاريخ مختصر — مثال: `30 أغسطس 2026`
  static String date(DateTime? value) {
    if (value == null) return '—';
    return '${value.day} ${_months[value.month - 1]} ${value.year}';
  }

  /// "عضو منذ" — مثال: `عضو منذ 10 يناير 2025`
  static String memberSince(DateTime? value) {
    if (value == null) return 'عضو منذ —';
    return 'عضو منذ ${date(value)}';
  }

  /// عدد الحركات — مثال: `42 حركة`
  static String entriesCount(int count) {
    if (count == 1) return 'حركة واحدة';
    if (count == 2) return 'حركتان';
    return '$count حركة';
  }

  /// وصف الحركة تحت اسمها — التاريخ + الخزينة.
  static String entrySubtitle(StatementEntryModel entry) {
    final parts = [
      date(entry.date),
      if (entry.treasuryName.isNotEmpty) entry.treasuryName,
    ];
    return parts.join(' · ');
  }
}
