import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'models/fee_structure.dart';
import 'models/fee_structure_create_request.dart';
import 'models/fee_structure_update_request.dart';

class FeeStructureRepository {
  final Dio dio;
  FeeStructureRepository(this.dio);

  Future<FeeStructure> createFeeStructure(FeeStructureCreateRequest request) async {
    final response = await dio.post(ApiConstants.feeStructures, data: request.toJson());
    return FeeStructure.fromJson(response.data);
  }

  Future<List<FeeStructure>> listFeeStructures({String? classId, String? academicYear}) async {
    final response = await dio.get(
      ApiConstants.feeStructures,
      queryParameters: {
        if (classId != null) 'class_id': classId,
        if (academicYear != null && academicYear.isNotEmpty) 'academic_year': academicYear,
      },
    );
    return (response.data as List).map((e) => FeeStructure.fromJson(e)).toList();
  }

  Future<FeeStructure> updateFeeStructure(String id, FeeStructureUpdateRequest request) async {
    final response = await dio.put('${ApiConstants.feeStructures}/$id', data: request.toJson());
    return FeeStructure.fromJson(response.data);
  }
}