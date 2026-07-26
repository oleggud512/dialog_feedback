import 'message_input.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_ai_message.freezed.dart';
part 'get_ai_message.g.dart';

@freezed
sealed class GetAiMessageParams with _$GetAiMessageParams {
  const factory GetAiMessageParams({
    required String initialTaskText,
    required List<MessageInput> messages,
  }) = _GetAiMessageParams;

  const GetAiMessageParams._();

  factory GetAiMessageParams.fromJson(Map<String, dynamic> json) =>
      _$GetAiMessageParamsFromJson(json);
}
