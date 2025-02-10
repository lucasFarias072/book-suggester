class Author {
  final int? id;
  final String name;
  

  Author({
    this.id,
    required this.name,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory Author.fromMap(Map<String, dynamic> map) {
    return Author(
      id: map['id'],
      name: map['name'],
    );
  }

}