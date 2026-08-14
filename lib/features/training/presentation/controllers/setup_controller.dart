import 'package:dialog_feedback/core/errors/result.dart';
import 'package:dialog_feedback/core/signal_registry/signal_registry.dart';
import 'package:dialog_feedback/shared/domain/entities/training.dart';
import 'package:dialog_feedback/shared/domain/repositories/training_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:signals/signals.dart';

@injectable
class SetupController extends SignalRegistry {
  final TrainingRepository _trainingRepository;

  SetupController(this._trainingRepository);

  late final isLoading = track(trackedSignal(false));
  late final training = track(trackedSignal<Result<Training>?>(null));

  Future<void> startTraining(String initialTaskText) async {
    if (isLoading.value == true) return;

    isLoading.value = true;

    final createdTraining = await _trainingRepository.createTraining(
      CreateTrainingParams(initialTaskText: initialTaskText),
    );

    batch(() {
      isLoading.value = false;
      training.value = createdTraining;
    });
  }

  void reset() {
    batch(() {
      isLoading.value = false;
      training.value = null;
    });
  }
}
