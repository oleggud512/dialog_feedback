import 'package:dialog_feedback/features/features.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

@freezed
sealed class Message with _$Message {
  const factory Message({
    required int id,
    required String messageText,
    required MessageRole role,
  }) = _Message;

  const Message._();
}
