import 'package:cms/core/network/dio_client.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/utils/attendance_event_utils.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/teachers/data/models/teacher.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/teacher_biometric_attendance_providers.dart';
import '../../data/models/teacher_attendance_models.dart';
import '../../services/biometric_scanner_service.dart';
import '../widgets/teacher_attendance_badges.dart';
import 'attendance_devices_screen.dart';
import 'teacher_enrollment_screen.dart';

class TeacherKioskScreen extends ConsumerStatefulWidget {
  const TeacherKioskScreen({super.key});

  @override
  ConsumerState<TeacherKioskScreen> createState() => _TeacherKioskScreenState();
}

class _TeacherKioskScreenState extends ConsumerState<TeacherKioskScreen> {
  String _eventType = 'check_in';
  AttendanceDevice? _selectedDevice;
  String? _deviceToken;
  ScannerConnectionStatus? _scannerStatus;
  List<LocalTemplateRecord> _localTemplates = const [];
  Teacher? _testTeacherSelection;

  bool _submitting = false;
  TeacherScanResponse? _lastResult;
  String? _errorTitle;
  String? _errorMessage;
  bool _showUnknownFingerprint = false;
  TeacherScanRequest? _pendingRetryRequest;

  @override
  void initState() {
    super.initState();
    _initKioskEnvironment();
  }

  Future<void> _initKioskEnvironment() async {
    final scanner = ref.read(biometricScannerAdapterProvider);
    final status = await scanner.checkConnection();
    final savedDeviceId =
        await ref.read(secureStorageProvider).getActiveKioskDeviceId();
    if (!mounted) return;
    setState(() => _scannerStatus = status);

    final devices = ref.read(attendanceDevicesProvider).valueOrNull;
    if (devices != null && devices.isNotEmpty) {
      await _bindDeviceSelection(devices, preferredId: savedDeviceId);
    }
  }

  Future<void> _bindDeviceSelection(
    List<AttendanceDevice> devices, {
    String? preferredId,
  }) async {
    final active = devices.where((d) => d.isActive).toList();
    if (active.isEmpty) {
      if (!mounted) return;
      setState(() {
        _selectedDevice = null;
        _deviceToken = null;
        _localTemplates = const [];
      });
      return;
    }

    AttendanceDevice chosen = active.first;
    if (preferredId != null) {
      chosen = active.firstWhere(
        (d) => d.id == preferredId,
        orElse: () => active.first,
      );
    }
    await _selectDevice(chosen);
  }

  Future<void> _selectDevice(AttendanceDevice device) async {
    final storage = ref.read(secureStorageProvider);
    final scanner = ref.read(biometricScannerAdapterProvider);
    final token = await storage.getDeviceToken(device.id);
    final templates = await scanner.listLocalTemplates(device.id);
    await storage.saveActiveKioskDeviceId(device.id);
    if (!mounted) return;
    setState(() {
      _selectedDevice = device;
      _deviceToken = token;
      _localTemplates = templates;
      _pendingRetryRequest = null;
      _errorMessage = null;
      _lastResult = null;
      _showUnknownFingerprint = false;
    });
  }

