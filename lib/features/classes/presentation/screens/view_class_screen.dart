import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/school_class.dart';

class ViewClassScreen extends ConsumerStatefulWidget {
  final SchoolClass schoolClass;
  const ViewClassScreen({super.key, required this.schoolClass});

  @override
  ConsumerState<ViewClassScreen> createState() => _ViewClassScreenState();
}

class _ViewClassScreenState extends ConsumerState<ViewClassScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Details')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            // Class info section
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.class_, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),

            // Class Name and Section
            Text(
              '${widget.schoolClass.name} - ${widget.schoolClass.section}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),

            // Academic Year
            Text(
              'Academic Year: ${widget.schoolClass.academicYear}',
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

            // Teacher Assignment
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Class Teacher'),
              subtitle: FutureBuilder<String?>(
                // We would need to fetch the teacher name from the teacher ID
                // For now, we'll show the ID or a placeholder
                // In a real implementation, we'd use a provider to get teacher details
                future: Future.value(widget.schoolClass.classTeacherId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  }
                  final teacherId = snapshot.data;
                  if (teacherId == null || teacherId.isEmpty) {
                    return const Text('No teacher assigned',
                        style: TextStyle(color: Colors.grey));
                  }
                  // In a real app, we'd look up the teacher name by ID
                  // For now, we'll show the ID
                  return Text('Teacher ID: $teacherId');
                },
              ),
            ),

            // Created Date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Created Date'),
              subtitle: Text(
                '${widget.schoolClass.createdAt.year}-${widget.schoolClass.createdAt.month.toString().padLeft(2, '0')}-${widget.schoolClass.createdAt.day.toString().padLeft(2, '0')}',
              ),
            ),

            // Status
            ListTile(
              leading: Icon(
                widget.schoolClass.isActive ? Icons.check_circle : Icons.cancel,
                color: widget.schoolClass.isActive ? Colors.green : Colors.red,
              ),
              title: const Text('Status'),
              subtitle: Text(
                widget.schoolClass.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.schoolClass.isActive ? Colors.green : Colors.red,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
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