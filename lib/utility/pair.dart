class Pair<T, E> {
  const Pair({required this.first, required this.second});

  final T first;
  final E second;

  @override
  String toString() => "first = $first, second = $second";
}
