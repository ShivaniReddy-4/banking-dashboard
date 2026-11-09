import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/format.dart';

/// Bar chart for the last 7 days of spending.
class WeekBarsPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color barColor;
  final Color todayColor;
  final Color textColor;

  WeekBarsPainter({
    required this.values,
    required this.labels,
    required this.barColor,
    required this.todayColor,
    required this.textColor,
  });

  void _text(Canvas canvas, String s, double cx, double y, {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(fontSize: 10, color: textColor, fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, y));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    final maxV = max(values.fold<double>(0, max), 1.0);
    const topPad = 16.0;
    const bottomPad = 20.0;
    final chartH = size.height - topPad - bottomPad;
    final slot = size.width / n;
    final barW = slot * 0.5;

    for (int i = 0; i < n; i++) {
      final cx = slot * i + slot / 2;
      final h = max(values[i] / maxV * chartH, 3.0);
      final top = topPad + (chartH - h);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - barW / 2, top, barW, h),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, Paint()..color = i == n - 1 ? todayColor : barColor);
      if (values[i] > 0) _text(canvas, shortMoney(values[i]), cx, top - 14);
      _text(canvas, labels[i], cx, size.height - 14, bold: i == n - 1);
    }
  }

  @override
  bool shouldRepaint(covariant WeekBarsPainter old) => true;
}

/// Donut chart of values with matching colors.
class DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final Color emptyColor;

  DonutPainter({required this.values, required this.colors, required this.emptyColor});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 26.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final total = values.fold<double>(0, (a, b) => a + b);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    if (total <= 0) {
      canvas.drawArc(rect, 0, 2 * pi, false, base..color = emptyColor);
      return;
    }

    double start = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * pi;
      canvas.drawArc(rect, start, max(sweep - 0.03, 0.001), false, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = colors[i]);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutPainter old) => true;
}
