import 'dart:math';

/// A random v4 UUID for one purchase attempt (SAF-132).
///
/// The API takes this as `client_request_id` and replays the original grant if
/// it sees the same value twice, so a retry of one attempt must reuse the id
/// and a genuinely new attempt must not. Hand-rolled rather than adding a
/// dependency for eight lines.
String newRequestId([Random? source]) {
  final random = source ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 1
  final hex = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
