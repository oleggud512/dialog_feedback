import 'package:dialog_feedback/app/app.dart';

sealed class Result<S> {
  S? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };
}

class Success<S> extends Result<S> {
  final S value;
  Success(this.value);

  @override
  String toString() => "$runtimeType($value)";
}

class Failure<S> extends Result<S> {
  final AppFailure failure;
  Failure(this.failure);

  @override
  String toString() => "$runtimeType($failure)";
}
