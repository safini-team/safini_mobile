import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/tab_freshness.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_app_usage_repository.dart';

/// Today's usage and rules for every child at once, for the "Everyone" views
/// on Today and Limits (SAF-269). One `app-usage` call per child, in
/// parallel; a child whose call failed is simply missing from the map.
class FamilyUsageCubit extends Cubit<Map<String, ChildAppUsageSnapshot>?> {
  FamilyUsageCubit(this._repo) : super(null);

  final IParentAppUsageRepository _repo;
  DateTime? _loadedAt;
  List<String> _loadedFor = const [];
  List<String>? _loading;
  int _generation = 0;

  /// Skips the refetch when the same children were loaded moments ago,
  /// unless [force] (pull-to-refresh, resume, a push).
  Future<void> load(List<String> childIds, {bool force = false}) async {
    if (!force &&
        ((isTabFresh(_loadedAt) && _sameChildren(childIds, _loadedFor)) ||
            (_loading != null && _sameChildren(childIds, _loading!)))) {
      return;
    }
    final generation = ++_generation;
    _loading = List.of(childIds);
    final results = await Future.wait(childIds.map(_repo.fetchAppUsage));
    if (isClosed || generation != _generation) return;
    _loading = null;
    final usage = <String, ChildAppUsageSnapshot>{};
    for (var i = 0; i < childIds.length; i++) {
      results[i].fold((_) {}, (snapshot) => usage[childIds[i]] = snapshot);
    }
    _loadedAt = DateTime.now();
    _loadedFor = List.of(childIds);
    emit(usage);
  }

  static bool _sameChildren(List<String> a, List<String> b) =>
      a.length == b.length && a.every(b.contains);
}
