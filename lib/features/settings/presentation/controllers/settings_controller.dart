import 'package:dialog_feedback/app/key_value_storage/secure_key_value_store.dart';
import 'package:dialog_feedback/core/signal_registry/signal_registry.dart';
import 'package:dialog_feedback/core/signals/key_value_signal.dart';
import 'package:injectable/injectable.dart';

@injectable
class SettingsController extends SignalRegistry {
  final SecureKeyValueStore _store;

  SettingsController(this._store);

  late final apiKey = track(_store.apiKey.toSignal());

  void setApiKey(String newApiKey) {
    apiKey.value = newApiKey;
  }
}
