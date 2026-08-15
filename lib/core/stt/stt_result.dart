import 'package:freezed_annotation/freezed_annotation.dart';

part 'stt_result.freezed.dart';

@freezed
sealed class SttResult with _$SttResult {
  const factory SttResult({
    required String text,
    required Duration duration,
  }) = _SttResult;

  const SttResult._();
}
