import 'package:cms/core/network/dio_client.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/utils/attendance_event_utils.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/teacher_biometric_attendance_providers.dart';
import '../../data/models/teacher_attendance_models.dart';
import '../../services/biometric_scanner_service.dart';

class AttendanceDevicesScreen extends ConsumerStatefulWidget {
  const AttendanceDevicesScreen({super.key});

  @override
  ConsumerState<AttendanceDevicesScreen> createState() =>
      _AttendanceDevicesScreenState();
}

class _AttendanceDevicesScreenState
    extends ConsumerState<AttendanceDevicesScreen> {
  String _workstationId = '';
  String? _activeDeviceId;
  final Map<String, bool> _localTokenPresent = {};
  ScannerConnectionStatus? _scannerStatus;
  bool _togglingId = false;

  @override
  void initState() {
    super.initState();
    _loadLocalWorkstationState();
  }

  Future<void> _loadLocalWorkstationState() async {
    final storage = ref.read(secureStorageProvider);
    final adapter = ref.read(biometricScannerAdapterProvider);
    final id = await storage.getOrCreateWorkstationIdentifier();
    final activeId = await storage.getActiveKioskDeviceId();
    final scanner = await adapter.checkConnection();
    if (!mounted) return;
    setState(() {
      _workstationId = id;
      _activeDeviceId = activeId;
      _scannerStatus = scanner;
    });
    _refreshLocalTokenMap();
  }

  Future<void> _refreshLocalTokenMap() async {
    final devices = ref.read(attendanceDevicesProvider).valueOrNull;
    if (devices == null) return;
    final storage = ref.read(secureStorageProvider);
    final map = <String, bool>{};
    for (final d in devices) {
      final tok = await storage.getDeviceToken(d.id);
      map[d.id] = tok != null && tok.isNotEmpty;
    }
    if (!mounted) return;
    setState(() => _localTokenPresent
      ..clear()
      ..addAll(map));
  }

  Future<void> _openRegisterDialog() async {
    final nameCtrl = TextEditingController();
    final modelCtrl = TextEditingController(text: 'USB Biometric Kiosk');
    final idCtrl = TextEditingController(text: _workstationId);
    final formKey = GlobalKey<FormState>();
    bool submitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('Register Attendance Kiosk'),
          content: SizedBox(
            width: 440,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Registers this workstation in the backend and stores the one-time device token securely in local OS credential storage.',
                    style: TextStyle(fontSize: 13, color: CampusStyle.muted),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Device Name *',
                      hintText: 'e.g. Main Office Kiosk PC',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 2) {
                        return 'Enter a name (at least 2 characters)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: idCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Device Identifier *',
                      helperText:
                          'Must be unique across all registered kiosks',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 3) {
                        return 'Enter an identifier (at least 3 characters)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: modelCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Scanner / Device Model (Optional)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => submitting = true);
                      try {
                        final repo = ref.read(
                          teacherBiometricAttendanceRepositoryProvider,
                        );
                        final created = await repo.registerDevice(
                          AttendanceDeviceCreateRequest(
                            deviceName: nameCtrl.text,
                            deviceIdentifier: idCtrl.text,
                            deviceModel: modelCtrl.text,
                          ),
                        );
                        final storage = ref.read(secureStorageProvider);
                        await storage.saveDeviceToken(
                          created.id,
                          created.deviceToken,
                        );
                        await storage.saveActiveKioskDeviceId(created.id);
                        ref.invalidate(attendanceDevicesProvider);
                        if (!dialogCtx.mounted) return;
                        Navigator.pop(dialogCtx);
                        if (!mounted) return;
                        setState(() {
                          _activeDeviceId = created.id;
                          _localTokenPresent[created.id] = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Registered "${created.deviceName}" and stored device token securely on this machine.',
                            ),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => submitting = false);
                        if (!dialogCtx.mounted) return;
                        ScaffoldMessenger.of(dialogCtx).showSnackBar(
                          SnackBar(
                            content: Text(friendlyErrorMessage(e)),
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Register & Pair'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleDeviceStatus(AttendanceDevice device, bool nextValue) async {
    if (!nextValue) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Disable Attendance Device?'),
          content: Text(
            'Deactivating "${device.deviceName}" immediately blocks fingerprint scans from that kiosk until reactivated.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Disable Device'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _togglingId = true);
    try {
      await ref
          .read(teacherBiometricAttendanceRepositoryProvider)
          .setDeviceActive(device.id, nextValue);
      ref.invalidate(attendanceDevicesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${device.deviceName} is now ${nextValue ? 'active' : 'disabled'}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyErrorMessage(e)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _togglingId = false);
    }
  }

  Future<void> _selectActiveDevice(AttendanceDevice device) async {
    await ref.read(secureStorageProvider).saveActiveKioskDeviceId(device.id);
    if (!mounted) return;
    setState(() => _activeDeviceId = device.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${device.deviceName}" set as active kiosk on this device.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(attendanceDevicesProvider);
    ref.listen(attendanceDevicesProvider, (_, next) {
      if (next.hasValue) {
        _refreshLocalTokenMap();
      }
    });

    return CampusPage(
      appBar: AppBar(
        title: const Text('Attendance Kiosk Devices'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(attendanceDevicesProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRegisterDialog,
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('Register Device'),
      ),
      body: CampusScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CampusSectionIntro(
              title: 'Registered Kiosk Workstations',
              subtitle:
                  'Register attendance kiosks, store device credentials securely in local OS storage, monitor scanner status, and enable or revoke devices.',
            ),
            const SizedBox(height: 16),
            _buildLocalWorkstationCard(),
            const SizedBox(height: 20),
            devicesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => _ErrorPanel(
                message: friendlyErrorMessage(e),
                onRetry: () => ref.invalidate(attendanceDevicesProvider),
              ),
              data: (devices) {
                if (devices.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E0F2)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.devices_other_rounded,
                          size: 48,
                          color: CampusStyle.primary,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No attendance devices registered yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Register this workstation to pair a kiosk and obtain a secure device token.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: CampusStyle.muted),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _openRegisterDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Register This Workstation'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: devices.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildDeviceCard(devices[index]),
                );
              },
            ),
            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalWorkstationCard() {
    final scanner = _scannerStatus;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9D2F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.usb_rounded, color: CampusStyle.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'This Workstation & Local Scanner Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: CampusStyle.ink,
                  ),
                ),
              ),
              if (scanner != null)
                Chip(
                  label: Text(
                    scanner.isReady ? 'Adapter Ready' : 'Not Connected',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: scanner.isReady
                      ? const Color(0xFF16A34A)
                      : Colors.orange.shade700,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Workstation Identifier: ${_workstationId.isEmpty ? 'Loading...' : _workstationId}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: CampusStyle.ink,
            ),
          ),
          if (scanner != null) ...[
            const SizedBox(height: 4),
            Text(
              '${scanner.adapterName} — ${scanner.statusDetail}',
              style: const TextStyle(fontSize: 12, color: CampusStyle.muted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceCard(AttendanceDevice device) {
    final isPairedLocally = _localTokenPresent[device.id] == true;
    final isActiveChoice = _activeDeviceId == device.id;
    final fmtDate = DateFormat('dd MMM yyyy, hh:mm a');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isActiveChoice
              ? CampusStyle.primary
              : const Color(0xFFE3E1EE),
          width: isActiveChoice ? 1.6 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: device.isActive
                      ? CampusStyle.primary.withValues(alpha: 0.12)
                      : Colors.grey.shade200,
                  child: Icon(
                    Icons.fingerprint_rounded,
                    color: device.isActive ? CampusStyle.primary : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            device.deviceName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          _BadgeChip(
                            label: device.isActive ? 'ACTIVE' : 'DISABLED',
                            color: device.isActive
                                ? const Color(0xFF16A34A)
                                : Colors.red.shade600,
                          ),
                          if (isPairedLocally)
                            const _BadgeChip(
                              label: 'Paired on This PC',
                              color: Color(0xFF2563EB),
                            ),
                          if (isActiveChoice)
                            const _BadgeChip(
                              label: 'Selected Kiosk',
                              color: CampusStyle.primary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ID: ${device.deviceIdentifier}${device.deviceModel != null ? ' • Model: ${device.deviceModel}' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: CampusStyle.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Registered: ${fmtDate.format(device.registeredAt.toLocal())}'
                        '${device.lastSeenAt != null ? ' • Last Seen: ${formatLocalTime(device.lastSeenAt)}' : ' • Never scanned yet'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CampusStyle.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: device.isActive,
                  onChanged: _togglingId
                      ? null
                      : (val) => _toggleDeviceStatus(device, val),
                ),
              ],
            ),
            if (isPairedLocally && device.isActive && !isActiveChoice) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => _selectActiveDevice(device),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Use as Active Kiosk'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final Color color;

  const _BadgeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Text(message, style: TextStyle(color: Colors.red.shade800)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
