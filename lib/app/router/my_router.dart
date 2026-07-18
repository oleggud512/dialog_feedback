import 'package:dialog_feedback/app/app.dart';
import 'package:dialog_feedback/features/features.dart';
import 'package:go_router/go_router.dart';

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
        path: AppUri.root.training.id().path,
        builder: (context, state) {
          final idStr = state.pathParameters[AppUri.root.training.id.paramName];
          final id = int.parse(idStr ?? "");
          return TrainingScreen(trainingId: id);
        },
      ),
    ],
  );
}
