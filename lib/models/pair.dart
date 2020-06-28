class Pair<T1, T2> {
  T1 first;
  T2 second;

  Pair(this.first, this.second);

  @override
  bool operator ==(Object other) {
    if (other is Pair<T1, T2>) {
      return (other.first == first) && (other.second == second);
    }
    return false;
  }

  @override
  int get hashCode => first.hashCode ^ second.hashCode;
}
