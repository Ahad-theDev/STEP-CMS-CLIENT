import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'package:cms/features/students/data/models/bulk_import_result.dart';
import 'package:cms/features/teachers/data/models/teacher.dart';
import 'models/school_class.dart';
import 'models/class_create_request.dart';
import 'models/class_update_request.dart';
import 'models/assign_teacher_request.dart';

class ClassRepository {
  final Dio dio;
  ClassRepository(this.dio);

  Future<SchoolClass> createClass(ClassCreateRequest request) async {
    final response = await dio.post(ApiConstants.classes, data: request.toJson());
    return SchoolClass.fromJson(response.data);
  }

  Future<SchoolClass> getClass(String classId) async {
    final response = await dio.get('${ApiConstants.classes}/$classId');
    return SchoolClass.fromJson(response.data);
  }

  Future<List<SchoolClass>> listClasses({int page = 1, int limit = 200}) async {
    final response = await dio.get(
      ApiConstants.classes,
      queryParameters: {'page': page, 'limit': limit},
    );
    return (response.data as List).map((e) => SchoolClass.fromJson(e)).toList();
  }

  Future<SchoolClass> updateClass(String classId, ClassUpdateRequest request) async {
    final response = await dio.put('${ApiConstants.classes}/$classId', data: request.toJson());
    return SchoolClass.fromJson(response.data);
  }

  Future<void> deleteClass(String classId) async {
    await dio.delete('${ApiConstants.classes}/$classId');
  }

  Future<void> assignTeacher(String classId, AssignTeacherRequest request) async {
    await dio.patch('${ApiConstants.classes}/$classId/assign-teacher', data: request.toJson());
  }

  /// Returns null if no teacher is assigned yet (backend 404s in that case).
  Future<Teacher?> getClassTeacher(String classId) async {
    try {
      final response = await dio.get('${ApiConstants.classes}/$classId/teacher');
      return Teacher.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<BulkImportResult> bulkImportClasses(String filePath, String fileName) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response = await dio.post(ApiConstants.classesBulkImport, data: formData);
    return BulkImportResult.fromJson(response.data);
  }
}