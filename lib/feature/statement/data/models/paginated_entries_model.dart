part of 'statement_model.dart';

/// الحركات مقسّمة صفحات — الجزء `entries` من الريسبونس.
class PaginatedEntriesModel extends Equatable {
  final int pageIndex;
  final int pageSize;

  /// إجمالي عدد الحركات على كل الصفحات.
  final int count;

  final int totalPages;
  final List<StatementEntryModel> data;

  const PaginatedEntriesModel({
    this.pageIndex = 1,
    this.pageSize = 10,
    this.count = 0,
    this.totalPages = 0,
    this.data = const [],
  });

  factory PaginatedEntriesModel.fromJson(Map<String, dynamic> json) {
    return PaginatedEntriesModel(
      pageIndex: json['pageIndex'] == null ? 1 : _asInt(json['pageIndex']),
      pageSize: json['pageSize'] == null ? 10 : _asInt(json['pageSize']),
      count: _asInt(json['count']),
      totalPages: _asInt(json['totalPages']),
      data: _asList(json['data'])
          .map((entry) => StatementEntryModel.fromJson(_asMap(entry)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageIndex': pageIndex,
      'pageSize': pageSize,
      'count': count,
      'totalPages': totalPages,
      'data': data.map((entry) => entry.toJson()).toList(),
    };
  }

  PaginatedEntriesModel copyWith({
    int? pageIndex,
    int? pageSize,
    int? count,
    int? totalPages,
    List<StatementEntryModel>? data,
  }) {
    return PaginatedEntriesModel(
      pageIndex: pageIndex ?? this.pageIndex,
      pageSize: pageSize ?? this.pageSize,
      count: count ?? this.count,
      totalPages: totalPages ?? this.totalPages,
      data: data ?? this.data,
    );
  }

  /// فيه صفحات تانية بعد الصفحة الحالية؟
  bool get hasMore => pageIndex < totalPages;

  @override
  List<Object?> get props => [pageIndex, pageSize, count, totalPages, data];
}
