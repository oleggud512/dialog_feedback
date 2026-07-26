import 'package:dialog_feedback/core/utils/logger.dart';
import 'result.dart';

mixin ActionExecutor {
  Future<Result<T>> execute<T>(
    Future<Result<T>> Function() action, {
    required Result<T> Function(Object error) createDefault,
    Result<T>? Function(
      Object error,
      void Function(String message) logAsSevere,
    )?
    onError,
  }) async {
    final callerTrace = StackTrace.current;

    try {
      return await action();
    } catch (e, st) {
      void triggerSevereLog(String message) {
        glog.e(
          "$message\n--- Caller Trace ---\n$callerTrace",
          error: e,
          stackTrace: st,
        );
      }

      if (onError != null) {
        final customResult = onError(e, triggerSevereLog);
        if (customResult != null) {
          return customResult;
        }
      }

      triggerSevereLog("Action Execution Failure");
      return createDefault(e);
    }
  }
}
