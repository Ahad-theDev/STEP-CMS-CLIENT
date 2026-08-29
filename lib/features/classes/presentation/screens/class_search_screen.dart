import 'package:cms/features/classes/data/models/school_class.dart';
import 'package:cms/features/classes/presentation/widgets/class_search_section.dart';
import 'package:cms/features/classes/presentation/screens/view_class_screen.dart';
import 'package:flutter/material.dart';

class ClassSearchScreen extends StatefulWidget {
  const ClassSearchScreen({super.key});

  @override
  State<ClassSearchScreen> createState() => _ClassSearchScreenState();
}

class _ClassSearchScreenState extends State<ClassSearchScreen> {
  final GlobalKey<ClassSearchSectionState> _classSearchSectionKey =
      GlobalKey<ClassSearchSectionState>();

  Future<void> _openClassDetailScreen(SchoolClass schoolClass) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ViewClassScreen(schoolClass: schoolClass)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Class List',
            onPressed: () {
              _classSearchSectionKey.currentState?.refresh();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ClassSearchSection(
          key: _classSearchSectionKey,
          onClassTap: _openClassDetailScreen,
        ),
      ),
    );
  }
}