import 'package:safini/features/child/domain/models/child_model.dart';

abstract class IChildRepository {
  Future<List<ChildModel>> fetchChildren();
}
