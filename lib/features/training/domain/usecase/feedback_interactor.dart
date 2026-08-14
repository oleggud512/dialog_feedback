import 'package:dialog_feedback/core/errors/app_failure.dart';
import 'package:dialog_feedback/core/errors/result.dart';
import 'package:dialog_feedback/features/training/domain/entities/training_feedback.dart';
import 'package:dialog_feedback/features/training/domain/params/get_ai_message.dart';
import 'package:dialog_feedback/features/training/domain/params/message_input.dart';
import 'package:dialog_feedback/features/training/domain/repositories/feedback_repository.dart';
import 'package:dialog_feedback/features/training/domain/repositories/message_repository.dart';
import 'package:dialog_feedback/features/training/domain/repositories/training_prompts_repository.dart';
import 'package:injectable/injectable.dart';

@singleton
class FeedbackInteractor {
  final FeedbackRepository _feedbackRepo;
  final MessageRepository _messageRepo;
  final TrainingPromptsRepository _promptsRepo;

  FeedbackInteractor(this._feedbackRepo, this._messageRepo, this._promptsRepo);

  Future<Result<TrainingFeedback>> getFeedback(int trainingId) {
    return _feedbackRepo.getFeedback(trainingId);
  }

  Future<Result<TrainingFeedback>> generateFeedback(int trainingId) async {
    final existingFeedbackRes = await _feedbackRepo.getFeedback(trainingId);

    if (existingFeedbackRes case Success()) {
      return Failure(AlreadyExistsFailure());
    }

    final messagesRes = await _messageRepo.getMessages(trainingId);

    if (messagesRes case Failure(:final failure)) {
      return Failure(failure);
    }

    final messages = messagesRes.valueOrNull!;

    final genRes = await _promptsRepo.getFeedback(
      GetAiMessageParams(
        initialTaskText: messages.training.initialTaskText,
        messages: messages.messages.map((m) => m.toInput()).toList(),
      ),
    );

    if (genRes case Failure(:final failure)) {
      return Failure(failure);
    }

    final gen = genRes.valueOrNull!;

    return _feedbackRepo.addFeedback(
      CreateTrainingFeedbackParams(
        feedbackText: gen.content,
        trainingId: trainingId,
      ),
    );
  }
}
