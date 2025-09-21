import 'dart:math' as math;

import 'package:devhub_gpt/features/dashboard/presentation/providers/commit_chart_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommitActivityCard extends ConsumerWidget {
  const CommitActivityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(chartPeriodProvider);
    final pointsAsync = ref.watch(commitChartDataProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _Header(title: 'Commit Activity'),
                _PeriodToggle(
                  period: period,
                  onChanged: (p) =>
                      ref.read(chartPeriodProvider.notifier).state = p,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: pointsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (e, _) => Text(
                  'Error: $e',
                  style: const TextStyle(color: Colors.redAccent),
                ),
                data: (points) {
                  if (points.isEmpty) {
                    return const Center(child: Text('No data'));
                  }
                  return _SmoothLineChart(points: points);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.show_chart, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.period, required this.onChanged});
  final ChartPeriod period;
  final ValueChanged<ChartPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final is7 = period == ChartPeriod.days7;
    final color = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Row(
        children: [
          _SegmentButton(
            label: '7 days',
            selected: is7,
            onTap: () => onChanged(ChartPeriod.days7),
          ),
          _SegmentDivider(color: color.outlineVariant),
          _SegmentButton(
            label: '30 days',
            selected: !is7,
            onTap: () => onChanged(ChartPeriod.days30),
          ),
        ],
      ),
    );
  }
}

