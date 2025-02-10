class CustomCategory {
  final int id;
  final String name;

  CustomCategory({required this.id, required this.name});

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
      other is CustomCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
