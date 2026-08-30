import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'models/subject.dart';
import 'models/subject_create_request.dart';
import 'models/subject_update_request.dart';

class SubjectRepository {
  final Dio dio;
  SubjectRepository(this.dio);

  Future<Subject> createSubject(SubjectCreateRequest request) async {
    final response = await dio.post(ApiConstants.subjects, data: request.toJson());
    return Subject.fromJson(response.data);
  }

  Future<List<Subject>> listSubjects({int page = 1, int limit = 200}) async {
    final response = await dio.get(
      ApiConstants.subjects,
      queryParameters: {'page': page, 'limit': limit},
    );
    return (response.data as List).map((e) => Subject.fromJson(e)).toList();
  }

  Future<Subject> updateSubject(String subjectId, SubjectUpdateRequest request) async {
    final response = await dio.put('${ApiConstants.subjects}/$subjectId', data: request.toJson());
    return Subject.fromJson(response.data);
  }

  Future<void> deleteSubject(String subjectId) async {
    await dio.delete('${ApiConstants.subjects}/$subjectId');
  }
}