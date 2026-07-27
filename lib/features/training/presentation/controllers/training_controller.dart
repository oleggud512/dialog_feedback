import 'package:dialog_feedback/app/errors/app_failure.dart';
import 'package:dialog_feedback/app/errors/result.dart';
import 'package:dialog_feedback/core/signal_registry/signal_registry.dart';
import 'package:dialog_feedback/features/training/domain/entities/message.dart';
import 'package:dialog_feedback/features/training/domain/entities/message_role.dart';
import 'package:dialog_feedback/features/training/domain/entities/messages_aggregate.dart';
import 'package:dialog_feedback/features/training/domain/params/add_message.dart';
import 'package:dialog_feedback/features/training/domain/usecase/training_interactor.dart';
import 'package:dialog_feedback/shared/domain/entities/training.dart';
import 'package:injectable/injectable.dart';
import 'package:signals/signals.dart';

@injectable
class TrainingController extends SignalRegistry {
  final TrainingInteractor _interactor;

  TrainingController(this._interactor);

  late final _aggregate = track(signal<MessagesAggregate?>(null));

  late final loading = track(signal<bool>(false));
  late final error = track(signal<AppFailure?>(null));

  late final loadingMessage = track(trackedSignal<Message?>(null));
  late final loadingMessageError = track(trackedSignal<AppFailure?>(null));

  late final training = track(
    computed<Training?>(() => _aggregate.value?.training),
  );

  late final messages = track(computed(_computeMessages));

  List<Message> _computeMessages() {
    final currentAggr = _aggregate.value;
    if (currentAggr == null) return [];

    final currentLoadingMes = loadingMessage.value;
    if (currentLoadingMes == null) return currentAggr.messages;

    return [...currentAggr.messages, currentLoadingMes];
  }

  void loadTraining(int trainingId) async {
    if (loading.value) return;

    batch(() {
      loading.value = true;
      error.value = null;
    });

    final messagesAggregateRes = await _interactor.getMessages(trainingId);

    batch(() {
      switch (messagesAggregateRes) {
        case Success(value: final messagesAggregate):
          _aggregate.value = messagesAggregate;
          break;
        case Failure(:final failure):
          error.value = failure;
          break;
      }

      loading.value = false;
    });
  }

  void addMessage(String messageText) async {
    final currentAggr = _aggregate.value;
    if (currentAggr == null || loadingMessage.value != null) return;

    final tempMessage = Message(
      id: -1,
      messageText: messageText,
      role: MessageRole.user,
      createdAt: DateTime.now(),
      trainingId: currentAggr.training.id,
    );

    batch(() {
      loadingMessage.value = tempMessage;
      loadingMessageError.value = null;
    });

    final answerPairRes = await _interactor.addMessage(
      AddMessageParams(
        trainingId: currentAggr.training.id,
        messageText: messageText,
      ),
    );

    switch (answerPairRes) {
      case Success(value: final answerPair):
        batch(() {
          _aggregate.value = currentAggr.copyWith(
            training: currentAggr.training.copyWith(
              isChatCompleted:
                  currentAggr.training.isChatCompleted ||
                  answerPair.isCompleted,
            ),
            messages: [
              ...currentAggr.messages,
              answerPair.question,
              answerPair.answer,
            ],
          );
          loadingMessage.value = null;
        });
        break;
      case Failure(:final failure):
        loadingMessageError.value = failure;
        break;
    }
  }

  void resetError() {
    batch(() {
      loadingMessage.value = null;
      loadingMessageError.value = null;
    });
  }
}
