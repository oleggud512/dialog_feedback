import 'package:dialog_feedback/app/database/database.dart';
import 'package:dialog_feedback/features/training/domain/entities/training_feedback.dart';

extension FeedbackDbModelMapper on FeedbackDbModel {
  TrainingFeedback toDomain() => TrainingFeedback(
    id: id,
    feedbackText: feedbackText,
    dateTime: createdAt,
    trainingId: trainingId,
  );
}
