import 'package:dialog_feedback/core/core.dart';
import 'package:dialog_feedback/di.dart';
import 'package:dialog_feedback/features/features.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalRegistryProvider(
      create: (_) => sl<HistoryController>(),
      child: _HistoryScreenContent(),
    );
  }
}

class _HistoryScreenContent extends StatelessWidget {
  const _HistoryScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Training History".hc)));
  }
}
