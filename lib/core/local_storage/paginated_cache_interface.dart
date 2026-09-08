part of 'local_storage.dart';


abstract interface class IPaginatedCache<T> {
  const IPaginatedCache();

  Future<void> cachePage(List<T> items, {required String cacheKey});

  Future<List<T>> getCachedPage({required String cacheKey});

  Future<void> clearCachedPage({required String cacheKey});
}

