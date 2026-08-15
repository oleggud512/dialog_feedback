sealed class AppFailure implements Exception {}

class UnknownFailure extends AppFailure {}

class NotFoundFailure extends AppFailure {}

class AlreadyExistsFailure extends AppFailure {}

class DatabaseFailure extends AppFailure {}

class GenerationFailure extends AppFailure {}

class NetworkFailure extends AppFailure {}

class PermissionDeniedFailure extends AppFailure {}

class RecordingFailure extends AppFailure {}

class NoActiveRecordingFailure extends RecordingFailure {}

class RecordingNotFoundFailure extends RecordingFailure {}
