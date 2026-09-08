part of '../service_locator.dart';
class HiveServiceLocator {
  static Future<void> execute({required GetIt getIt}) async {
    getIt.registerLazySingleton<HiveServiceImpl>(
        () => HiveServiceImpl.instance);
    // `ITokenCache` و `IUserCache` بيتسجلوا في `AuthServiceLocator` قبل
    // `Dio` عشان الـ interceptor يلاقيهم.
    getIt.registerLazySingleton<IThemeCache>(() => getIt<HiveServiceImpl>());
  }
}
