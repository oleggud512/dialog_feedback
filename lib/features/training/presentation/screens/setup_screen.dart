import 'package:dialog_feedback/core/errors/result.dart';
import 'package:dialog_feedback/core/navigation/app_uri.dart';
import 'package:dialog_feedback/core/extensions/dev.dart';
import 'package:dialog_feedback/core/signal_registry/signal_registry.dart';
import 'package:dialog_feedback/di.dart';
import '../controllers/setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_hooks.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalRegistryProvider(
      create: (_) => sl<SetupController>(),
      child: _SetupScreenContent(),
    );
  }
}

class _SetupScreenContent extends HookWidget {
  const _SetupScreenContent();

  @override
  Widget build(BuildContext context) {
    final setupController = context.watch<SetupController>();

    final cont = useTextEditingController();

    useSignalEffect(() {
      if (setupController.isLoading.value == false &&
          setupController.training.value is Success &&
          setupController.training.previousValue is! Success) {
        final id = setupController.training.value!.valueOrNull!.id;
        context.push(AppUri.root.training.id(id.toString()).path);

        cont.clear();
        setupController.reset();
      }
    }, keys: [setupController.isLoading, setupController.training]);

    return Scaffold(
      appBar: AppBar(
        title: Text("Setup Training".hc),
        leading: IconButton(
          onPressed: () {
            context.push(AppUri.root.settings.path);
          },
          color: Theme.of(context).primaryColor.hc,
          icon: Icon(Icons.settings),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.push(AppUri.root.history.path);
            },
            label: Text("History".hc),
            icon: Icon(Icons.history_edu_rounded),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ConstrainedBox(
              constraints: .new(minHeight: 200),
              child: Padding(
                padding: .all(16),
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: .stretch,
                  children: [
                    Flexible(
                      fit: .tight,
                      child: TextField(
                        controller: cont,
                        maxLines: null,
                        minLines: null,
                        textAlignVertical: .top,
                        scrollPhysics: NeverScrollableScrollPhysics(),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        context.read<SetupController>().startTraining(
                          cont.text,
                        );
                      },
                      label: Text("Start Training".hc),
                      iconAlignment: .end,
                      icon: SignalBuilder(
                        builder: (context) {
                          if (setupController.isLoading.value == false) {
                            return Icon(Icons.arrow_forward);
                          }
                          return SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white.hc,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
