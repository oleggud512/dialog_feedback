import 'package:dialog_feedback/app/errors/result.dart';
import 'package:dialog_feedback/core/signal_registry/signal_registry.dart';
import 'package:dialog_feedback/shared/domain/entities/training.dart';
import 'package:dialog_feedback/shared/domain/repositories/training_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:signals/signals_flutter.dart';

@injectable
class HistoryController extends SignalRegistry {
  final TrainingRepository _repo;

  HistoryController(this._repo);

  late final isLoading = track(trackedSignal(false));
  late final trainings = track(trackedSignal<Result<List<Training>>?>(null));

  Future<void> loadTrainings() async {
    isLoading.value = true;

    final result = await _repo.getTrainings();

    batch(() {
      isLoading.value = false;
      trainings.value = result;
    });
  }
}
