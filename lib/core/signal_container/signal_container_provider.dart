part of 'signal_container.dart';

class SignalContainerProvider<T extends SignalContainer> extends Provider<T> {
  SignalContainerProvider({
    super.key,
    required super.create,
    super.child,
    super.lazy,
    super.builder,
  }) : super(dispose: (_, container) => container.dispose());
}
