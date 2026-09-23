enum AppBlockStatus {
  /// Not yet checked.
  initial,

  /// Platform can't enforce (iOS / web) — nothing to do.
  unsupported,

  /// Missing one of the required permissions or tamper guards.
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

  /// An active device admin blocks the silent uninstall/clear-data/force-stop
  /// paths and alerts the parent when it is removed, so a child cannot drop the
  /// limits quietly (removal is still possible, just not silent). Part of setup.
  final bool hasDeviceAdmin;
  final bool isChecking;
  final String? errorMessage;

  const AppBlockState({
    this.status = AppBlockStatus.initial,
    this.hasUsageAccess = false,
    this.hasOverlayPermission = false,
    this.hasDeviceAdmin = false,
    this.isChecking = false,
    this.errorMessage,
  });

  const AppBlockState.initial() : this();

  bool get needsUsageAccess => !hasUsageAccess;
  bool get needsOverlayPermission => !hasOverlayPermission;
  bool get needsDeviceAdmin => !hasDeviceAdmin;
  bool get hasAllPermissions =>
      hasUsageAccess && hasOverlayPermission && hasDeviceAdmin;

  /// The permissions checklist is only for a confirmed gap or activation
  /// failure. [AppBlockStatus.initial] is the in-flight check, including the
  /// profile/pairing wait after permissions are already granted, and must not
  /// replace the child shell or every reopen flashes setup.
  bool get showsSetup =>
      status == AppBlockStatus.needsPermissions ||
      status == AppBlockStatus.error;

  AppBlockState copyWith({
    AppBlockStatus? status,
    bool? hasUsageAccess,
    bool? hasOverlayPermission,
    bool? hasDeviceAdmin,
    bool? isChecking,
    String? errorMessage,
  }) {
    return AppBlockState(
      status: status ?? this.status,
      hasUsageAccess: hasUsageAccess ?? this.hasUsageAccess,
      hasOverlayPermission: hasOverlayPermission ?? this.hasOverlayPermission,
      hasDeviceAdmin: hasDeviceAdmin ?? this.hasDeviceAdmin,
      isChecking: isChecking ?? this.isChecking,
      errorMessage: errorMessage,
    );
  }
}
