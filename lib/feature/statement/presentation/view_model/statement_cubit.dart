import 'package:eman_shareholders/core/bloc/paginated_bloc/exports.dart';
import 'package:eman_shareholders/core/enum/status.dart';
import 'package:eman_shareholders/core/extensions/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data_source/statement_data_source.dart';
import '../../data/models/statement_model.dart';

/// كيوبت كشف حساب المساهم.
///
/// الملخص (بيانات المساهم والإجماليات) بيتحمّل مع أول صفحة، والحركات
/// بتتنقل صفحة بصفحة — كل صفحة بتستبدل اللي قبلها عشان الـ pagination
/// يبان واضح.
class StatementCubit extends Cubit<BaseState<StatementModel>> {
  final StatementDataSource _dataSource;

  StatementCubit(this._dataSource) : super(const BaseState<StatementModel>());

  /// حجم صفحة الحركات.
  static const int _pageSize = 10;

  /// الفلتر المفعّل حاليًا.
  StatementFilter _filter = StatementFilter.empty;
  StatementFilter get filter => _filter;

  /// الصفحة المعروضة حاليًا.
  int _pageIndex = 1;
  int get pageIndex => _pageIndex;

  /// جاري تحميل صفحة حركات — بيخلي الليست تعرض لودينج فوقها بس من غير
  /// ما الصفحة كلها تختفي.
  bool _isChangingPage = false;
  bool get isChangingPage => _isChangingPage;

  Future<void> getStatement() => _fetch(pageIndex: 1, isFirstLoad: true);

  /// إعادة التحميل من الأول — للسحب للتحديث وزر "إعادة المحاولة".
  Future<void> refreshStatement() =>
      _fetch(pageIndex: _pageIndex, isFirstLoad: !state.hasData);

  /// بتطبّق فلتر جديد وبترجع لأول صفحة.
  Future<void> applyFilter(StatementFilter filter) {
    if (filter == _filter) return Future.value();
    _filter = filter;
    return _fetch(pageIndex: 1);
  }

  /// بتشيل كل الفلاتر.
  Future<void> clearFilter() => applyFilter(StatementFilter.empty);

  /// بتروح لصفحة معينة من الحركات.
  Future<void> goToPage(int page) {
    final totalPages = state.data?.entries.totalPages ?? 1;
    if (page < 1 || page > totalPages || page == _pageIndex) {
      return Future.value();
    }
    return _fetch(pageIndex: page);
  }

  Future<void> nextPage() => goToPage(_pageIndex + 1);

  Future<void> previousPage() => goToPage(_pageIndex - 1);

  Future<void> _fetch({required int pageIndex, bool isFirstLoad = false}) async {
    if (_isChangingPage) return;
    _isChangingPage = true;

    // أول تحميل بيعرض لودينج الشاشة كلها، وتغيير الصفحة/الفلتر بيعرض
    // لودينج على الليست بس.
    emit(
      state.copyWith(
        status: isFirstLoad ? Status.loading : Status.isLoadingMore,
      ),
    );

    final result = await _dataSource.getStatement(
      pageIndex: pageIndex,
      pageSize: _pageSize,
      filter: _filter,
    );

    if (isClosed) {
      _isChangingPage = false;
      return;
    }

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          failure: failure,
          errorMessage: failure.message,
        ),
      ),
      (statement) {
        _pageIndex = statement.entries.pageIndex;
        emit(
          BaseState<StatementModel>(status: Status.success, data: statement),
        );
      },
    );

    _isChangingPage = false;
  }
}
