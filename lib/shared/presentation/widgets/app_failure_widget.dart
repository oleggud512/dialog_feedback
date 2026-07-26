import 'package:dialog_feedback/app/errors/app_failure.dart';
import 'package:dialog_feedback/core/extensions/dev.dart';
import 'package:flutter/material.dart';
import '../extensions/app_failure.dart';

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
