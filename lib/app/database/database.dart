import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'database.steps.dart';

part 'database.g.dart';

const _dbName = 'my_database';

@DataClassName("TrainingDbModel")
class TrainingTable extends Table {
  @override
  String get tableName => "training";

  late final id = integer().autoIncrement()();
  late final initialTaskText = text()();
  late final isChatCompleted = boolean().withDefault(Constant(false))();
  late final createdAt = dateTime().withDefault(currentDateAndTime)();
}

enum MessageTableMessageRole { ai, user }

@DataClassName("MessageDbModel")
class MessageTable extends Table {
  @override
  String get tableName => "message";

  late final id = integer().autoIncrement()();
  late final messageText = text()();
  late final role = textEnum<MessageTableMessageRole>()();
  late final createdAt = dateTime().withDefault(currentDateAndTime)();
  late final trainingId = integer().references(TrainingTable, #id)();
}

@DataClassName("FeedbackDbModel")
class FeedbackTable extends Table {
  @override
  String get tableName => "feedback";

  late final id = integer().autoIncrement()();
  late final feedbackText = text()();
  late final createdAt = dateTime().withDefault(currentDateAndTime)();
  late final trainingId = integer().references(TrainingTable, #id).unique()();
}

@DriftDatabase(tables: [TrainingTable, MessageTable, FeedbackTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: _dbName,
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.createTable(schema.message);
      },
      from2To3: (m, schema) async {
        await m.createTable(schema.feedback);
      },
    ),
  );

  Future<void> deleteDb() async {
    await close();

    final directory = await getApplicationSupportDirectory();
    final dbPath = p.join(directory.path, '$_dbName.sqlite');

    final dbFile = File(dbPath);

    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    final walFile = File('$dbPath-wal');
    if (await walFile.exists()) {
      await walFile.delete();
    }

    final shmFile = File('$dbPath-shm');
    if (await shmFile.exists()) {
      await shmFile.delete();
    }

    final journalFile = File('$dbPath-journal');
    if (await journalFile.exists()) {
      await journalFile.delete();
    }
  }
}
