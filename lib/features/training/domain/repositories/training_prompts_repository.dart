import 'package:dialog_feedback/core/errors/result.dart';
import '../params/get_ai_message.dart';
import '../results/feedback_result.dart';
import '../results/message_result.dart';

abstract interface class TrainingPromptsRepository {
  Future<Result<MessageResult>> getAiMessage(GetAiMessageParams params);
  Future<Result<FeedbackResult>> getFeedback(GetAiMessageParams params);
}
