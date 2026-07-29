import 'package:key_value_storage/key_value_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'secure_storage_adapter.dart';

class SecureKeyValueStore extends KeyValueStore {
  SecureKeyValueStore()
    : super(FlutterSecureStorageAdapter(), namespace: 'default');

  late final apiKey = stringEntity('apiKey', defaultValue: '');
  late final ttsApiKey = stringEntity('ttsApiKey', defaultValue: '');
}
