import 'dart:convert';
import 'dart:typed_data';

import 'package:safini/core/utils/constants/controlled_apps.dart';

/// One app installed on a child's device, as enumerated natively on the child
/// device and synced to the backend so the parent can see the child's apps.
///
/// Wire format (snake_case) matches the
/// `PUT/GET /v1/children/{child_id}/installed-apps` endpoints
/// (see `BACKEND_TODO.md` #4).
class InstalledApp {
  final String packageName;
  final String appName;

  /// Lowercase hex SHA-256 of [iconPng]. Sent on every upload; the server
  /// answers with the hashes it still needs the bytes for.
  final String? iconSha256;

  /// The launcher icon as a PNG. Only the phone that has the app has this.
  final Uint8List? iconPng;

  /// Where anyone else gets the icon: a path on the API, `null` until the
  /// child's phone has uploaded it.
  final String? iconUrl;

  /// The slug a parent's rule on this app goes under, as the API names it.
  /// Every app on the phone has one, not only the catalog's.
  final String? appSlug;

  const InstalledApp({
    required this.packageName,
    required this.appName,
    this.iconSha256,
    this.iconPng,
    this.iconUrl,
    this.appSlug,
  });

  factory InstalledApp.fromJson(Map<String, dynamic> json) {
    final iconUrl = json['icon_url'];
    final appSlug = json['app_slug'];
    return InstalledApp(
      packageName: (json['package_name'] ?? json['packageName'] ?? '')
          .toString(),
      appName: (json['app_name'] ?? json['appName'] ?? '').toString(),
      iconUrl: iconUrl is String && iconUrl.isNotEmpty ? iconUrl : null,
      appSlug: appSlug is String && appSlug.isNotEmpty ? appSlug : null,
    );
  }

  /// The slug to set a limit or block under, or `null` when this app cannot
  /// take one. An API from before every app had a slug only knew the
  /// catalog's apps, so those still map by package.
  String? get ruleSlug => appSlug ?? ControlledApps.slugFor(packageName);

  /// One entry of the upload. The icon's bytes only go when [withIcon] - the
  /// server has most of them already.
  Map<String, dynamic> toJson({bool withIcon = false}) => {
    'package_name': packageName,
    'app_name': appName,
    if (iconSha256 != null) 'icon_sha256': iconSha256,
    if (withIcon && iconPng != null) 'icon_png': base64Encode(iconPng!),
  };
}

/// The parent-facing snapshot returned by
/// `GET /v1/children/{child_id}/installed-apps`: the app list plus the moment
/// the child device last uploaded it.
///
/// `updatedAt == null` means the child's phone has **never** synced — distinct
/// from "synced, and the list happens to be empty".
class InstalledAppsSnapshot {
  final List<InstalledApp> apps;
  final DateTime? updatedAt;

  const InstalledAppsSnapshot({required this.apps, this.updatedAt});

  /// True when the device has never uploaded a snapshot.
  bool get neverSynced => updatedAt == null;

  factory InstalledAppsSnapshot.fromJson(Map<String, dynamic> json) {
    final rawApps = json['apps'];
    final apps = rawApps is List
        ? rawApps
              .whereType<Map>()
              .map(
                (e) => InstalledApp.fromJson(
                  e.map((k, v) => MapEntry(k.toString(), v)),
                ),
              )
              .toList()
        : <InstalledApp>[];
    final rawUpdatedAt = json['updated_at'] ?? json['updatedAt'];
    return InstalledAppsSnapshot(
      apps: apps,
      updatedAt: rawUpdatedAt is String && rawUpdatedAt.isNotEmpty
          ? DateTime.tryParse(rawUpdatedAt)
          : null,
    );
  }
}
