import 'dart:io';

import 'package:dialog_feedback/core/errors/result.dart';

abstract interface class TtsApi {
  Future<Result<File>> generate(String text);
}
