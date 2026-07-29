import 'package:dialog_feedback/app/errors/app_failure.dart';
import 'package:dialog_feedback/core/extensions/dev.dart';
import 'package:dialog_feedback/core/signal_registry/signal_registry.dart';
import 'package:dialog_feedback/di.dart';
import 'package:dialog_feedback/features/training/domain/entities/message.dart';
import 'package:dialog_feedback/features/training/domain/entities/message_role.dart';
import 'package:dialog_feedback/features/training/domain/entities/messages_aggregate.dart';
import 'package:dialog_feedback/features/training/presentation/controllers/feedback_controller.dart';
import 'package:dialog_feedback/features/training/presentation/widgets/message_widget.dart';
import 'package:dialog_feedback/shared/domain/entities/training.dart';
import 'package:dialog_feedback/shared/presentation/widgets/app_failure_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
                final error = feedbackController.error.value;
                final aggregate = feedbackController.aggregate.value;

                if (aggregate == null && error == null) {
                  return Skeletonizer(
                    enabled: true,
                    child: _MessagesAggregateWidget(
                      aggregate: fakeMessagesAggregate,
                    ),
                  );
                }

                if (error != null) {
                  return Stack(
                    children: [
                      FadeTransition(
                        opacity: AlwaysStoppedAnimation(0),
                        child: _MessagesAggregateWidget(
                          aggregate: fakeMessagesAggregate,
                        ),
                      ),
                      Positioned.fill(child: AppFailureWidget(failure: error)),
                    ],
                  );
                }

                if (aggregate != null) {
                  return _MessagesAggregateWidget(aggregate: aggregate);
                }

                return AppFailureWidget(failure: UnknownFailure());
              },
            ),
            Padding(
              padding: .all(16),
              child: SignalBuilder(
                builder: (context) {
                  final loading = feedbackController.loading.value;
                  final feedback = feedbackController.feedback.value;
                  final error = feedbackController.feedbackError.value;
                  final generating =
                      feedbackController.isFeedbackGenerating.value;
                  if (loading || generating) {
                    return Stack(
                      children: [
                        Skeletonizer(
                          enabled: true,
                          child: MarkdownBody(data: fakeFeedback),
                        ),
                        if (generating)
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                "Generating Feedback...".hc,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge,
                              ),
                            ),
                          ),
                      ],
                    );
                  }

                  if (error != null) {
                    return Stack(
                      children: [
                        FadeTransition(
                          opacity: AlwaysStoppedAnimation(0),
                          child: MarkdownBody(data: fakeFeedback),
                        ),
                        Positioned.fill(
                          child: AppFailureWidget(failure: error),
                        ),
                      ],
                    );
                  }

                  if (feedback != null) {
                    return MarkdownBody(data: feedback.feedbackText);
                  }

                  return AppFailureWidget(failure: UnknownFailure());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesAggregateWidget extends StatelessWidget {
  const _MessagesAggregateWidget({required this.aggregate});

  final MessagesAggregate aggregate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      mainAxisSize: .min,
      children: [
        Container(
          color: Theme.of(context).colorScheme.surfaceContainer.hc,
          padding: .all(16),
          child: Text(aggregate.training.initialTaskText),
        ),
        ...aggregate.messages.map(
          (message) => MessageWidget(
            key: ValueKey(message.id),
            message: message,
            autoPlay: false,
          ),
        ),
      ],
    );
  }
}

final fakeTraining = Training(
  id: 0,
  initialTaskText:
      "Sie möchten Deutsch lernen und suchen nach einem Privatlehrer. Schreiben Sie mit Ihrem Partner über die Möglichkeiten.",
  isChatCompleted: true,
  createdAt: DateTime(2026, 1, 1),
);

