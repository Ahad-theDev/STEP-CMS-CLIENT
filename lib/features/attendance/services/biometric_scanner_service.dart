import 'dart:convert';
import 'package:cms/core/storage/secure_storage_service.dart';
import 'package:cms/core/utils/attendance_event_utils.dart';

class ScannerConnectionStatus {
  final bool isReady;
  final bool isHardwareSdkAttached;
  final String adapterName;
  final String statusDetail;

  const ScannerConnectionStatus({
    required this.isReady,
    required this.isHardwareSdkAttached,
    required this.adapterName,
    required this.statusDetail,
  });
}

class CapturedTemplateResult {
  /// Opaque identifier from the local scanner/SDK adapter.
  /// Must never be a local filesystem path, image, or raw biometric template bytes.
  final String templateReference;
  final String templateVersion;

  const CapturedTemplateResult({
    required this.templateReference,
    required this.templateVersion,
  });
}

class LocalTemplateRecord {
  final String teacherId;
  final String teacherName;
  final String deviceId;
  final String templateReference;
  final String templateVersion;
  final String enrolledAtIso;

  const LocalTemplateRecord({
    required this.teacherId,
    required this.teacherName,
    required this.deviceId,
    required this.templateReference,
    required this.templateVersion,
    required this.enrolledAtIso,
  });

  factory LocalTemplateRecord.fromJson(Map<String, dynamic> json) =>
      LocalTemplateRecord(
        teacherId: json['teacher_id'] as String,
        teacherName: json['teacher_name'] as String? ?? '',
        deviceId: json['device_id'] as String,
        templateReference: json['template_reference'] as String,
        templateVersion: json['template_version'] as String? ?? 'local-kiosk-v1',
        enrolledAtIso: json['enrolled_at'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'teacher_id': teacherId,
        'teacher_name': teacherName,
        'device_id': deviceId,
        'template_reference': templateReference,
        'template_version': templateVersion,
        'enrolled_at': enrolledAtIso,
      };
}

/// Vendor-agnostic abstraction for USB fingerprint scanner SDK integration.
/// Current cross-platform implementation stores opaque template references
/// in OS-backed secure storage; a Windows vendor SDK (e.g. ZKTeco/SecuGen FFI)
/// can be plugged in behind this contract without changing kiosk UI or backend APIs.
abstract class BiometricScannerAdapter {
  Future<ScannerConnectionStatus> checkConnection();

  Future<List<LocalTemplateRecord>> listLocalTemplates(String deviceId);

  Future<CapturedTemplateResult> enrollTeacherTemplate({
    required String teacherId,
    required String teacherName,
    required String deviceId,
  });

  Future<void> deleteLocalTemplate({
    required String teacherId,
    required String deviceId,
  });

  Future<LocalTemplateRecord?> matchTeacherLocally({
    required String deviceId,
    required String teacherId,
  });
}

class LocalWorkstationScannerAdapter implements BiometricScannerAdapter {
  final SecureStorageService _storage;

  LocalWorkstationScannerAdapter(this._storage);

  static const _version = 'workstation-adapter-v1';

  @override
  Future<ScannerConnectionStatus> checkConnection() async {
    return const ScannerConnectionStatus(
      isReady: true,
      isHardwareSdkAttached: false,
      adapterName: 'Workstation Kiosk Adapter (SDK Ready)',
      statusDetail:
          'Local secure template matching active. Connect a Windows USB scanner SDK plugin for live sensor capture.',
    );
  }

  @override
  Future<List<LocalTemplateRecord>> listLocalTemplates(String deviceId) async {
    final raw = await _storage.getLocalTemplatesJson(deviceId);
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(LocalTemplateRecord.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalTemplates(
    String deviceId,
    List<LocalTemplateRecord> items,
  ) {
    return _storage.saveLocalTemplatesJson(
      deviceId,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<CapturedTemplateResult> enrollTeacherTemplate({
    required String teacherId,
    required String teacherName,
    required String deviceId,
  }) async {
    final existing = await listLocalTemplates(deviceId);
    final tplRef = 'tpl_${generateEventUuid().replaceAll('-', '').substring(0, 16)}';
    final record = LocalTemplateRecord(
      teacherId: teacherId,
      teacherName: teacherName,
      deviceId: deviceId,
      templateReference: tplRef,
      templateVersion: _version,
      enrolledAtIso: formatIsoWithLocalOffset(DateTime.now()),
    );
    final updated = [
      ...existing.where((e) => e.teacherId != teacherId),
      record,
    ];
    await _saveLocalTemplates(deviceId, updated);
    return CapturedTemplateResult(
      templateReference: tplRef,
      templateVersion: _version,
    );
  }

  @override
  Future<void> deleteLocalTemplate({
    required String teacherId,
    required String deviceId,
  }) async {
    final existing = await listLocalTemplates(deviceId);
    final updated = existing.where((e) => e.teacherId != teacherId).toList();
    await _saveLocalTemplates(deviceId, updated);
  }

  @override
  Future<LocalTemplateRecord?> matchTeacherLocally({
    required String deviceId,
    required String teacherId,
  }) async {
    final existing = await listLocalTemplates(deviceId);
    for (final item in existing) {
      if (item.teacherId == teacherId) {
        return item;
      }
    }
    return null;
  }
}
