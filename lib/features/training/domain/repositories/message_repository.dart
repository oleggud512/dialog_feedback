import 'package:dialog_feedback/app/errors/result.dart';
import '../entities/answer_pair.dart';
import '../entities/message.dart';
import '../entities/messages_aggregate.dart';

abstract interface class MessageRepository {
  Future<Result<MessagesAggregate>> getMessages(int trainingId);
  Future<Result<Message>> createMessage(CreateMessageParams params);
  Future<Result<AnswerPair>> createAnswerPair({
    required CreateMessageParams userParams,
    required CreateMessageParams aiParams,
    required bool isCompleted,
  });
}
