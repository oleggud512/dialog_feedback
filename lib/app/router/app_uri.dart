import 'package:go_router_uri/go_router_uri.dart';

class AppUri extends RootSubPath {
  AppUri._() {
    register(LeafSubPath.new);
  }

  static final root = AppUri._();

  late final setup = leafRoute('setup');
}
