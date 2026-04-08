import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:omnigram/service/stealth/encryption_service.dart';
import 'package:omnigram/utils/get_path/databases_path.dart';
import 'package:path/path.dart';

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
    } else {
      // If key exists but DB file doesn't (reinstall), delete stale key
      final databasePath = await getAnxDataBasesPath();
      final dbFile = File(join(databasePath, 'stealth_database.db'));
      if (!await dbFile.exists()) {
        await _storage.delete(key: _keyName);
        key = EncryptionService.generateKey();
        await _storage.write(key: _keyName, value: key);
      }
    }
    return key;
  }

  static Future<bool> isSetUp() async {
    final key = await _storage.read(key: _keyName);
    return key != null;
  }
}
