import 'package:flutter_test/flutter_test.dart';
import 'package:cms/features/attendance/data/models/teacher_trends_response.dart';

void main() {
  final base = <String, dynamic>{
    'teacher_id': 'teacher1',
    'date_from': '2026-11-01',
    'date_to': '2026-11-04',
    'classes': <dynamic>[],
  };
  test('own attendance parses without student class records', () {
    final result = TeacherTrendsResponse.fromJson({
      ...base,
      'attendance_trends': [
        {
          'date': '2026-11-01',
          'present': 1,
          'absent': 0,
          'late': 0,
          'leave': 0,
          'percentage': 100,
        },
      ],
    });
    expect(result.classes, isEmpty);
    expect(result.attendanceTrends.single.present, 1);
  });
  test('older server responses still parse existing class trends', () {
    final result = TeacherTrendsResponse.fromJson({
      ...base,
      'classes': [
        {
          'class_id': 'class1',
          'trends': [
            {
              'date': '2026-11-01',
              'present': 3,
              'absent': 1,
              'late': 0,
              'leave': 0,
              'percentage': 75,
            },
          ],
        },
      ],
    });
    expect(result.attendanceTrends, isEmpty);
    expect(result.classes.single.trends.single.present, 3);
  });
}
