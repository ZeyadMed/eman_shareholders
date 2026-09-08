import 'package:eman_shareholders/core/enum/status.dart';
import 'package:eman_shareholders/core/http/either.dart';
import 'package:eman_shareholders/core/http/failure.dart';
import 'package:eman_shareholders/feature/statement/data/data_source/statement_data_source.dart';
import 'package:eman_shareholders/feature/statement/data/models/statement_model.dart';
import 'package:eman_shareholders/feature/statement/presentation/view_model/statement_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// داتا سورس بيسجّل كل نداء عشان نتأكد من الباراميترات المبعوتة.
class RecordingDataSource implements StatementDataSource {
  final List<({int pageIndex, int pageSize, StatementFilter filter})> calls = [];

  /// عدد الصفحات اللي "السيرفر" بيرجعها.
  int totalPages;
  int count;
  Failure? failure;

  RecordingDataSource({this.totalPages = 5, this.count = 42});

  @override
  Future<Either<Failure, StatementModel>> getStatement({
    int pageIndex = 1,
    int pageSize = 10,
    StatementFilter filter = StatementFilter.empty,
  }) async {
    calls.add((pageIndex: pageIndex, pageSize: pageSize, filter: filter));

    final error = failure;
    if (error != null) return Left(error);

    return Right(
      StatementModel(
        entries: PaginatedEntriesModel(
          pageIndex: pageIndex,
          pageSize: pageSize,
          count: count,
          totalPages: totalPages,
          data: [StatementEntryModel(id: pageIndex)],
        ),
      ),
    );
  }
}

