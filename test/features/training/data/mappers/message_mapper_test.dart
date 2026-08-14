import 'package:dialog_feedback/core/database/database.dart';
import 'package:dialog_feedback/features/training/data/mappers/message_mapper.dart';
import 'package:dialog_feedback/features/training/domain/entities/message_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageMapper', () {
    test(
      'MessageDbModelMapper.toDomain correctly maps MessageDbModel to Message',
      () {
        final createdAt = DateTime(2026, 1, 1);
        final model = MessageDbModel(
          id: 10,
          messageText: 'Hello world',
          role: MessageTableMessageRole.user,
          createdAt: createdAt,
          trainingId: 5,
          audioPath: 'some/path',
        );

        final domain = model.toDomain();

        expect(domain.id, 10);
        expect(domain.messageText, 'Hello world');
        expect(domain.role, MessageRole.user);
        expect(domain.createdAt, createdAt);
        expect(domain.trainingId, 5);
        expect(domain.audioPath, 'some/path');
      },
    );

    test('MessageTableMessageRoleMapper maps roles correctly to domain', () {
      expect(MessageTableMessageRole.ai.toDomain(), MessageRole.ai);
      expect(MessageTableMessageRole.user.toDomain(), MessageRole.user);
    });

    test('MessageRoleMapper maps domain roles correctly to data', () {
      expect(MessageRole.ai.toData(), MessageTableMessageRole.ai);
      expect(MessageRole.user.toData(), MessageTableMessageRole.user);
    });
  });
}
