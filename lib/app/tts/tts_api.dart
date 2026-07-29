import 'dart:io';

import 'package:dialog_feedback/app/errors/result.dart';

abstract interface class TtsApi {
  Future<Result<File>> generate(String text);
}
