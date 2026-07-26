import 'package:dialog_feedback/app/errors/action_executor.dart';
import 'package:dialog_feedback/app/errors/app_failure.dart';
import 'package:dialog_feedback/app/errors/result.dart';
import 'package:dialog_feedback/app/key_value_storage/secure_key_value_store.dart';
import '../../domain/params/get_ai_message.dart';
import '../../domain/repositories/training_prompts_repository.dart';
import '../../domain/results/feedback_result.dart';
import '../../domain/results/message_result.dart';
import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:injectable/injectable.dart';
import 'training_prompts.dart';

@Singleton(as: TrainingPromptsRepository)
class TrainingPromptsRepositoryImpl
    with ActionExecutor
    implements TrainingPromptsRepository {
  late final Genkit ai;

  TrainingPromptsRepositoryImpl(SecureKeyValueStore store) {
    ai = Genkit(plugins: [googleAI(apiKey: store.apiKey.get().trim())]);
  }

  List<Message> buildGetAiMessageMessages(GetAiMessageParams params) {
    if (params.messages.isEmpty) {
      return [
        Message(
          role: .user,
          content: [
            TextPart(
              text: getAiMessageAiFirstPrompt(
                initialTaskText: params.initialTaskText,
              ),
            ),
          ],
        ),
      ];
    }

    final contents = <Message>[];

    final messages = [...params.messages];

    final firstMessage = messages.removeAt(0);

    switch (firstMessage.role) {
      case .ai:
        contents.addAll([
          Message(
            role: .user,
            content: [
              TextPart(
                text: getAiMessageAiFirstPrompt(
                  initialTaskText: params.initialTaskText,
                ),
              ),
            ],
          ),
          Message(
            role: .model,
            content: [TextPart(text: firstMessage.messageText)],
          ),
        ]);
        break;
      case .user:
        contents.add(
          Message(
            role: .user,
            content: [
              TextPart(
                text: getAiMessageUserFirstPrompt(
                  initialTaskText: params.initialTaskText,
                  userMessage: firstMessage.messageText,
                ),
              ),
            ],
          ),
        );
        break;
    }

    for (final m in messages) {
      final part = TextPart(text: m.messageText);
      contents.add(switch (m.role) {
        .ai => Message(role: .model, content: [part]),
        .user => Message(role: .user, content: [part]),
      });
    }

    return contents;
  }

  @override
  Future<Result<MessageResult>> getAiMessage(GetAiMessageParams params) async {
    return execute(() async {
      final response = await ai.generate(
        model: googleAI.gemini("gemini-3.5-flash"),
        outputSchema: MessageResult.$schema,
        system: getAiMessageSystemPrompt(),
        messages: buildGetAiMessageMessages(params),
      );
      final output = response.output;

      if (output == null) {
        return Failure(GenerationFailure());
      }

      return Success(output);
    }, createDefault: (e) => Failure(GenerationFailure()));
  }

  @override
  Future<Result<FeedbackResult>> getFeedback(GetAiMessageParams params) async {
    return execute(() async {
      final response = await ai.generate(
        model: googleAI.gemini("gemini-3.1-pro-preview"),
        outputSchema: FeedbackResult.$schema,
        // TODO: Add language selection
        system: getFeedbackSystemPrompt(language: "English"),
        prompt: getFeedbackUserPrompt(
          initialTaskText: params.initialTaskText,
          messages: params.messages,
        ),
      );
      final output = response.output;

      if (output == null) {
        return Failure(GenerationFailure());
      }

      return Success(output);
    }, createDefault: (e) => Failure(GenerationFailure()));
  }
}
