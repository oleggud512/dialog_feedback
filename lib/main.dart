import 'package:dialog_feedback/my_app.dart';
import 'package:dialog_feedback/di.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();

  runApp(const MyApp());
}
