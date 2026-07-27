import 'package:dialog_feedback/features/training/domain/entities/message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'answer_pair.freezed.dart';

@freezed
sealed class AnswerPair with _$AnswerPair {
  const factory AnswerPair({
    required Message question,
    required Message answer,
    required bool isCompleted,
  }) = _AnswerPair;

  const AnswerPair._();
}
