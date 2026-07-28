import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_feedback.freezed.dart';

@freezed
sealed class TrainingFeedback with _$TrainingFeedback {
  const factory TrainingFeedback({
    required int id,
    required String feedbackText,
    required DateTime dateTime,
    required int trainingId,
  }) = _TrainingFeedback;

  const TrainingFeedback._();
}

@freezed
sealed class CreateTrainingFeedbackParams with _$CreateTrainingFeedbackParams {
  const factory CreateTrainingFeedbackParams({
    required String feedbackText,
    required int trainingId,
  }) = _CreateTrainingFeedbackParams;

  const CreateTrainingFeedbackParams._();
}
