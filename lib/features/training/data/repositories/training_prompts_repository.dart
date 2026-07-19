import 'package:dialog_feedback/app/errors/result.dart';
import 'package:dialog_feedback/features/features.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: TrainingPromptsRepository)
class TrainingPromptsRepositoryImpl implements TrainingPromptsRepository {
  @override
  Future<Result<MessageResult>> getAiMessage(GetAiMessageParams params) async {
    // TODO: implement getAiMessage
    throw UnimplementedError();
  }

  @override
  Future<Result<FeedbackResult>> getFeedback(GetAiMessageParams params) async {
    // TODO: implement getFeedback
    throw UnimplementedError();
  }
}
