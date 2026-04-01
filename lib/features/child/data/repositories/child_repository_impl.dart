import 'package:safini/features/child/domain/models/child_model.dart';
import 'package:safini/features/child/domain/repositories/i_child_repository.dart';

class ChildRepositoryImpl implements IChildRepository {
  @override
  Future<List<ChildModel>> fetchChildren() async {
    return const [
      ChildModel(id: 'child_1', name: 'Child One'),
      ChildModel(id: 'child_2', name: 'Child Two'),
    ];
  }
}
