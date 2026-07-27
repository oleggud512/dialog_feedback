import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_message.freezed.dart';

@freezed
sealed class AddMessageParams with _$AddMessageParams {
  const factory AddMessageParams({
    required int trainingId,
    required String messageText,
  }) = _AddMessageParams;

  const AddMessageParams._();
}
