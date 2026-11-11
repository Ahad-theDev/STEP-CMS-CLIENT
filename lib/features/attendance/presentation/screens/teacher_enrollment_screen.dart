import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/core/utils/error_utils.dart';
import 'package:cms/features/teachers/application/teachers_list_controller.dart';
import 'package:cms/features/teachers/data/models/teacher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/teacher_biometric_attendance_providers.dart';
import '../../data/models/teacher_attendance_models.dart';

class TeacherEnrollmentScreen extends ConsumerStatefulWidget {
  const TeacherEnrollmentScreen({super.key});

  @override
  ConsumerState<TeacherEnrollmentScreen> createState() =>
      _TeacherEnrollmentScreenState();
}

class _TeacherEnrollmentScreenState
    extends ConsumerState<TeacherEnrollmentScreen> {
  Teacher? _selectedTeacher;
  AttendanceDevice? _selectedDevice;
  bool _isBusy = false;

  Future<void> _enrollTeacher() async {
    if (_selectedTeacher == null || _selectedDevice == null) return;
    if (!_selectedDevice!.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected device is disabled. Enable it before enrolling.'),
        ),
      );
      return;
    }

    setState(() => _isBusy = true);
    try {
      final scanner = ref.read(biometricScannerAdapterProvider);
      final repo = ref.read(teacherBiometricAttendanceRepositoryProvider);

      // Step 1: Capture & save local template securely (never sending paths/images to server)
      final captured = await scanner.enrollTeacherTemplate(
        teacherId: _selectedTeacher!.id,
        teacherName: _selectedTeacher!.fullName,
        deviceId: _selectedDevice!.id,
      );

      // Step 2: Register opaque enrollment metadata on FastAPI
      await repo.enrollTeacherFingerprint(
        _selectedTeacher!.id,
        FingerprintEnrollmentRequest(
          deviceId: _selectedDevice!.id,
          templateReference: captured.templateReference,
          templateVersion: captured.templateVersion,
        ),
      );

      ref.invalidate(teacherEnrollmentsProvider(_selectedTeacher!.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enrolled ${_selectedTeacher!.fullName} on "${_selectedDevice!.deviceName}".',
          ),
          backgroundColor: const Color(0xFF16A34A),
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
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _revokeEnrollment(FingerprintEnrollment item, String deviceName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Fingerprint Enrollment?'),
        content: Text(
          'This will revoke ${_selectedTeacher?.fullName}\'s enrollment on "$deviceName" and delete the local template on this workstation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      final repo = ref.read(teacherBiometricAttendanceRepositoryProvider);
      final scanner = ref.read(biometricScannerAdapterProvider);
      await repo.revokeTeacherEnrollment(item.teacherId, item.deviceId);
      await scanner.deleteLocalTemplate(
        teacherId: item.teacherId,
        deviceId: item.deviceId,
      );
      ref.invalidate(teacherEnrollmentsProvider(item.teacherId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fingerprint enrollment revoked.')),
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
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teachersAsync = ref.watch(teachersListControllerProvider);
    final devicesAsync = ref.watch(attendanceDevicesProvider);

    return CampusPage(
      appBar: AppBar(
        title: const Text('Teacher Fingerprint Enrollment'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(teachersListControllerProvider);
              ref.invalidate(attendanceDevicesProvider);
              if (_selectedTeacher != null) {
                ref.invalidate(
                  teacherEnrollmentsProvider(_selectedTeacher!.id),
                );
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
              title: 'Enroll & Manage Teacher Fingerprints',
              subtitle:
                  'Link a teacher\'s local kiosk fingerprint template to a registered attendance workstation. Only opaque template references are synced to the server.',
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 700;
                final teacherField = teachersAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text(
                    'Failed to load teachers: ${friendlyErrorMessage(e)}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  data: (teachers) {
                    final active = teachers.where((t) => t.isActive).toList()
                      ..sort((a, b) => a.fullName.compareTo(b.fullName));
                    return DropdownButtonFormField<Teacher>(
                      initialValue: active.contains(_selectedTeacher)
                          ? _selectedTeacher
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Teacher',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: active
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                t.department != null && t.department!.isNotEmpty
                                    ? '${t.fullName} (${t.department})'
                                    : t.fullName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedTeacher = v),
                    );
                  },
                );

                final deviceField = devicesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text(
                    'Failed to load devices: ${friendlyErrorMessage(e)}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  data: (devices) {
                    final activeDevices =
                        devices.where((d) => d.isActive).toList();
                    if (_selectedDevice == null && activeDevices.length == 1) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _selectedDevice == null) {
                          setState(() => _selectedDevice = activeDevices.first);
                        }
                      });
                    }
                    return DropdownButtonFormField<AttendanceDevice>(
                      initialValue: activeDevices.any(
                        (d) => d.id == _selectedDevice?.id,
                      )
                          ? activeDevices.firstWhere(
                              (d) => d.id == _selectedDevice?.id,
                            )
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Target Kiosk Device',
                        prefixIcon: Icon(Icons.fingerprint_rounded),
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
                      onChanged: (v) => setState(() => _selectedDevice = v),
                    );
                  },
                );

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: teacherField),
                      const SizedBox(width: 14),
                      Expanded(child: deviceField),
                    ],
                  );
                }
                return Column(
                  children: [
                    teacherField,
                    const SizedBox(height: 12),
                    deviceField,
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: (_isBusy ||
                        _selectedTeacher == null ||
                        _selectedDevice == null)
                    ? null
                    : _enrollTeacher,
                icon: _isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.fingerprint_rounded),
                label: Text(
                  _isBusy
                      ? 'Enrolling...'
                      : 'Capture & Enroll Fingerprint on Selected Device',
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedTeacher != null) ...[
              Text(
                'Enrollment History for ${_selectedTeacher!.fullName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CampusStyle.ink,
                ),
              ),
              const SizedBox(height: 12),
              _buildEnrollmentsList(
                _selectedTeacher!.id,
                devicesAsync.valueOrNull ?? const [],
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F8FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE4E2F0)),
                ),
                child: const Text(
                  'Select a teacher above to view or register fingerprint enrollments.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: CampusStyle.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentsList(
    String teacherId,
    List<AttendanceDevice> devices,
  ) {
    final enrollmentsAsync = ref.watch(teacherEnrollmentsProvider(teacherId));
    final deviceNameById = {for (final d in devices) d.id: d.deviceName};
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

    return enrollmentsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Text(
        'Failed to load enrollments: ${friendlyErrorMessage(e)}',
        style: const TextStyle(color: Colors.red),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE4E2F0)),
            ),
            child: const Text(
              'This teacher has no fingerprint enrollments yet.',
              style: TextStyle(color: CampusStyle.muted),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            final deviceName =
                deviceNameById[item.deviceId] ?? 'Device ${item.deviceId}';
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E0F0)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: item.isActive
                      ? const Color(0xFFDCFCE7)
                      : Colors.grey.shade200,
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: item.isActive
                        ? const Color(0xFF16A34A)
                        : Colors.grey,
                  ),
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        deviceName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: item.isActive
                            ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                            : Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.isActive ? 'ACTIVE' : 'REVOKED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: item.isActive
                              ? const Color(0xFF16A34A)
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  'Ref: ${item.templateReference ?? 'N/A'}'
                  ' • Version: ${item.templateVersion ?? 'N/A'}\n'
                  'Enrolled: ${dateFmt.format(item.enrolledAt.toLocal())}',
                ),
                isThreeLine: true,
                trailing: item.isActive
                    ? IconButton(
                        tooltip: 'Revoke Enrollment',
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red.shade700,
                        ),
                        onPressed: _isBusy
                            ? null
                            : () => _revokeEnrollment(item, deviceName),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
