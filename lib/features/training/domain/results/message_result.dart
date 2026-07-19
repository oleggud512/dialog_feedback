import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_result.freezed.dart';
part 'message_result.g.dart';

@freezed
sealed class MessageResult with _$MessageResult {
  const factory MessageResult({
    required String messageText,
    required bool isCompleted,
  }) = _MessageResult;

  const MessageResult._();

  factory MessageResult.fromJson(Map<String, dynamic> json) =>
      _$MessageResultFromJson(json);
}
