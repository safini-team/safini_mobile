import 'package:safini/features/child/domain/models/child_model.dart';

class ChildDto {
  final String id;
  final String name;

  const ChildDto({
    required this.id,
    required this.name,
  });

  factory ChildDto.fromJson(Map<String, dynamic> json) {
    return ChildDto(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  ChildModel toDomain() {
    return ChildModel(id: id, name: name);
  }
}
