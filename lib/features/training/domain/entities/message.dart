import 'message_role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

@freezed
sealed class Message with _$Message {
  const factory Message({
    required int id,
    required String messageText,
    required MessageRole role,
    required DateTime createdAt,
    required int trainingId,
  }) = _Message;

  const Message._();
}

@freezed
sealed class CreateMessageParams with _$CreateMessageParams {
  const factory CreateMessageParams({
    required String messageText,
    required MessageRole role,
    required int trainingId,
  }) = _CreateMessageParams;

  const CreateMessageParams._();
}
