// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:schemantic/schemantic.dart';

part 'feedback_result.freezed.dart';
part 'feedback_result.g.dart';

@freezed
sealed class FeedbackResult with _$FeedbackResult {
  @JsonSerializable(createJsonSchema: true)
  const factory FeedbackResult({required String content}) = _FeedbackResult;

  const FeedbackResult._();

  factory FeedbackResult.fromJson(Map<String, dynamic> json) =>
      _$FeedbackResultFromJson(json);

  static final $schema = SchemanticType.from(
    jsonSchema: _$_FeedbackResultJsonSchema,
    parse: (json) => FeedbackResult.fromJson(json as Map<String, dynamic>),
  );
}
