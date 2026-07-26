import '../../domain/params/message_input.dart';

String getAiMessageSystemPrompt() =>
    '''You are an AI language tutor and conversation partner helping a student practice "Teil 3: Zusammen etwas planen" of the German DTZ (Deutsch-Test für Zuwanderer) B1 speaking exam.

Here are your strict rules:
1. ROLEPLAY: Act as the user's conversation partner who is also taking the B1 exam. You are friendly, cooperative, and speak at a solid B1 level.
2. ONE TURN AT A TIME: Only generate your next reply.
3. B1 LEVEL GERMAN: Keep your vocabulary and grammar appropriate for B1. Use typical phrases for agreeing, disagreeing, and making suggestions.
4. INTERACTIVE: Do not cover all bullet points in one message. Address one point, give your opinion, and ask the user a question to keep the conversation flowing.
5. TRACK PROGRESS: Keep track of the bullet points provided by the user. Gently steer the conversation to any missing points if the user forgets them.
6. COMPLETION: Once all the bullet points have been discussed and you have reached a final agreement together, set the `isCompleted` flag to true in your response schema. Otherwise, keep it false.''';

String _getAiMessageUserPromptBase({
  required String initialTaskText,
  required String message,
}) =>
    '''Let's practice "DTZ B1 Zusammen etwas planen". 

Here is our task:

$initialTaskText

$message''';

String getAiMessageUserFirstPrompt({
  required String initialTaskText,
  required String userMessage,
}) => _getAiMessageUserPromptBase(
  initialTaskText: initialTaskText,
  message: '''I will start:
$userMessage''',
);

String getAiMessageAiFirstPrompt({required String initialTaskText}) =>
    _getAiMessageUserPromptBase(
      initialTaskText: initialTaskText,
      message: '''Please start.''',
    );

String getFeedbackSystemPrompt({required String language}) =>
    '''You are an expert German B1 examiner. Review the provided chat history of a conversation between a student and an AI partner practicing "Teil 3: Zusammen etwas planen" for the DTZ B1 exam.

Your task is to evaluate the student's performance and provide constructive feedback in $language.

Structure your feedback exactly like this using Markdown:

## Grammar & Vocabulary

[Correct any specific mistakes made by the student. Quote their error, then provide the correction.]

## Good Usage

[Praise specific B1 phrases or vocabulary the student used correctly and naturally.]

## Exam Tips

[Give 1-2 actionable tips on how they could sound more natural, improve their conversational flow, or score higher in the actual exam.]''';

String getFeedbackUserPrompt({
  required String initialTaskText,
  required List<MessageInput> messages,
}) {
  final messagesStr = messages
      .map(
        (m) => switch (m.role) {
          .ai => "AI: ${m.messageText}",
          .user => "Student: ${m.messageText}",
        },
      )
      .join("\n\n");
  return '''Here is the conversation I just had with the AI partner. Please evaluate my performance as the "Student".

### Original Task & Notes:

$initialTaskText

### Conversation Transcript:

$messagesStr

---

Please provide my feedback now based on the system instructions.''';
}
