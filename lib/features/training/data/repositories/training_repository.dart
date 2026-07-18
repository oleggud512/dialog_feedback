import 'package:dialog_feedback/app/app.dart';
import 'package:dialog_feedback/core/core.dart';
import 'package:dialog_feedback/features/features.dart';
import 'package:injectable/injectable.dart';

Training _toDomain(TrainingDbModel model) => Training(
  id: model.id,
  initialTaskText: model.initialTaskText,
  isChatCompleted: model.isChatCompleted,
  createdAt: model.createdAt,
);

@Singleton(as: TrainingRepository)
class TrainingRepositoryImpl implements TrainingRepository {
  final AppDatabase db;

  TrainingRepositoryImpl(this.db);

  @override
  Future<Result<Training>> createTraining(CreateTrainingParams params) async {
    try {
      final res = await db
          .into(db.trainingTable)
          .insert(
            TrainingTableCompanion.insert(
              initialTaskText: params.initialTaskText,
            ),
          );

      return getTraining(res);
    } catch (e, st) {
      glog.e(e, stackTrace: st);
      return Failure(DatabaseFailure());
    }
  }

  Future<Result<Training>> getTraining(int id) async {
    final query = db.select(db.trainingTable)
      ..where((tbl) => tbl.id.equals(id));

    final res = await query.getSingleOrNull();

    if (res == null) {
      return Failure(NotFoundFailure());
    }

    return Success(_toDomain(res));
  }
}
