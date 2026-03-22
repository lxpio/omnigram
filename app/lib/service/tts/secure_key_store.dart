import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for TTS API keys.
/// Uses iOS Keychain / Android EncryptedSharedPreferences.
/// Keys never leave the device and are not synced to Omnigram Server.
class SecureKeyStore {
  static final SecureKeyStore _instance = SecureKeyStore._();
  factory SecureKeyStore() => _instance;
  SecureKeyStore._();

  static const _storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  static const _prefix = 'tts_api_key_';

  /// Store an API key for a service (e.g., 'openai', 'elevenlabs', 'azure')
  Future<void> setKey(String serviceId, String key) async {
    await _storage.write(key: '$_prefix$serviceId', value: key);
  }

  /// Retrieve an API key for a service. Returns null if not set.
  Future<String?> getKey(String serviceId) async {
    return await _storage.read(key: '$_prefix$serviceId');
  }

  /// Delete an API key for a service.
  Future<void> deleteKey(String serviceId) async {
    await _storage.delete(key: '$_prefix$serviceId');
  }

  /// Check if an API key is stored for a service.
  Future<bool> hasKey(String serviceId) async {
    final key = await _storage.read(key: '$_prefix$serviceId');
    return key != null && key.isNotEmpty;
  }

  /// Delete all stored TTS API keys.
  Future<void> deleteAll() async {
    final all = await _storage.readAll();
    for (final key in all.keys) {
      if (key.startsWith(_prefix)) {
        await _storage.delete(key: key);
      }
    }
  }
}
