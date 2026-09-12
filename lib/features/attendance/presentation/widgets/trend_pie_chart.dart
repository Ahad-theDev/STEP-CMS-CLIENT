import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/trend_point.dart';

class _Slice {
  final String label;
  final int count;
  final Color color;
  _Slice(this.label, this.count, this.color);
}

class TrendPieChart extends StatelessWidget {
  final List<TrendPoint> points;
  const TrendPieChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No data in this range')),
      );
    }

    int present = 0, absent = 0, late = 0, leave = 0;
    for (final p in points) {
      present += p.present;
      absent += p.absent;
      late += p.late;
      leave += p.leave;
    }
    final total = present + absent + late + leave;
    if (total == 0) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No attendance recorded in this range')),
      );
    }

    final slices = <_Slice>[
      _Slice('Present', present, Colors.green),
      _Slice('Absent', absent, Colors.red),
      _Slice('Late', late, Colors.orange),
      _Slice('Leave', leave, Colors.blue),
    ].where((s) => s.count > 0).toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: slices.map((s) {
                final pct = s.count / total * 100;
                return PieChartSectionData(
                  value: s.count.toDouble(),
                  color: s.color,
                  title: '${pct.toStringAsFixed(0)}%',
                  radius: 70,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: slices
              .map((s) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 10, height: 10, color: s.color),
                      const SizedBox(width: 4),
                      Text('${s.label}: ${s.count}', style: const TextStyle(fontSize: 12)),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }
}