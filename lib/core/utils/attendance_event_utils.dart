import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _secureRandom = Random.secure();

/// Generates an RFC-4122 version 4 UUID string without external dependencies.
String generateEventUuid() {
  final bytes = List<int>.generate(16, (_) => _secureRandom.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int b) => b.toRadixString(16).padLeft(2, '0');
  final h = bytes.map(hex).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
}

/// Formats a DateTime with explicit numeric timezone offset (e.g. +05:00 or -04:00),
/// satisfying FastAPI's requirement that `captured_at` include a timezone offset.
String formatIsoWithLocalOffset(DateTime dt) {
  final local = dt.isUtc ? dt.toLocal() : dt;
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final totalMinutes = offset.inMinutes.abs();
  final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
  final minutes = (totalMinutes % 60).toString().padLeft(2, '0');

  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)}'
      'T${two(local.hour)}:${two(local.minute)}:${two(local.second)}'
      '$sign$hours:$minutes';
}

/// Converts a nullable backend timestamp to local readable 12-hour format.
String formatLocalTime(DateTime? dt, {String fallback = '—'}) {
  if (dt == null) return fallback;
  return DateFormat('hh:mm a').format(dt.toLocal());
}

/// Formats a DateTime into YYYY-MM-DD using local date fields.
String formatApiDate(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}-${two(dt.month)}-${two(dt.day)}';
}

/// Formats a [TimeOfDay] into HH:MM:00 for backend `time` fields.
String formatTimeOfDayForApi(TimeOfDay t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m:00';
}

/// Parses HH:MM[:SS] string into [TimeOfDay].
TimeOfDay parseApiTimeOfDay(String raw) {
  final parts = raw.split(':');
  final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 8 : 8;
  final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
}

int timeOfDayToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

String formatTimeOfDay12h(TimeOfDay t) {
  final dt = DateTime(2026, 1, 1, t.hour, t.minute);
  return DateFormat('hh:mm a').format(dt);
}

/// Combines a calendar date and a [TimeOfDay] in device-local time.
DateTime combineLocalDateAndTime(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

/// Formats total worked minutes as `Xh Ym` (or `0m`).
String formatWorkedDuration(int totalMinutes) {
  if (totalMinutes <= 0) return '0m';
  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}
