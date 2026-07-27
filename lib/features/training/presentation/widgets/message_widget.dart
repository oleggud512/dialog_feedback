import 'package:dialog_feedback/features/training/domain/entities/message.dart';
import 'package:dialog_feedback/features/training/domain/entities/message_role.dart';
import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: switch (message.role) {
        MessageRole.user => Theme.of(context).colorScheme.primaryFixedDim,
        MessageRole.ai => Colors.transparent,
      },
      child: FractionallySizedBox(
        widthFactor: 0.7,
        alignment: switch (message.role) {
          MessageRole.user => .centerRight,
          MessageRole.ai => .centerLeft,
        },
        child: Padding(
          padding: .all(8.0),
          child: Column(
            spacing: 4,
            mainAxisSize: .min,
            crossAxisAlignment: switch (message.role) {
              MessageRole.user => .start,
              MessageRole.ai => .end,
            },
            children: [
              Text(message.messageText),
              Text(
                message.createdAt.toIso8601String(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
