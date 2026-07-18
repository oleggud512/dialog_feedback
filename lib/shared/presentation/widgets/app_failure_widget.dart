import 'package:dialog_feedback/app/app.dart';
import 'package:dialog_feedback/core/core.dart';
import 'package:dialog_feedback/shared/shared.dart';
import 'package:flutter/material.dart';

class AppFailureWidget extends StatelessWidget {
  const AppFailureWidget({super.key, required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: .min,
        spacing: 16,
        children: [
          Icon(Icons.error_outline, color: Colors.red.hc),
          Text(failure.localize()),
        ],
      ),
    );
  }
}
