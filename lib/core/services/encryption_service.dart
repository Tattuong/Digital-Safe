import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._();
  static EncryptionService get instance => _instance;
  EncryptionService._();

  enc.Key? _key;
  enc.IV? _iv;

  bool get isReady => _key != null && _iv != null;

  void initFromPin(String pin, String salt) {
    final derived = _deriveKey(pin, salt);
    _key = enc.Key(derived);
    _iv = enc.IV(derived.sublist(0, 16));
  }

  void clear() {
    _key = null;
    _iv = null;
  }

  Uint8List _deriveKey(String pin, String salt) {
    final bytes = utf8.encode('$pin:$salt:digital_safe_v1');
    var hash = sha256.convert(bytes).bytes;
    for (var i = 0; i < 10000; i++) {
      hash = sha256.convert(hash).bytes;
    }
    return Uint8List.fromList(hash);
  }

  String encryptString(String plain) {
    if (!isReady) return plain;
    final encrypter = enc.Encrypter(enc.AES(_key!, mode: enc.AESMode.cbc));
    return encrypter.encrypt(plain, iv: _iv!).base64;
  }

  String decryptString(String cipher) {
    if (!isReady) return cipher;
    try {
      final encrypter = enc.Encrypter(enc.AES(_key!, mode: enc.AESMode.cbc));
      return encrypter.decrypt(enc.Encrypted.fromBase64(cipher), iv: _iv!);
    } catch (e) {
      debugPrint('Decrypt error: $e');
      return '';
    }
  }

  Future<String> encryptFile(String sourcePath) async {
    if (!isReady) return sourcePath;
    final bytes = await File(sourcePath).readAsBytes();
    final encrypter = enc.Encrypter(enc.AES(_key!, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(bytes, iv: _iv!);
    final dir = await _vaultDir();
    final outPath = p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.enc');
    await File(outPath).writeAsBytes(encrypted.bytes);
    return outPath;
  }

  Future<Uint8List?> decryptFile(String encPath) async {
    if (!isReady) return null;
    try {
      final bytes = await File(encPath).readAsBytes();
      final encrypter = enc.Encrypter(enc.AES(_key!, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decryptBytes(enc.Encrypted(bytes), iv: _iv!);
      return Uint8List.fromList(decrypted);
    } catch (e) {
      debugPrint('File decrypt error: $e');
      return null;
    }
  }

  Future<Directory> _vaultDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'vault_files'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}
