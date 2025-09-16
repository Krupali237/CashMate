class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  // ✅ Convert UserModel to Map (for SQLite insert)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // ✅ Convert Map from SQLite to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
    );
  }

}

