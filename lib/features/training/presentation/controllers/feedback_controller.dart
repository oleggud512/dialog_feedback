import 'package:dialog_feedback/app/errors/app_failure.dart';
import 'package:dialog_feedback/app/errors/result.dart';
import 'package:dialog_feedback/core/signal_registry/signal_registry.dart';
import 'package:dialog_feedback/features/training/domain/entities/messages_aggregate.dart';
import 'package:dialog_feedback/features/training/domain/entities/training_feedback.dart';
import 'package:dialog_feedback/features/training/domain/usecase/feedback_interactor.dart';
import 'package:dialog_feedback/features/training/domain/usecase/training_interactor.dart';
import 'package:injectable/injectable.dart';
import 'package:signals/signals_hooks.dart';

enum FeedbackLoadingState { loading, generating }

@injectable
class FeedbackController extends SignalRegistry {
  final FeedbackInteractor _interactor;
  final TrainingInteractor _trainingInteractor;

  FeedbackController(this._interactor, this._trainingInteractor);

  late final loading = track(signal(false));

  late final aggregate = track(signal<MessagesAggregate?>(null));
  late final error = track(signal<AppFailure?>(null));

  late final feedback = track(signal<TrainingFeedback?>(null));
  late final isFeedbackGenerating = track(signal(false));
  late final feedbackError = track(signal<AppFailure?>(null));

  void loadFeedback(int trainingId) async {
    if (loading.value) return;

    batch(() {
      loading.value = true;
      isFeedbackGenerating.value = false;
    });

    final aggregateRes = await _trainingInteractor.getMessages(trainingId);

    switch (aggregateRes) {
      case Success(:final value):
        aggregate.value = value;
        break;
      case Failure(:final failure):
        error.value = failure;
        break;
    }

    final feedbackRes = await _interactor.getFeedback(trainingId);

    if (feedbackRes case Success(:final value)) {
      batch(() {
        loading.value == false;
        feedback.value = value;
      });
      return;
    }

    isFeedbackGenerating.value = true;

    final genFeedbackRes = await _interactor.generateFeedback(trainingId);

    batch(() {
      switch (genFeedbackRes) {
        case Success(:final value):
          feedback.value = value;
          break;
        case Failure(:final failure):
          feedbackError.value = failure;
          break;
      }
      loading.value = false;
    });
  }
}
