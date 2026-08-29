import 'package:cms/features/classes/data/models/school_class.dart';
import 'package:cms/features/classes/presentation/widgets/class_search_section.dart';
import 'package:cms/features/classes/presentation/screens/view_class_screen.dart';
import 'package:flutter/material.dart';

class SearchClassesScreen extends StatefulWidget {
  const SearchClassesScreen({super.key});

  @override
  State<SearchClassesScreen> createState() => _SearchClassesScreenState();
}

class _SearchClassesScreenState extends State<SearchClassesScreen> {
  Future<void> _openViewClassScreen(SchoolClass schoolClass) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ViewClassScreen(schoolClass: schoolClass)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Classes')),
      body: ClassSearchSection(
        onClassTap: _openViewClassScreen,
      ),
    );
  }
}