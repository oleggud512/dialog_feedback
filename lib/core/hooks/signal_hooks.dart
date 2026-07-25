import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals.dart';

TextEditingController useSignalTextEditingController(
  ReadonlySignal<String> signal,
) {
  final controller = useTextEditingController(text: signal.peek());

  useEffect(() {
    final unbind = effect(() {
      final val = signal.value;
      if (controller.text != val) {
        final selection = controller.selection;

        controller.value = TextEditingValue(
          text: val,
          selection: TextSelection(
            baseOffset: selection.baseOffset.clamp(0, val.length),
            extentOffset: selection.extentOffset.clamp(0, val.length),
          ),
        );
      }
    });
    return unbind;
  }, [signal, controller]);

  return controller;
}
