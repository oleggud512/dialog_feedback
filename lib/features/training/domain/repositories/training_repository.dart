import 'package:dialog_feedback/app/app.dart';
import 'package:dialog_feedback/features/features.dart';

abstract interface class TrainingRepository {
  Future<Result<Training>> createTraining(CreateTrainingParams params);
}
