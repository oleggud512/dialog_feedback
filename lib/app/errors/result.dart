import 'package:dialog_feedback/app/app.dart';

sealed class Result<S> {}

class Success<S> extends Result<S> {
  final S value;
  Success(this.value);

  @override
  String toString() => "$runtimeType($value)";
}

class Failure<S> extends Result<S> {
  final AppFailure error;
  Failure(this.error);

  @override
  String toString() => "$runtimeType($error)";
}
