import 'package:dialog_feedback/app/app.dart';
import 'package:dialog_feedback/core/core.dart';
import 'package:dialog_feedback/di.dart';
import 'package:dialog_feedback/features/features.dart';
import 'package:dialog_feedback/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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

  final List<Training> trainings;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: .all(16),
      itemCount: trainings.length,
      separatorBuilder: (_, _) => SizedBox(height: 16),
      itemBuilder: (context, i) {
        final training = trainings[i];

        return _TrainingListWidget(
          key: ValueKey(training.id),
          training: training,
        );
      },
    );
  }
}

class _TrainingListWidget extends StatelessWidget {
  const _TrainingListWidget({super.key, required this.training});

  final Training training;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: .all(0),
      child: Padding(
        padding: .all(16),
        child: Column(
          crossAxisAlignment: .stretch,
          mainAxisSize: .min,
          spacing: 8,
          children: [
            Text(training.initialTaskText),
            Align(alignment: .centerEnd, child: Text(training.id.toString())),
          ],
        ),
      ),
    );
  }
}
