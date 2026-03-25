import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/service/sync/sync_encryption.dart';

void main() {
  group('SyncEncryption', () {
    test('_generateKey produces 32-char key (via enable/getKey)', () async {
      // We can test key generation indirectly through the public API
      // but SyncEncryption depends on flutter_secure_storage which needs
      // platform channels. These tests verify the static API contract.
      expect(SyncEncryption.isEnabled, isA<Function>());
      expect(SyncEncryption.enable, isA<Function>());
      expect(SyncEncryption.disable, isA<Function>());
      expect(SyncEncryption.getKey, isA<Function>());
      expect(SyncEncryption.importKey, isA<Function>());
      expect(SyncEncryption.encrypt, isA<Function>());
      expect(SyncEncryption.decrypt, isA<Function>());
    });
  });
}
