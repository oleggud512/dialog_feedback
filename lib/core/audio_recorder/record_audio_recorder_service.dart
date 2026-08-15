import 'dart:async';
import 'dart:io';

import 'package:dialog_feedback/core/audio_recorder/audio_recorder_service.dart';
import 'package:dialog_feedback/core/errors/action_executor.dart';
import 'package:dialog_feedback/core/errors/app_failure.dart';
import 'package:dialog_feedback/core/errors/result.dart';
import 'package:dialog_feedback/core/utils/logger.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

FutureOr<void> disposeAudioRecorderService(AudioRecorderService instance) {
  if (instance is RecordAudioRecorderService) {
    return instance.dispose();
  }
}

@Singleton(as: AudioRecorderService, dispose: disposeAudioRecorderService)
class RecordAudioRecorderService
    with ActionExecutor
    implements AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;

  RecordAudioRecorderService();

  static const _config = RecordConfig(
    encoder: AudioEncoder.aacLc,
    bitRate: 128000,
    sampleRate: 44100,
    numChannels: 1,
  );

  @override
  Future<Result<void>> start() async {
    return execute(() async {
      final permitted = await _recorder.hasPermission();
      if (!permitted) {
        return Failure(PermissionDeniedFailure());
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${Uuid().v7()}.m4a';
      final targetPath = join(dir.path, 'recordings', fileName);

      final targetFile = File(targetPath);
      await targetFile.parent.create(recursive: true);

      _currentRecordingPath = targetPath;
      await _recorder.start(_config, path: targetPath);

      return Success(null);
    }, createDefault: (_) => Failure(RecordingFailure()));
  }

  @override
  Future<Result<File>> stop() async {
    return execute(() async {
      final path = await _recorder.stop();
      final recordedPath = path ?? _currentRecordingPath;
      _currentRecordingPath = null;

      if (recordedPath == null) {
        return Failure(NoActiveRecordingFailure());
      }

      final file = File(recordedPath);
      if (!await file.exists()) {
        return Failure(RecordingNotFoundFailure());
      }

      return Success(file);
    }, createDefault: (_) => Failure(RecordingFailure()));
  }

  @override
  Future<Result<void>> cancel() async {
    return execute(() async {
      await _recorder.cancel();
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {}
        }
        _currentRecordingPath = null;
      }
      return Success(null);
    }, createDefault: (_) => Failure(RecordingFailure()));
  }

  @override
  Future<bool> isRecording() async {
    try {
      return await _recorder.isRecording();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _recorder.dispose();
    } catch (e, st) {
      glog.e('Failed to dispose AudioRecorder', error: e, stackTrace: st);
    }
  }
}
