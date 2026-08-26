import 'package:flutter/material.dart';
import 'package:cms/features/students/data/models/student.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(student.fullName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Full Name'),
              subtitle: Text(student.fullName),
            ),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Roll Number'),
              subtitle: Text(student.rollNumber),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Guardian Name'),
              subtitle: Text(student.guardianName ?? '-'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Guardian Phone'),
              subtitle: Text(student.guardianPhone ?? '-'),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Monthly Fee'),
              subtitle: Text('${student.monthlyFee}'),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Discount'),
              subtitle: Text('${student.discount}'),
            ),
            ListTile(
              leading: Icon(
                student.isActive ? Icons.check_circle : Icons.cancel,
                color: student.isActive ? Colors.green : Colors.red,
              ),
              title: const Text('Status'),
              subtitle: Text(student.isActive ? 'Active' : 'Inactive'),
            ),
          ],
        ),
      ),
    );
  }
}