import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safini/features/parent/data/dto/parent_user_dto.dart';
import 'package:safini/features/parent/domain/models/parent_user_model.dart';

class ParentRemoteDataSource {
  final SupabaseClient _supabase;

  ParentRemoteDataSource(this._supabase);

  Future<ParentUserModel> getUser(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .single();

      return ParentUserDto.fromJson(response).toDomain();
    } catch (e) {
      rethrow;
    }
  }
}
