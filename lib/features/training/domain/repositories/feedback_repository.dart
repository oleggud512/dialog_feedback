import 'package:dialog_feedback/app/errors/result.dart';
import 'package:dialog_feedback/features/training/domain/entities/training_feedback.dart';

abstract interface class FeedbackRepository {
  Future<Result<TrainingFeedback>> getFeedback(int trainingId);
  Future<Result<TrainingFeedback>> addFeedback(
    CreateTrainingFeedbackParams params,
  );
}
