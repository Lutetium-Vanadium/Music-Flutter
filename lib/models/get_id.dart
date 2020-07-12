abstract class DbCollection {
  String get getId;

  bool needsUpdate(Map<String, dynamic> other);
}
