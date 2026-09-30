import 'package:cms/core/network/dio_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/ai_repository.dart';

part 'ai_repository_provider.g.dart';

@riverpod
AiRepository aiRepository(AiRepositoryRef ref) {
  return AiRepository(ref.read(dioProvider));
}
