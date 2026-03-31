class ParentAuthUserModel {
  final String id;
  final String role;

  const ParentAuthUserModel({
    required this.id,
    required this.role,
  });

  factory ParentAuthUserModel.fromMap(Map<String, dynamic> map) {
    return ParentAuthUserModel(
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
