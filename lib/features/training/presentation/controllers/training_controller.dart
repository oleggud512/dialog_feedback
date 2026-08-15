import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:dialog_feedback/core/audio_recorder/audio_recorder_service.dart';
import 'package:dialog_feedback/core/errors/app_failure.dart';
import 'package:dialog_feedback/core/errors/result.dart';
import 'package:dialog_feedback/core/signal_registry/signal_registry.dart';
import 'package:dialog_feedback/core/stt/stt_api.dart';
import 'package:dialog_feedback/core/utils/int_id.dart';
import 'package:dialog_feedback/core/utils/logger.dart';
import 'package:dialog_feedback/features/training/domain/entities/message.dart';
import 'package:dialog_feedback/features/training/domain/entities/message_role.dart';
import 'package:dialog_feedback/features/training/domain/entities/messages_aggregate.dart';
import 'package:dialog_feedback/features/training/domain/params/add_message.dart';
import 'package:dialog_feedback/features/training/domain/usecase/training_interactor.dart';
import 'package:dialog_feedback/shared/domain/entities/training.dart';
import 'package:injectable/injectable.dart';
import 'package:signals/signals.dart';

@injectable
class TrainingController extends SignalRegistry {
  final TrainingInteractor _interactor;
  final AudioRecorderService _audioRecorder;
  final SttApi _stt;

  final AudioPlayer _player = AudioPlayer();
  bool _isDisposed = false;

  File? _pendingAudioFile;
  String? _pendingTranscribedText;

  TrainingController(this._interactor, this._audioRecorder, this._stt);

  late final _aggregate = track(signal<MessagesAggregate?>(null));

  late final loading = track(signal<bool>(false));
  late final error = track(signal<AppFailure?>(null));

  late final loadingMessage = track(trackedSignal<Message?>(null));
  late final loadingMessageError = track(trackedSignal<AppFailure?>(null));
  late final isMessageLoading = track(computed(_computeIsMessageLoading));

  late final isRecording = track(signal<bool>(false));
  late final isPlayingAiAudio = track(signal<bool>(false));
  late final isTranscribing = track(signal<bool>(false));
  late final showLastAiResponse = track(signal<bool>(false));
  late final hasPendingRetry = track(signal<bool>(false));

  late final training = track(
    computed<Training?>(() => _aggregate.value?.training),
  );

  late final messages = track(computed(_computeMessages));

  late final lastAiMessage = track(
    computed<Message?>(() {
      final msgs = _aggregate.value?.messages;
      if (msgs == null || msgs.isEmpty) return null;
      return msgs.lastWhereOrNull((m) => m.role == MessageRole.ai);
    }),
  );

  late final isSendEnabled = track(
    computed<bool>(() {
      return isRecording.value &&
          !isMessageLoading.value &&
          !isPlayingAiAudio.value &&
          !isTranscribing.value &&
          loadingMessageError.value == null &&
          training.value?.isChatCompleted != true;
    }),
  );

  bool _computeIsMessageLoading() {
    final isMessage = loadingMessage.value != null;
    final isError = loadingMessageError.value != null;
    return isMessage && !isError;
  }

  List<Message> _computeMessages() {
    final currentAggr = _aggregate.value;
    if (currentAggr == null) return [];

    final currentLoadingMes = loadingMessage.value;
    if (currentLoadingMes == null) return currentAggr.messages;

    return [...currentAggr.messages, currentLoadingMes];
  }

  void loadTraining(int trainingId) async {
    if (loading.value) return;

    batch(() {
      loading.value = true;
      error.value = null;
    });

    final messagesAggregateRes = await _interactor.getMessages(trainingId);

    batch(() {
      switch (messagesAggregateRes) {
        case Success(value: final messagesAggregate):
          _aggregate.value = messagesAggregate;
          break;
        case Failure(:final failure):
          error.value = failure;
          break;
      }

      loading.value = false;
    });
  }

  void letAiStart() async {
    final currentAggr = _aggregate.value;
    if (currentAggr == null || loadingMessage.value != null || _isDisposed) {
      return;
    }

    final tempMessage = Message(
      id: intId(),
      messageText: "",
      role: MessageRole.ai,
      createdAt: DateTime.now(),
      trainingId: currentAggr.training.id,
      audioPath: "",
    );

    batch(() {
      loadingMessage.value = tempMessage;
      loadingMessageError.value = null;
    });

    final messageRes = await _interactor.generateInitialMessage(
      currentAggr.training.id,
    );

    switch (messageRes) {
      case Success(value: final message):
        batch(() {
          _aggregate.value = currentAggr.copyWith(
            messages: [...currentAggr.messages, message],
          );
          loadingMessage.value = null;
        });

        if (message.audioPath.isNotEmpty) {
          await _playAiAudio(message.audioPath);
        }

        if (!_isDisposed && training.value?.isChatCompleted != true) {
          await startRecording();
        }
        break;

      case Failure(:final failure):
        loadingMessageError.value = failure;
        break;
    }
  }

