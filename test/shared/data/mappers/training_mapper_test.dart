import 'package:dialog_feedback/core/database/database.dart';
import 'package:dialog_feedback/shared/data/mappers/training_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'TrainingDbModelMapper.toDomain correctly maps TrainingDbModel to Training',
    () {
      final createdAt = DateTime(2026, 1, 1);
      final model = TrainingDbModel(
        id: 42,
        initialTaskText: 'Learn Dart',
        isChatCompleted: true,
        createdAt: createdAt,
      );

      final domain = model.toDomain();

      expect(domain.id, 42);
      expect(domain.initialTaskText, 'Learn Dart');
      expect(domain.isChatCompleted, true);
      expect(domain.createdAt, createdAt);
    },
  );
}
