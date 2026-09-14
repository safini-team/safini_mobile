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

  /// Device admin resists uninstall/clear-data; the accessibility guard covers
  /// floating/PiP windows and Safini's own App-info page. Both are part of a
  /// complete setup, so a child cannot quietly weaken the limits.
  final bool hasDeviceAdmin;
  final bool hasAccessibility;
  final bool isChecking;
  final String? errorMessage;

  const AppBlockState({
    this.status = AppBlockStatus.initial,
    this.hasUsageAccess = false,
    this.hasOverlayPermission = false,
    this.hasDeviceAdmin = false,
    this.hasAccessibility = false,
    this.isChecking = false,
    this.errorMessage,
  });

  const AppBlockState.initial() : this();

  bool get needsUsageAccess => !hasUsageAccess;
  bool get needsOverlayPermission => !hasOverlayPermission;
  bool get needsDeviceAdmin => !hasDeviceAdmin;
  bool get needsAccessibility => !hasAccessibility;
  bool get hasAllPermissions =>
      hasUsageAccess &&
      hasOverlayPermission &&
      hasDeviceAdmin &&
      hasAccessibility;

  AppBlockState copyWith({
    AppBlockStatus? status,
    bool? hasUsageAccess,
    bool? hasOverlayPermission,
    bool? hasDeviceAdmin,
    bool? hasAccessibility,
    bool? isChecking,
    String? errorMessage,
  }) {
    return AppBlockState(
      status: status ?? this.status,
      hasUsageAccess: hasUsageAccess ?? this.hasUsageAccess,
      hasOverlayPermission: hasOverlayPermission ?? this.hasOverlayPermission,
      hasDeviceAdmin: hasDeviceAdmin ?? this.hasDeviceAdmin,
      hasAccessibility: hasAccessibility ?? this.hasAccessibility,
      isChecking: isChecking ?? this.isChecking,
      errorMessage: errorMessage,
    );
  }
}