class _SegmentDivider extends StatelessWidget {
  const _SegmentDivider({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: color.withValues(alpha: 0.5));
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected ? scheme.primary : Colors.transparent;
    final fg = selected ? scheme.onPrimary : scheme.onSurfaceVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: bg,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _SmoothLineChart extends StatelessWidget {
  const _SmoothLineChart({required this.points});
  final List<ChartPoint> points; // assumed chronological (oldest -> newest)

  @override
  Widget build(BuildContext context) {
    final maxY = (points.fold<int>(
      0,
      (m, p) => math.max(m, p.count),
    )).clamp(0, 100000);
    final primary = Theme.of(context).colorScheme.primary;
    return _InteractiveChart(
      points: points,
      maxY: math.max(1, maxY),
      primary: primary,
    );
  }
}

class _InteractiveChart extends StatefulWidget {
  const _InteractiveChart({
    required this.points,
    required this.maxY,
    required this.primary,
  });
  final List<ChartPoint> points;
  final int maxY;
  final Color primary;

  @override
  State<_InteractiveChart> createState() => _InteractiveChartState();
}

class _InteractiveChartState extends State<_InteractiveChart> {
  int? hovered;

  Rect _chartRect(Size size) => Rect.fromLTWH(
        _ChartPainter.padL,
        _ChartPainter.padT,
        size.width - _ChartPainter.padL - _ChartPainter.padR,
        180 - _ChartPainter.padT - _ChartPainter.padB,
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, 180);
        final rect = _chartRect(size);
        final n = widget.points.length.clamp(1, 1000);
        Offset posFor(int i) {
          final t = n == 1 ? 0.0 : i / (n - 1);
          final x = rect.left + t * rect.width;
          final value = widget.points[i].count.toDouble();
          final y = _ChartPainter.yFor(value, rect, widget.maxY.toDouble());
          return Offset(x, y);
        }

        Widget bubble() {
          if (hovered == null) return const SizedBox.shrink();
          final i = hovered!.clamp(0, widget.points.length - 1);
          final p = widget.points[i];
          final pos = posFor(i);
          final date = p.date;
          final label =
              '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
          final samples = p.samples;
          final theme = Theme.of(context);
          final tooltipTheme = TooltipTheme.of(context);
          final left = (pos.dx + 8).clamp(rect.left, rect.right - 280);
          final top = (pos.dy - 8 - 96).clamp(rect.top, rect.bottom - 96);

          final decoration = _tooltipDecoration(context, tooltipTheme);
          final padding = tooltipTheme.padding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
          final baseStyle = _tooltipTextStyle(context, tooltipTheme);
          final accentColor =
              baseStyle.color ?? theme.colorScheme.onInverseSurface;
          final mutedStyle = baseStyle.copyWith(
            color: accentColor.withValues(alpha: 0.7),
          );
          final titleStyle = baseStyle.copyWith(fontWeight: FontWeight.w700);

          return Positioned(
            left: left,
            top: top,
            child: DecoratedBox(
              decoration: decoration,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Padding(
                  padding: padding,
                  child: DefaultTextStyle(
                    style: baseStyle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$label • ${p.count} commits', style: titleStyle),
                        const SizedBox(height: 6),
                        if (p.count > 0) ...[
                          for (final s in samples.take(3)) Text('• $s'),
                        ],
                        if (p.count > samples.length)
                          Text('• …', style: mutedStyle),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return MouseRegion(
          onExit: (_) => setState(() => hovered = null),
          onHover: (e) {
            final dx = e.localPosition.dx;
            final dy = e.localPosition.dy;
            if (!rect.contains(Offset(dx, dy))) {
              if (hovered != null) setState(() => hovered = null);
              return;
            }
            final t = ((dx - rect.left) / rect.width).clamp(0.0, 1.0);
            final idx = (t * (n - 1)).round();
            if (hovered != idx) setState(() => hovered = idx);
          },
          child: Stack(
            children: [
              CustomPaint(
                size: size,
                painter: _ChartPainter(
                  points: widget.points,
                  maxY: widget.maxY,
                  primary: widget.primary,
                  highlight: hovered,
                ),
                child: SizedBox(width: size.width, height: size.height),
              ),
              bubble(),
            ],
          ),
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.points,
    required this.maxY,
    required this.primary,
    this.highlight,
  });
  final List<ChartPoint> points;
  final int maxY;
  final Color primary;
  final int? highlight;

  static const double padL = 36;
  static const double padR = 12;
  static const double padT = 12;
  static const double padB = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final chartRect = Rect.fromLTWH(
      padL,
      padT,
      size.width - padL - padR,
      size.height - padT - padB,
    );
    const scheme = Colors.grey;

    // Grid lines (4 horizontals)
    final gridPaint = Paint()
      ..color = scheme.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = chartRect.top + chartRect.height * i / 4;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    // Axes labels (min/max on X, max on Y)
    void tp(String text, Offset pos, {TextAlign align = TextAlign.left}) {
      final span = TextSpan(
        text: text,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      );
      final painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: align,
      );
      painter.layout();
      painter.paint(canvas, pos);
    }

    if (points.isNotEmpty) {
      final first = points.first.date;
      final last = points.last.date;
      tp(
        '${first.month}/${first.day}',
        Offset(chartRect.left, chartRect.bottom + 6),
      );
      final endLabel = '${last.month}/${last.day}';
      final endPainter = TextPainter(
        text: TextSpan(
          text: endLabel,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      endPainter.paint(
        canvas,
        Offset(chartRect.right - endPainter.width, chartRect.bottom + 6),
      );
      tp(maxY.toString(), Offset(4, chartRect.top - 6));
      tp('0', Offset(4, chartRect.bottom - 6));
    }

    if (points.length < 2) return;

    // Build path for line
    final linePaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final n = points.length;
    for (int i = 0; i < n; i++) {
      final p = points[i];
      final t = i / (n - 1);
      final x = chartRect.left + t * chartRect.width;
      final y = _yFor(p.count.toDouble(), chartRect, maxY.toDouble());
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    // Fill under curve (subtle)
    final fillPath = Path.from(path)
      ..lineTo(chartRect.right, chartRect.bottom)
      ..lineTo(chartRect.left, chartRect.bottom)
      ..close();
    final fillPaint = Paint()..color = primary.withValues(alpha: 0.08);
    canvas.drawPath(fillPath, fillPaint);

    // Draw small circles
    final dotPaint = Paint()..color = primary;
    for (int i = 0; i < n; i++) {
      final t = i / (n - 1);
      final x = chartRect.left + t * chartRect.width;
      final y = _yFor(points[i].count.toDouble(), chartRect, maxY.toDouble());
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
      // Date labels for every day under the corresponding point
      final d = points[i].date;
      final s =
          '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
      final labelPainter = TextPainter(
        text: TextSpan(
          text: s,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final lx = (x - labelPainter.width / 2).clamp(
        chartRect.left,
        chartRect.right - labelPainter.width,
      );
      labelPainter.paint(canvas, Offset(lx, chartRect.bottom + 6));
    }

    // Highlighted point magnifier + guide
    if (highlight != null && highlight! >= 0 && highlight! < n) {
      final i = highlight!;
      final t = i / (n - 1);
      final x = chartRect.left + t * chartRect.width;
      final y = _yFor(points[i].count.toDouble(), chartRect, maxY.toDouble());
      // Vertical guide line
      final guide = Paint()
        ..color = primary.withValues(alpha: 0.35)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom),
        guide,
      );
      // Magnifier circle
      final lens = Paint()
        ..color = primary.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 22, lens);
      final lensBorder = Paint()
        ..color = primary.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(x, y), 22, lensBorder);
      // Emphasized dot
      final dot = Paint()..color = primary;
      canvas.drawCircle(Offset(x, y), 4, dot);
    }
  }

  static double yFor(double value, Rect r, double max) {
    final clamped = value.clamp(0, max);
    final frac = max == 0 ? 0.0 : clamped / max;
    return r.bottom - frac * r.height;
  }

  static double _yFor(double value, Rect r, double max) => yFor(value, r, max);

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    if (oldDelegate.maxY != maxY) return true;
    if (oldDelegate.points.length != points.length) return true;
    for (int i = 0; i < points.length; i++) {
      if (oldDelegate.points[i].count != points[i].count ||
          oldDelegate.points[i].date != points[i].date) {
        return true;
      }
    }
    if (oldDelegate.highlight != highlight) return true;
    if (oldDelegate.primary != primary) return true;
    return false;
  }
}

Decoration _tooltipDecoration(
  BuildContext context,
  TooltipThemeData tooltipTheme,
) {
  final decoration = tooltipTheme.decoration;
  if (decoration != null) {
    return decoration;
  }
  final theme = Theme.of(context);
  final shadowColor = theme.brightness == Brightness.dark
      ? Colors.black.withValues(alpha: 0.5)
      : Colors.black.withValues(alpha: 0.2);

  return ShapeDecoration(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    color: theme.colorScheme.inverseSurface,
    shadows: [
      BoxShadow(color: shadowColor, blurRadius: 12, offset: const Offset(0, 6)),
    ],
  );
}

TextStyle _tooltipTextStyle(
  BuildContext context,
  TooltipThemeData tooltipTheme,
) {
  final theme = Theme.of(context);
  final defaultStyle = theme.textTheme.labelSmall ??
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  final result = tooltipTheme.textStyle ?? defaultStyle;
  if (result.color != null) return result;
  final defaultColor = theme.colorScheme.onInverseSurface;
  return result.copyWith(color: defaultColor);
}
