class Pair<T, E> {
  final T first;
  final E second;

  const Pair({required this.first, required this.second});

  @override
  String toString() => "first = $first, second = $second";
}
