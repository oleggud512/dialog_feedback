part of 'signal_registry.dart';

class SignalRegistryProvider<T extends SignalRegistry> extends Provider<T> {
  SignalRegistryProvider({
    super.key,
    required super.create,
    super.child,
    super.lazy,
    super.builder,
  }) : super(dispose: (_, container) => container.dispose());
}
