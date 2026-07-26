import 'message_input.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_feedback.freezed.dart';
part 'get_feedback.g.dart';

@freezed
sealed class GetFeedback with _$GetFeedback {
  const factory GetFeedback({
    required String initialTaskText,
    required List<MessageInput> messages,
  }) = _GetFeedback;

  const GetFeedback._();

  factory GetFeedback.fromJson(Map<String, dynamic> json) =>
      _$GetFeedbackFromJson(json);
}
