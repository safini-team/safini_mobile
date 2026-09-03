import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/parent/data/services/parent_app_blocking_service.dart';
import 'package:safini/features/parent/presentation/cubit/parent_installed_apps_state.dart';

/// Loads the apps installed on a child's device for the parent to browse.
///
/// The child device uploads its list (see `ChildAppRulesService`); this only
/// reads it back via `GET /children/{id}/installed-apps`. A 404 (no child, or a
/// stale build) is treated as "nothing synced yet" rather than a hard error —
/// the screen then shows its empty state. A live child that has simply never
/// synced comes back as `200` with `updated_at: null`.
class ParentInstalledAppsCubit extends Cubit<ParentInstalledAppsState> {
  final ParentAppBlockingService _service;

  String? _childId;

  ParentInstalledAppsCubit(this._service)
    : super(const ParentInstalledAppsLoading());

  /// The child id this cubit last queried — the parent's currently-selected
  /// kid (`child.id` from `/families/current`). Surfaced so the screen can show
  /// it next to "no apps", since a mismatch with the child device's own
  /// `/me` `child_id` is the usual cause of an empty list.
  String? get queriedChildId => _childId;

  Future<void> load(String childId) async {
    _childId = childId;
    debugPrint('[ParentInstalledAppsCubit] load childId="$childId"');
    if (childId.isEmpty) {
      // No kid selected on the Limits screen — a real error, not "empty".
      emit(
        const ParentInstalledAppsError(
          'No child selected. Pick a kid on the Limits screen first.',
        ),
      );
      return;
    }

    emit(const ParentInstalledAppsLoading());
    final result = await _service.fetchInstalledApps(childId);
    if (isClosed) return;

    result.fold(
      (failure) {
        if (failure is NotFoundFailure) {
          emit(const ParentInstalledAppsLoaded([], endpointMissing: true));
        } else {
          emit(ParentInstalledAppsError(failure.message));
        }
      },
      (snapshot) {
        final sorted = [...snapshot.apps]
          ..sort(
            (a, b) =>
                a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
          );
        emit(ParentInstalledAppsLoaded(sorted, updatedAt: snapshot.updatedAt));
      },
    );
  }

  Future<void> refresh() => _childId == null ? Future.value() : load(_childId!);
}
