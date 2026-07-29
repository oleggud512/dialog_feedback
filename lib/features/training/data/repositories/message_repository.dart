import 'package:dialog_feedback/app/database/database.dart';
import 'package:dialog_feedback/app/errors/action_executor.dart';
import 'package:dialog_feedback/app/errors/app_failure.dart';
import 'package:dialog_feedback/app/errors/result.dart';
import 'package:dialog_feedback/features/training/domain/entities/answer_pair.dart';
import 'package:dialog_feedback/shared/data/mappers/training_mapper.dart';
import '../mappers/message_mapper.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/messages_aggregate.dart';
import '../../domain/repositories/message_repository.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: MessageRepository)
class MessageRepositoryImpl with ActionExecutor implements MessageRepository {
  final AppDatabase db;

  MessageRepositoryImpl(this.db);

  Future<Result<Message>> getMessage(int messageId) {
    return execute(() async {
      final query = db.select(db.messageTable)
        ..where((tbl) => tbl.id.equals(messageId));

      final res = await query.getSingleOrNull();

      if (res == null) {
        return Failure(NotFoundFailure());
      }

      return Success(res.toDomain());
    }, createDefault: (_) => Failure(DatabaseFailure()));
  }

  @override
  Future<Result<Message>> createMessage(CreateMessageParams params) {
    return execute(() async {
      final row = await db
          .into(db.messageTable)
          .insertReturning(
            MessageTableCompanion.insert(
              messageText: params.messageText,
              role: params.role.toData(),
              trainingId: params.trainingId,
              audioPath: Value(params.audioPath),
            ),
          );
      return Success(row.toDomain());
    }, createDefault: (_) => Failure(DatabaseFailure()));
  }

  @override
  Future<Result<MessagesAggregate>> getMessages(int trainingId) {
    return execute(() async {
      final query = db.select(db.trainingTable).join([
        leftOuterJoin(
          db.messageTable,
          db.messageTable.trainingId.equalsExp(db.trainingTable.id),
        ),
      ])..where(db.trainingTable.id.equals(trainingId));

      final rows = await query.get();

      if (rows.isEmpty) {
        return Failure(NotFoundFailure());
      }

      final trainingDbModel = rows.first.readTable(db.trainingTable);
      final training = trainingDbModel.toDomain();

      final messages = rows
          .map((row) => row.readTableOrNull(db.messageTable)?.toDomain())
          .whereType<Message>()
          .toList();

      return Success(MessagesAggregate(training: training, messages: messages));
    }, createDefault: (_) => Failure(DatabaseFailure()));
  }

  @override
  Future<Result<AnswerPair>> createAnswerPair({
    required CreateMessageParams userParams,
    required CreateMessageParams aiParams,
    required bool isCompleted,
  }) {
    return execute(() async {
      return db.transaction(() async {
        final userRow = await db
            .into(db.messageTable)
            .insertReturning(
              MessageTableCompanion.insert(
                messageText: userParams.messageText,
                role: userParams.role.toData(),
                trainingId: userParams.trainingId,
                audioPath: Value(userParams.audioPath),
              ),
            );

        final aiRow = await db
            .into(db.messageTable)
            .insertReturning(
              MessageTableCompanion.insert(
                messageText: aiParams.messageText,
                role: aiParams.role.toData(),
                trainingId: aiParams.trainingId,
                audioPath: Value(aiParams.audioPath),
              ),
            );

        if (isCompleted) {
          await (db.update(
            db.trainingTable,
          )..where((tbl) => tbl.id.equals(userParams.trainingId))).write(
            const TrainingTableCompanion(isChatCompleted: Value(true)),
          );
        }

        return Success(
          AnswerPair(
            question: userRow.toDomain(),
            answer: aiRow.toDomain(),
            isCompleted: isCompleted,
          ),
        );
      });
    }, createDefault: (_) => Failure(DatabaseFailure()));
  }
}