  void sendVoiceInput() async {
    final currentAggr = _aggregate.value;
    if (currentAggr == null ||
        !isRecording.value ||
        loadingMessage.value != null ||
        _isDisposed) {
      return;
    }

    isRecording.value = false;

    final stopRes = await _audioRecorder.stop();
    if (stopRes case Failure(:final failure)) {
      loadingMessageError.value = failure;
      return;
    }

    final recordedFile = stopRes.valueOrNull!;

    isTranscribing.value = true;
    final sttRes = await _stt.transcribe(recordedFile);
    isTranscribing.value = false;

    if (sttRes case Failure(:final failure)) {
      await _deleteFile(recordedFile);
      loadingMessageError.value = failure;
      return;
    }

    final transcribedText = sttRes.valueOrNull!.text.trim();
    if (transcribedText.isEmpty) {
      await _deleteFile(recordedFile);
      loadingMessageError.value = RecordingFailure();
      return;
    }

    _pendingAudioFile = recordedFile;
    _pendingTranscribedText = transcribedText;
    hasPendingRetry.value = true;

    await _submitPendingMessage();
  }

  Future<void> _submitPendingMessage() async {
    final currentAggr = _aggregate.value;
    final recordedFile = _pendingAudioFile;
    final transcribedText = _pendingTranscribedText;

    if (currentAggr == null ||
        recordedFile == null ||
        transcribedText == null ||
        _isDisposed) {
      return;
    }

    final tempMessage = Message(
      id: intId(),
      messageText: transcribedText,
      role: MessageRole.user,
      createdAt: DateTime.now(),
      trainingId: currentAggr.training.id,
      audioPath: recordedFile.path,
    );

    batch(() {
      loadingMessage.value = tempMessage;
      loadingMessageError.value = null;
    });

    final answerPairRes = await _interactor.addMessage(
      AddMessageParams(
        trainingId: currentAggr.training.id,
        messageText: transcribedText,
        audioPath: recordedFile.path,
      ),
    );

    switch (answerPairRes) {
      case Success(value: final answerPair):
        _pendingAudioFile = null;
        _pendingTranscribedText = null;
        hasPendingRetry.value = false;

        batch(() {
          _aggregate.value = currentAggr.copyWith(
            training: currentAggr.training.copyWith(
              isChatCompleted:
                  currentAggr.training.isChatCompleted ||
                  answerPair.isCompleted,
            ),
            messages: [
              ...currentAggr.messages,
              answerPair.question,
              answerPair.answer,
            ],
          );
          loadingMessage.value = null;
        });

        if (answerPair.answer.audioPath.isNotEmpty) {
          await _playAiAudio(answerPair.answer.audioPath);
        }

        if (!_isDisposed && training.value?.isChatCompleted != true) {
          await startRecording();
        }
        break;

      case Failure(:final failure):
        loadingMessageError.value = failure;
        break;
    }
  }

  Future<void> startRecording() async {
    if (_isDisposed || isRecording.value) return;
    final startRes = await _audioRecorder.start();
    if (startRes case Failure(:final failure)) {
      loadingMessageError.value = failure;
    } else {
      isRecording.value = true;
    }
  }

  Future<void> _playAiAudio(String audioPath) async {
    if (audioPath.isEmpty || _isDisposed) return;
    try {
      isPlayingAiAudio.value = true;
      final completer = Completer<void>();
      StreamSubscription? sub;
      sub = _player.onPlayerComplete.listen((_) {
        sub?.cancel();
        if (!completer.isCompleted) completer.complete();
      });

      await _player.play(DeviceFileSource(audioPath));
      await completer.future;
    } catch (e, st) {
      glog.e('Failed to play AI audio: $e', error: e, stackTrace: st);
    } finally {
      if (!_isDisposed) {
        isPlayingAiAudio.value = false;
      }
    }
  }

  void replayLastAiAudio() async {
    final aiMsg = lastAiMessage.value;
    if (aiMsg == null ||
        aiMsg.audioPath.isEmpty ||
        isPlayingAiAudio.value ||
        _isDisposed) {
      return;
    }

    if (isRecording.value) {
      isRecording.value = false;
      await _audioRecorder.cancel();
    }

    await _playAiAudio(aiMsg.audioPath);

    if (!_isDisposed && training.value?.isChatCompleted != true) {
      await startRecording();
    }
  }

  void toggleShowLastAiResponse() {
    showLastAiResponse.value = !showLastAiResponse.value;
  }

  void retry() async {
    if (_pendingTranscribedText != null) {
      await _submitPendingMessage();
    } else {
      resetError();
    }
  }

  void resetError() async {
    if (_pendingAudioFile != null) {
      await _deleteFile(_pendingAudioFile!);
      _pendingAudioFile = null;
      _pendingTranscribedText = null;
      hasPendingRetry.value = false;
    }

    batch(() {
      loadingMessage.value = null;
      loadingMessageError.value = null;
    });

    if (!_isDisposed &&
        _aggregate.value != null &&
        training.value?.isChatCompleted != true &&
        messages.value.isNotEmpty) {
      await startRecording();
    }
  }

  Future<void> _deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      glog.e('Failed to delete temporary audio file: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_pendingAudioFile != null) {
      _deleteFile(_pendingAudioFile!);
      _pendingAudioFile = null;
      _pendingTranscribedText = null;
    }
    _player.dispose();
    _audioRecorder.cancel();
    super.dispose();
  }
}
