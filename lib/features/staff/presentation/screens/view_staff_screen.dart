import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/staff_member.dart';

class ViewStaffScreen extends ConsumerStatefulWidget {
  final StaffMember staff;
  const ViewStaffScreen({super.key, required this.staff});

  @override
  ConsumerState<ViewStaffScreen> createState() => _ViewStaffScreenState();
}

class _ViewStaffScreenState extends ConsumerState<ViewStaffScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Details')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            // Profile section
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),

            // Full Name
            Text(
              widget.staff.fullName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),

            // Designation
            Text(
              widget.staff.designation ?? 'No designation set',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Divider
            const Divider(height: 1),
            const SizedBox(height: 24),

            // Details section
            const Text(
              'Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Join Date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Join Date'),
              subtitle: Text(
                widget.staff.joinDate == null
                    ? 'Not set'
                    : '${widget.staff.joinDate!.year}-${widget.staff.joinDate!.month.toString().padLeft(2, '0')}-${widget.staff.joinDate!.day.toString().padLeft(2, '0')}',
              ),
            ),

            // Status
            ListTile(
              leading: Icon(
                widget.staff.isActive ? Icons.check_circle : Icons.cancel,
                color: widget.staff.isActive ? Colors.green : Colors.red,
              ),
              title: const Text('Status'),
              subtitle: Text(
                widget.staff.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.staff.isActive ? Colors.green : Colors.red,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons (if needed in future)
            // For now, just a close button
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}