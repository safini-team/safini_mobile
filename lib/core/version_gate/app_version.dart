/// Semver-ish compare for store version names (`1.0.8`, `1.4.0-beta+12`).
///
/// Build metadata after `+` is ignored. A missing minor/patch is zero.
/// Pre-release (`-beta`) is lower than the same numbers without a suffix.
/// Unparseable input returns null so callers can fail open.
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch, [this.preRelease = '']);

  final int major;
  final int minor;
  final int patch;
  final String preRelease;

  static AppVersion? tryParse(String raw) {
    var value = raw.trim();
    if (value.isEmpty) return null;

    final plus = value.indexOf('+');
    if (plus >= 0) value = value.substring(0, plus);

    var pre = '';
    final dash = value.indexOf('-');
    if (dash >= 0) {
      pre = value.substring(dash + 1);
      value = value.substring(0, dash);
    }
    if (value.isEmpty) return null;

    final parts = value.split('.');
    if (parts.isEmpty || parts.length > 4) return null;

    final nums = <int>[];
    for (final part in parts) {
      if (part.isEmpty) return null;
      final n = int.tryParse(part);
      if (n == null || n < 0) return null;
      nums.add(n);
    }
    while (nums.length < 3) {
      nums.add(0);
    }
    return AppVersion(nums[0], nums[1], nums[2], pre);
  }

  bool get isPreRelease => preRelease.isNotEmpty;

  @override
  int compareTo(AppVersion other) {
    final byMajor = major.compareTo(other.major);
    if (byMajor != 0) return byMajor;
    final byMinor = minor.compareTo(other.minor);
    if (byMinor != 0) return byMinor;
    final byPatch = patch.compareTo(other.patch);
    if (byPatch != 0) return byPatch;
    if (preRelease.isEmpty && other.preRelease.isNotEmpty) return 1;
    if (preRelease.isNotEmpty && other.preRelease.isEmpty) return -1;
    return preRelease.compareTo(other.preRelease);
  }

  @override
  String toString() {
    final core = '$major.$minor.$patch';
    return preRelease.isEmpty ? core : '$core-$preRelease';
  }

  @override
  bool operator ==(Object other) =>
      other is AppVersion &&
      major == other.major &&
      minor == other.minor &&
      patch == other.patch &&
      preRelease == other.preRelease;

  @override
  int get hashCode => Object.hash(major, minor, patch, preRelease);
}

/// Negative if [left] < [right], zero if equal, positive if greater.
/// Null when either side cannot be parsed.
int? compareAppVersions(String left, String right) {
  final a = AppVersion.tryParse(left);
  final b = AppVersion.tryParse(right);
  if (a == null || b == null) return null;
  return a.compareTo(b);
}
