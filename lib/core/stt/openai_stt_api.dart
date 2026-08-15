import 'dart:async';
import 'dart:io';

import 'package:dialog_feedback/core/errors/action_executor.dart';
import 'package:dialog_feedback/core/errors/app_failure.dart';
import 'package:dialog_feedback/core/errors/result.dart';
import 'package:dialog_feedback/core/key_value_storage/secure_key_value_store.dart';
import 'package:dialog_feedback/core/stt/stt_api.dart';
import 'package:dialog_feedback/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';

FutureOr<void> disposeOpenaiSttApi(SttApi instance) {
  if (instance is OpenaiSttApi) {
    instance.dispose();
  }
}

@Singleton(as: SttApi, dispose: disposeOpenaiSttApi)
class OpenaiSttApi with ActionExecutor implements SttApi {
  final SecureKeyValueStore _store;

  OpenaiSttApi(this._store);

  static const String _endpoint =
      'https://api.openai.com/v1/audio/transcriptions';

  final dio = Dio();

  String key() => _store.openaiApiKey.get().trim();

  @override
  Future<Result<SttResult>> transcribe(
    File audioFile, {
    String? language,
  }) async {
    return execute(() async {
      final apiKey = key();
      if (apiKey.isEmpty) {
        glog.e('OpenAI API key is empty for STT');
        return Failure(NetworkFailure());
      }

      final fileName = basename(audioFile.path);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: fileName,
        ),
        'model': 'gpt-transcribe',
        if (language != null && language.isNotEmpty)
          'languages': [language],
        'response_format': 'verbose_json',
      });

      final response = await dio.post(
        _endpoint,
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );

      final data = response.data;
      if (data case {'text': final String text}) {
        final durationSeconds = (data['duration'] as num?)?.toDouble() ?? 0.0;
        final duration = Duration(
          microseconds: (durationSeconds * 1000000).round(),
        );

        return Success(
          SttResult(
            text: text.trim(),
            duration: duration,
          ),
        );
      }

      glog.e('Unexpected STT response format: $data');
      return Failure(NetworkFailure());
    }, createDefault: (_) => Failure(NetworkFailure()));
  }

  void dispose() {
    dio.close();
  }
}
