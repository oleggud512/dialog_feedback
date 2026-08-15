import 'package:dialog_feedback/core/errors/app_failure.dart';
import 'package:dialog_feedback/core/extensions/dev.dart';
import 'package:dialog_feedback/core/navigation/app_uri.dart';
import 'package:dialog_feedback/core/signal_registry/signal_registry.dart';
import 'package:dialog_feedback/di.dart';
import 'package:dialog_feedback/features/training/presentation/controllers/training_controller.dart';
import 'package:dialog_feedback/shared/presentation/extensions/app_failure.dart';
import 'package:dialog_feedback/shared/presentation/widgets/app_failure_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key, required this.trainingId});

  final int trainingId;

  @override
  Widget build(BuildContext context) {
    return SignalRegistryProvider(
      create: (_) => sl<TrainingController>()..loadTraining(trainingId),
      child: const _TrainingScreenContent(),
    );
  }
}

class _TrainingScreenContent extends StatelessWidget {
  const _TrainingScreenContent();

  @override
  Widget build(BuildContext context) {
    final trainingController = context.watch<TrainingController>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Training".hc),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer.hc,
      ),
      body: Column(
        crossAxisAlignment: .stretch,
        children: [
          // Top Initial Task Header
          Container(
            color: Theme.of(context).colorScheme.surfaceContainer.hc,
            padding: .all(16),
            child: SignalBuilder(
              builder: (context) {
                final loading = trainingController.loading.value;
                if (loading) {
                  return Center(child: CircularProgressIndicator());
                }

                final error = trainingController.error.value;
                if (error != null) {
                  return AppFailureWidget(failure: error);
                }

                final taskText =
                    trainingController.training.value?.initialTaskText;
                if (taskText == null) {
                  return AppFailureWidget(failure: UnknownFailure());
                }

                return SelectableText(taskText);
              },
            ),
          ),

          // Main Center Area (Replacing Chat List)
          Expanded(
            child: SignalBuilder(
              builder: (context) {
                final loading = trainingController.loading.value;
                if (loading) {
                  return const SizedBox.shrink();
                }

                final messages = trainingController.messages.value;
                final isCompleted =
                    trainingController.training.value?.isChatCompleted == true;

                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: .all(24.0),
                      child: Column(
                        mainAxisAlignment: .center,
                        children: [
                          Icon(
                            Icons.record_voice_over,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Ready to begin training".hc,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () {
                              trainingController.letAiStart();
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: Text("Let AI start".hc),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final isRecording = trainingController.isRecording.value;
                final isPlayingAiAudio =
                    trainingController.isPlayingAiAudio.value;
                final isTranscribing = trainingController.isTranscribing.value;
                final isMessageLoading =
                    trainingController.isMessageLoading.value;
                final showLastAiResponse =
                    trainingController.showLastAiResponse.value;
                final lastAiMessage = trainingController.lastAiMessage.value;

                return SingleChildScrollView(
                  padding: .all(20),
                  child: Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      // Voice State Status Box
                      Card.outlined(
                        child: Padding(
                          padding: .all(20),
                          child: Column(
                            children: [
                              if (isPlayingAiAudio) ...[
                                Icon(
                                  Icons.volume_up_rounded,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "AI is speaking...".hc,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ] else if (isTranscribing) ...[
                                const CircularProgressIndicator(),
                                const SizedBox(height: 12),
                                Text(
                                  "Transcribing your voice...".hc,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ] else if (isMessageLoading) ...[
                                const CircularProgressIndicator(),
                                const SizedBox(height: 12),
                                Text(
                                  "AI is thinking...".hc,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ] else if (isRecording) ...[
                                const Icon(
                                  Icons.mic,
                                  size: 48,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Listening... Speak now".hc,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ] else if (isCompleted) ...[
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 48,
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Conversation completed".hc,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ] else ...[
                                const Icon(
                                  Icons.mic_none,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Waiting...".hc,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Toggleable Last AI Response Section
                      if (lastAiMessage != null) ...[
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              "Last AI Response".hc,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                trainingController.toggleShowLastAiResponse();
                              },
                              icon: Icon(
                                showLastAiResponse
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                              ),
                              label: Text(
                                showLastAiResponse ? "Hide".hc : "Show".hc,
                              ),
                            ),
                          ],
                        ),
                        if (showLastAiResponse) ...[
                          const SizedBox(height: 8),
                          Card.filled(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: .start,
                                children: [
                                  SelectableText(
                                    lastAiMessage.messageText,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  if (lastAiMessage.audioPath.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: .centerRight,
                                      child: TextButton.icon(
                                        onPressed: isPlayingAiAudio
                                            ? null
                                            : () {
                                                trainingController
                                                    .replayLastAiAudio();
                                              },
                                        icon: const Icon(
                                          Icons.replay,
                                          size: 18,
                                        ),
                                        label: Text("Replay Audio".hc),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Error Display Area
          SignalBuilder(
            builder: (context) {
              final messageError = trainingController.loadingMessageError.value;
              if (messageError == null) return const SizedBox.shrink();

              final hasPendingRetry =
                  trainingController.hasPendingRetry.value;

              return Container(
                color: Theme.of(context).colorScheme.errorContainer,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        messageError.localize(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    if (hasPendingRetry) ...[
                      TextButton(
                        onPressed: () => trainingController.retry(),
                        child: Text(
                          "Retry".hc,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => trainingController.resetError(),
                        child: Text(
                          "Discard".hc,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ] else ...[
                      TextButton(
                        onPressed: () => trainingController.resetError(),
                        child: Text(
                          "Dismiss".hc,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          // Bottom Action Bar
          Container(
            color: Theme.of(context).colorScheme.surfaceContainer.hc,
            padding: .fromLTRB(16, 12, 16, 16),
            child: SignalBuilder(
              builder: (context) {
                final isCompleted =
                    trainingController.training.value?.isChatCompleted == true;

                if (isCompleted) {
                  return FilledButton(
                    onPressed: () {
                      final id = trainingController.training.value?.id;
                      if (id == null) return;
                      context.push(AppUri.root.feedback.id(id.toString()).path);
                    },
                    child: Text("Generate Feedback".hc),
                  );
                }

                final messages = trainingController.messages.value;
                if (messages.isEmpty) {
                  return const SizedBox.shrink();
                }

                final isSendEnabled = trainingController.isSendEnabled.value;

                return FilledButton.icon(
                  onPressed: isSendEnabled
                      ? () => trainingController.sendVoiceInput()
                      : null,
                  icon: const Icon(Icons.send),
                  label: Text("Send Response".hc),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
