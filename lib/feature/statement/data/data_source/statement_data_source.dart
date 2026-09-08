import 'package:eman_shareholders/core/helpers/helpers.dart';
import 'package:eman_shareholders/core/http/either.dart';
import 'package:eman_shareholders/core/http/failure.dart';
import 'package:eman_shareholders/core/http/http.dart';

import '../models/statement_model.dart';

abstract interface class StatementDataSource {
  /// بتجيب كشف حساب المساهم — [pageIndex] و [pageSize] بيتحكموا في صفحة
  /// الحركات (`entries`)، أما بيانات المساهم والإجماليات فبترجع كاملة كل مرة.
  ///
  /// [filter] بيقيّد الحركات بالتاريخ والنوع.
  Future<Either<Failure, StatementModel>> getStatement({
    int pageIndex,
    int pageSize,
    StatementFilter filter,
  });
}

class StatementDataSourceImpl implements StatementDataSource {
  final GenericDataSource _genericDataSource;

  StatementDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, StatementModel>> getStatement({
    int pageIndex = 1,
    int pageSize = 10,
    StatementFilter filter = StatementFilter.empty,
  }) {
    return _genericDataSource.fetchResult<StatementModel>(
      endpoint: Endpoints.shareholderStatement,
      // السيرفر بيسمي باراميترات الصفحات `PageIndex`/`PageSize`، وباراميترات
      // الفلتر `fromDate`/`toDate`/`transactionType`.
      queryParameters: {
        'PageIndex': pageIndex,
        'PageSize': pageSize,
        ...filter.toQueryParameters(),
      },
      // `fetchResult` بيبعت الـ `data` كـ Map جاهزة.
      fromJson: (json) => StatementModel.fromJson(
        json is Map<String, dynamic>
            ? json
            : Map<String, dynamic>.from(json as Map? ?? {}),
      ),
    );
  }
}
