import 'package:go_router_uri/go_router_uri.dart';

class AppUri extends RootSubPath {
  AppUri._() {
    register(LeafSubPath.new);
    register(TrainingSubPath.new);
    register(FeedbackSubPath.new);
  }

  static final root = AppUri._();

  late final setup = leafRoute('setup');

  late final history = leafRoute('history');

  late final settings = leafRoute('settings');

  late final training = route<TrainingSubPath>('training');

  late final feedback = route<FeedbackSubPath>('feedback');
}

class TrainingSubPath extends AppSubPath<TrainingSubPath> {
  TrainingSubPath(super.parent);

  late final id = leafParam('id');
}

class FeedbackSubPath extends AppSubPath<FeedbackSubPath> {
  FeedbackSubPath(super.parent);

  late final id = leafParam('id');
}
