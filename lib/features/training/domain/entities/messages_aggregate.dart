import 'package:dialog_feedback/shared/domain/entities/training.dart';
import 'message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'messages_aggregate.freezed.dart';

@freezed
sealed class MessagesAggregate with _$MessagesAggregate {
  const factory MessagesAggregate({
    required Training training,
    required List<Message> messages,
  }) = _MessagesAggregate;

  const MessagesAggregate._();
}
