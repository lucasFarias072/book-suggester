class Book {
  final int? id;
  final String title;
  final int? categoryId; // Chave estrangeira p/ Category
  

  Book(
      {this.id,
      required this.title,
      required this.categoryId,
      });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category_id': categoryId
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
        id: map['id'],
        title: map['title'],
        categoryId: map['category_id']
      );
  }
}
