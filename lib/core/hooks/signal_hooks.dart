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
        controller.text = val;
      }
    });
    return unbind;
  }, [signal, controller]);

  return controller;
}
