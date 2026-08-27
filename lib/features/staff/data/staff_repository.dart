import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'models/staff_member.dart';
import 'models/staff_create_request.dart';
import 'models/staff_update_request.dart';

class StaffRepository {
  final Dio dio;
  StaffRepository(this.dio);

  Future<StaffMember> createStaff(StaffCreateRequest request) async {
    final response = await dio.post(ApiConstants.staff, data: request.toJson());
    return StaffMember.fromJson(response.data);
  }

  Future<StaffMember> getStaff(String staffId) async {
    final response = await dio.get('${ApiConstants.staff}/$staffId');
    return StaffMember.fromJson(response.data);
  }

  Future<List<StaffMember>> listStaff({int page = 1, int limit = 20}) async {
    final response = await dio.get(
      ApiConstants.staff,
      queryParameters: {'page': page, 'limit': limit},
    );
    return (response.data as List).map((e) => StaffMember.fromJson(e)).toList();
  }

  Future<StaffMember> updateStaff(String staffId, StaffUpdateRequest request) async {
    final response = await dio.put('${ApiConstants.staff}/$staffId', data: request.toJson());
    return StaffMember.fromJson(response.data);
  }

  Future<void> deleteStaff(String staffId) async {
    await dio.delete('${ApiConstants.staff}/$staffId');
  }
}