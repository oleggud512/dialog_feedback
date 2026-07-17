import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals.dart';

part 'signal_container_provider.dart';

abstract class SignalContainer {
  final List<void Function()> _cleanups = [];

  T track<T extends ReadonlySignal>(T signalInstance) {
    _cleanups.add(signalInstance.dispose);
    return signalInstance;
  }

  void trackEffect(void Function() effectCleanup) {
    _cleanups.add(effectCleanup);
  }

  @mustCallSuper
  void dispose() {
    for (final cleanup in _cleanups) {
      cleanup();
    }
    _cleanups.clear();
  }
}
