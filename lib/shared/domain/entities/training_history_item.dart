import 'package:freezed_annotation/freezed_annotation.dart';
import 'training.dart';

part 'training_history_item.freezed.dart';

@freezed
sealed class TrainingHistoryItem with _$TrainingHistoryItem {
  const factory TrainingHistoryItem({
    required Training training,
    required bool hasFeedback,
  }) = _TrainingHistoryItem;

  const TrainingHistoryItem._();
}
