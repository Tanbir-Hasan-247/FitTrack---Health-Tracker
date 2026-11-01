import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/weight_record.dart';

/// Interactive and sleek CustomPainter line chart for weight history
class WeightTrendChart extends StatelessWidget {
  final List<WeightRecord> records;
  final double height;

  const WeightTrendChart({super.key, required this.records, this.height = 200});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        child: const Text(
          'No weight records logged yet',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      );
    }

    // Sort chronologically ascending for the chart
    final sorted = List<WeightRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Limit to latest 14 data points for clean rendering
    final displayList = sorted.length > 14
        ? sorted.sublist(sorted.length - 14)
        : sorted;

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: CustomPaint(
        size: Size.infinite,
        painter: _WeightLineChartPainter(records: displayList),
      ),
    );
  }
}

class _WeightLineChartPainter extends CustomPainter {
  final List<WeightRecord> records;

  _WeightLineChartPainter({required this.records});

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;

    final weights = records.map((e) => e.weightKg).toList();
    double minWeight = weights.reduce(math.min);
    double maxWeight = weights.reduce(math.max);

    // Add padding to bounds
    if (minWeight == maxWeight) {
      minWeight -= 2;
      maxWeight += 2;
    } else {
      final range = maxWeight - minWeight;
      minWeight -= range * 0.15;
      maxWeight += range * 0.15;
    }

    final double bottomPadding = 24.0;
    final double graphHeight = size.height - bottomPadding;
    final double graphWidth = size.width;

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = AppColors.cardBorder.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 3; i++) {
      final y = graphHeight * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(graphWidth, y), gridPaint);
    }

    if (records.length == 1) {
      final y = graphHeight / 2;
      final x = graphWidth / 2;
      final pointPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 6, pointPaint);
      return;
    }

    final points = <Offset>[];
    final stepX = graphWidth / (records.length - 1);

    for (int i = 0; i < records.length; i++) {
      final x = i * stepX;
      final normalizedY =
          (records[i].weightKg - minWeight) / (maxWeight - minWeight);
      final y = graphHeight - (normalizedY * graphHeight);
      points.add(Offset(x, y));
    }

    // Gradient fill under the line
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, graphHeight);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlX = (p1.dx + p2.dx) / 2;
      fillPath.cubicTo(controlX, p1.dy, controlX, p2.dy, p2.dx, p2.dy);
    }

    fillPath.lineTo(points.last.dx, graphHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.35),
          AppColors.primary.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, graphWidth, graphHeight));

    canvas.drawPath(fillPath, fillPaint);

    // Draw the main line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlX = (p1.dx + p2.dx) / 2;
      linePath.cubicTo(controlX, p1.dy, controlX, p2.dy, p2.dx, p2.dy);
    }

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // Draw data points & value labels
    for (int i = 0; i < points.length; i++) {
      // Draw point
      canvas.drawCircle(points[i], 4.5, Paint()..color = AppColors.surface);
      canvas.drawCircle(points[i], 3.0, Paint()..color = AppColors.primary);

      // Draw date labels on first, middle, last points
      if (i == 0 || i == points.length - 1 || i == points.length ~/ 2) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: records[i].date.length >= 5
                ? records[i].date.substring(5)
                : records[i].date,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final labelX = (points[i].dx - textPainter.width / 2).clamp(
          0.0,
          graphWidth - textPainter.width,
        );
        textPainter.paint(canvas, Offset(labelX, graphHeight + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WeightLineChartPainter oldDelegate) {
    return oldDelegate.records != records;
  }
}

/// Clean 7-day Bar Chart for Workouts and Water tracking
class WeeklyBarChart extends StatelessWidget {
  final Map<String, num> dailyData; // date 'yyyy-MM-dd' -> value
  final String unit;
  final Color barColor;
  final double height;

  const WeeklyBarChart({
    super.key,
    required this.dailyData,
    this.unit = '',
    this.barColor = AppColors.secondary,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final entries = dailyData.entries.toList();
    final maxValue = entries.map((e) => e.value.toDouble()).fold(0.0, math.max);
    final safeMax = maxValue == 0 ? 1.0 : maxValue;
    final maxBarHeight = (height - 90).clamp(20.0, 300.0);

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.map((entry) {
          final val = entry.value.toDouble();
          final percentage = (val / safeMax).clamp(0.0, 1.0);
          final dateParts = entry.key.split('-');
          final dayLabel = dateParts.length == 3
              ? '${dateParts[1]}/${dateParts[2]}'
              : entry.key;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                val > 0
                    ? (val >= 1000
                          ? '${(val / 1000).toStringAsFixed(1)}k'
                          : val.toInt().toString())
                    : '0',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 22,
                height: maxBarHeight * (percentage > 0.08 ? percentage : 0.08),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [barColor, barColor.withValues(alpha: 0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dayLabel,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Circular Goal Progress Ring
class CircularGoalProgress extends StatelessWidget {
  final double current;
  final double target;
  final String unit;
  final Color progressColor;
  final double size;

  const CircularGoalProgress({
    super.key,
    required this.current,
    required this.target,
    this.unit = 'ml',
    this.progressColor = AppColors.secondary,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentText = '${(progress * 100).toInt()}%';

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              progress: progress,
              color: progressColor,
              backgroundColor: AppColors.surfaceLight,
              strokeWidth: 10,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                percentText,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${current.toInt()} / ${target.toInt()} $unit',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Active arc
    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
