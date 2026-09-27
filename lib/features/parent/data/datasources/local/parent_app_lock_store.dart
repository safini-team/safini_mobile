import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safini/features/parent/domain/models/parent_pin_record.dart';

/// Local PIN material only. Never a network call.
abstract class ParentAppLockStore {
  Future<ParentPinRecord?> read();
  Future<void> write(ParentPinRecord record);
  Future<void> clear();
}

/// In-memory store for tests and for hosts without the Keychain plugin.
class MemoryParentAppLockStore implements ParentAppLockStore {
  ParentPinRecord? _record;

  @override
  Future<ParentPinRecord?> read() async => _record;

  @override
  Future<void> write(ParentPinRecord record) async => _record = record;

  @override
  Future<void> clear() async => _record = null;
}

/// Keychain (iOS) / Keystore-backed storage (Android). One JSON blob, never
/// the PIN in plaintext.
class SecureParentAppLockStore implements ParentAppLockStore {
  SecureParentAppLockStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
              synchronizable: false,
            ),
          );

  static const _key = 'parent_app_lock_pin_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<ParentPinRecord?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return ParentPinRecord.tryParse(
        decoded.map((key, value) => MapEntry(key.toString(), value)),
      );
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('Parent app lock read failed: ${e.code}');
      rethrow;
    }
  }

  @override
  Future<void> write(ParentPinRecord record) async {
    try {
      await _storage.write(key: _key, value: jsonEncode(record.toJson()));
    } on MissingPluginException {
      return;
    } on PlatformException catch (e) {
      debugPrint('Parent app lock write failed: ${e.code}');
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } on MissingPluginException {
      return;
    } on PlatformException catch (e) {
      debugPrint('Parent app lock clear failed: ${e.code}');
      rethrow;
    }
  }
}
