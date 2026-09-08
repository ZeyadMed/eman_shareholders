import 'package:eman_shareholders/core/theme/theme.dart';
import 'package:eman_shareholders/feature/statement/data/models/statement_model.dart';
import 'package:eman_shareholders/feature/statement/presentation/widgets/statement_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// بيلف الشاشة بنفس إعدادات `main.dart` — نفس الـ delegates ونفس
/// اللغة ونفس الثيم، عشان الاختبار يعكس التطبيق الحقيقي (الثيم مهم
/// لأن مقاساته الكبيرة هي اللي كانت بتضخّم الـ date picker).
Widget _app({required void Function(StatementFilter?) onResult}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => MaterialApp(
      locale: const Locale('ar'),
      theme: AppThemeData.light(context),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await showStatementFilterSheet(
                    context,
                    current: StatementFilter.empty,
                  );
                  onResult(result);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  // شاشة الاختبار الافتراضية 800x600 (أوسع وأقصر من الموبايل) فالشيت
  // بيطلع بره الشاشة. بنضبطها على مقاس موبايل حقيقي.
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(375 * 3, 812 * 3);
    view.devicePixelRatio = 3;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher
        .views
        .first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('الشيت بيعرض الأنواع الأربعة بالعربي', (tester) async {
    await tester.pumpWidget(_app(onResult: (_) {}));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('فلترة الحركات'), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);
    expect(find.text('إيداع رأس مال'), findsOneWidget);
    expect(find.text('سحب من رأس المال'), findsOneWidget);
    expect(find.text('رسملة أرباح'), findsOneWidget);
    expect(find.text('توزيع أرباح'), findsOneWidget);
  });

  testWidgets('اختيار نوع وتطبيق بيرجّع الفلتر بالـ apiValue', (tester) async {
    StatementFilter? result;
    await tester.pumpWidget(_app(onResult: (value) => result = value));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('سحب من رأس المال'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تطبيق الفلتر'));
    await tester.pumpAndSettle();

    expect(result!.transactionType, TransactionType.capitalWithdrawal);
    expect(
      result!.toQueryParameters()['transactionType'],
      'CapitalWithdrawal',
    );
  });

  testWidgets('date picker بيفتح من غير ما يقع', (tester) async {
    await tester.pumpWidget(_app(onResult: (_) {}));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('من'));
    await tester.pumpAndSettle();

    // لو ناقصة `flutter_localizations` الـ picker بيرمي استثناء هنا.
    expect(tester.takeException(), isNull);
  });

  testWidgets('مسح الكل بيصفّر الاختيارات', (tester) async {
    StatementFilter? result;
    await tester.pumpWidget(_app(onResult: (value) => result = value));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('توزيع أرباح'));
    await tester.pumpAndSettle();
    expect(find.text('مسح الكل'), findsOneWidget);

    await tester.tap(find.text('مسح الكل'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تطبيق الفلتر'));
    await tester.pumpAndSettle();

    expect(result!.isActive, isFalse);
  });
}
