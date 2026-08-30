import 'package:cms/features/subjects/presentation/widgets/subject_search_section.dart';
import 'package:flutter/material.dart';

class SearchSubjectScreen extends StatefulWidget {
  const SearchSubjectScreen({super.key});

  @override
  State<SearchSubjectScreen> createState() => _SearchSubjectScreenState();
}

class _SearchSubjectScreenState extends State<SearchSubjectScreen> {
  final _searchSectionKey = GlobalKey<SubjectSearchSectionState>();

  Future<void> _refresh() async {
    await _searchSectionKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SubjectSearchSection(
        key: _searchSectionKey,
        onSubjectTap: (subject) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected: ${subject.name} (${subject.code})')),
          );
        },
      ),
    );
  }
}