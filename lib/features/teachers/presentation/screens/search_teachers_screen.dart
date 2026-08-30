import 'package:flutter/material.dart';
import '../widgets/teacher_search_section.dart';

class SearchTeachersScreen extends StatelessWidget {
  const SearchTeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Teachers')),
      body: const SingleChildScrollView(child: TeacherSearchSection()),
    );
  }
}