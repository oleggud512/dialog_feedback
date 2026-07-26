import 'package:dialog_feedback/app/database/database.dart';
import 'package:dialog_feedback/app/errors/action_executor.dart';
import 'package:dialog_feedback/app/errors/app_failure.dart';
import 'package:dialog_feedback/app/errors/result.dart';
import 'package:dialog_feedback/shared/domain/entities/training.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_role.dart';
import '../../domain/entities/messages_aggregate.dart';
import '../../domain/repositories/message_repository.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

Training _toDomain(TrainingDbModel model) => Training(
  id: model.id,
  initialTaskText: model.initialTaskText,
  isChatCompleted: model.isChatCompleted,
  createdAt: model.createdAt,
);

Message _messageToDomain(MessageDbModel model) => Message(
  id: model.id,
  messageText: model.messageText,
  role: switch (model.role) {
    .ai => MessageRole.ai,
    .user => MessageRole.user,
  },
  createdAt: model.createdAt,
  trainingId: model.trainingId,
);

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

      return Success(_messageToDomain(res));
    }, createDefault: (_) => Failure(DatabaseFailure()));
  }

  @override
  Future<Result<Message>> createMessage(CreateMessageParams params) {
    return execute(() async {
      final res = await db
          .into(db.messageTable)
          .insert(
            MessageTableCompanion.insert(
              messageText: params.messageText,
              role: switch (params.role) {
                .ai => MessageTableMessageRole.ai,
                .user => MessageTableMessageRole.user,
              },
              trainingId: params.trainingId,
            ),
          );
      return getMessage(res);
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
      final training = _toDomain(trainingDbModel);

      final messages = rows
          .map((row) {
            final messageDbModel = row.readTableOrNull(db.messageTable);
            if (messageDbModel == null) return null;
            return _messageToDomain(messageDbModel);
          })
          .whereType<Message>()
          .toList();

      return Success(MessagesAggregate(training: training, messages: messages));
    }, createDefault: (_) => Failure(DatabaseFailure()));
  }
}
