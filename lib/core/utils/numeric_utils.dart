/// Safe numeric parsers that seamlessly handle num, String (e.g. Postgres Decimal "100.00"), and null.
double parseDouble(dynamic val, [double defaultValue = 0.0]) {
  if (val == null) return defaultValue;
  if (val is num) return val.toDouble();
  if (val is String) {
    return double.tryParse(val) ?? defaultValue;
  }
  return defaultValue;
}

double? parseNullableDouble(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toDouble();
  if (val is String) {
    return double.tryParse(val);
  }
  return null;
}

int parseInt(dynamic val, [int defaultValue = 0]) {
  if (val == null) return defaultValue;
  if (val is num) return val.toInt();
  if (val is String) {
    return int.tryParse(val) ?? (double.tryParse(val)?.toInt() ?? defaultValue);
  }
  return defaultValue;
}
