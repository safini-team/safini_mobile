/// On-device PIN material. The PIN itself is never stored; only a salt and a
/// stretched hash go in the Keychain / Keystore blob.
class ParentPinRecord {
  const ParentPinRecord({
    required this.version,
    required this.saltHex,
    required this.hashHex,
  });

  final int version;
  final String saltHex;
  final String hashHex;

  Map<String, dynamic> toJson() => {'v': version, 's': saltHex, 'h': hashHex};

  static ParentPinRecord? tryParse(Map<String, dynamic> json) {
    final version = json['v'];
    final salt = json['s'];
    final hash = json['h'];
    if (version is! int || salt is! String || hash is! String) return null;
    if (salt.isEmpty || hash.isEmpty) return null;
    return ParentPinRecord(version: version, saltHex: salt, hashHex: hash);
  }
}
