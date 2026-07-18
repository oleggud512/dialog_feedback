import 'package:dialog_feedback/app/app.dart';
import 'package:dialog_feedback/shared/shared.dart';

abstract interface class TrainingRepository {
  Future<Result<Training>> createTraining(CreateTrainingParams params);
  Future<Result<List<Training>>> getTrainings();
}
