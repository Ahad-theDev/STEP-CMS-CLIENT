import 'package:cms/core/utils/attendance_event_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  static final Map<String, String> _memoryCache = {};

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _workstationIdKey = 'attendance_workstation_identifier';
  static const _activeDeviceIdKey = 'attendance_active_device_id';
  static String _deviceTokenKey(String deviceId) =>
      'attendance_device_token_$deviceId';
  static String _localTemplatesKey(String deviceId) =>
      'attendance_local_templates_$deviceId';

  Future<void> saveToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    _memoryCache[_accessTokenKey] = accessToken;
    _memoryCache[_refreshTokenKey] = refreshToken;
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
    } catch (_) {}
    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (_) {}
  }

  Future<String?> getAccessToken() async {
    if (_memoryCache.containsKey(_accessTokenKey)) {
      return _memoryCache[_accessTokenKey];
    }
    try {
      final val = await _storage.read(key: _accessTokenKey);
      if (val != null) {
        _memoryCache[_accessTokenKey] = val;
      }
      return val;
    } catch (_) {
      return _memoryCache[_accessTokenKey];
    }
  }

  Future<String?> getRefreshToken() async {
    if (_memoryCache.containsKey(_refreshTokenKey)) {
      return _memoryCache[_refreshTokenKey];
    }
    try {
      final val = await _storage.read(key: _refreshTokenKey);
      if (val != null) {
        _memoryCache[_refreshTokenKey] = val;
      }
      return val;
    } catch (_) {
      return _memoryCache[_refreshTokenKey];
    }
  }

  Future<void> clearToken() async {
    _memoryCache.remove(_accessTokenKey);
    _memoryCache.remove(_refreshTokenKey);
    try {
      await _storage.delete(key: _accessTokenKey);
    } catch (_) {}
    try {
      await _storage.delete(key: _refreshTokenKey);
    } catch (_) {}
  }

  Future<String> getOrCreateWorkstationIdentifier() async {
    if (_memoryCache.containsKey(_workstationIdKey)) {
      final existing = _memoryCache[_workstationIdKey]!;
      if (existing.trim().isNotEmpty) return existing;
    }
    try {
      final existing = await _storage.read(key: _workstationIdKey);
      if (existing != null && existing.trim().isNotEmpty) {
        _memoryCache[_workstationIdKey] = existing;
        return existing;
      }
    } catch (_) {}
    final created = 'kiosk-${generateEventUuid()}';
    _memoryCache[_workstationIdKey] = created;
    try {
      await _storage.write(key: _workstationIdKey, value: created);
    } catch (_) {}
    return created;
  }

  Future<void> saveDeviceToken(String deviceId, String token) async {
    final key = _deviceTokenKey(deviceId);
    _memoryCache[key] = token;
    try {
      await _storage.write(key: key, value: token);
    } catch (_) {}
  }

  Future<String?> getDeviceToken(String deviceId) async {
    final key = _deviceTokenKey(deviceId);
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }
    try {
      final val = await _storage.read(key: key);
      if (val != null) {
        _memoryCache[key] = val;
      }
      return val;
    } catch (_) {
      return _memoryCache[key];
    }
  }

  Future<void> deleteDeviceToken(String deviceId) async {
    final key = _deviceTokenKey(deviceId);
    _memoryCache.remove(key);
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  Future<void> saveActiveKioskDeviceId(String? deviceId) async {
    if (deviceId == null || deviceId.isEmpty) {
      _memoryCache.remove(_activeDeviceIdKey);
      try {
        await _storage.delete(key: _activeDeviceIdKey);
      } catch (_) {}
    } else {
      _memoryCache[_activeDeviceIdKey] = deviceId;
      try {
        await _storage.write(key: _activeDeviceIdKey, value: deviceId);
      } catch (_) {}
    }
  }

  Future<String?> getActiveKioskDeviceId() async {
    if (_memoryCache.containsKey(_activeDeviceIdKey)) {
      return _memoryCache[_activeDeviceIdKey];
    }
    try {
      final val = await _storage.read(key: _activeDeviceIdKey);
      if (val != null) {
        _memoryCache[_activeDeviceIdKey] = val;
      }
      return val;
    } catch (_) {
      return _memoryCache[_activeDeviceIdKey];
    }
  }

  Future<void> saveLocalTemplatesJson(String deviceId, String jsonStr) async {
    final key = _localTemplatesKey(deviceId);
    _memoryCache[key] = jsonStr;
    try {
      await _storage.write(key: key, value: jsonStr);
    } catch (_) {}
  }

  Future<String?> getLocalTemplatesJson(String deviceId) async {
    final key = _localTemplatesKey(deviceId);
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }
    try {
      final val = await _storage.read(key: key);
      if (val != null) {
        _memoryCache[key] = val;
      }
      return val;
    } catch (_) {
      return _memoryCache[key];
    }
  }
}
