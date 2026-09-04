import 'package:flutter/material.dart';
import '../widgets/lecture_search_section.dart';

class SearchLecturesScreen extends StatelessWidget {
  const SearchLecturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Lectures')),
      body: const SingleChildScrollView(child: LectureSearchSection()),
    );
  }
}