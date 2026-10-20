import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/presentation/widgets.dart';
import '../domain/body_records.dart';

class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.entries});
  final List<WeightEntry> entries;
  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox(
          height: 150, child: Center(child: Text('この期間の体重記録はありません')));
    }
    final sorted = entries.reversed.toList();
    final values = sorted.map((e) => e.weight.kg).toList();
    final min = values.reduce(math.min);
    final max = values.reduce(math.max);
    return Semantics(
        label:
            '${entries.length}件の体重記録。最小${min.toStringAsFixed(1)}kg、最大${max.toStringAsFixed(1)}kg',
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${max.toStringAsFixed(1)} kg',
                style: const TextStyle(fontSize: 11)),
            Text('${entries.length}件の記録', style: const TextStyle(fontSize: 11))
          ]),
          SizedBox(
              height: 140,
              width: double.infinity,
              child: CustomPaint(
                  painter: _WeightPainter(
                      sorted, Theme.of(context).colorScheme.primary))),
          Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 4,
              children: [
                Text(dayLabel(sorted.first.recordedAt),
                    style: const TextStyle(fontSize: 11)),
                Text('最小 ${min.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 11)),
                Text(dayLabel(sorted.last.recordedAt),
                    style: const TextStyle(fontSize: 11))
              ]),
        ]));
  }
}

class _WeightPainter extends CustomPainter {
  _WeightPainter(this.entries, this.color);
  final List<WeightEntry> entries;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final values = entries.map((e) => e.weight.kg).toList();
    final min = values.reduce(math.min) - 0.5;
    final max = values.reduce(math.max) + 0.5;
    final first = entries.first.recordedAt.millisecondsSinceEpoch;
    final span =
        math.max(1, entries.last.recordedAt.millisecondsSinceEpoch - first);
    final points = entries
        .map((entry) => Offset(
            entries.length == 1
                ? size.width / 2
                : 6 +
                    (size.width - 12) *
                        (entry.recordedAt.millisecondsSinceEpoch - first) /
                        span,
            size.height -
                16 -
                (size.height - 32) * (entry.weight.kg - min) / (max - min)))
        .toList();
    final grid = Paint()
      ..color = const Color(0xFFE8EADD)
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final y = 16 + (size.height - 32) * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    final area = Path.from(path)
      ..lineTo(points.last.dx, size.height - 16)
      ..lineTo(points.first.dx, size.height - 16)
      ..close();
    canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withOpacity(0.2), color.withOpacity(0)])
              .createShader(Offset.zero & size));
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = color);
      canvas.drawCircle(point, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightPainter oldDelegate) =>
      oldDelegate.entries != entries || oldDelegate.color != color;
}
