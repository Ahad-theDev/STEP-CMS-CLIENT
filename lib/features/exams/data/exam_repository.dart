import 'package:dio/dio.dart';
import 'package:cms/features/exams/data/models/exam_model.dart';
import 'package:cms/features/exams/data/models/exam_subject_model.dart';
import 'package:cms/features/exams/data/models/exam_marks_grid_model.dart';
import 'package:cms/features/exams/data/models/bulk_marks_save_request.dart';
import 'package:cms/features/exams/data/models/exam_results_model.dart';
import 'package:cms/features/exams/data/models/exam_correction_model.dart';

class ExamException implements Exception {
  final String message;
  final int? statusCode;

  ExamException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ExamRepository {
  final Dio _dio;

  ExamRepository(this._dio);

  Never _handleError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      String? msg;
      if (data is Map) {
        if (data['error'] is Map && data['error']['message'] != null) {
          msg = data['error']['message'].toString();
        } else if (data['detail'] != null) {
          if (data['detail'] is List) {
            msg = (data['detail'] as List)
                .map((item) => item is Map ? item['msg'] : item.toString())
                .join(', ');
          } else {
            msg = data['detail'].toString();
          }
        } else if (data['message'] != null) {
          msg = data['message'].toString();
        }
      }
      throw ExamException(
        msg ?? e.message ?? 'An unexpected network error occurred',
        e.response?.statusCode,
      );
    }
    throw ExamException(e.toString());
  }

  /// 1. List exams (GET /exams)
  Future<ExamListResponse> listExams({
    int page = 1,
    int limit = 20,
    String? classId,
    String? academicYear,
  }) async {
    try {
      final q = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (classId != null && classId.isNotEmpty) q['class_id'] = classId;
      if (academicYear != null && academicYear.isNotEmpty) {
        q['academic_year'] = academicYear;
      }

      final response = await _dio.get('/exams', queryParameters: q);
      return ExamListResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _handleError(e);
    }
  }

  /// 2. Create exam (POST /exams)
  Future<Exam> createExam(ExamCreateRequest req) async {
    try {
      final response = await _dio.post('/exams', data: req.toJson());
      return Exam.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _handleError(e);
    }
  }

  /// 3. Get exam details (GET /exams/{exam_id})
  Future<ExamMarksGrid> getExamDetails(String examId) async {
    try {
      final response = await _dio.get('/exams/$examId');
      return ExamMarksGrid.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _handleError(e);
    }
  }

  /// 4. Add subjects to exam (POST /exams/{exam_id}/subjects)
  Future<List<ExamSubject>> addSubjects(
    String examId,
    List<ExamSubjectCreate> subjects,
  ) async {
    try {
      final response = await _dio.post(
        '/exams/$examId/subjects',
        data: {'subjects': subjects.map((s) => s.toJson()).toList()},
      );
      final rawList = response.data as List<dynamic>? ?? [];
      return rawList
          .map((s) => ExamSubject.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _handleError(e);
    }
  }

  /// 5. Replace/Update complete subject configuration (PUT /exams/{exam_id}/subjects)
  Future<List<ExamSubject>> replaceSubjects(
    String examId,
    List<ExamSubjectUpdate> subjects,
  ) async {
    try {
      final response = await _dio.put(
        '/exams/$examId/subjects',
        data: {'subjects': subjects.map((s) => s.toJson()).toList()},
      );
      final rawList = response.data as List<dynamic>? ?? [];
      return rawList
          .map((s) => ExamSubject.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _handleError(e);
    }
  }

  /// 6. Load marks grid (GET /exams/{exam_id}/marks-grid)
  Future<ExamMarksGrid> getMarksGrid(String examId) async {
    try {
      final response = await _dio.get('/exams/$examId/marks-grid');
      return ExamMarksGrid.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _handleError(e);
    }
  }

  /// 7. Save complete marks grid / Publish results (PUT /exams/{exam_id}/marks)
  Future<BulkExamMarksResponse> saveAllMarks(
    String examId,
    BulkExamMarksRequest req,
  ) async {
    try {
      final response = await _dio.put('/exams/$examId/marks', data: req.toJson());
      return BulkExamMarksResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  /// 8. Explicit publish (POST /exams/{exam_id}/publish)
  Future<Map<String, dynamic>> publishExam(String examId) async {
    try {
      final response = await _dio.post('/exams/$examId/publish');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      _handleError(e);
    }
  }

  /// 9. Class results (GET /exams/{exam_id}/results)
  Future<ExamClassResults> getClassResults(String examId) async {
    try {
      final response = await _dio.get('/exams/$examId/results');
      return ExamClassResults.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _handleError(e);
    }
  }

  /// 10. Correct single result (PATCH /exams/{exam_id}/results/{result_id})
  Future<Map<String, dynamic>> correctResult(
    String examId,
    String resultId,
    ExamResultCorrection req,
  ) async {
    try {
      final response = await _dio.patch(
        '/exams/$examId/results/$resultId',
        data: req.toJson(),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      _handleError(e);
    }
  }

  /// 11. Correction history audit (GET /exams/{exam_id}/results/{result_id}/audit)
  Future<List<ExamResultAudit>> getResultAudit(
    String examId,
    String resultId,
  ) async {
    try {
      final response = await _dio.get(
        '/exams/$examId/results/$resultId/audit',
      );
      final rawList = response.data as List<dynamic>? ?? [];
      return rawList
          .map((a) => ExamResultAudit.fromJson(a as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _handleError(e);
    }
  }

  /// 12. Student exam history (GET /students/{student_id}/exam-results)
  Future<StudentExamHistoryResponse> getStudentExamHistory(
    String studentId, {
    String? academicYear,
    String? examType,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final q = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (academicYear != null && academicYear.isNotEmpty) {
        q['academic_year'] = academicYear;
      }
      if (examType != null && examType.isNotEmpty) q['exam_type'] = examType;
      if (dateFrom != null && dateFrom.isNotEmpty) q['date_from'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) q['date_to'] = dateTo;

      final response = await _dio.get(
        '/students/$studentId/exam-results',
        queryParameters: q,
      );
      return StudentExamHistoryResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      _handleError(e);
    }
  }
}