  bool _isRetryableError(Object e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return true;
        case DioExceptionType.badResponse:
          final code = e.response?.statusCode ?? 0;
          return code >= 500;
        default:
          return false;
      }
    }
    return false;
  }

  String _classifyErrorTitle(Object e) {
    if (e is DioException) {
      final code = e.response?.statusCode;
      if (code == 401) return 'Authentication / Device Token Invalid (401)';
      if (code == 403) return 'Teacher Not Enrolled on This Kiosk (403)';
      if (code == 404) return 'Teacher or Device Not Found (404)';
      if (code == 409) return 'Attendance Policy / State Conflict (409)';
      if (code == 422) return 'Clock Skew or Validation Error (422)';
      if (code != null && code >= 500) return 'Server Error ($code)';
      return 'Connection Error';
    }
    return 'Scan Failed';
  }

  Future<void> _handleScanForTeacher(Teacher teacher) async {
    if (_selectedDevice == null ||
        _deviceToken == null ||
        _deviceToken!.isEmpty) {
      setState(() {
        _lastResult = null;
        _showUnknownFingerprint = false;
        _errorTitle = 'Device Not Paired';
        _errorMessage =
            'No local device token found for this kiosk. Register or pair this workstation in Attendance Devices first.';
      });
      return;
    }

    // Step 1: Match locally against enrolled workstation templates first
    final scanner = ref.read(biometricScannerAdapterProvider);
    final matched = await scanner.matchTeacherLocally(
      deviceId: _selectedDevice!.id,
      teacherId: teacher.id,
    );

    if (matched == null) {
      // Handoff rule: If no local match is found, show unknown-fingerprint message
      // and do NOT call POST /attendance/teachers/scan.
      if (!mounted) return;
      setState(() {
        _lastResult = null;
        _errorMessage = null;
        _pendingRetryRequest = null;
        _showUnknownFingerprint = true;
      });
      return;
    }

    // Step 2: Build fresh scan payload with new UUID event_id and timezone-aware timestamp
    final req = TeacherScanRequest(
      eventId: generateEventUuid(),
      teacherId: matched.teacherId,
      deviceId: _selectedDevice!.id,
      eventType: _eventType,
      capturedAt: formatIsoWithLocalOffset(DateTime.now()),
    );
    await _submitScanRequest(req);
  }

  Future<void> _submitScanRequest(TeacherScanRequest req) async {
    if (_deviceToken == null) return;
    setState(() {
      _submitting = true;
      _showUnknownFingerprint = false;
      _errorTitle = null;
      _errorMessage = null;
      _lastResult = null;
    });

    try {
      final repo = ref.read(teacherBiometricAttendanceRepositoryProvider);
      final response = await repo.submitFingerprintScan(
        request: req,
        deviceToken: _deviceToken!,
      );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _lastResult = response;
        _pendingRetryRequest = null;
      });
      ref.invalidate(
        teacherDailyAttendanceProvider(formatApiDate(DateTime.now())),
      );
    } catch (e) {
      if (!mounted) return;
      final retryable = _isRetryableError(e);
      setState(() {
        _submitting = false;
        _errorTitle = _classifyErrorTitle(e);
        _errorMessage = friendlyErrorMessage(e);
        // Preserve event_id ONLY for retryable network timeouts / 5xx
        _pendingRetryRequest = retryable ? req : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(attendanceDevicesProvider);
    final teachersAsync = ref.watch(teachersListControllerProvider);

    ref.listen(attendanceDevicesProvider, (_, next) {
      if (next.hasValue && _selectedDevice == null) {
        ref.read(secureStorageProvider).getActiveKioskDeviceId().then((id) {
          if (mounted) {
            _bindDeviceSelection(next.value!, preferredId: id);
          }
        });
      }
    });

    return CampusPage(
      appBar: AppBar(
        title: const Text('Teacher Attendance Kiosk'),
        actions: [
          IconButton(
            tooltip: 'Kiosk Devices',
            icon: const Icon(Icons.devices_rounded),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AttendanceDevicesScreen(),
                ),
              );
              ref.invalidate(attendanceDevicesProvider);
              if (_selectedDevice != null) {
                await _selectDevice(_selectedDevice!);
              }
            },
          ),
          IconButton(
            tooltip: 'Fingerprint Enrollment',
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TeacherEnrollmentScreen(),
                ),
              );
              if (_selectedDevice != null) {
                await _selectDevice(_selectedDevice!);
              }
            },
          ),
        ],
      ),
      body: CampusScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CampusSectionIntro(
              title: 'Biometric Arrival & Departure Kiosk',
              subtitle:
                  'Select Arrival (Check-In) or Departure (Check-Out), verify scanner pairing, and record server-authenticated teacher attendance.',
            ),
            const SizedBox(height: 16),
            devicesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(
                'Failed to load devices: ${friendlyErrorMessage(e)}',
                style: const TextStyle(color: Colors.red),
              ),
              data: (devices) => _buildDeviceBar(devices),
            ),
            const SizedBox(height: 16),
            _buildModeSelector(),
            const SizedBox(height: 20),
            if (_lastResult != null) _buildSuccessCard(_lastResult!),
            if (_showUnknownFingerprint) _buildUnknownFingerprintCard(),
            if (_errorMessage != null) _buildErrorCard(),
            const SizedBox(height: 16),
            teachersAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text(
                'Failed to load teachers: ${friendlyErrorMessage(e)}',
                style: const TextStyle(color: Colors.red),
              ),
              data: (teachers) => _buildScannerInteractionPanel(teachers),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceBar(List<AttendanceDevice> devices) {
    final activeDevices = devices.where((d) => d.isActive).toList();
    final isPaired = _deviceToken != null && _deviceToken!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9D2F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 600;
              final dropdown = DropdownButtonFormField<AttendanceDevice>(
                initialValue: activeDevices.any((d) => d.id == _selectedDevice?.id)
                    ? activeDevices.firstWhere(
                        (d) => d.id == _selectedDevice?.id,
                      )
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Active Kiosk Device',
                  isDense: true,
                ),
                items: activeDevices
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text(
                          d.deviceName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (d) {
                  if (d != null) _selectDevice(d);
                },
              );

              final statusBadges = Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Chip(
                    avatar: Icon(
                      isPaired ? Icons.lock_rounded : Icons.warning_amber_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      isPaired ? 'Token Paired' : 'Not Paired Here',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: isPaired
                        ? const Color(0xFF16A34A)
                        : Colors.orange.shade800,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  if (_scannerStatus != null)
                    Chip(
                      avatar: const Icon(
                        Icons.usb_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        _scannerStatus!.isReady ? 'Scanner Ready' : 'Offline',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: CampusStyle.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              );

              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    dropdown,
                    const SizedBox(height: 10),
                    statusBadges,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: dropdown),
                  const SizedBox(width: 12),
                  statusBadges,
                ],
              );
            },
          ),
          if (!isPaired) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AttendanceDevicesScreen(),
                  ),
                );
                ref.invalidate(attendanceDevicesProvider);
              },
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: const Text('Register & Pair This Workstation Now'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    final isCheckIn = _eventType == 'check_in';
    return Row(
      children: [
        Expanded(
          child: _KioskModeButton(
            title: 'ARRIVAL',
            subtitle: 'Check-In',
            icon: Icons.login_rounded,
            selected: isCheckIn,
            activeColor: const Color(0xFF16A34A),
            onTap: _submitting
                ? null
                : () => setState(() {
                      _eventType = 'check_in';
                      _pendingRetryRequest = null;
                      _errorMessage = null;
                      _lastResult = null;
                      _showUnknownFingerprint = false;
                    }),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KioskModeButton(
            title: 'DEPARTURE',
            subtitle: 'Check-Out',
            icon: Icons.logout_rounded,
            selected: !isCheckIn,
            activeColor: const Color(0xFF2563EB),
            onTap: _submitting
                ? null
                : () => setState(() {
                      _eventType = 'check_out';
                      _pendingRetryRequest = null;
                      _errorMessage = null;
                      _lastResult = null;
                      _showUnknownFingerprint = false;
                    }),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessCard(TeacherScanResponse res) {
    final bg = res.duplicate
        ? const Color(0xFFEFF6FF)
        : const Color(0xFFF0FDF4);
    final border = res.duplicate
        ? const Color(0xFF60A5FA)
        : const Color(0xFF22C55E);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                res.duplicate
                    ? Icons.info_rounded
                    : Icons.check_circle_rounded,
                color: border,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  res.duplicate
                      ? 'Already Processed — ${res.teacherName}'
                      : '${res.teacherName} — ${res.eventType == 'check_in' ? 'Checked In' : 'Checked Out'}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AttendanceStatusBadge(status: res.attendanceStatus),
              if (res.shortLeave) ...[
                const SizedBox(width: 6),
                const ShortLeaveBadge(),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(res.message, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            'Date: ${res.attendanceDate} • Check-In: ${formatLocalTime(res.checkInAt)} • Check-Out: ${formatLocalTime(res.checkOutAt)}',
            style: const TextStyle(fontSize: 13, color: CampusStyle.ink),
          ),
        ],
      ),
    );
  }

  Widget _buildUnknownFingerprintCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF97316)),
      ),
      child: Row(
        children: [
          const Icon(Icons.fingerprint_rounded, color: Color(0xFFEA580C), size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Unknown Fingerprint',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF9A3412),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'No matching local template exists on this workstation. Enroll the teacher on this device first before scanning.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9A3412)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _errorTitle ?? 'Scan Rejected',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red.shade900, fontSize: 13),
          ),
          if (_pendingRetryRequest != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _submitting
                  ? null
                  : () => _submitScanRequest(_pendingRetryRequest!),
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Retry Pending Scan (Same Event ID)'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScannerInteractionPanel(List<Teacher> teachers) {
    final activeTeachers = teachers.where((t) => t.isActive).toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
    final enrolledIds = _localTemplates.map((e) => e.teacherId).toSet();
    final enrolledTeachers =
        activeTeachers.where((t) => enrolledIds.contains(t.id)).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sensors_rounded, color: CampusStyle.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Waiting for ${_eventType == 'check_in' ? 'Arrival' : 'Departure'} Scan (${enrolledTeachers.length} enrolled locally)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_submitting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap an enrolled teacher below to simulate a matched fingerprint scan from the scanner SDK, or select any teacher to verify unknown/unenrolled rejection.',
            style: TextStyle(fontSize: 13, color: CampusStyle.muted),
          ),
          const SizedBox(height: 14),
          if (enrolledTeachers.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F8FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'No local templates found on the selected kiosk. Enroll teachers in "Teacher Fingerprint Enrollment" to test matched scans.',
                style: TextStyle(color: CampusStyle.muted),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: enrolledTeachers.map((teacher) {
                return FilledButton.tonalIcon(
                  onPressed:
                      _submitting ? null : () => _handleScanForTeacher(teacher),
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: Text('Scan ${teacher.fullName}'),
                );
              }).toList(),
            ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 520;
              final selector = DropdownButtonFormField<Teacher>(
                initialValue: activeTeachers.contains(_testTeacherSelection)
                    ? _testTeacherSelection
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Test Any Teacher Scan (Matched or Unenrolled)',
                  isDense: true,
                ),
                items: activeTeachers
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          '${t.fullName}${enrolledIds.contains(t.id) ? ' (Enrolled)' : ' (Unenrolled)'}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (t) => setState(() => _testTeacherSelection = t),
              );
              final btn = FilledButton.icon(
                onPressed: (_submitting || _testTeacherSelection == null)
                    ? null
                    : () => _handleScanForTeacher(_testTeacherSelection!),
                icon: const Icon(Icons.touch_app_rounded),
                label: const Text('Trigger Scan'),
              );
              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    selector,
                    const SizedBox(height: 10),
                    btn,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: selector),
                  const SizedBox(width: 12),
                  btn,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _KioskModeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color activeColor;
  final VoidCallback? onTap;

  const _KioskModeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.activeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? activeColor : const Color(0xFFD5D2E6),
            width: selected ? 2 : 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 26,
                color: selected ? Colors.white : activeColor,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: selected ? Colors.white : CampusStyle.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white70 : CampusStyle.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
