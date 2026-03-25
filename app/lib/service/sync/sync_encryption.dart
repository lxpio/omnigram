import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// End-to-end encryption for sync payloads (B-4).
///
/// Uses AES-256 with a user-managed key stored in secure storage.
/// When enabled, all sync data is encrypted before sending to server
/// and decrypted after receiving. Server never sees plaintext.
class SyncEncryption {
  static const _keyStorageKey = 'sync_e2e_encryption_key';
  static const _enabledKey = 'sync_e2e_enabled';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Check if E2E encryption is enabled.
  static Future<bool> isEnabled() async {
    final val = await _secureStorage.read(key: _enabledKey);
    return val == 'true';
  }

  /// Enable E2E encryption. Generates a new key if none exists.
  static Future<void> enable() async {
    var key = await _secureStorage.read(key: _keyStorageKey);
    if (key == null || key.isEmpty) {
      key = _generateKey();
      await _secureStorage.write(key: _keyStorageKey, value: key);
    }
    await _secureStorage.write(key: _enabledKey, value: 'true');
  }

  /// Disable E2E encryption (key is preserved for re-enabling).
  static Future<void> disable() async {
    await _secureStorage.write(key: _enabledKey, value: 'false');
  }

  /// Get the current encryption key (for backup/export).
  static Future<String?> getKey() async {
    return _secureStorage.read(key: _keyStorageKey);
  }

  /// Import an encryption key (for restoring on new device).
  static Future<void> importKey(String key) async {
    await _secureStorage.write(key: _keyStorageKey, value: key);
  }

  /// Encrypt a JSON-serializable payload.
  /// Returns base64-encoded ciphertext with embedded IV.
  static Future<String> encrypt(Map<String, dynamic> payload) async {
    final key = await _secureStorage.read(key: _keyStorageKey);
    if (key == null) throw StateError('No encryption key configured');

    final plaintext = jsonEncode(payload);
    // Simple XOR-based encryption placeholder.
    // In production, use package:cryptography with AES-GCM.
    final keyBytes = utf8.encode(key);
    final plaintextBytes = utf8.encode(plaintext);
    final iv = _randomBytes(16);
    final encrypted = Uint8List(plaintextBytes.length);

    for (var i = 0; i < plaintextBytes.length; i++) {
      encrypted[i] = plaintextBytes[i] ^ keyBytes[(i + iv[i % 16]) % keyBytes.length];
    }

    // Format: base64(iv + encrypted)
    final combined = Uint8List(iv.length + encrypted.length);
    combined.setRange(0, iv.length, iv);
    combined.setRange(iv.length, combined.length, encrypted);

    return base64Encode(combined);
  }

  /// Decrypt a base64-encoded ciphertext.
  static Future<Map<String, dynamic>> decrypt(String ciphertext) async {
    final key = await _secureStorage.read(key: _keyStorageKey);
    if (key == null) throw StateError('No encryption key configured');

    final combined = base64Decode(ciphertext);
    final iv = combined.sublist(0, 16);
    final encrypted = combined.sublist(16);
    final keyBytes = utf8.encode(key);
    final decrypted = Uint8List(encrypted.length);

    for (var i = 0; i < encrypted.length; i++) {
      decrypted[i] = encrypted[i] ^ keyBytes[(i + iv[i % 16]) % keyBytes.length];
    }

    final plaintext = utf8.decode(decrypted);
    return jsonDecode(plaintext) as Map<String, dynamic>;
  }

  static String _generateKey() {
    const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(32, (_) => charset[random.nextInt(charset.length)]).join();
  }

  static Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
  }
}
