// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:schemantic/schemantic.dart';

part 'message_result.freezed.dart';
part 'message_result.g.dart';

@freezed
sealed class MessageResult with _$MessageResult {
  @JsonSerializable(createJsonSchema: true)
  const factory MessageResult({
    required String messageText,
    required bool isCompleted,
  }) = _MessageResult;

  const MessageResult._();

  factory MessageResult.fromJson(Map<String, dynamic> json) =>
      _$MessageResultFromJson(json);

  static final $schema = SchemanticType.from(
    jsonSchema: _$_MessageResultJsonSchema,
    parse: (json) => MessageResult.fromJson(json),
  );
}
