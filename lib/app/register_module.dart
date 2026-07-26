import 'dart:async';

import 'package:dialog_feedback/app/database/database.dart';
import 'package:dialog_feedback/app/key_value_storage/secure_key_value_store.dart';
import 'package:injectable/injectable.dart';

FutureOr<void> disposeAppDatabase(AppDatabase instance) => instance.close();

FutureOr<void> disposeSecureKeyValueStore(SecureKeyValueStore instance) =>
    instance.dispose();

@module
abstract class RegisterModule {
  @Singleton(dispose: disposeAppDatabase)
  AppDatabase appDatabase() => AppDatabase();

  @preResolve
  @Singleton(dispose: disposeSecureKeyValueStore)
  Future<SecureKeyValueStore> secureKeyValueStore() async {
    final storage = SecureKeyValueStore();
    await storage.init();
    return storage;
  }
}
