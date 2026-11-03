import 'package:flutter_test/flutter_test.dart';
import 'package:cms/core/utils/fetch_all_pages.dart';

void main() {
  test('loads 1257 students across every page', () async {
    final source = List.generate(1257, (i) => '$i');
    final loaded = await fetchAllPages<String>(
      idOf: (s) => s,
      fetch: (page, limit) async =>
          source.skip((page - 1) * limit).take(limit).toList(),
    );
    expect(loaded, source);
  });
  test('continues when server returns fewer than requested', () async {
    final source = List.generate(600, (i) => '$i');
    final loaded = await fetchAllPages<String>(
      idOf: (s) => s,
      fetch: (page, _) async => source.skip((page - 1) * 30).take(30).toList(),
    );
    expect(loaded, source);
  });
  test('empty collection finishes', () async {
    expect(
      await fetchAllPages<String>(idOf: (s) => s, fetch: (_, _) async => []),
      isEmpty,
    );
  });
  test('page failure does not return a misleading partial count', () async {
    await expectLater(
      fetchAllPages<String>(
        idOf: (s) => s,
        fetch: (page, _) async {
          if (page == 2) throw Exception('offline');
          return ['one'];
        },
      ),
      throwsException,
    );
  });
  test('repeated page fails instead of looping forever', () async {
    await expectLater(
      fetchAllPages<String>(idOf: (s) => s, fetch: (_, _) async => ['one']),
      throwsStateError,
    );
  });
  test('overlapping pages do not duplicate records', () async {
    final pages = [
      ['1', '2'],
      ['2', '3'],
      <String>[],
    ];
    expect(
      await fetchAllPages<String>(
        idOf: (s) => s,
        fetch: (page, _) async => pages[page - 1],
      ),
      ['1', '2', '3'],
    );
  });
}
