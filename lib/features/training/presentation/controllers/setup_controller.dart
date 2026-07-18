import 'package:dialog_feedback/core/core.dart';
import 'package:dialog_feedback/features/features.dart';
import 'package:injectable/injectable.dart';

@injectable
class SetupController extends SignalRegistry {
  final TrainingRepository _trainingRepository;

  SetupController(this._trainingRepository);

  Future<void> startTraining(String initialTaskText) async {
    print(initialTaskText);
  }
}
