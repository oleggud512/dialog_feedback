import 'package:dialog_feedback/app/errors/result.dart';
import '../entities/training.dart';

abstract interface class TrainingRepository {
  Future<Result<Training>> createTraining(CreateTrainingParams params);
  Future<Result<List<Training>>> getTrainings();
}
