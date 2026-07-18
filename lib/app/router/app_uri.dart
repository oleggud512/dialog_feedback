import 'package:go_router_uri/go_router_uri.dart';

class AppUri extends RootSubPath {
  AppUri._() {
    register(LeafSubPath.new);
    register(TrainingSubPath.new);
  }

  static final root = AppUri._();

  late final setup = leafRoute('setup');

  late final training = route<TrainingSubPath>('training');
}

class TrainingSubPath extends AppSubPath<TrainingSubPath> {
  TrainingSubPath(super.parent);

  late final id = leafParam('id');
}
