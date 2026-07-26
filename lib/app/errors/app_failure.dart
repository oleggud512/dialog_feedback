sealed class AppFailure implements Exception {}

class UnknownFailure extends AppFailure {}

class NotFoundFailure extends AppFailure {}

class DatabaseFailure extends AppFailure {}

class GenerationFailure extends AppFailure {}
