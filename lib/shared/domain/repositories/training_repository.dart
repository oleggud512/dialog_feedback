import 'package:dialog_feedback/app/errors/result.dart';
import '../entities/training.dart';
import '../entities/training_history_item.dart';

abstract interface class TrainingRepository {
  Future<Result<Training>> createTraining(CreateTrainingParams params);
  Future<Result<List<TrainingHistoryItem>>> getTrainings();
}

