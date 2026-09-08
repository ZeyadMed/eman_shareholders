part of '../service_locator.dart';

final GetIt getIt = GetIt.instance;

abstract interface class DI {
  static Future<void> execute() async {
    // الترتيب مهم: كاش التوكن و`SessionManager` لازم يكونوا متسجلين قبل
    // `Dio` عشان الـ `AuthInterceptor` يلاقيهم وقت الإنشاء.
    await AuthServiceLocator.execute(getIt: getIt);
    await SharedServiceLocator.execute(getIt: getIt);
    await HiveServiceLocator.execute(getIt: getIt);
    await ThemeServiceLocator.execute(getIt: getIt);
    await StatementServiceLocator.execute(getIt: getIt);
  }
}
