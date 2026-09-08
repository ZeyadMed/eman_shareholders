import 'package:eman_shareholders/core/cache_manager/cache_manager.dart';
import 'package:eman_shareholders/core/helpers/helpers.dart';
import 'package:eman_shareholders/core/local_storage/local_storage.dart';
import 'package:eman_shareholders/feature/auth/user_token.dart';

/// المصدر الوحيد لحالة جلسة المستخدم — التوكن بيتخزن في Hive (كائن كامل)
/// وكوبي من الـ access token في SharedPreferences عشان الشاشات القديمة
/// (السبلاش/الـ logout) تفضل شغالة على نفس الحقيقة.
class SessionManager {
  final ITokenCache _tokenCache;

  SessionManager(this._tokenCache);

  UserToken? get token {
    final cached = _tokenCache.getAccessToken();
    if (cached == null || !cached.isValid) return null;
    return cached;
  }

  String? get accessToken => token?.accessToken;

  /// فيه جلسة محفوظة؟ ما بنشوفش الصلاحية هنا — التوكن المنتهي بيتجدد
  /// أوتوماتيك بالـ refresh token، فوجوده لوحده كفاية للدخول.
  bool get isLoggedIn => token != null;

  /// هيدر التصريح للريكوستات — null لو مفيش جلسة.
  Map<String, String> get authHeader {
    final value = accessToken;
    if (value == null || value.isEmpty) return const {};
    return {'Authorization': 'Bearer $value'};
  }

  Future<void> save(UserToken newToken) async {
    await _tokenCache.saveAccessToken(newToken);
    await CacheManager.saveAccessToken(newToken.accessToken);
    await CacheManager.clearGuestMode();
    loggerInfo('Session saved for user ${newToken.userId}');
  }

  /// بيحدّث التوكن بعد التجديد مع الحفاظ على بيانات المستخدم لو السيرفر
  /// رجّع الـ tokens بس.
  Future<void> update(UserToken refreshed) async {
    final current = _tokenCache.getAccessToken();
    if (current == null) {
      await save(refreshed);
      return;
    }

    await save(
      current.copyWith(
        accessToken: refreshed.accessToken,
        refreshToken: refreshed.hasRefreshToken
            ? refreshed.refreshToken
            : current.refreshToken,
        expiresAtUtc: refreshed.expiresAtUtc,
        userType: refreshed.userType.isNotEmpty ? refreshed.userType : null,
        userId: refreshed.userId.isNotEmpty ? refreshed.userId : null,
        userName: refreshed.userName.isNotEmpty ? refreshed.userName : null,
      ),
    );
  }

  Future<void> clear() async {
    await _tokenCache.clearAccessToken();
    await CacheManager.delAccessToken();
    loggerInfo('Session cleared');
  }
}
