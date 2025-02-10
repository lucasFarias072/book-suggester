class UserModel {
  final int? id;
  final String nickname;
  final String email;
  final String password;

  UserModel({
    this.id,
    required this.nickname,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        id: map['id'],
        nickname: map['nickname'],
        email: map['email'],
        password: map['password']);
  }
}
