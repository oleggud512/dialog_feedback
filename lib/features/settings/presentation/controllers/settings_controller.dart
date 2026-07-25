import 'package:dialog_feedback/app/app.dart';
import 'package:dialog_feedback/core/core.dart';
import 'package:injectable/injectable.dart';

@injectable
class SettingsController extends SignalRegistry {
  final SecureKeyValueStore _store;

  SettingsController(this._store);

  late final apiKey = track(_store.apiKey.toSignal());

  void setApiKey(String newApiKey) {
    final sanitized = newApiKey.trim();
    apiKey.value = sanitized;
  }
}
