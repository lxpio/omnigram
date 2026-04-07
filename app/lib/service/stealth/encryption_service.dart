import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class EncryptionService {
  EncryptionService._();

  static String encrypt(String plaintext, String key) {
    if (plaintext.isEmpty) return '';
    final keyBytes = _deriveKey(key);
    final plainBytes = utf8.encode(plaintext);
    final nonce = _generateNonce(16);
    final cipherBytes = _xorCipher(plainBytes, keyBytes, nonce);
    final combined = Uint8List(nonce.length + cipherBytes.length);
    combined.setAll(0, nonce);
    combined.setAll(nonce.length, cipherBytes);
    return base64.encode(combined);
  }

  static String decrypt(String ciphertext, String key) {
    if (ciphertext.isEmpty) return '';
    try {
      final keyBytes = _deriveKey(key);
      final combined = base64.decode(ciphertext);
      if (combined.length < 16) return ciphertext;
      final nonce = combined.sublist(0, 16);
      final cipherBytes = combined.sublist(16);
      final plainBytes = _xorCipher(cipherBytes, keyBytes, nonce);
      return utf8.decode(plainBytes);
    } catch (_) {
      return ciphertext;
    }
  }

  static String generateKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Uint8List _deriveKey(String key) {
    return Uint8List.fromList(sha256.convert(utf8.encode(key)).bytes);
  }

  static Uint8List _generateNonce(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => random.nextInt(256)));
  }

  static Uint8List _xorCipher(List<int> data, Uint8List key, List<int> nonce) {
    final result = Uint8List(data.length);
    var streamIndex = 0;
    var counter = 0;
    Uint8List stream = Uint8List(0);
    for (var i = 0; i < data.length; i++) {
      if (streamIndex >= stream.length) {
        final counterBytes = utf8.encode(counter.toString());
        final input = Uint8List(key.length + nonce.length + counterBytes.length);
        input.setAll(0, key);
        input.setAll(key.length, nonce);
        input.setAll(key.length + nonce.length, counterBytes);
        stream = Uint8List.fromList(sha256.convert(input).bytes);
        streamIndex = 0;
        counter++;
      }
      result[i] = data[i] ^ stream[streamIndex++];
    }
    return result;
  }
}
