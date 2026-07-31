import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'encryption_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;
  AuthService._();

  static const _pinHashKey = 'ds_pin_hash';
  static const _pinSaltKey = 'ds_pin_salt';
  static const _userNameKey = 'ds_user_name';
  static const _autoLockKey = 'ds_auto_lock_minutes';

  final _secure = const FlutterSecureStorage();

  bool _unlocked = false;
  String _salt = '';
  String _userName = 'User';

  bool get isUnlocked => _unlocked;
  String get userName => _userName;

  Future<bool> hasPin() async {
    final hash = await _secure.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<int> autoLockMinutes() async {
    return await StorageService.instance.getInt(_autoLockKey) ?? 5;
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    await StorageService.instance.saveInt(_autoLockKey, minutes);
  }

  Future<void> setupPin(String pin, {String userName = 'User'}) async {
    _salt = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _hashPin(pin, _salt);
    await _secure.write(key: _pinHashKey, value: hash);
    await _secure.write(key: _pinSaltKey, value: _salt);
    await StorageService.instance.saveString(_userNameKey, userName);
    _userName = userName;
    _unlockWithPin(pin);
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secure.read(key: _pinHashKey);
    _salt = await _secure.read(key: _pinSaltKey) ?? '';
    if (storedHash == null || _salt.isEmpty) return false;
    final ok = storedHash == _hashPin(pin, _salt);
    if (ok) _unlockWithPin(pin);
    return ok;
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    if (!await verifyPin(oldPin)) return false;
    final hash = _hashPin(newPin, _salt);
    await _secure.write(key: _pinHashKey, value: hash);
    _unlockWithPin(newPin);
    return true;
  }

  Future<void> loadUserName() async {
    _userName = await StorageService.instance.getString(_userNameKey) ?? 'User';
  }

  /// Clears PIN credentials. Vault data must be cleared separately.
  Future<void> resetPin() async {
    lock();
    await _secure.delete(key: _pinHashKey);
    await _secure.delete(key: _pinSaltKey);
    await StorageService.instance.remove(_userNameKey);
    _userName = 'User';
    _salt = '';
    _unlocked = false;
  }

  void _unlockWithPin(String pin) {
    _unlocked = true;
    EncryptionService.instance.initFromPin(pin, _salt);
  }

  void lock() {
    _unlocked = false;
    EncryptionService.instance.clear();
  }

  String _hashPin(String pin, String salt) {
    return '$salt:${pin.codeUnits.fold<int>(0, (a, b) => a + b * 31)}:${pin.length}';
  }
}
