import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:safini/features/parent/domain/models/parent_pin_record.dart';

/// Stretches a 4-digit PIN with a random salt. A 4-digit space is small, so
/// Keychain / Keystore is the real barrier; this keeps the PIN out of
/// plaintext dumps and logs.
class ParentPinHasher {
  const ParentPinHasher({Random? random}) : _random = random;

  static const int pinLength = 4;
  static const int version = 1;
  static const int saltLength = 16;
  static const int iterations = 8000;

  static final RegExp _digits = RegExp(r'^\d{4}$');

  final Random? _random;

  bool isValid(String pin) => _digits.hasMatch(pin);

  ParentPinRecord hash(String pin, {List<int>? salt}) {
    if (!isValid(pin)) {
      throw ArgumentError('PIN must be 4 digits');
    }
    final saltBytes = salt ?? _newSalt();
    return ParentPinRecord(
      version: version,
      saltHex: _toHex(saltBytes),
      hashHex: _toHex(_stretch(pin, saltBytes)),
    );
  }

  bool matches(String pin, ParentPinRecord record) {
    if (!isValid(pin)) return false;
    final saltBytes = _fromHex(record.saltHex);
    if (saltBytes == null || saltBytes.isEmpty) return false;
    final actual = _toHex(_stretch(pin, saltBytes));
    return _constantTimeEquals(actual, record.hashHex);
  }

  List<int> _stretch(String pin, List<int> salt) {
    List<int> bytes = utf8.encode(pin);
    for (var i = 0; i < iterations; i++) {
      bytes = sha256.convert(<int>[...salt, ...bytes]).bytes;
    }
    return bytes;
  }

  List<int> _newSalt() {
    final random = _random ?? Random.secure();
    return List<int>.generate(saltLength, (_) => random.nextInt(256));
  }

  static String _toHex(List<int> bytes) {
    final out = StringBuffer();
    for (final byte in bytes) {
      out.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return out.toString();
  }

  static Uint8List? _fromHex(String hex) {
    if (hex.length.isOdd) return null;
    final bytes = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < bytes.length; i++) {
      final slice = hex.substring(i * 2, i * 2 + 2);
      final value = int.tryParse(slice, radix: 16);
      if (value == null) return null;
      bytes[i] = value;
    }
    return bytes;
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
