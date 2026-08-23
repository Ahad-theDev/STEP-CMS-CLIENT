import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cms/core/network/dio_client.dart';
import '../data/class_repository.dart';

part 'class_repository_provider.g.dart';

@riverpod
ClassRepository classRepository(ClassRepositoryRef ref) {
  return ClassRepository(ref.read(dioProvider));
}