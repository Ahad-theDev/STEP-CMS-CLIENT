import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'ai_repository_provider.dart';

part 'ai_suggestions_controller.g.dart';

@riverpod
class AiSuggestionsController extends _$AiSuggestionsController {
  @override
  Future<List<String>> build() async {
    final repo = ref.read(aiRepositoryProvider);
    return repo.getSuggestions();
  }

  Future<void> refreshSuggestions() async {
    ref.invalidateSelf();
    await ref.read(aiSuggestionsControllerProvider.future);
  }
}
