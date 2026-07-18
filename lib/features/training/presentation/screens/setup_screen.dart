import 'package:dialog_feedback/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SetupScreen extends HookWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cont = useTextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text("Setup Training".hc)),
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
                    FilledButton(
                      onPressed: () {
                        print(cont.text);
                      },
                      child: Text("Start Training".hc),
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
