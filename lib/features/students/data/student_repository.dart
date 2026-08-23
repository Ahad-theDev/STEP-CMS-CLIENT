import 'package:cms/core/constants/api_constants.dart';
import 'package:cms/features/students/data/models/student.dart';
import 'package:cms/features/students/data/models/student_create_request.dart';
import 'package:dio/dio.dart';

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
