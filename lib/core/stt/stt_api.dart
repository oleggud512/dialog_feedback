import 'dart:io';

import 'package:dialog_feedback/core/errors/result.dart';
import 'package:dialog_feedback/core/stt/stt_result.dart';

export 'stt_result.dart';

/// Abstract interface for Speech-To-Text (STT) services.
abstract interface class SttApi {
  /// Transcribes the given [audioFile] into text with duration metadata.
  ///
  /// - [language]: Optional ISO-639-1 / ISO-639-3 language code (e.g., 'de', 'en').
  Future<Result<SttResult>> transcribe(
    File audioFile, {
    String? language,
  });
}
