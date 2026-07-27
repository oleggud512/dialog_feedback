import 'package:dialog_feedback/core/extensions/dev.dart';
import 'package:dialog_feedback/core/signal_registry/signal_registry.dart';
import 'package:dialog_feedback/di.dart';
import 'package:dialog_feedback/features/training/presentation/controllers/training_controller.dart';
import 'package:flutter/material.dart';

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

class _TrainingScreenContent extends StatelessWidget {
  const _TrainingScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Training".hc)));
  }
}
