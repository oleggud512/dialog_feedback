import 'package:dialog_feedback/app/errors/app_failure.dart';
import 'package:dialog_feedback/app/errors/result.dart';
import 'package:dialog_feedback/app/tts/tts_api.dart';
import 'package:dialog_feedback/features/training/domain/entities/answer_pair.dart';
import 'package:dialog_feedback/features/training/domain/entities/message.dart';
import 'package:dialog_feedback/features/training/domain/entities/message_role.dart';
import 'package:dialog_feedback/features/training/domain/entities/messages_aggregate.dart';
import 'package:dialog_feedback/features/training/domain/params/add_message.dart';
import 'package:dialog_feedback/features/training/domain/params/get_ai_message.dart';
import 'package:dialog_feedback/features/training/domain/params/message_input.dart';
import 'package:dialog_feedback/features/training/domain/repositories/message_repository.dart';
import 'package:dialog_feedback/features/training/domain/repositories/training_prompts_repository.dart';
import 'package:injectable/injectable.dart';

@singleton
class TrainingInteractor {
  final TrainingPromptsRepository _promptsRepo;
  final MessageRepository _messageRepo;
  final TtsApi _tts;

  TrainingInteractor(this._promptsRepo, this._messageRepo, this._tts);

  Future<Result<AnswerPair>> addMessage(AddMessageParams params) async {
    final messagesRes = await _messageRepo.getMessages(params.trainingId);

    if (messagesRes case Failure(:final failure)) {
      return Failure(failure);
    }

    final messages = messagesRes.valueOrNull!;

    final generatedMessageRes = await _promptsRepo.getAiMessage(
      GetAiMessageParams(
        initialTaskText: messages.training.initialTaskText,
        messages: [
          ...messages.messages.map((m) => m.toInput()),
          MessageInput(messageText: params.messageText, role: MessageRole.user),
        ],
      ),
    );

    if (generatedMessageRes case Failure(:final failure)) {
      return Failure(failure);
    }

    final generatedMessage = generatedMessageRes.valueOrNull!;

    final auidoFileRes = await _tts.generate(generatedMessage.messageText);

    final audioFilePath = switch (auidoFileRes) {
      Success(:final value) => value.path,
      _ => "",
    };

    return _messageRepo.createAnswerPair(
      userParams: CreateMessageParams(
        messageText: params.messageText,
        role: MessageRole.user,
        trainingId: params.trainingId,
        audioPath: "",
      ),
      aiParams: CreateMessageParams(
        messageText: generatedMessage.messageText,
        role: MessageRole.ai,
        trainingId: params.trainingId,
        audioPath: audioFilePath,
      ),
      isCompleted: generatedMessage.isCompleted,
    );
  }

  Future<Result<Message>> generateInitialMessage(int trainingId) async {
    final messagesRes = await _messageRepo.getMessages(trainingId);

    if (messagesRes case Failure(:final failure)) {
      return Failure(failure);
    }

    final messages = messagesRes.valueOrNull!;

    if (messages.messages.isNotEmpty) {
      return Failure(AlreadyExistsFailure());
    }

    final generatedMessageRes = await _promptsRepo.getAiMessage(
      GetAiMessageParams(
        initialTaskText: messages.training.initialTaskText,
        messages: const [],
      ),
    );

    if (generatedMessageRes case Failure(:final failure)) {
      return Failure(failure);
    }

    final generatedMessage = generatedMessageRes.valueOrNull!;

    final audioFileRes = await _tts.generate(generatedMessage.messageText);
    final audioFilePath = switch (audioFileRes) {
      Success(:final value) => value.path,
      _ => "",
    };

    return _messageRepo.createMessage(
      CreateMessageParams(
        messageText: generatedMessage.messageText,
        role: MessageRole.ai,
        trainingId: trainingId,
        audioPath: audioFilePath,
      ),
    );
  }

  Future<Result<MessagesAggregate>> getMessages(int trainingId) {
    return _messageRepo.getMessages(trainingId);
  }
}
