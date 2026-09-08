import 'dart:convert';

import 'package:eman_shareholders/feature/statement/data/models/statement_model.dart';
import 'package:eman_shareholders/feature/statement/presentation/widgets/statement_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const String _json = '''
{
  "shareholder": {
    "id": 5, "name": "أحمد محمود", "phoneNumber": "01012345678",
    "address": "القاهرة - مدينة نصر", "contributedAmount": 500000.00,
    "ownedPercentage": 25.00, "companyPercentage": 20.00,
    "totalProfitReceived": 45000.00, "accruedProfit": 3200.50,
    "capitalTreasuryId": 1, "capitalTreasuryName": "الخزينة الرئيسية",
    "notes": "مساهم مؤسس", "createdAt": "2025-01-10T09:00:00"
  },
  "totalCapitalDeposited": 500000.00, "totalCapitalWithdrawn": 50000.00,
  "totalProfitCapitalized": 20000.00, "totalProfitDistributed": 45000.00,
  "accruedProfit": 3200.50,
  "entries": {
    "pageIndex": 1, "pageSize": 10, "count": 42, "totalPages": 5,
    "data": [
      {
        "id": 301, "voucherNumber": "", "date": "2026-08-30T00:00:00",
        "transactionType": "ProfitDistribution", "amount": 15000.00,
        "companyShare": 3000.00, "shareholderShare": 12000.00,
        "capitalBalanceAfter": 0, "treasuryName": "خزينة الأرباح",
        "notes": "تسوية أرباح شهر أغسطس"
      },
      {
        "id": 119, "voucherNumber": "PAY-2026-0044",
        "date": "2026-07-01T00:00:00", "transactionType": "CapitalWithdrawal",
        "amount": 50000.00, "companyShare": null, "shareholderShare": null,
        "capitalBalanceAfter": 500000.00, "treasuryName": "الخزينة الرئيسية",
        "notes": "سحب جزء من رأس المال"
      },
      {
        "id": 3, "voucherNumber": "REC-2025-0001",
        "date": "2025-01-10T00:00:00", "transactionType": "CapitalDeposit",
        "amount": 500000.00, "companyShare": null, "shareholderShare": null,
        "capitalBalanceAfter": 500000.00, "treasuryName": "الخزينة الرئيسية",
        "notes": "إيداع رأس المال الأولي"
      }
    ]
  }
}
''';

/// بيلف الويدجت بنفس إعدادات التطبيق — ScreenUtil و RTL.
Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      locale: const Locale('ar'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    ),
  );
}

void main() {
  final statement = StatementModel.fromJson(
    jsonDecode(_json) as Map<String, dynamic>,
  );

  // شاشة الاختبار الافتراضية 800x600، والـ `ScreenUtil` بيقيس عليها
  // فالأطوال بتطلع غلط. بنضبطها على مقاس موبايل حقيقي.
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(375 * 3, 812 * 3);
    view.devicePixelRatio = 3;
  });

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('الكارت الأزرق بيعرض المبلغ والنسبة والأرباح المستحقة', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        StatementHeaderCard(
          contributedAmount: statement.shareholder.contributedAmount,
          companyPercentage: statement.shareholder.companyPercentage,
          accruedProfit: statement.accruedProfit,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('إجمالي مساهمتك في رأس المال'), findsOneWidget);
    expect(find.text('500,000.00 ج.م'), findsOneWidget);
    expect(find.text('20%'), findsOneWidget);
    expect(find.text('3,200.50 ج.م'), findsOneWidget);
  });

  testWidgets('ملخص رأس المال بيعرض الإجماليات الخمسة', (tester) async {
    await tester.pumpWidget(_wrap(CapitalSummaryCard(statement: statement)));
    await tester.pumpAndSettle();

    expect(find.text('ملخص رأس المال'), findsOneWidget);
    expect(find.text('إجمالي الإيداعات'), findsOneWidget);
    expect(find.text('إجمالي السحوبات'), findsOneWidget);
    expect(find.text('الأرباح المرسملة'), findsOneWidget);
    expect(find.text('الأرباح الموزعة'), findsOneWidget);
    expect(find.text('الأرباح المستحقة'), findsOneWidget);
    expect(find.text('50,000.00 ج.م'), findsOneWidget);
    expect(find.text('20,000.00 ج.م'), findsOneWidget);
  });

  testWidgets('بيانات الحساب بتعرض العنوان والخزينة وتاريخ الانضمام', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(AccountInfoCard(shareholder: statement.shareholder)),
    );
    await tester.pumpAndSettle();

    expect(find.text('بيانات الحساب'), findsOneWidget);
    expect(find.text('القاهرة - مدينة نصر'), findsOneWidget);
    expect(find.text('الخزينة الرئيسية'), findsOneWidget);
    expect(find.text('عضو منذ 10 يناير 2025'), findsOneWidget);
    expect(find.text('01012345678'), findsOneWidget);
  });

  testWidgets('الحركات بتعرض النوع والمبلغ بالعلامة الصح', (tester) async {
    await tester.pumpWidget(
      _wrap(StatementEntriesCard(entries: statement.entries)),
    );
    await tester.pumpAndSettle();

    // التوزيع بيعرض نصيب المساهم (12000) مش المبلغ الكلي (15000).
    expect(find.text('توزيع أرباح'), findsOneWidget);
    expect(find.text('+12,000.00 ج.م'), findsOneWidget);

    // السحب بعلامة سالب.
    expect(find.text('سحب من رأس المال'), findsOneWidget);
    expect(find.text('-50,000.00 ج.م'), findsOneWidget);

    // الإيداع بعلامة زائد.
    expect(find.text('إيداع رأس مال'), findsOneWidget);
    expect(find.text('+500,000.00 ج.م'), findsOneWidget);

    // رقم السند بيظهر لما يكون موجود بس.
    expect(find.text('سند: REC-2025-0001'), findsOneWidget);
    expect(find.textContaining('سند: '), findsNWidgets(2));
  });

  testWidgets('شريط الصفحات بيعرض الصفحة الحالية وبيتنقل', (tester) async {
    final selected = <int>[];
    await tester.pumpWidget(
      _wrap(
        StatementPaginationBar(
          pageIndex: 1,
          totalPages: 5,
          count: 42,
          onPageSelected: selected.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('صفحة 1 من 5 · 42 حركة'), findsOneWidget);
    // ٥ صفحات بتتعرض كلها من غير اختصار.
    expect(find.text('…'), findsNothing);

    await tester.tap(find.text('3'));
    expect(selected, [3]);
  });

  testWidgets('الصفحة الحالية مش قابلة للضغط ومفيش رجوع من أول صفحة', (
    tester,
  ) async {
    final selected = <int>[];
    await tester.pumpWidget(
      _wrap(
        StatementPaginationBar(
          pageIndex: 1,
          totalPages: 5,
          count: 42,
          onPageSelected: selected.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // ضغط على الصفحة الحالية ما بيعملش حاجة.
    await tester.tap(find.text('1'));
    // سهم الرجوع معطّل في أول صفحة.
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    expect(selected, isEmpty);

    // السهم التالي شغال.
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    expect(selected, [2]);
  });

  testWidgets('الصفحات الكتير بتتعرض مختصرة بنقاط', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StatementPaginationBar(
          pageIndex: 10,
          totalPages: 20,
          count: 200,
          onPageSelected: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // أول وآخر صفحة دايمًا ظاهرين، والحالية وجيرانها.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('…'), findsNWidgets(2));
  });

  testWidgets('مفيش شريط صفحات لو صفحة واحدة بس', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StatementPaginationBar(
          pageIndex: 1,
          totalPages: 1,
          count: 3,
          onPageSelected: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('صفحة'), findsNothing);
  });

  testWidgets('رسالة القائمة الفاضية متمركزة في نص الكارت أفقيًا ورأسيًا', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const StatementEntriesCard(entries: PaginatedEntriesModel())),
    );
    await tester.pumpAndSettle();

    final card = tester.getRect(find.byType(StatementCard));
    final icon = tester.getRect(find.byIcon(Icons.receipt_long_outlined));
    final text = tester.getRect(find.text('مفيش حركات على حسابك لحد الآن'));

    // أفقيًا: مركز الأيقونة والنص = مركز الكارت.
    expect(icon.center.dx, closeTo(card.center.dx, 1));
    expect(text.center.dx, closeTo(card.center.dx, 1));

    // رأسيًا: مركز الكتلة (من فوق الأيقونة لتحت النص) = مركز الكارت.
    final contentCenterY = (icon.top + text.bottom) / 2;
    expect(contentCenterY, closeTo(card.center.dy, 1));

    // الكارت لازم يبقى فيه مساحة فعلية مش ملزوق على المحتوى.
    expect(card.height, greaterThanOrEqualTo(250));
  });

  testWidgets('رسالة الفلتر وزر المسح متمركزين كمان', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StatementEntriesCard(
          entries: const PaginatedEntriesModel(),
          isFiltered: true,
          onClearFilter: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final card = tester.getRect(find.byType(StatementCard));
    expect(
      tester.getRect(find.text('مفيش حركات مطابقة للفلتر')).center.dx,
      closeTo(card.center.dx, 1),
    );
    expect(
      tester.getRect(find.text('مسح الفلتر')).center.dx,
      closeTo(card.center.dx, 1),
    );
  });

  testWidgets('قائمة حركات فاضية بتعرض رسالة مش كارت فاضي', (tester) async {
    await tester.pumpWidget(
      _wrap(const StatementEntriesCard(entries: PaginatedEntriesModel())),
    );
    await tester.pumpAndSettle();

    expect(find.text('مفيش حركات على حسابك لحد الآن'), findsOneWidget);
  });

  testWidgets('القائمة الفاضية بسبب الفلتر بتعرض رسالة مختلفة وزر مسح', (
    tester,
  ) async {
    var cleared = false;
    await tester.pumpWidget(
      _wrap(
        StatementEntriesCard(
          entries: const PaginatedEntriesModel(),
          isFiltered: true,
          onClearFilter: () => cleared = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مفيش حركات مطابقة للفلتر'), findsOneWidget);
    expect(find.text('مفيش حركات على حسابك لحد الآن'), findsNothing);

    await tester.tap(find.text('مسح الفلتر'));
    expect(cleared, isTrue);
  });

  testWidgets('شريط الفلتر بيعرض الفلاتر المفعّلة بالعربي وبيشيلها', (
    tester,
  ) async {
    StatementFilter? changed;
    final filter = StatementFilter(
      fromDate: DateTime(2026, 1, 15),
      transactionType: TransactionType.profitDistribution,
    );

    await tester.pumpWidget(
      _wrap(
        StatementFilterBar(
          filter: filter,
          onOpenFilter: () {},
          onFilterChanged: (value) => changed = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // الاسم العربي بيتعرض مش الـ apiValue.
    expect(find.text('توزيع أرباح'), findsOneWidget);
    expect(find.text('ProfitDistribution'), findsNothing);
    expect(find.text('من 15 يناير 2026'), findsOneWidget);
    expect(find.text('فلترة (2)'), findsOneWidget);

    // شيل فلتر النوع.
    await tester.tap(
      find.descendant(
        of: find
            .ancestor(of: find.text('توزيع أرباح'), matching: find.byType(Row))
            .first,
        matching: find.byIcon(Icons.close_rounded),
      ),
    );
    expect(changed?.transactionType, isNull);
    // التاريخ فضل زي ما هو.
    expect(changed?.fromDate, DateTime(2026, 1, 15));
  });

  testWidgets('ريسبونس فاضي ما بيوقعش الشاشة', (tester) async {
    final empty = StatementModel.fromJson(const {});
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            StatementGreeting(name: empty.shareholder.name),
            StatementHeaderCard(
              contributedAmount: empty.shareholder.contributedAmount,
              companyPercentage: empty.shareholder.companyPercentage,
              accruedProfit: empty.accruedProfit,
            ),
            CapitalSummaryCard(statement: empty),
            AccountInfoCard(shareholder: empty.shareholder),
            StatementEntriesCard(entries: empty.entries),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('0.00 ج.م'), findsWidgets);
  });
}
