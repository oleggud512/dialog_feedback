import 'dart:async';

import 'package:dialog_feedback/app/app.dart';
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
