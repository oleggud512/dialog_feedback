import 'package:freezed_annotation/freezed_annotation.dart';

part 'training.freezed.dart';

@freezed
sealed class Training with _$Training {
  const factory Training({
    required int id,
    required String initialTaskText,
    required bool isChatCompleted,
    required DateTime createdAt,
  }) = _Training;

  const Training._();
}

@freezed
sealed class CreateTrainingParams with _$CreateTrainingParams {
  const factory CreateTrainingParams({required String initialTaskText}) =
      _CreateTrainingParams;

  const CreateTrainingParams._();
}
