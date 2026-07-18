import 'package:dialog_feedback/app/app.dart';
import 'package:dialog_feedback/features/features.dart';
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
      final appFailure = result.error;
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

      final failure = (result as Failure).error;
      expect(failure, isA<DatabaseFailure>());
    },
  );
}
