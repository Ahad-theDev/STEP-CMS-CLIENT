import 'package:flutter/material.dart';
import '../widgets/defaulters_section.dart';

class DefaultersScreen extends StatelessWidget {
  const DefaultersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Defaulters')),
      body: const DefaultersSection(),
    );
  }
}