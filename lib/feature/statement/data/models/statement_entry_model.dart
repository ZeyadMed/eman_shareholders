part of 'statement_model.dart';

/// نوع الحركة — الأنواع اللي بترجع من الـ API في `transactionType`.
enum TransactionType {
  /// إيداع رأس مال.
  capitalDeposit('CapitalDeposit', 'إيداع رأس مال'),

  /// سحب من رأس المال.
  capitalWithdrawal('CapitalWithdrawal', 'سحب من رأس المال'),

  /// رسملة أرباح (تحويل الأرباح لرأس مال).
  profitCapitalization('ProfitCapitalization', 'رسملة أرباح'),

  /// توزيع أرباح.
  profitDistribution('ProfitDistribution', 'توزيع أرباح'),

  /// أي نوع جديد ما نعرفهوش — بنعرضه من غير ما التطبيق يقع.
  unknown('', 'حركة');

  const TransactionType(this.apiValue, this.label);

  /// القيمة اللي بترجع من الـ API.
  final String apiValue;

  /// الاسم المعروض للمستخدم بالعربي.
  final String label;

  static TransactionType fromApi(String? value) {
    if (value == null || value.isEmpty) return TransactionType.unknown;
    return TransactionType.values.firstWhere(
      (type) => type.apiValue.toLowerCase() == value.toLowerCase(),
      orElse: () => TransactionType.unknown,
    );
  }

  /// الأنواع اللي المستخدم يقدر يفلتر بيها — `unknown` مش نوع حقيقي
  /// فمش بيتعرض في الفلتر.
  static const List<TransactionType> filterable = [
    capitalDeposit,
    capitalWithdrawal,
    profitCapitalization,
    profitDistribution,
  ];

  /// الحركات اللي بتزوّد رصيد المساهم (بتتعرض بعلامة +).
  bool get isCredit =>
      this == TransactionType.capitalDeposit ||
      this == TransactionType.profitCapitalization ||
      this == TransactionType.profitDistribution;

  /// الحركات اللي بتقلل رصيد المساهم (بتتعرض بعلامة -).
  bool get isDebit => this == TransactionType.capitalWithdrawal;
}

/// حركة واحدة في كشف الحساب — عنصر من `entries.data`.
class StatementEntryModel extends Equatable {
  final int id;

  /// رقم السند — بيرجع فاضي في بعض الحركات.
  final String voucherNumber;
  final DateTime? date;
  final TransactionType transactionType;
  final double amount;

  /// نصيب الشركة — بيرجع null في غير التوزيعات.
  final double? companyShare;

  /// نصيب المساهم — بيرجع null في غير التوزيعات.
  final double? shareholderShare;

  /// رصيد رأس المال بعد الحركة.
  final double capitalBalanceAfter;

  final String treasuryName;
  final String notes;

  const StatementEntryModel({
    this.id = 0,
    this.voucherNumber = '',
    this.date,
    this.transactionType = TransactionType.unknown,
    this.amount = 0,
    this.companyShare,
    this.shareholderShare,
    this.capitalBalanceAfter = 0,
    this.treasuryName = '',
    this.notes = '',
  });

  factory StatementEntryModel.fromJson(Map<String, dynamic> json) {
    return StatementEntryModel(
      id: _asInt(json['id']),
      voucherNumber: _asString(json['voucherNumber']),
      date: _asDate(json['date']),
      transactionType: TransactionType.fromApi(
        json['transactionType']?.toString(),
      ),
      amount: _asDouble(json['amount']),
      companyShare: _asDoubleOrNull(json['companyShare']),
      shareholderShare: _asDoubleOrNull(json['shareholderShare']),
      capitalBalanceAfter: _asDouble(json['capitalBalanceAfter']),
      treasuryName: _asString(json['treasuryName']),
      notes: _asString(json['notes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voucherNumber': voucherNumber,
      'date': date?.toIso8601String(),
      'transactionType': transactionType.apiValue,
      'amount': amount,
      'companyShare': companyShare,
      'shareholderShare': shareholderShare,
      'capitalBalanceAfter': capitalBalanceAfter,
      'treasuryName': treasuryName,
      'notes': notes,
    };
  }

  /// المبلغ اللي المفروض يتعرض للمساهم — في التوزيعات بنعرض نصيبه هو.
  double get displayAmount => shareholderShare ?? amount;

  @override
  List<Object?> get props => [
    id,
    voucherNumber,
    date,
    transactionType,
    amount,
    companyShare,
    shareholderShare,
    capitalBalanceAfter,
    treasuryName,
    notes,
  ];
}
