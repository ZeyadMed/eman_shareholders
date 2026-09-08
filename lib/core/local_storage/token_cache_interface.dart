part of 'local_storage.dart';


abstract interface class ITokenCache {
   UserToken? getAccessToken();
   Future<void> saveAccessToken(UserToken token);

  Future<void> clearAccessToken();
}