import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:omnigram/service/stealth/encryption_service.dart';

class BiometricAuthService {
  BiometricAuthService._();

  static const _keyName = 'stealth_db_encryption_key';
  static final _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage();

  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  static Future<String?> getOrCreateKey() async {
    var key = await _storage.read(key: _keyName);
    if (key == null) {
      key = EncryptionService.generateKey();
      await _storage.write(key: _keyName, value: key);
    }
    return key;
  }

  static Future<bool> isSetUp() async {
    final key = await _storage.read(key: _keyName);
    return key != null;
  }
}
