import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'models/lecture.dart';
import 'models/lecture_create_request.dart';
import 'models/lecture_update_request.dart';
import 'models/lecture_override_request.dart';
import 'models/lecture_override.dart';

class LectureRepository {
  final Dio dio;
  LectureRepository(this.dio);

  Future<Lecture> createLecture(LectureCreateRequest request) async {
    final response = await dio.post(ApiConstants.lectures, data: request.toJson());
    return Lecture.fromJson(response.data);
  }

  Future<List<Lecture>> listLectures({
    String? classId,
    String? teacherId,
    String? dayOfWeek,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await dio.get(
      ApiConstants.lectures,
      queryParameters: {
        if (classId != null) 'class_id': classId,
        if (teacherId != null) 'teacher_id': teacherId,
        if (dayOfWeek != null) 'day_of_week': dayOfWeek,
        'page': page,
        'limit': limit,
      },
    );
    return (response.data as List).map((e) => Lecture.fromJson(e)).toList();
  }

  Future<Lecture> updateLecture(String lectureId, LectureUpdateRequest request) async {
    final response = await dio.put('${ApiConstants.lectures}/$lectureId', data: request.toJson());
    return Lecture.fromJson(response.data);
  }

  Future<void> deleteLecture(String lectureId) async {
    await dio.delete('${ApiConstants.lectures}/$lectureId');
  }

  Future<LectureOverride> createOverride(
      String templateLectureId, LectureOverrideRequest request) async {
    final response = await dio.post(
      '${ApiConstants.lectures}/$templateLectureId/overrides',
      data: request.toJson(),
    );
    return LectureOverride.fromJson(response.data);
  }
}