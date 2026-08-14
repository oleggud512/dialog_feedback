import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dialog_feedback/core/errors/action_executor.dart';
import 'package:dialog_feedback/core/errors/app_failure.dart';
import 'package:dialog_feedback/core/errors/result.dart';
import 'package:dialog_feedback/core/key_value_storage/secure_key_value_store.dart';
import 'package:dialog_feedback/core/tts/tts_api.dart';
import 'package:dialog_feedback/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

FutureOr<void> disposeGoogleTtsApi(TtsApi instance) {
  if (instance is GoogleTtsApi) {
    instance.dispose();
  }
}

@Singleton(as: TtsApi, dispose: disposeGoogleTtsApi)
class GoogleTtsApi with ActionExecutor implements TtsApi {
  final SecureKeyValueStore _store;

  GoogleTtsApi(this._store);

  static const String _endpoint =
      'https://texttospeech.googleapis.com/v1/text:synthesize';

  final dio = Dio(BaseOptions(headers: {'Content-Type': 'application/json'}));

  String key() => _store.ttsApiKey.get().trim();

  @override
  Future<Result<File>> generate(String text) async {
    return execute(() async {
      final response = await dio.post(
        _endpoint,
        queryParameters: {'key': key()},
        data: {
          'input': {'text': text},
          'voice': {
            'languageCode': 'de-DE',
            'name': 'de-DE-Standard-G',
            'ssmlGender': 'FEMALE',
          },
          'audioConfig': {'audioEncoding': 'MP3'},
        },
      );

      final data = response.data;

      if (data case {'audioContent': final content}) {
        final bytes = base64Decode(content);
        final dir = await getApplicationDocumentsDirectory();
        final fileName = Uuid().v7();
        final savePath = join(dir.path, 'audios', '$fileName.mp3');
        final file = File(savePath);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes);
        return Success(file);
      }
      glog.e("Incorrect response format.\n$data");
      return Failure(NetworkFailure());
    }, createDefault: (_) => Failure(NetworkFailure()));
  }

  void dispose() {
    dio.close();
  }
}
