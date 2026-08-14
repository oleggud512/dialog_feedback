import 'package:dialog_feedback/app/errors/app_failure.dart';
import 'package:dialog_feedback/app/errors/result.dart';
import 'package:dialog_feedback/app/router/app_uri.dart';
import 'package:dialog_feedback/core/extensions/dev.dart';
import 'package:dialog_feedback/core/signal_registry/signal_registry.dart';
import 'package:dialog_feedback/di.dart';
import 'package:dialog_feedback/shared/domain/entities/training_history_item.dart';
import 'package:dialog_feedback/shared/presentation/widgets/app_failure_widget.dart';
import '../controllers/history_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalRegistryProvider(
      create: (_) => sl<HistoryController>()..loadTrainings(),
      child: _HistoryScreenContent(),
    );
  }
}

class _HistoryScreenContent extends StatelessWidget {
  const _HistoryScreenContent();

  @override
  Widget build(BuildContext context) {
    final historyController = context.watch<HistoryController>();

    return Scaffold(
      appBar: AppBar(title: Text("Training History".hc)),
      body: SignalBuilder(
        builder: (context) {
          final isLoading = historyController.isLoading.value;

          if (isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final trainings = historyController.trainings.value;

          return switch (trainings) {
            Success(:final value) => _HistoryList(trainings: value),
            Failure(:final failure) => AppFailureWidget(failure: failure),
            _ => AppFailureWidget(failure: NotFoundFailure()),
          };
        },
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.trainings});

  final List<TrainingHistoryItem> trainings;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: .all(16),
      itemCount: trainings.length,
      separatorBuilder: (_, _) => SizedBox(height: 16),
      itemBuilder: (context, i) {
        final item = trainings[i];

        return _TrainingListWidget(
          key: ValueKey(item.training.id),
          item: item,
        );
      },
    );
  }
}

class _TrainingListWidget extends StatelessWidget {
  const _TrainingListWidget({super.key, required this.item});

  final TrainingHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: .all(0),
      clipBehavior: .hardEdge,
      child: InkWell(
        onTap: () {
          final id = item.training.id.toString();
          if (item.hasFeedback) {
            context.push(AppUri.root.feedback.id(id).path);
          } else {
            context.push(AppUri.root.training.id(id).path);
          }
        },
        child: Padding(
          padding: .all(16),
          child: Column(
            crossAxisAlignment: .stretch,
            mainAxisSize: .min,
            spacing: 8,
            children: [
              Text(item.training.initialTaskText),
              Align(
                alignment: .centerEnd,
                child: Text(item.training.id.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
