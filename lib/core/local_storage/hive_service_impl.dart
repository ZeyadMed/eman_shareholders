part of "local_storage.dart";

class HiveServiceImpl implements IUserCache, ITokenCache, IThemeCache {
  // ---------------------- Boxes ----------------------
  static const String userBoxName = 'user_box';
  static const String tokenBoxName = 'token_box';
  static const String themeBoxName = 'theme_box';
  static const String deviceBoxName = 'device_box'; 

  // ----------------------- Keys ----------------------
  static const String currentUserKey = 'current_user';
  static const String accessTokenKey = 'access_token';
  static const String themeModeKey = 'theme_mode';
  static const String deviceIdKey = 'device_id'; 

  static Box<String>? _themeBox;
  static Box<UserModel>? _userBox;
  static Box<UserToken>? _tokenBox;
  static Box<String>? _deviceBox; 

  const HiveServiceImpl._();

  static final HiveServiceImpl instance = HiveServiceImpl._();

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(UserTokenAdapter());
    Hive.registerAdapter(UserModelAdapter());
   
    // Open boxes
    _userBox = await Hive.openBox<UserModel>(userBoxName);
    _tokenBox = await Hive.openBox<UserToken>(tokenBoxName);
    _themeBox = await Hive.openBox<String>(themeBoxName);
    _deviceBox = await Hive.openBox<String>(deviceBoxName); 
  }

  // ---------------------- User ----------------------
  @override
  Future<void> cacheUserModel(UserModel user) async {
    await _userBox?.put(currentUserKey, user);
    loggerInfo('User cached: ${user.name}');
  }

  @override
  UserModel? getCachedUserModel() {
    final user = _userBox?.get(currentUserKey);
    if (user != null) {
      loggerInfo('Retrieved user from cache: ${user.name}');
    }
    return user;
  }

  @override
  Future<void> updateCachedUserModel(UserModel user) async {
    final currentUser = _userBox?.get(currentUserKey);

    if (currentUser == null) {
      await cacheUserModel(user);
      return;
    }

    final updatedUser = currentUser.copyWith(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
    );

    await _userBox?.put(currentUserKey, updatedUser);
    loggerInfo('Updated user in cache: ${updatedUser.name}');
  }

  @override
  Future<void> clearUserModel() async {
    await _userBox?.delete(currentUserKey);
    loggerInfo('User cache cleared');
  }

  // ---------------------- Token ----------------------
  @override
  Future<void> saveAccessToken(UserToken token) async {
    await _tokenBox?.put(accessTokenKey, token);
    loggerInfo('Access token saved');
  }

  @override
  UserToken? getAccessToken() {
    return _tokenBox?.get(accessTokenKey);
  }

  @override
  Future<void> clearAccessToken() async {
    await _tokenBox?.delete(accessTokenKey);
    loggerInfo('Access token cleared');
  }

  // ---------------------- Theme ----------------------
  @override
  Future<void> saveThemeMode(String themeMode) async {
    await _themeBox?.put(themeModeKey, themeMode);
    loggerInfo('Theme mode saved: $themeMode');
  }

  @override
  String? getThemeMode() {
    final theme = _themeBox?.get(themeModeKey);
    if (theme != null) {
      loggerInfo('Retrieved theme mode from cache: $theme');
    }
    return theme;
  }

  @override
  Future<void> clearThemeMode() async {
    await _themeBox?.delete(themeModeKey);
    loggerInfo('Theme mode cleared');
  }

  // ---------------------- Device ID 🔥 ----------------------
  Future<String> getDeviceId() async {
    String? deviceId = _deviceBox?.get(deviceIdKey);

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await _deviceBox?.put(deviceIdKey, deviceId);
      loggerInfo('New Device ID created: $deviceId');
    } else {
      loggerInfo('Existing Device ID: $deviceId');
    }

    return deviceId;
  }

  String getDeviceInfo() {
    return "Android"; // تقدر تطورها بعدين
  }

  // ------------------ Generic & Helper ---------------------
  static Future<Box<E>> openBox<E>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) return Hive.box<E>(boxName);
    return await Hive.openBox<E>(boxName);
  }

  Future<void> clearAll() async {
    await _userBox?.clear();
    await _tokenBox?.clear();
    await _themeBox?.clear();
    await _deviceBox?.clear(); // 🔥 NEW
    loggerInfo('All local caches cleared');
  }
}