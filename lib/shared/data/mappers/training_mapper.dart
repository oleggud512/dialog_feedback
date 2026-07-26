import 'package:dialog_feedback/app/database/database.dart';
import 'package:dialog_feedback/shared/domain/entities/training.dart';

extension TrainingDbModelMapper on TrainingDbModel {
  Training toDomain() => Training(
    id: id,
    initialTaskText: initialTaskText,
    isChatCompleted: isChatCompleted,
    createdAt: createdAt,
  );
}
