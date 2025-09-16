class UserModel {
  int? id;
  String name;
  String email;
  String password; // Empty for Google sign-in

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.password = "", // Default empty
  });

  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    password: json['password'] ?? "", // fallback for Google sign-in
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
  };

  /// 🔹 Add copyWith so we can update specific fields
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
