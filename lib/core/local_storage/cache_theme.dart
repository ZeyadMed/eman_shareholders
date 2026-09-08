part of 'local_storage.dart';

abstract interface class IThemeCache {
  Future<void> saveThemeMode(String themeMode);
  String? getThemeMode();
  Future<void> clearThemeMode();
}