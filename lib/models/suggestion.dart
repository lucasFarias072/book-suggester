class Suggestion {
  int? id;
  String nickname;
  String authorName;
  String bookTitle;
  String opinion;
  int categoryId;

  Suggestion(
      {this.id,
      required this.nickname,
      required this.authorName,
      required this.bookTitle,
      required this.opinion,
      required this.categoryId});

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'author_name': authorName,
      'book_title': bookTitle,
      'opinion': opinion,
      'category_id': categoryId
    };
  }

  factory Suggestion.fromMap(Map<String, dynamic> map) {
    return Suggestion(
        id: map['id'],
        nickname: map['nickname'],
        authorName: map['author_name'],
        bookTitle: map['book_title'],
        opinion: map['opinion'],
        categoryId: map['category_id']);
  }
}
