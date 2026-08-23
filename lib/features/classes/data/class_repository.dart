import 'package:dio/dio.dart';
import 'package:cms/core/constants/api_constants.dart';
import 'models/school_class.dart';

class ClassRepository {
  final Dio dio;
  ClassRepository(this.dio);

  Future<List<SchoolClass>> listClasses({int page = 1, int limit = 200}) async {
    final response = await dio.get(
      ApiConstants.classes,
      queryParameters: {'page': page, 'limit': limit},
    );
    return (response.data as List).map((e) => SchoolClass.fromJson(e)).toList();
  }
}