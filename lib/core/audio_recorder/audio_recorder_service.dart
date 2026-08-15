import 'dart:io';

import 'package:dialog_feedback/core/errors/result.dart';

/// Core service for recording voice audio to a file.
abstract interface class AudioRecorderService {
  /// Starts recording audio to a file (optimized for STT / Whisper).
  Future<Result<void>> start();

  /// Stops the current recording and returns the recorded [File].
  Future<Result<File>> stop();

  /// Cancels the recording session and cleans up the temporary file.
  Future<Result<void>> cancel();

  /// Returns `true` if a recording session is currently active.
  Future<bool> isRecording();

  /// Releases recorder resources.
  Future<void> dispose();
}
