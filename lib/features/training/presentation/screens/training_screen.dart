import 'package:dialog_feedback/app/errors/app_failure.dart';
import 'package:dialog_feedback/app/router/app_uri.dart';
import 'package:dialog_feedback/core/extensions/dev.dart';
import 'package:dialog_feedback/core/extensions/list.dart';
import 'package:dialog_feedback/core/signal_registry/signal_registry.dart';
import 'package:dialog_feedback/di.dart';
import 'package:dialog_feedback/features/training/presentation/controllers/training_controller.dart';
import 'package:dialog_feedback/features/training/presentation/widgets/message_widget.dart';
import 'package:dialog_feedback/shared/presentation/extensions/app_failure.dart';
import 'package:dialog_feedback/shared/presentation/widgets/app_failure_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_hooks.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key, required this.trainingId});

  final int trainingId;

  @override
  Widget build(BuildContext context) {
    return SignalRegistryProvider(
      create: (_) => sl<TrainingController>()..loadTraining(trainingId),
      child: _TrainingScreenContent(),
    );
  }
}

class _TrainingScreenContent extends HookWidget {
  const _TrainingScreenContent();

  @override
  Widget build(BuildContext context) {
    final trainingController = context.watch<TrainingController>();

    final inputCont = useTextEditingController();

    void addMessage() {
      final trimmed = inputCont.text.trim();
      if (trimmed.isNotEmpty) {
        trainingController.addMessage(trimmed);
        inputCont.clear();
      }
    }

    useSignalEffect(() {
      final curMes = trainingController.loadingMessage.value;
      final prevMes = trainingController.loadingMessage.previousValue;
      final curErr = trainingController.loadingMessageError.value;
      final prevErr = trainingController.loadingMessageError.previousValue;

      if (prevMes != null &&
          curMes == null &&
          prevErr != null &&
          curErr == null &&
          inputCont.text.isEmpty) {
        inputCont.text = prevMes.messageText;
      }
    }, keys: [trainingController]);

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

                return Text(taskText);
              },
            ),
          ),
          Expanded(
            child: SignalBuilder(
              builder: (context) {
                final messages = trainingController.messages.value;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final message = messages.reversedAt(i);

                    return MessageWidget(
                      key: ValueKey(message.id),
                      message: message,
                    );
                  },
                );
              },
            ),
          ),
          SignalBuilder(
            builder: (context) {
              final isMessageLoading =
                  trainingController.isMessageLoading.value;
              final messageError = trainingController.loadingMessageError.value;

              return Column(
                crossAxisAlignment: .stretch,
                mainAxisSize: .min,
                children: [
                  if (messageError != null)
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      crossAxisAlignment: .end,
                      spacing: 4,
                      children: [
                        Text(
                          messageError.localize(),
                          style: TextStyle(color: Colors.red.hc),
                        ),
                        InkWell(
                          onTap: () {
                            trainingController.resetError();
                          },
                          child: Text("Reset".hc),
                        ),
                      ],
                    ),
                  isMessageLoading
                      ? LinearProgressIndicator(minHeight: 4)
                      : SizedBox(height: 4),
                ],
              );
            },
          ),
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
                    child: Text("Generate Feedback"),
                  );
                }

                final isMessageInProgress =
                    trainingController.loadingMessage.value != null;

                return Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: inputCont,
                        maxLines: null,
                        minLines: null,
                        expands: false,
                        onSubmitted: isMessageInProgress
                            ? null
                            : (_) {
                                addMessage();
                              },
                        enabled: !isMessageInProgress,
                        decoration: InputDecoration(
                          hintText: "Enter a message...".hc,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: isMessageInProgress
                          ? null
                          : () {
                              addMessage();
                            },
                      icon: Icon(Icons.send),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
