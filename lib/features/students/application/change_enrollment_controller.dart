import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'student_repository_provider.dart';
import '../data/models/enrollment_change_request.dart';

part 'change_enrollment_controller.g.dart';

@riverpod
class ChangeEnrollmentController extends _$ChangeEnrollmentController {
  @override
  FutureOr<void> build() {}

  Future<bool> changeEnrollment(String studentId, EnrollmentChangeRequest request) async {
    state = const AsyncLoading();
    final repo = ref.read(studentRepositoryProvider);
    try {
      await repo.changeEnrollment(studentId, request);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}