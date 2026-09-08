import 'package:equatable/equatable.dart';

import 'statement_model.dart';

/// فلتر كشف الحساب — بيتحول لـ query parameters للـ API.
///
/// المفاتيح اللي بتتبعت للباك اند إنجليزي (`CapitalDeposit`…) لكن العرض
/// للمستخدم بيبقى بالعربي من [TransactionType.label].
class StatementFilter extends Equatable {
  /// من تاريخ — بيتبعت كـ `fromDate`.
  final DateTime? fromDate;

  /// لحد تاريخ — بيتبعت كـ `toDate`.
  final DateTime? toDate;

  /// نوع الحركة — بيتبعت كـ `transactionType` بالـ `apiValue`.
  final TransactionType? transactionType;

  const StatementFilter({this.fromDate, this.toDate, this.transactionType});

  /// فلتر فاضي — كل الحركات.
  static const StatementFilter empty = StatementFilter();

  /// فيه أي فلتر مفعّل؟
  bool get isActive =>
      fromDate != null || toDate != null || transactionType != null;

  /// عدد الفلاتر المفعّلة — بيتعرض على شكل badge جانب زر الفلتر.
  int get activeCount => [
        fromDate != null,
        toDate != null,
        transactionType != null,
      ].where((active) => active).length;

  /// الباراميترات اللي بتتبعت للـ API — بنشيل الفاضي.
  Map<String, dynamic> toQueryParameters() {
    return {
      // التاريخ لوحده بدون وقت — السيرفر مستقبل `date-time` فـ ISO تمشي.
      if (fromDate != null) 'fromDate': _asDateOnly(fromDate!),
      if (toDate != null) 'toDate': _asDateOnly(toDate!),
      if (transactionType != null)
        'transactionType': transactionType!.apiValue,
    };
  }

  /// `2026-09-02` — بنبعت التاريخ بس عشان ما نقصّش حركات في نفس اليوم
  /// بسبب الوقت.
  static String _asDateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  StatementFilter copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    TransactionType? transactionType,
    bool clearFromDate = false,
    bool clearToDate = false,
    bool clearTransactionType = false,
  }) {
    return StatementFilter(
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      transactionType: clearTransactionType
          ? null
          : (transactionType ?? this.transactionType),
    );
  }

  @override
  List<Object?> get props => [fromDate, toDate, transactionType];
}
