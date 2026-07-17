import 'package:dialog_feedback/app/app.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RegisterModule {
  AppDatabase appDatabase() => AppDatabase();
}
