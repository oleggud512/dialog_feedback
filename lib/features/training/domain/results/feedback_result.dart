import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_result.freezed.dart';
part 'feedback_result.g.dart';

@freezed
sealed class FeedbackResult with _$FeedbackResult {
  const factory FeedbackResult({required String content}) = _FeedbackResult;

  const FeedbackResult._();

  factory FeedbackResult.fromJson(Map<String, dynamic> json) =>
      _$FeedbackResultFromJson(json);
}