void main() {
  group('StatementFilter query parameters', () {
    test('الفلتر الفاضي ما بيبعتش أي باراميتر', () {
      expect(StatementFilter.empty.toQueryParameters(), isEmpty);
      expect(StatementFilter.empty.isActive, isFalse);
      expect(StatementFilter.empty.activeCount, 0);
    });

    test('بيبعت الـ key الإنجليزي للباك اند مش الاسم العربي', () {
      for (final type in TransactionType.filterable) {
        final params = StatementFilter(
          transactionType: type,
        ).toQueryParameters();
        expect(params['transactionType'], type.apiValue);
        // الاسم العربي للعرض بس.
        expect(params['transactionType'], isNot(type.label));
      }
    });

    test('الأنواع الأربعة بمفاتيحها الصح', () {
      expect(
        TransactionType.filterable.map((t) => t.apiValue).toList(),
        [
          'CapitalDeposit',
          'CapitalWithdrawal',
          'ProfitCapitalization',
          'ProfitDistribution',
        ],
      );
      // `unknown` مش خيار فلترة.
      expect(
        TransactionType.filterable.contains(TransactionType.unknown),
        isFalse,
      );
    });

    test('التواريخ بتتبعت بصيغة yyyy-MM-dd', () {
      final params = StatementFilter(
        fromDate: DateTime(2026, 1, 5),
        toDate: DateTime(2026, 12, 31),
      ).toQueryParameters();

      expect(params['fromDate'], '2026-01-05');
      expect(params['toDate'], '2026-12-31');
    });

    test('activeCount بيعد الفلاتر المفعّلة', () {
      expect(
        StatementFilter(fromDate: DateTime(2026, 1, 1)).activeCount,
        1,
      );
      expect(
        StatementFilter(
          fromDate: DateTime(2026, 1, 1),
          toDate: DateTime(2026, 2, 1),
          transactionType: TransactionType.capitalDeposit,
        ).activeCount,
        3,
      );
    });

    test('copyWith بيشيل فلتر واحد بس', () {
      final filter = StatementFilter(
        fromDate: DateTime(2026, 1, 1),
        toDate: DateTime(2026, 2, 1),
        transactionType: TransactionType.capitalDeposit,
      );

      final withoutType = filter.copyWith(clearTransactionType: true);
      expect(withoutType.transactionType, isNull);
      expect(withoutType.fromDate, DateTime(2026, 1, 1));
      expect(withoutType.toDate, DateTime(2026, 2, 1));
    });
  });

  group('StatementCubit pagination', () {
    test('أول تحميل بيجيب الصفحة الأولى', () async {
      final source = RecordingDataSource();
      final cubit = StatementCubit(source);

      await cubit.getStatement();

      expect(source.calls.single.pageIndex, 1);
      expect(cubit.pageIndex, 1);
      expect(cubit.state.status, Status.success);
      await cubit.close();
    });

    test('التنقل بيستبدل الصفحة مش بيضيف عليها', () async {
      final source = RecordingDataSource();
      final cubit = StatementCubit(source);

      await cubit.getStatement();
      await cubit.goToPage(3);

      expect(source.calls.last.pageIndex, 3);
      expect(cubit.pageIndex, 3);
      // صفحة واحدة معروضة — مش تراكم صفحات.
      expect(cubit.state.data!.entries.data.length, 1);
      expect(cubit.state.data!.entries.data.single.id, 3);
      await cubit.close();
    });

    test('مفيش نداء لصفحة بره النطاق', () async {
      final source = RecordingDataSource(totalPages: 3);
      final cubit = StatementCubit(source);

      await cubit.getStatement();
      final callsAfterLoad = source.calls.length;

      await cubit.goToPage(0);
      await cubit.goToPage(4);
      await cubit.goToPage(1); // نفس الصفحة الحالية

      expect(source.calls.length, callsAfterLoad);
      await cubit.close();
    });

    test('nextPage و previousPage بيتحركوا صح', () async {
      final source = RecordingDataSource();
      final cubit = StatementCubit(source);

      await cubit.getStatement();
      await cubit.nextPage();
      expect(cubit.pageIndex, 2);

      await cubit.previousPage();
      expect(cubit.pageIndex, 1);

      // مفيش رجوع قبل أول صفحة.
      final before = source.calls.length;
      await cubit.previousPage();
      expect(source.calls.length, before);
      await cubit.close();
    });

    test('تطبيق فلتر بيرجع لأول صفحة وبيبعت الفلتر', () async {
      final source = RecordingDataSource();
      final cubit = StatementCubit(source);

      await cubit.getStatement();
      await cubit.goToPage(4);
      expect(cubit.pageIndex, 4);

      await cubit.applyFilter(
        StatementFilter(transactionType: TransactionType.capitalWithdrawal),
      );

      final last = source.calls.last;
      // الفلتر بيرجّع المستخدم لأول صفحة.
      expect(last.pageIndex, 1);
      expect(
        last.filter.transactionType,
        TransactionType.capitalWithdrawal,
      );
      expect(cubit.filter.isActive, isTrue);
      await cubit.close();
    });

    test('الفلتر بيفضل مفعّل مع تغيير الصفحة', () async {
      final source = RecordingDataSource();
      final cubit = StatementCubit(source);

      await cubit.getStatement();
      await cubit.applyFilter(
        StatementFilter(fromDate: DateTime(2026, 1, 1)),
      );
      await cubit.goToPage(2);

      // نفس الفلتر اتبعت مع الصفحة الجديدة.
      expect(source.calls.last.pageIndex, 2);
      expect(source.calls.last.filter.fromDate, DateTime(2026, 1, 1));
      await cubit.close();
    });

    test('نفس الفلتر ما بيعملش نداء تاني', () async {
      final source = RecordingDataSource();
      final cubit = StatementCubit(source);

      await cubit.getStatement();
      final filter = StatementFilter(
        transactionType: TransactionType.capitalDeposit,
      );
      await cubit.applyFilter(filter);
      final callsAfterFilter = source.calls.length;

      await cubit.applyFilter(filter);
      expect(source.calls.length, callsAfterFilter);
      await cubit.close();
    });

    test('clearFilter بيشيل الفلتر ويرجّع لأول صفحة', () async {
      final source = RecordingDataSource();
      final cubit = StatementCubit(source);

      await cubit.getStatement();
      await cubit.applyFilter(
        StatementFilter(transactionType: TransactionType.profitDistribution),
      );
      await cubit.clearFilter();

      expect(cubit.filter.isActive, isFalse);
      expect(source.calls.last.filter.toQueryParameters(), isEmpty);
      expect(source.calls.last.pageIndex, 1);
      await cubit.close();
    });

    test('فشل تحميل صفحة بيعرض الخطأ', () async {
      final source = RecordingDataSource();
      final cubit = StatementCubit(source);

      await cubit.getStatement();
      source.failure = ServerFailure(message: 'مشكلة في الشبكة');
      await cubit.goToPage(2);

      expect(cubit.state.status, Status.failure);
      expect(cubit.state.errorMessage, 'مشكلة في الشبكة');
      // البيانات القديمة فضلت معروضة.
      expect(cubit.state.data, isNotNull);
      await cubit.close();
    });
  });
}
