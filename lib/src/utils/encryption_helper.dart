import 'dart:developer';

import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  static encrypt.Key? _key;
  static encrypt.IV? _iv;
  static encrypt.Encrypter? _encrypter;

  static void initialize(String? base64Key) {
    if (base64Key != null && base64Key.isNotEmpty) {
      try {
        _key = encrypt.Key.fromBase64(base64Key);
        _iv = encrypt.IV.fromLength(16);
        _encrypter = encrypt.Encrypter(encrypt.AES(_key!));
      } catch (e) {
        _initializeDefault();
        log('ENCRYPTION: [WARNING] EncryptionHelper not initialized with custom key. Using default key.');
      }
    } else {
      _initializeDefault();
      log('ENCRYPTION: [WARNING] EncryptionHelper not initialized with custom key. Using default key.');
    }
  }

  /// Fallback default key
  static void _initializeDefault() {
    _key =
        encrypt.Key.fromBase64('RXZlbnRTdHJhdEFuYWx5dGljczIwMjRLZXlTZWN1cmU=');
    _iv = encrypt.IV.fromLength(16);
    _encrypter = encrypt.Encrypter(encrypt.AES(_key!));
  }

  /// Encrypt JSON string
  static String encryptData(String plainText) {
    if (_encrypter == null) {
      _initializeDefault();
      log('ENCRYPTION: [WARNING] EncryptionHelper not initialized with custom key. Using default key.');
    }

    try {
      final encrypted = _encrypter!.encrypt(plainText, iv: _iv!);
      return encrypted.base64;
    } catch (e) {
      return plainText;
    }
  }

  /// Decrypt to JSON string
  static String decryptData(String encryptedText) {
    if (_encrypter == null) {
      _initializeDefault();
    }

    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      return _encrypter!.decrypt(encrypted, iv: _iv!);
    } catch (e) {
      return encryptedText;
    }
  }
}
