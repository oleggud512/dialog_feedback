import 'dart:async';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:signals/signals_flutter.dart';

class KeyValueSignal<T> extends FlutterSignal<T> {
  final KeyValueEntity<T> entity;
  StreamSubscription<T>? _subscription;

  KeyValueSignal(this.entity) : super(entity.get()) {
    _subscription = entity.watch().listen((newValue) {
      if (super.value != newValue) {
        super.value = newValue;
      }
    });

    onDispose(() {
      _subscription?.cancel();
    });
  }

  @override
  set value(T newValue) {
    if (super.value == newValue) return;
    super.value = newValue;
    entity.set(newValue);
  }
}

extension KeyValueEntitySignalX<T> on KeyValueEntity<T> {
  KeyValueSignal<T> toSignal() => KeyValueSignal<T>(this);
}
