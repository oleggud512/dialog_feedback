import 'package:dialog_feedback/app/app.dart';
import 'package:dialog_feedback/features/features.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: MessageRepository)
class MessageRepositoryImpl implements MessageRepository {
  final AppDatabase db;

  MessageRepositoryImpl(this.db);

  @override
  Future<Result<Message>> createMessage(CreateMessageParams params) {
    // TODO: implement createMessage
    throw UnimplementedError();
  }

  @override
  Future<Result<MessagesAggregate>> getMessages(int trainingId) {
    // TODO: implement getMessages
    throw UnimplementedError();
  }
}
