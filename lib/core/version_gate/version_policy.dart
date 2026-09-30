import 'package:safini/core/version_gate/app_version.dart';

/// Play Store listing used when the policy omits `store_url` on Android.
const kPlayStoreListingUrl =
    'https://play.google.com/store/apps/details?id=com.safini.app';

/// Public App Store listing for the iOS bundle `com.safini.app`.
const kAppStoreListingUrl =
    'https://apps.apple.com/us/app/safini/id6761075183';

class PlatformVersionPolicy {
  const PlatformVersionPolicy({
    required this.minSupported,
    required this.latestRecommended,
    required this.storeUrl,
  });

  final String minSupported;
  final String latestRecommended;
  final String storeUrl;

  String effectiveStoreUrl({required bool isIos}) {
    final url = storeUrl.trim();
    if (isIos) {
      final uri = Uri.tryParse(url);
      final validAppStoreUrl =
          uri != null &&
          uri.scheme == 'https' &&
          uri.host == 'apps.apple.com' &&
          uri.pathSegments.contains('id6761075183');
      return validAppStoreUrl ? url : kAppStoreListingUrl;
    }
    return url.isNotEmpty ? url : kPlayStoreListingUrl;
  }

  static PlatformVersionPolicy? tryParse(dynamic data) {
    if (data is! Map) return null;
    final min = data['min_supported']?.toString().trim() ?? '';
    final latest = data['latest_recommended']?.toString().trim() ?? '';
    if (AppVersion.tryParse(min) == null) return null;
    if (AppVersion.tryParse(latest) == null) return null;
    return PlatformVersionPolicy(
      minSupported: min,
      latestRecommended: latest,
      storeUrl: data['store_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'min_supported': minSupported,
    'latest_recommended': latestRecommended,
    'store_url': storeUrl,
  };

  @override
  bool operator ==(Object other) =>
      other is PlatformVersionPolicy &&
      minSupported == other.minSupported &&
      latestRecommended == other.latestRecommended &&
      storeUrl == other.storeUrl;

  @override
  int get hashCode => Object.hash(minSupported, latestRecommended, storeUrl);
}

class VersionPolicyMessage {
  const VersionPolicyMessage({
    this.hardTitle = '',
    this.hardBody = '',
    this.softTitle = '',
    this.softBody = '',
  });

  final String hardTitle;
  final String hardBody;
  final String softTitle;
  final String softBody;

  static VersionPolicyMessage? tryParse(dynamic data) {
    if (data is! Map) return null;
    return VersionPolicyMessage(
      hardTitle: data['hard_title']?.toString() ?? '',
      hardBody: data['hard_body']?.toString() ?? '',
      softTitle: data['soft_title']?.toString() ?? '',
      softBody: data['soft_body']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'hard_title': hardTitle,
    'hard_body': hardBody,
    'soft_title': softTitle,
    'soft_body': softBody,
  };

  @override
  bool operator ==(Object other) =>
      other is VersionPolicyMessage &&
      hardTitle == other.hardTitle &&
      hardBody == other.hardBody &&
      softTitle == other.softTitle &&
      softBody == other.softBody;

  @override
  int get hashCode => Object.hash(hardTitle, hardBody, softTitle, softBody);
}

/// Remote policy from `GET /v1/system/version-policy`. One document for parent
/// and child; the client picks android vs ios.
class VersionPolicy {
  const VersionPolicy({required this.android, required this.ios, this.message});

  final PlatformVersionPolicy android;
  final PlatformVersionPolicy ios;
  final VersionPolicyMessage? message;

  PlatformVersionPolicy forIos(bool isIos) => isIos ? ios : android;

  static VersionPolicy? tryParse(dynamic data) {
    if (data is! Map) return null;
    final android = PlatformVersionPolicy.tryParse(data['android']);
    final ios = PlatformVersionPolicy.tryParse(data['ios']);
    if (android == null || ios == null) return null;
    return VersionPolicy(
      android: android,
      ios: ios,
      message: VersionPolicyMessage.tryParse(data['message']),
    );
  }

  Map<String, dynamic> toJson() => {
    'android': android.toJson(),
    'ios': ios.toJson(),
    if (message != null) 'message': message!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is VersionPolicy &&
      android == other.android &&
      ios == other.ios &&
      message == other.message;

  @override
  int get hashCode => Object.hash(android, ios, message);

  /// Screenshot / QA only. Never used as a shipped min-version seed.
  factory VersionPolicy.forced(VersionGateForce force) {
    switch (force) {
      case VersionGateForce.hard:
        const android = PlatformVersionPolicy(
          minSupported: '99.0.0',
          latestRecommended: '99.0.0',
          storeUrl: kPlayStoreListingUrl,
        );
        const ios = PlatformVersionPolicy(
          minSupported: '99.0.0',
          latestRecommended: '99.0.0',
          storeUrl: kAppStoreListingUrl,
        );
        return const VersionPolicy(android: android, ios: ios);
      case VersionGateForce.soft:
        const android = PlatformVersionPolicy(
          minSupported: '0.0.1',
          latestRecommended: '99.0.0',
          storeUrl: kPlayStoreListingUrl,
        );
        const ios = PlatformVersionPolicy(
          minSupported: '0.0.1',
          latestRecommended: '99.0.0',
          storeUrl: kAppStoreListingUrl,
        );
        return const VersionPolicy(android: android, ios: ios);
    }
  }
}

enum VersionGateForce { hard, soft }

VersionGateForce? parseVersionGateForce(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'hard':
      return VersionGateForce.hard;
    case 'soft':
      return VersionGateForce.soft;
    default:
      return null;
  }
}
