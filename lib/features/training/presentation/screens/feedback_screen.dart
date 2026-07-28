import 'package:dialog_feedback/core/signal_registry/signal_registry.dart';
import 'package:dialog_feedback/di.dart';
import 'package:dialog_feedback/features/training/presentation/controllers/feedback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key, required this.trainingId});

  final int trainingId;

  @override
  Widget build(BuildContext context) {
    return SignalRegistryProvider(
      create: (_) => sl<FeedbackController>()..loadFeedback(trainingId),
      child: _FeedbackScreenContent(),
    );
  }
}

class _FeedbackScreenContent extends StatelessWidget {
  const _FeedbackScreenContent();

  @override
  Widget build(BuildContext context) {
    final feedbackController = context.watch<FeedbackController>();
    return Scaffold(
      appBar: AppBar(title: Text("Feedback")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: .stretch,
          mainAxisSize: .min,
          children: [
            SignalBuilder(
              builder: (context) {
                return Text(feedbackController.aggregate.value.toString());
              },
            ),
            SignalBuilder(
              builder: (context) {
                return MarkdownBody(
                  data: (feedbackController.feedback.value?.feedbackText)
                      .toString(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
