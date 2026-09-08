part of 'local_storage.dart';

class HivePaginatedCache<T> implements IPaginatedCache<T> {
  final String boxName;
  Box<List>? _box;

  HivePaginatedCache({required this.boxName});

  Future<Box<List>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<List>(boxName);
    }
    return _box!;
  }

  @override
  Future<void> cachePage(List<T> items, {required String cacheKey}) async {
    final box = await _getBox();
    await box.put(cacheKey, items);
  }

  @override
  Future<List<T>> getCachedPage({required String cacheKey}) async {
    final box = await _getBox();
    final data = box.get(cacheKey);
    if (data != null) {
      return data.cast<T>();
    }
    return [];
  }

  @override
  Future<void> clearCachedPage({required String cacheKey}) async {
    final box = await _getBox();
    await box.delete(cacheKey);
  }
}
