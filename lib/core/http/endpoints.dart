part of 'http.dart';

abstract interface class Endpoints {
  static const String baseUrl = 'https://amantheone.runasp.net';
  static const String forgetPassword = "/api/Auth/client-forget-password";
  static const String resetPassword = "/api/Auth/client-reset-password";
  static const String login = "/api/Auth/client-login";

  /// تجديد التوكن — بياخد `refreshToken` و `deviceInfo` و `deviceId`.
  static const String refreshToken = "/api/auth/refresh-token";

  /// إلغاء الـ refresh token على السيرفر.
  static const String logoutSession = "/api/auth/logout";

  // ─── مصادقة المساهم (OTP) ────────────────────────
  /// إرسال رمز التحقق لرقم هاتف المساهم.
  static const String shareholderRequestOtp =
      "/api/shareholder/auth/request-otp";

  /// إعادة إرسال رمز التحقق.
  static const String shareholderResendOtp = "/api/shareholder/auth/resend-otp";

  /// التحقق من الرمز — بيرجع الـ access و refresh token.
  static const String shareholderVerifyOtp = "/api/shareholder/auth/verify-otp";
  static const String register = "/api/Auth/client-register";
  static const String logout = "/api/Auth/logout";
  static const String logoutAll = "/api/Auth/logout-all";
  static const String logoutOthers = "/api/Auth/logout-others";
  static const String propertyGroups = "/api/client/properties/groups";
  static const String properties = "/api/client/properties";
  static const String bookings = "/api/client/bookings";
  static String postFavourites(num propertyId) =>
      "/api/client/properties/$propertyId/favorite";
  static String deleteFavourites(num propertyId) =>
      "/api/client/properties/$propertyId/favorite";
  static String rateProperty(num id) => "/api/client/properties/$id/rate";
  static String getPropertyRatings(num propertyId) =>
      "/api/client/properties/$propertyId/ratings";
  static String getfavourite = "/api/client/properties/favorites";
  static String bookingsCancel(num id) => "/api/client/bookings/$id/cancel";
  static String deleteAccount = "/api/client/profile";
  static String getProfile = "/api/client/profile";
  static String contactUs = "/api/client/content/contact-us";
  static String faqs = "/api/client/content/faqs";
  static String termsConditions = "/api/client/content/terms-and-conditions";

  /// كشف حساب المساهم — بيانات المساهم والإجماليات وحركاته مقسّمة صفحات.
  static const String shareholderStatement = "/api/shareholder/statement";
}
