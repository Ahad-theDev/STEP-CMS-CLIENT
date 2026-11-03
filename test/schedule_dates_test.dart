import 'package:flutter_test/flutter_test.dart';
import 'package:cms/core/utils/schedule_dates.dart';

void main() {
  test('Full-week lecture uses its weekday rather than today', () {
    expect(
      scheduleDateForWeekday(DateTime(2026, 11, 3), 'friday'),
      DateTime(2026, 11, 6),
    );
  });
  test('Sunday belongs to the week ending that day', () {
    expect(
      scheduleDateForWeekday(DateTime(2026, 11, 8), 'monday'),
      DateTime(2026, 11, 2),
    );
    expect(
      scheduleDateForWeekday(DateTime(2026, 11, 8), 'sunday'),
      DateTime(2026, 11, 8),
    );
  });
  test('Week calculation crosses year boundaries and removes time', () {
    expect(
      scheduleDateForWeekday(DateTime(2027, 1, 1, 22), 'monday'),
      DateTime(2026, 12, 28),
    );
  });
  test('Unknown weekdays are rejected', () {
    expect(
      () => scheduleDateForWeekday(DateTime(2026, 11, 3), 'invalid'),
      throwsArgumentError,
    );
  });
}
