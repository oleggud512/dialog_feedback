import 'package:dialog_feedback/app/errors/result.dart';
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

  TrainingInteractor(this._promptsRepo, this._messageRepo);

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
          ...messages.messages.map(
            (m) => MessageInput(messageText: m.messageText, role: m.role),
          ),
          MessageInput(messageText: params.messageText, role: MessageRole.user),
        ],
      ),
    );

    if (generatedMessageRes case Failure(:final failure)) {
      return Failure(failure);
    }

    final generatedMessage = generatedMessageRes.valueOrNull!;

    return _messageRepo.createAnswerPair(
      userParams: CreateMessageParams(
        messageText: params.messageText,
        role: MessageRole.user,
        trainingId: params.trainingId,
      ),
      aiParams: CreateMessageParams(
        messageText: generatedMessage.messageText,
        role: MessageRole.ai,
        trainingId: params.trainingId,
      ),
      isCompleted: generatedMessage.isCompleted,
    );
  }

  Future<Result<MessagesAggregate>> getMessages(int trainingId) {
    return _messageRepo.getMessages(trainingId);
  }
}
