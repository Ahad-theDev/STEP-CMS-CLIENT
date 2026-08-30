import 'package:cms/features/students/data/models/bulk_import_result.dart';
import 'package:cms/features/teachers/data/models/teacher_update_request.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import 'models/teacher.dart';
import 'models/teacher_create_request.dart';

class TeacherRepository {
  final Dio dio;
  TeacherRepository(this.dio);

  /// Management-only, per your router — the bearer token from
  /// AuthInterceptor makes this work automatically once logged in.
  Future<Teacher> createTeacher(TeacherCreateRequest request) async {
    final response = await dio.post(ApiConstants.teachers, data: request.toJson());
    return Teacher.fromJson(response.data);
  }
  Future<List<Teacher>> listTeachers() async {
  final response = await dio.get('${ApiConstants.teachers}/all');
  return (response.data as List).map((e) => Teacher.fromJson(e)).toList();
}

Future<Teacher> updateTeacher(String teacherId, TeacherUpdateRequest request) async {
  final response = await dio.patch('${ApiConstants.teachers}/$teacherId', data: request.toJson());
  return Teacher.fromJson(response.data);
}

Future<void> deleteTeacher(String teacherId) async {
  await dio.delete('${ApiConstants.teachers}/$teacherId');
}


Future<List<Teacher>> searchTeachers({
  String? department,
  String? subjectSpecializationId,
  int page = 1,
  int limit = 20,
}) async {
  final response = await dio.get(
    ApiConstants.teachers,
    queryParameters: {
      if (department != null && department.isNotEmpty) 'department': department,
      if (subjectSpecializationId != null && subjectSpecializationId.isNotEmpty)
        'subject_specialization_id': subjectSpecializationId,
      'page': page,
      'limit': limit,
    },
  );
  return (response.data as List).map((e) => Teacher.fromJson(e)).toList();
}

Future<BulkImportResult> bulkImportTeachers(String filePath, String fileName) async {
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(filePath, filename: fileName),
  });
  final response = await dio.post(ApiConstants.teachersBulkImport, data: formData);
  return BulkImportResult.fromJson(response.data);
}
}