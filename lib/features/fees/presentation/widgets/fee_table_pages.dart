import 'package:flutter/material.dart';

class FeeTablePages<T> extends StatefulWidget {
  const FeeTablePages({
    super.key,
    required this.records,
    required this.builder,
  });

  final List<T> records;
  final Widget Function(List<T>) builder;

  @override
  State<FeeTablePages<T>> createState() => _FeeTablePagesState<T>();
}

class _FeeTablePagesState<T> extends State<FeeTablePages<T>> {
  static const _pageSize = 25;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final count = widget.records.length;
    final last = count == 0 ? 0 : (count - 1) ~/ _pageSize;
    final page = _page.clamp(0, last);
    final start = page * _pageSize;
    final records = widget.records.skip(start).take(_pageSize).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('${start + 1}–${start + records.length} of $count records'),
            IconButton(
              tooltip: 'Previous page',
              icon: const Icon(Icons.chevron_left),
              onPressed: page == 0
                  ? null
                  : () => setState(() => _page = page - 1),
            ),
            IconButton(
              tooltip: 'Next page',
              icon: const Icon(Icons.chevron_right),
              onPressed: page == last
                  ? null
                  : () => setState(() => _page = page + 1),
            ),
          ],
        ),
        widget.builder(records),
      ],
    );
  }
}
