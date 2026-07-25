import 'package:dialog_feedback/core/core.dart';
import 'package:dialog_feedback/di.dart';
import 'package:dialog_feedback/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends HookWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalRegistryProvider(
      create: (_) => sl<SettingsController>(),
      child: const _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends HookWidget {
  const _SettingsScreenContent();

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();

    final apiKeyCont = useSignalTextEditingController(
      settingsController.apiKey,
    );

    return Scaffold(
      appBar: AppBar(title: Text("App Settings".hc)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: apiKeyCont,
              decoration: InputDecoration(helperText: "API Key".hc),
              onChanged: (value) => settingsController.setApiKey(value),
            ),
          ],
        ),
      ),
    );
  }
}
