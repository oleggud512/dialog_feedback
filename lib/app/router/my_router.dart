import 'package:dialog_feedback/features/history/presentation/screens/history_screen.dart';
import 'package:dialog_feedback/features/settings/presentation/screens/settings_screen.dart';
import 'package:dialog_feedback/features/training/presentation/screens/feedback_screen.dart';
import 'package:dialog_feedback/features/training/presentation/screens/setup_screen.dart';
import 'package:dialog_feedback/features/training/presentation/screens/training_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:dialog_feedback/core/navigation/app_uri.dart';

class MyRouter {
  const MyRouter._();

  static final router = _createRouter();

  static GoRouter _createRouter() => GoRouter(
    initialLocation: AppUri.root.setup.path,
    routes: [
      GoRoute(
        path: AppUri.root.setup.path,
        builder: (context, state) => SetupScreen(),
      ),
      GoRoute(
        path: AppUri.root.history.path,
        builder: (context, state) => HistoryScreen(),
      ),
      GoRoute(
        path: AppUri.root.settings.path,
        builder: (context, state) => SettingsScreen(),
      ),
      GoRoute(
        path: AppUri.root.training.id().path,
        builder: (context, state) {
          final idStr = state.pathParameters[AppUri.root.training.id.paramName];
          final id = int.parse(idStr ?? "");
          return TrainingScreen(trainingId: id);
        },
      ),
      GoRoute(
        path: AppUri.root.feedback.id().path,
        builder: (context, state) {
          final idStr = state.pathParameters[AppUri.root.feedback.id.paramName];
          final id = int.parse(idStr ?? "");
          return FeedbackScreen(trainingId: id);
        },
      ),
    ],
  );
}
