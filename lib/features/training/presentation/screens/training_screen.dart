import 'package:dialog_feedback/core/extensions/dev.dart';
import 'package:flutter/material.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key, required this.trainingId});

  final int trainingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Training $trainingId".hc)));
  }
}
