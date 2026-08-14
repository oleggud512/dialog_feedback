import 'package:dialog_feedback/core/database/database.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_role.dart';

extension MessageDbModelMapper on MessageDbModel {
  Message toDomain() => Message(
    id: id,
    messageText: messageText,
    role: role.toDomain(),
    createdAt: createdAt,
    trainingId: trainingId,
    audioPath: audioPath,
  );
}

extension MessageTableMessageRoleMapper on MessageTableMessageRole {
  MessageRole toDomain() => switch (this) {
    MessageTableMessageRole.ai => MessageRole.ai,
    MessageTableMessageRole.user => MessageRole.user,
  };
}

extension MessageRoleMapper on MessageRole {
  MessageTableMessageRole toData() => switch (this) {
    MessageRole.ai => MessageTableMessageRole.ai,
    MessageRole.user => MessageTableMessageRole.user,
  };
}
