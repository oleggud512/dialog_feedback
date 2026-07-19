import 'package:dialog_feedback/app/app.dart';
import 'package:dialog_feedback/features/features.dart';

abstract interface class TrainingPromptsRepository {
  Future<Result<MessageResult>> getAiMessage(GetAiMessageParams params);
  Future<Result<FeedbackResult>> getFeedback(GetAiMessageParams params);
}
