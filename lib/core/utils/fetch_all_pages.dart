/// Loads complete collections without assuming that the server honors page size.
/// A failed/repeated page is an error, never a silently truncated collection.
Future<List<T>> fetchAllPages<T>({
  required Future<List<T>> Function(int page, int limit) fetch,
  required String Function(T item) idOf,
  int pageSize = 100,
}) async {
  final result = <T>[];
  final seen = <String>{};
  for (var page = 1; ; page++) {
    final items = await fetch(page, pageSize);
    if (items.isEmpty) return result;
    var added = 0;
    for (final item in items) {
      if (seen.add(idOf(item))) {
        result.add(item);
        added++;
      }
    }
    if (added == 0) {
      throw StateError(
        'Pagination did not advance. Please refresh and try again.',
      );
    }
  }
}
