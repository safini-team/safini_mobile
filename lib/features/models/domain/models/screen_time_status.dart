/// iOS Screen Time status for one child, as synced to the backend so the parent
/// can see it. The iOS analogue of `InstalledAppsSnapshot` — Apple forbids an
/// installed-app list, so this is **counts and flags only**, never app names or
/// the opaque selection tokens (those are per-device and never leave the phone).
///
/// Wire format (snake_case) matches `PUT/GET
/// /v1/children/{child_id}/screen-time-status` (see `BACKEND_TODO.md` #5 /
/// `observation/ios_parent_backend_sync.md`).
class ScreenTimeStatus {
  /// Always `ios` for now (the only platform with Screen Time).
  final String platform;

  /// `notDetermined | denied | approved | unavailable`.
  final String authorization;

  final int selectedApplications;
  final int selectedCategories;
  final bool shieldActive;

  /// When the child device last pushed this. `null` → never synced.
  final DateTime? updatedAt;

  const ScreenTimeStatus({
    this.platform = 'ios',
    required this.authorization,
    this.selectedApplications = 0,
    this.selectedCategories = 0,
    this.shieldActive = false,
    this.updatedAt,
  });

  /// True when the child device has never pushed a status.
  bool get neverSynced => updatedAt == null;

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'authorization': authorization,
    'selected_applications': selectedApplications,
    'selected_categories': selectedCategories,
    'shield_active': shieldActive,
  };

  factory ScreenTimeStatus.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is num ? v.toInt() : 0;
    final rawUpdatedAt = json['updated_at'] ?? json['updatedAt'];
    return ScreenTimeStatus(
      platform: (json['platform'] ?? 'ios').toString(),
      authorization: (json['authorization'] ?? 'unavailable').toString(),
      selectedApplications: asInt(
        json['selected_applications'] ?? json['selectedApplications'],
      ),
      selectedCategories: asInt(
        json['selected_categories'] ?? json['selectedCategories'],
      ),
      shieldActive:
          (json['shield_active'] ?? json['shieldActive'] ?? false) == true,
      updatedAt: rawUpdatedAt is String && rawUpdatedAt.isNotEmpty
          ? DateTime.tryParse(rawUpdatedAt)
          : null,
    );
  }
}