final fakeMessages = [
  Message(
    id: 1,
    messageText:
        "Hallo! Ich suche einen Deutschlehrer für die Tochter meiner Bekannte. Weißt du, wo den Lehrer gefunden werden kann?",
    role: MessageRole.user,
    createdAt: DateTime(2026, 1, 1, 10, 0),
    trainingId: 0,
    audioPath: "",
  ),
  Message(
    id: 2,
    messageText:
        "Hallo! Es gibt verschiedene Online-Plattformen und Foren, wo man Nachhilfelehrer finden kann. Suchst du Präsenz- oder Online-Unterricht?",
    role: MessageRole.ai,
    createdAt: DateTime(2026, 1, 1, 10, 1),
    trainingId: 0,
    audioPath: "",
  ),
  Message(
    id: 3,
    messageText:
        "Ist dafür E-Mail benutzt oder im Brief müssen wir den Preis nachfragen, wenn der Lehrer zu Besuch kommt? Wie findest du?",
    role: MessageRole.user,
    createdAt: DateTime(2026, 1, 1, 10, 2),
    trainingId: 0,
    audioPath: "",
  ),
  Message(
    id: 4,
    messageText:
        "Normalerweise schreibt man zuerst eine E-Mail oder Nachricht auf der Plattform, um nach den Preisen und Terminen zu fragen. Oft bieten Lehrer auch Probestunden an.",
    role: MessageRole.ai,
    createdAt: DateTime(2026, 1, 1, 10, 3),
    trainingId: 0,
    audioPath: "",
  ),
  Message(
    id: 5,
    messageText:
        "Das klingt gut! Das richte ich der Bekannte gleich aus. Vielen Dank für deine Hilfe!",
    role: MessageRole.user,
    createdAt: DateTime(2026, 1, 1, 10, 4),
    trainingId: 0,
    audioPath: "",
  ),
];

final fakeMessagesAggregate = MessagesAggregate(
  training: fakeTraining,
  messages: fakeMessages,
);

const fakeFeedback = '''## Grammar & Vocabulary

- "Die Tochter meiner Bekannte..." -> Correction: "Die Tochter meiner Bekannten..." (Genitive case. 'Die Bekannte' is an adjectival noun, so it takes an 'n' here).
- "...wo den Lehrer gefunden werden kann?" -> Correction: "...wo man einen Lehrer finden kann?" (It is much better to use active voice with 'man' instead of the passive. If using passive, it must be nominative: 'der Lehrer').
- "Ist dafür E-Mail benutzt..." -> Correction: "Wird dafür eine E-Mail benutzt..." or more naturally: "Benutzt man dafür E-Mails?".
- "Im Brief müssen wir..." -> Correction: "In der E-Mail müssen wir..." ('Brief' specifically means a physical paper letter, which doesn't fit an online search).
- "...den Preis nachfragen..." -> Correction: "...nach dem Preis fragen...".
- "...wenn der Lehrer zu Besuch kommt." -> Correction: "...wenn der Lehrer nach Hause kommt." ('Zu Besuch kommen' implies a casual social visit from a friend, not a professional service).
- "Wie findest du?" -> Correction: "Was meinst du?", "Was denkst du?", or "Wie findest du das?".
- "...richte ich der Bekannte gleich aus." -> Correction: "...richte ich der Bekannten gleich aus." (Dative case).

## Good Usage

- Excellent use of subordinate clauses: "...finde ich eine tolle Idee, weil es sehr einfach ist." and "Aber ich kann mir vorstellen, dass..."
- Great use of indirect questions, which shows strong B1 mastery: "Ich wollte dich fragen, wie man den Kontakt..."
- You used highly natural conversational questions to keep the dialogue flowing: "Findest du nicht?" and "Das klingt gut."
- Great B1 vocabulary: "ausreichend", "ausrichten", "stattfinden".

## Exam Tips

- **Use 'man' instead of Passive:** In spoken B1 German, active sentences using 'man' sound much more natural than passive constructions. Instead of trying to build a passive sentence like 'wo der Lehrer gefunden werden kann', use 'wo man einen Lehrer finden kann'. It minimizes grammatical errors and sounds more authentic.
- **React to Specific Details:** To score higher on interactive communication, react explicitly to the examples your partner gives. When the AI suggested Tuesday and Thursday afternoons for tutoring, you could have built on it by saying, "Ja, Dienstag und Donnerstag passen gut, da hat sie keine Hobbys." This shows you are actively listening and expanding the roleplay.''';
