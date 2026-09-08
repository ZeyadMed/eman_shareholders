part of '../service_locator.dart';

class SharedServiceLocator {
  static Future<void> execute({required GetIt getIt}) async {
    // final token = HiveServiceImpl.instance.getAccessToken();

    // loggerWarn("token in sl $token");
    loggerWarn(
        "Accept Language in sl ${navigatorKey.currentContext?.isArabic}");
    getIt.registerLazySingleton<Dio>(
      () {
        final dio = Dio(
          BaseOptions(
            baseUrl: Endpoints.baseUrl,
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Cache-Control': 'no-cache',
              'Pragma': 'no-cache',
              'Accept-Language':
                  navigatorKey.currentContext?.isArabic ?? true ? 'ar' : 'en',
            },
          ),
        );

        dio.interceptors.addAll([
          // الـ auth أول واحد — بيحقن التوكن وبيتعامل مع 401 والتجديد.
          AuthInterceptor(
            dio: dio,
            session: getIt<SessionManager>(),
            onSessionExpired: () {
              final context = navigatorKey.currentContext;
              if (context == null) return;
              context.showTopSnackBar(
                message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى',
                type: SnackBarType.error,
              );
              // مسار الدخول مكتوب صريح عشان ما نستوردش `AppRouter` هنا
              // ونعمل دورة استيراد (router → screens → cubits → DI).
              context.go('/login');
            },
          ),
          if (kDebugMode)
            PrettyDioLogger(
              requestHeader: true,
              requestBody: true,
              responseBody: true,
              responseHeader: false,
              error: true,
              compact: true,
              enabled: true,
              request: true,
              maxWidth: 90,
            ),
        ]);

        return dio;
      },
    );
    getIt.registerLazySingleton<ApiConsumer>(
        () => ApiConsumerImpl(dio: getIt<Dio>()));
    getIt.registerLazySingleton<GenericDataSource>(
        () => GenericDataSource(getIt<ApiConsumer>()));
    getIt.registerLazySingleton<SyncManager>(() => SyncManager());
    getIt.registerLazySingleton<ConnectivityService>(
        () => ConnectivityService.instance);

    // getIt.registerLazySingleton<SyncBloc>(() => SyncBloc(syncManager: getIt<SyncManager>(), connectivityService: getIt<ConnectivityService>()));
  }
}
