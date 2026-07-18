import 'package:dialog_feedback/app/app.dart';
import 'package:dialog_feedback/core/core.dart';

mixin DbErrorHandler {
  Future<Result<T>> runDb<T>(Future<Result<T>> Function() action) async {
    final callerTrace = StackTrace.current;

    try {
      return await action();
    } catch (e, st) {
      glog.e(
        "Database Execution Failure\n--- DB Trace ---\n$st\n--- Caller Trace ---\n$callerTrace",
        error: e,
      );
      return Failure(DatabaseFailure());
    }
  }
}
