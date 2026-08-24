enum AppBlockStatus {
  /// Not yet checked.
  initial,

  /// Platform can't enforce (iOS / web) — nothing to do.
  unsupported,

  /// Missing Usage Access and/or overlay permission.
  needsPermissions,

  /// Permissions granted, service running, rules synced.
  active,

  /// Something went wrong while activating.
  error,
}

class AppBlockState {
  final AppBlockStatus status;
  final bool hasUsageAccess;
  final bool hasOverlayPermission;
  final String? errorMessage;

  const AppBlockState({
    this.status = AppBlockStatus.initial,
    this.hasUsageAccess = false,
    this.hasOverlayPermission = false,
    this.errorMessage,
  });

  const AppBlockState.initial() : this();

  bool get needsUsageAccess => !hasUsageAccess;
  bool get needsOverlayPermission => !hasOverlayPermission;
  bool get hasAllPermissions => hasUsageAccess && hasOverlayPermission;

  AppBlockState copyWith({
    AppBlockStatus? status,
    bool? hasUsageAccess,
    bool? hasOverlayPermission,
    String? errorMessage,
  }) {
    return AppBlockState(
      status: status ?? this.status,
      hasUsageAccess: hasUsageAccess ?? this.hasUsageAccess,
      hasOverlayPermission: hasOverlayPermission ?? this.hasOverlayPermission,
      errorMessage: errorMessage,
    );
  }
}
