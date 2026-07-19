import 'package:dialog_feedback/app/app.dart';
import 'package:dialog_feedback/my_app.dart';
import 'package:dialog_feedback/di.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();

  final db = sl<AppDatabase>();
  await db.customStatement("DELETE FROM training");
  await db.customStatement(
    "DELETE FROM sqlite_sequence WHERE name = 'training';",
  );

  final cur = await db.select(db.trainingTable).get();
  print(cur);

  runApp(const MyApp());
}
