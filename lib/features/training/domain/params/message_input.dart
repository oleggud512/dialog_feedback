import '../entities/message.dart';
import '../entities/message_role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_input.freezed.dart';
part 'message_input.g.dart';

@freezed
sealed class MessageInput with _$MessageInput {
  const factory MessageInput({
    required String messageText,
    required MessageRole role,
  }) = _MessageInput;

  const MessageInput._();

  factory MessageInput.fromJson(Map<String, dynamic> json) =>
      _$MessageInputFromJson(json);
}

extension MessageToInput on Message {
  MessageInput toInput() => MessageInput(messageText: messageText, role: role);
}
