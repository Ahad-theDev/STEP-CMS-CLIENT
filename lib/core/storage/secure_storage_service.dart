import 'package:cms/core/utils/attendance_event_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

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
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<String> getOrCreateWorkstationIdentifier() async {
    final existing = await _storage.read(key: _workstationIdKey);
    if (existing != null && existing.trim().isNotEmpty) {
      return existing;
    }
    final created = 'kiosk-${generateEventUuid()}';
    await _storage.write(key: _workstationIdKey, value: created);
    return created;
  }

  Future<void> saveDeviceToken(String deviceId, String token) {
    return _storage.write(key: _deviceTokenKey(deviceId), value: token);
  }

  Future<String?> getDeviceToken(String deviceId) {
    return _storage.read(key: _deviceTokenKey(deviceId));
  }

  Future<void> deleteDeviceToken(String deviceId) {
    return _storage.delete(key: _deviceTokenKey(deviceId));
  }

  Future<void> saveActiveKioskDeviceId(String? deviceId) async {
    if (deviceId == null || deviceId.isEmpty) {
      await _storage.delete(key: _activeDeviceIdKey);
    } else {
      await _storage.write(key: _activeDeviceIdKey, value: deviceId);
    }
  }

  Future<String?> getActiveKioskDeviceId() {
    return _storage.read(key: _activeDeviceIdKey);
  }

  Future<void> saveLocalTemplatesJson(String deviceId, String jsonStr) {
    return _storage.write(key: _localTemplatesKey(deviceId), value: jsonStr);
  }

  Future<String?> getLocalTemplatesJson(String deviceId) {
    return _storage.read(key: _localTemplatesKey(deviceId));
  }
}
