import 'package:easy_localization/easy_localization.dart';
import 'package:eman_shareholders/core/internet_connenction/internet_connenction_cubit.dart';
import 'package:eman_shareholders/core/router/app_router.dart';
import 'package:eman_shareholders/core/style/assets.dart';
import 'package:eman_shareholders/core/theme/app_colors.dart';
import 'package:eman_shareholders/core/theme/text_styles.dart';
import 'package:eman_shareholders/core/theme/theme.dart';
import 'package:eman_shareholders/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eman_shareholders/core/cache_manager/cache_manager.dart';
import 'package:eman_shareholders/core/internet_connenction/internet_connection_state.dart';
import 'package:eman_shareholders/core/local_storage/local_storage.dart';
import 'package:eman_shareholders/core/service_locator/service_locator.dart';
import 'package:eman_shareholders/core/theme/theme_mode_controller.dart';
import 'package:lottie/lottie.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'navigatorKey-${DateTime.now().millisecondsSinceEpoch}',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 // await FirebaseMessaging.instance.requestPermission();
 // MessagingConfig.initFirebaseMessaging();
 // FirebaseMessaging.onBackgroundMessage(MessagingConfig.messageHandler);
  await CacheManager.init();
  await ThemeModeController.loadSavedTheme();
  //await CacheManager.fetchAndSaveFcmToken();
  EasyLocalization.ensureInitialized();
  await HiveServiceImpl.init();
  await DI.execute();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/translations',
        // ignore: deprecated_member_use
        fallbackLocale: const Locale('ar'),
        // ignore: deprecated_member_use
        startLocale: const Locale('ar'),
        saveLocale: true,
        useOnlyLangCode: true,
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Force Arabic locale regardless of device language
    context.setLocale(const Locale('ar'));

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (context) => InternetCubit(),
          child: BlocBuilder<InternetCubit, InternetState>(
            builder: (context, state) {
              final bool offline = state is InternetOffState;
              return ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeModeController.notifier,
                builder: (context, themeMode, _) {
                  return MaterialApp.router(
                    title: "Ewan Booking",
                    debugShowCheckedModeBanner: false,
                    scaffoldMessengerKey: scaffoldMessengerKey,
                    localizationsDelegates: [
                      ...context.localizationDelegates,
                      // الـ date picker وباقي ويدجتس ماتيريال محتاجين
                      // الترجمات العامة، وبدونها بيرموا
                      // "No MaterialLocalizations found".
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: context.supportedLocales,
                    locale: const Locale('ar'),
                    theme: AppThemeData.light(context),
                    darkTheme: AppThemeData.dark(context),
                    themeMode: themeMode,
                    routerConfig: AppRouter.router,
                    builder: (context, child) {
                      final media = MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.noScaling);
                      if (offline) {
                        return MediaQuery(
                          data: media,
                          child: Scaffold(
                            backgroundColor: AppColors.whiteColor,
                            body: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Lottie.asset(
                                    Assets.assetsSvgNoInternet,
                                    height: 200.h,
                                  ),
                                ),
                                Gaps.h18(),
                                Center(
                                  child: Text(
                                    "noInternet".tr(),
                                    style: TextStyles.blackBold14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return MediaQuery(data: media, child: child!);
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
