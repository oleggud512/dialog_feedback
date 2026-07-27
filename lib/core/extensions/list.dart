extension ListExtensions<T> on List<T> {
  T reversedAt(int index) => this[length - 1 - index];
}
