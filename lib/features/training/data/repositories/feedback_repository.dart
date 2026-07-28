import 'package:dialog_feedback/app/database/database.dart';
import 'package:dialog_feedback/app/errors/action_executor.dart';
import 'package:dialog_feedback/app/errors/app_failure.dart';
import 'package:dialog_feedback/app/errors/result.dart';
import 'package:dialog_feedback/features/training/data/mappers/feedback_mapper.dart';
import 'package:dialog_feedback/features/training/domain/entities/training_feedback.dart';
import 'package:dialog_feedback/features/training/domain/repositories/feedback_repository.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: FeedbackRepository)
class FeedbackRepositoryImpl with ActionExecutor implements FeedbackRepository {
  final AppDatabase db;

  FeedbackRepositoryImpl(this.db);

  @override
  Future<Result<TrainingFeedback>> addFeedback(
    CreateTrainingFeedbackParams params,
  ) {
    return execute(() async {
      final feedbackRow = await db
          .into(db.feedbackTable)
          .insertReturning(
            FeedbackTableCompanion.insert(
              feedbackText: params.feedbackText,
              trainingId: params.trainingId,
            ),
          );
      return Success(feedbackRow.toDomain());
    }, createDefault: (_) => Failure(DatabaseFailure()));
  }

  @override
  Future<Result<TrainingFeedback>> getFeedback(int trainingId) {
    return execute(() async {
      final query = db.select(db.feedbackTable)
        ..where((tbl) => tbl.trainingId.equals(trainingId));

      final feedbackRow = await query.getSingleOrNull();

      if (feedbackRow == null) {
        return Failure(NotFoundFailure());
      }

      return Success(feedbackRow.toDomain());
    }, createDefault: (_) => Failure(DatabaseFailure()));
  }
}
