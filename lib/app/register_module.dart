import 'dart:async';

import 'package:dialog_feedback/app/app.dart';
import 'package:injectable/injectable.dart';

FutureOr<void> disposeAppDatabase(AppDatabase instance) {
  return instance.close();
}

@module
abstract class RegisterModule {
  @Singleton(dispose: disposeAppDatabase)
  AppDatabase appDatabase() => AppDatabase();
}
