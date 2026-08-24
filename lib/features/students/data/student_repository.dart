import 'package:cms/core/constants/api_constants.dart';
import 'package:cms/features/students/data/models/student.dart';
import 'package:cms/features/students/data/models/student_create_request.dart';
import 'package:dio/dio.dart';
import 'models/student_update_request.dart';
import 'models/enrollment_change_request.dart';

class StudentRepository {
  final Dio dio;
  StudentRepository(this.dio);

  Future<Student> createStudent(StudentCreateRequest request) async {
    final response = await dio.post(
      ApiConstants.students,
      data: request.toJson(),
    );
    return Student.fromJson(response.data);
  }

  Future<Student> getStudent(String studentId) async {
    final response = await dio.get('${ApiConstants.students}/$studentId');
    return Student.fromJson(response.data);
  }

  Future<Student> updateStudent(
    String studentId,
    StudentUpdateRequest request,
  ) async {
    final response = await dio.put(
      '${ApiConstants.students}/$studentId',
      data: request.toJson(),
    );
    return Student.fromJson(response.data);
  }

  Future<void> deleteStudent(String studentId) async {
    await dio.delete('${ApiConstants.students}/$studentId');
  }

  Future<void> changeEnrollment(
    String studentId,
    EnrollmentChangeRequest request,
  ) async {
    await dio.patch(
      '${ApiConstants.students}/$studentId/enrollment',
      data: request.toJson(),
    );
  }

  Future<List<Student>> listStudents({
    String? classId,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await dio.get(
      ApiConstants.students,
      queryParameters: {
        if (classId != null) 'class_id': classId,
        'page': page,
        'limit': limit,
      },
    );
    return (response.data as List).map((e) => Student.fromJson(e)).toList();
  }
}
