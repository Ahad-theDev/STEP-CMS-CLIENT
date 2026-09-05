import 'package:flutter/material.dart';
import '../widgets/lecture_search_section.dart';
import '../../data/models/lecture.dart';

class SelectLectureRichScreen extends StatelessWidget {
  final String title;
  const SelectLectureRichScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: LectureSearchSection(
          onLectureTap: (Lecture lecture) => Navigator.of(context).pop(lecture),
        ),
      ),
    );
  }
}