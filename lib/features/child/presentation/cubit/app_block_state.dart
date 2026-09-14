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

  /// An active device admin resists uninstall/clear-data/force-stop, so a child
  /// cannot quietly drop the limits. Part of a complete setup.
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
