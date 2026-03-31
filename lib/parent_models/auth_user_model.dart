class AuthUserModel {
  final String id;
  final String role;

  const AuthUserModel({
    required this.id,
    required this.role,
  });

  factory AuthUserModel.fromMap(Map<String, dynamic> map) {
    return AuthUserModel(
      id: map['id'] as String,
      role: map['role'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
    };
  }
}
