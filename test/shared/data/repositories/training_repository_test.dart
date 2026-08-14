import 'package:dialog_feedback/app/database/database.dart';
import 'package:dialog_feedback/app/errors/app_failure.dart';
import 'package:dialog_feedback/app/errors/result.dart';
import 'package:dialog_feedback/shared/data/repositories/training_repository.dart';
import 'package:dialog_feedback/shared/domain/entities/training.dart';
import 'package:dialog_feedback/shared/domain/entities/training_history_item.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TrainingRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    repo = TrainingRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    "createTraining successfully inserts a training and returns a the created training",
    () async {
      final params = CreateTrainingParams(initialTaskText: "Test task");

      final result = await repo.createTraining(params);

      final success = result as Success<Training>;
      final training = success.value;

      expect(training.id, 1);
      expect(training.initialTaskText, "Test task");
      expect(training.isChatCompleted, false);
      expect(training.createdAt, isA<DateTime>());

      final rawRows = await db.select(db.trainingTable).get();
      expect(rawRows.length, 1);
    },
  );

  test(
    "getTraining returns a domain exception when there is nothing to find",
    () async {
      final result = await repo.getTraining(666);

      result as Failure<Training>;
      final appFailure = result.failure;
      expect(appFailure, isA<NotFoundFailure>());
    },
  );

  test(
    "createTraining returns a Failure when the database throws an exception",
    () async {
      final params = CreateTrainingParams(initialTaskText: "Test task");

      await db.customStatement('DROP TABLE training;');

      final result = await repo.createTraining(params);

      expect(result, isA<Failure>());

      final failure = (result as Failure).failure;
      expect(failure, isA<DatabaseFailure>());
    },
  );

  test("getTrainings returns an empty list when there is no data", () async {
    final result = await repo.getTrainings();

    expect(result, isA<Success<List<TrainingHistoryItem>>>());

    final list = (result as Success<List<TrainingHistoryItem>>).value;
    expect(list, isEmpty);
  });

  test(
    "getTrainings returns mapped records ordered descending by createdAt with hasFeedback flag",
    () async {
      final now = DateTime.now();

      final id1 = await db
          .into(db.trainingTable)
          .insert(
            TrainingTableCompanion.insert(
              initialTaskText: "Old Task",
              createdAt: Value(now.subtract(const Duration(days: 1))),
            ),
          );

      final id2 = await db
          .into(db.trainingTable)
          .insert(
            TrainingTableCompanion.insert(
              initialTaskText: "New Task",
              createdAt: Value(now),
            ),
          );

      await db
          .into(db.feedbackTable)
          .insert(
            FeedbackTableCompanion.insert(
              feedbackText: "Great job!",
              trainingId: id1,
            ),
          );

      final result = await repo.getTrainings();

      expect(result, isA<Success<List<TrainingHistoryItem>>>());
      final list = (result as Success<List<TrainingHistoryItem>>).value;

      expect(list.length, 2);

      expect(list[0].training.id, id2);
      expect(list[0].training.initialTaskText, "New Task");
      expect(list[0].hasFeedback, false);

      expect(list[1].training.id, id1);
      expect(list[1].training.initialTaskText, "Old Task");
      expect(list[1].hasFeedback, true);
    },
  );
}
