import 'package:equatable/equatable.dart';

export 'statement_filter.dart';

part 'json_parsing.dart';
part 'shareholder_model.dart';
part 'statement_entry_model.dart';
part 'paginated_entries_model.dart';

/// الريسبونس الكامل لكشف حساب المساهم — الجزء `data` من الريسبونس.
class StatementModel extends Equatable {
  final ShareholderModel shareholder;

  /// إجمالي الإيداعات في رأس المال.
  final double totalCapitalDeposited;

  /// إجمالي السحوبات من رأس المال.
  final double totalCapitalWithdrawn;

  /// الأرباح المرسملة.
  final double totalProfitCapitalized;

  /// الأرباح الموزعة.
  final double totalProfitDistributed;

  /// الأرباح المستحقة.
  final double accruedProfit;

  /// حركات كشف الحساب (مقسّمة صفحات).
  final PaginatedEntriesModel entries;

  const StatementModel({
    this.shareholder = const ShareholderModel(),
    this.totalCapitalDeposited = 0,
    this.totalCapitalWithdrawn = 0,
    this.totalProfitCapitalized = 0,
    this.totalProfitDistributed = 0,
    this.accruedProfit = 0,
    this.entries = const PaginatedEntriesModel(),
  });

  factory StatementModel.fromJson(Map<String, dynamic> json) {
    return StatementModel(
      shareholder: ShareholderModel.fromJson(_asMap(json['shareholder'])),
      totalCapitalDeposited: _asDouble(json['totalCapitalDeposited']),
      totalCapitalWithdrawn: _asDouble(json['totalCapitalWithdrawn']),
      totalProfitCapitalized: _asDouble(json['totalProfitCapitalized']),
      totalProfitDistributed: _asDouble(json['totalProfitDistributed']),
      accruedProfit: _asDouble(json['accruedProfit']),
      entries: PaginatedEntriesModel.fromJson(_asMap(json['entries'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shareholder': shareholder.toJson(),
      'totalCapitalDeposited': totalCapitalDeposited,
      'totalCapitalWithdrawn': totalCapitalWithdrawn,
      'totalProfitCapitalized': totalProfitCapitalized,
      'totalProfitDistributed': totalProfitDistributed,
      'accruedProfit': accruedProfit,
      'entries': entries.toJson(),
    };
  }

  /// نسخة جديدة مع دمج صفحة حركات إضافية — بتُستخدم في التحميل التدريجي.
  StatementModel copyWithMoreEntries(PaginatedEntriesModel nextPage) {
    return StatementModel(
      shareholder: shareholder,
      totalCapitalDeposited: totalCapitalDeposited,
      totalCapitalWithdrawn: totalCapitalWithdrawn,
      totalProfitCapitalized: totalProfitCapitalized,
      totalProfitDistributed: totalProfitDistributed,
      accruedProfit: accruedProfit,
      entries: nextPage.copyWith(
        data: [...entries.data, ...nextPage.data],
      ),
    );
  }

  @override
  List<Object?> get props => [
    shareholder,
    totalCapitalDeposited,
    totalCapitalWithdrawn,
    totalProfitCapitalized,
    totalProfitDistributed,
    accruedProfit,
    entries,
  ];
}
