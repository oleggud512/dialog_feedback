import 'package:dialog_feedback/core/key_value_storage/secure_key_value_store.dart';
import 'package:dialog_feedback/core/signal_registry/signal_registry.dart';
import 'package:dialog_feedback/core/signals/key_value_signal.dart';
import 'package:injectable/injectable.dart';

@injectable
class SettingsController extends SignalRegistry {
  final SecureKeyValueStore _store;

  SettingsController(this._store);

  late final apiKey = track(_store.apiKey.toSignal());
  late final ttsApiKey = track(_store.ttsApiKey.toSignal());
  late final openaiApiKey = track(_store.openaiApiKey.toSignal());

  void setApiKey(String newApiKey) {
    apiKey.value = newApiKey;
  }

  void setTtsApiKey(String newApiKey) {
    ttsApiKey.value = newApiKey;
  }

  void setOpenaiApiKey(String newApiKey) {
    openaiApiKey.value = newApiKey;
  }
}
