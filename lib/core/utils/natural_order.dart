final _numberOrText = RegExp(r'\d+|\D+');

int naturalCompare(String left, String right) {
  final a = _numberOrText.allMatches(left.toLowerCase()).toList();
  final b = _numberOrText.allMatches(right.toLowerCase()).toList();
  for (var i = 0; i < a.length && i < b.length; i++) {
    final x = a[i].group(0)!;
    final y = b[i].group(0)!;
    final nx = BigInt.tryParse(x);
    final ny = BigInt.tryParse(y);
    final order = nx != null && ny != null ? nx.compareTo(ny) : x.compareTo(y);
    if (order != 0) return order;
  }
  return a.length.compareTo(b.length);
}
