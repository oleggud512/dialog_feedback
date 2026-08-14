part of 'secure_key_value_store.dart';

class FlutterSecureStorageAdapter implements KeyValueStorageAdapter {
  final storage = FlutterSecureStorage();

  @override
  Future<void> delete(String key) => storage.delete(key: key);

  @override
  Future<Map<String, String>> loadAll() => storage.readAll();

  @override
  Future<void> write(String key, String value) =>
      storage.write(key: key, value: value);
}
