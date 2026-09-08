import 'package:eman_shareholders/feature/auth/verify_otp/presentation/verify_otp.dart';
import 'package:eman_shareholders/feature/statement/presentation/statement_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:eman_shareholders/feature/auth/login/presentation/login_screen.dart';
import 'package:eman_shareholders/feature/splash/presentation/view/splash_screen.dart';
import 'package:eman_shareholders/main.dart';

abstract class AppRouter {
  static const String root = '/';
  static const String webViewContainer = '/webViewContainer';
  static const String onboarding = '/onboarding';
  static const String login = '/login';

  static const String verifyOtp = '/verifyOtp';

  // ************* HOME *************
  static const String initialRoot = '/initialRoot';
  static const String homeScreen = '/HomeScreen';
  static const String bookingScreen = '/BookingScreen';
  static const String favScreen = '/FavScreen';
  static const String hotelDetails = '/hotelDetails';
  static const String bookingDetails = '/bookingDetails';
  static const String paymentScreen = '/paymentScreen';
  static const String statementScreen = '/statementScreen';


  // ************* PROFILE *************
  static const String profileScreen = '/profileScreen';
  static const String contactUsScreen = '/contactUsScreen';
  static const String notificationScreen = '/notificationScreen';
  static const String customerServiceScreen = '/customerServiceScreen';
  static const String aboutUs = '/aboutUs';
  static const String updateProfileScreen = '/updateProfileScreen';
  static const String privacyPolicy = '/privacyPolicy';
  static const String settingsScreen = '/settingsScreen';
  static const String helpSupportScreen = '/helpSupportScreen';
  static const String editProfileScreen = '/editProfileScreen';
  static const String termsConditionsScreen = '/termsConditionsScreen';
  static const String reviewsPage = '/reviewsPage';

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    routes: [
      // -----------------------------------Splash Screen and OnBoarding--------------------------------
      GoRoute(path: root, builder: (context, state) => const SplashScreen()),
      // -----------------------------------Auth--------------------------------
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: verifyOtp,
        builder: (context, state) {
          final extra = state.extra;
          // بندعم `VerifyOtpArgs` والـ String القديم (رقم بس) عشان أي
          // استدعاء قديم ما يقعش.
          if (extra is VerifyOtpArgs) {
            return VerifyOtp(
              phoneNumber: extra.phoneNumber,
              expirySeconds: extra.expirySeconds,
            );
          }
          return VerifyOtp(phoneNumber: extra as String? ?? '');
        },
      ),
      GoRoute(path: statementScreen, builder: (context, state) => const StatementScreen()),
    ],
  );
}
