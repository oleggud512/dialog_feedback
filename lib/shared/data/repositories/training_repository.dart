import 'package:dialog_feedback/app/database/database.dart';
import 'package:dialog_feedback/app/errors/action_executor.dart';
import 'package:dialog_feedback/app/errors/app_failure.dart';
import 'package:dialog_feedback/app/errors/result.dart';
import 'package:dialog_feedback/shared/data/mappers/training_mapper.dart';
import 'package:dialog_feedback/shared/domain/entities/training.dart';
import 'package:dialog_feedback/shared/domain/entities/training_history_item.dart';
import 'package:dialog_feedback/shared/domain/repositories/training_repository.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: TrainingRepository)
class TrainingRepositoryImpl with ActionExecutor implements TrainingRepository {
  final AppDatabase db;

  TrainingRepositoryImpl(this.db);

  @override
  Future<Result<Training>> createTraining(CreateTrainingParams params) async {
    return execute(() async {
      final row = await db
          .into(db.trainingTable)
          .insertReturning(
            TrainingTableCompanion.insert(
              initialTaskText: params.initialTaskText,
            ),
          );

      return Success(row.toDomain());
    }, createDefault: (_) => Failure(DatabaseFailure()));
  }

  Future<Result<Training>> getTraining(int id) async {
    return execute(() async {
      final query = db.select(db.trainingTable)
        ..where((tbl) => tbl.id.equals(id));

      final res = await query.getSingleOrNull();

      if (res == null) {
        return Failure(NotFoundFailure());
      }

      return Success(res.toDomain());
    }, createDefault: (_) => Failure(DatabaseFailure()));
  }

  @override
  Future<Result<List<TrainingHistoryItem>>> getTrainings() async {
    return execute(() async {
      final query = db.select(db.trainingTable).join([
        leftOuterJoin(
          db.feedbackTable,
          db.feedbackTable.trainingId.equalsExp(db.trainingTable.id),
        ),
      ])..orderBy([OrderingTerm.desc(db.trainingTable.createdAt)]);

      final rows = await query.get();

      final historyItems = rows.map((row) {
        final trainingModel = row.readTable(db.trainingTable);
        final feedbackModel = row.readTableOrNull(db.feedbackTable);

        return TrainingHistoryItem(
          training: trainingModel.toDomain(),
          hasFeedback: feedbackModel != null,
        );
      }).toList();

      return Success(historyItems);
    }, createDefault: (_) => Failure(DatabaseFailure()));
  }
}
