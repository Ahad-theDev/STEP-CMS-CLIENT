import 'package:flutter/material.dart';
import '../../data/models/trend_point.dart';

class TrendBarChart extends StatelessWidget {
  final List<TrendPoint> points;
  static const double _chartHeight = 160;
  static const double _barWidth = 28;

  const TrendBarChart({super.key, required this.points});

  Color _barColor(double pct) {
    if (pct >= 85) return Colors.green;
    if (pct >= 75) return Colors.orange;
    return Colors.red;
  }

  String _shortDate(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    return '${parts[2]}/${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: _chartHeight,
        child: Center(child: Text('No data in this range')),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((p) {
          final pct = p.percentage.clamp(0, 100);
          final barHeight = (_chartHeight - 40) * (pct / 100);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${pct.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10)),
                const SizedBox(height: 4),
                Container(
                  width: _barWidth,
                  height: barHeight < 2 ? 2 : barHeight,
                  decoration: BoxDecoration(
                    color: _barColor(pct.toDouble()),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: _barWidth + 8,
                  child: Text(
                    _shortDate(p.date),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}