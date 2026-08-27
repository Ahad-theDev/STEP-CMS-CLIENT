import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cms/core/network/dio_client.dart';
import '../data/staff_repository.dart';

part 'staff_repository_provider.g.dart';

@riverpod
StaffRepository staffRepository(StaffRepositoryRef ref) {
  return StaffRepository(ref.read(dioProvider));
}