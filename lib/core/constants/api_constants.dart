class ApiConstants {
  // static const String baseUrl = 'http://10.0.2.2:8000/';
  // static const String baseUrl = 'http://127.0.0.1:8000/';
  static const String baseUrl =
      'https://overhand-nebula-appliance.ngrok-free.dev/';
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String refresh = 'auth/refresh';
  static const String me = 'auth/me';
  static const String students = 'students';
  static const String classes = 'classes';
  static const String teachers = 'teachers';
  static const String teachersBulkImport = 'teachers/bulk-import';
  static const String studentsBulkImport = 'students/bulk-import';
  static const String staff = 'staff';
  static const String classesBulkImport = 'classes/bulk-import';
  static const String subjects = 'subjects';
  static const String lectures = 'lectures';
static const String schedulePreview = 'schedule/preview';
static const String scheduleBulkShift = 'schedule/bulk-shift';
static const String schedulePublish = 'schedule/publish';
static const String calendarHolidays = 'calendar/holidays';
}
