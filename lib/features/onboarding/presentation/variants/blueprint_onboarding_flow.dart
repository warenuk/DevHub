import 'dart:math' as math;

import 'package:devhub_gpt/features/onboarding/presentation/widgets/onboarding_pager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BlueprintOnboardingFlow extends StatelessWidget {
  const BlueprintOnboardingFlow({
    super.key,
    required this.accent,
    required this.onComplete,
  });

  final Color accent;
  final Future<void> Function() onComplete;

  Future<void> _complete() => onComplete();

  @override
  Widget build(BuildContext context) {
    return OnboardingPager(
      slides: _slides(),
      backgroundBuilder: (context, notifier) =>
          _BlueprintBackground(accent: accent, pageNotifier: notifier),
      palette: OnboardingPalette(
        primaryText: Colors.white,
        secondaryText: Colors.white.withOpacity(0.78),
        buttonBackground: accent,
        buttonForeground: Colors.black,
        skipColor: Colors.white70,
        indicatorActive: accent,
        indicatorInactive: Colors.white24,
        cardColor: const Color(0xFF101A26),
      ),
      onComplete: _complete,
      onSkip: _complete,
    );
  }

  List<OnboardingSlideContent> _slides() {
    return [
      OnboardingSlideContent(
        title: 'Плануйте спринти як креслення',
        description:
            'Створюйте контрольні листи для релізів, обʼєднуйте issue та pull request'
            ' у єдину площину, щоби команда бачила чітку структуру.',
        buildIllustration: (context, offset) =>
            _BlueprintBoardIllustration(offset: offset, accent: accent),
      ),
      OnboardingSlideContent(
        title: 'Розкладайте потоки роботи',
        description:
            'Відображайте залежності між задачами, автогенеруйте flow діаграми та'
            ' миттєво помічайте блокери.',
        buildIllustration: (context, offset) =>
            _BlueprintFlowIllustration(offset: offset, accent: accent),
      ),
      OnboardingSlideContent(
        title: 'Працюйте як єдина команда',
        description:
            'Коментуйте прямо на схемах, фіксуйте рішення й відслідковуйте виконання'
            ' без перемикань між вкладками.',
        buildIllustration: (context, offset) =>
            _BlueprintTeamIllustration(offset: offset, accent: accent),
      ),
    ];
  }
}

class _BlueprintBackground extends StatefulWidget {
  const _BlueprintBackground({
    required this.pageNotifier,
    required this.accent,
  });

  final ValueListenable<double> pageNotifier;
  final Color accent;

  @override
  State<_BlueprintBackground> createState() => _BlueprintBackgroundState();
}

class _BlueprintBackgroundState extends State<_BlueprintBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, widget.pageNotifier]),
      builder: (context, _) {
        final scan = (_controller.value * 2) - 1;
        return Stack(
          children: [
            Container(color: const Color(0xFF0C131B)),
            CustomPaint(
              painter: _BlueprintGridPainter(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(scan, -1),
                    end: Alignment(scan + 0.5, 1),
                    colors: [
                      widget.accent.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            _BlueprintNodes(
              accent: widget.accent,
              pageNotifier: widget.pageNotifier,
            ),
          ],
        );
      },
    );
  }
}

class _BlueprintGridPainter extends CustomPainter {
  _BlueprintGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const double spacing = 48;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlueprintGridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _BlueprintNodes extends StatelessWidget {
  const _BlueprintNodes({required this.accent, required this.pageNotifier});

  final Color accent;
  final ValueListenable<double> pageNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: pageNotifier,
      builder: (context, value, _) {
        final shift = (value % 1) * 18;
        return Stack(
          children: [
            _node(const Offset(120, 160), 12, accent.withOpacity(0.45)),
            _node(Offset(320 + shift, 260), 18, accent.withOpacity(0.6)),
            _node(Offset(540 - shift, 120), 16, accent.withOpacity(0.35)),
          ],
        );
      },
    );
  }

  Widget _node(Offset position, double size, Color color) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _BlueprintBoardIllustration extends StatelessWidget {
  const _BlueprintBoardIllustration({
    required this.offset,
    required this.accent,
  });

  final double offset;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width, 520.0);
    final height = width * 0.68;
    final shift = offset * 26;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(shift, shift * 0.2),
              child: _BlueprintCard(
                accent: accent,
                child: _BoardContent(accent: accent),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Transform.translate(
              offset: Offset(-shift * 0.6, -shift * 0.4),
              child: _BlueprintBubble(label: 'Backlog', accent: accent),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 26,
            child: Transform.translate(
              offset: Offset(shift * 0.8, shift * 0.5),
              child: _BlueprintBubble(label: 'Release map', accent: accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlueprintFlowIllustration extends StatelessWidget {
  const _BlueprintFlowIllustration({
    required this.offset,
    required this.accent,
  });

  final double offset;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width, 540.0);
    final height = width * 0.62;
    final shift = offset * 24;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(-shift * 0.6, shift * 0.4),
              child: _BlueprintCard(
                accent: accent,
                child: _FlowContent(accent: accent),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: Offset(shift * 0.9, -shift * 0.6),
              child: _BlueprintMarker(title: 'CI pipeline', accent: accent),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Transform.translate(
              offset: Offset(-shift * 0.8, shift * 0.4),
              child: _BlueprintMarker(title: 'QA checks', accent: accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlueprintTeamIllustration extends StatelessWidget {
  const _BlueprintTeamIllustration({
    required this.offset,
    required this.accent,
  });

  final double offset;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width, 520.0);
    final height = width * 0.66;
    final shift = offset * 18;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(-shift, 0),
              child: _BlueprintCard(
                accent: accent,
                child: _TeamContent(accent: accent),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Transform.translate(
              offset: Offset(shift * 0.9, shift * 0.3),
              child: _BlueprintBubble(label: 'Shared notes', accent: accent),
            ),
          ),
          Align(
            alignment: Alignment(0.2, -1),
            child: Transform.translate(
              offset: Offset(-shift * 0.4, shift * 0.6),
              child: _BlueprintMarker(title: 'Decision log', accent: accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlueprintCard extends StatelessWidget {
  const _BlueprintCard({required this.accent, required this.child});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2A).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.18),
            blurRadius: 30,
            spreadRadius: 3,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BoardContent extends StatelessWidget {
  const _BoardContent({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.view_kanban_outlined, color: accent),
            const SizedBox(width: 10),
            const Text(
              'Sprint 42 blueprint',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _boardColumn('To Do', accent),
            const SizedBox(width: 16),
            _boardColumn('In Progress', accent.withOpacity(0.8)),
            const SizedBox(width: 16),
            _boardColumn('Review', accent.withOpacity(0.6)),
          ],
        ),
      ],
    );
  }

  Widget _boardColumn(String label, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < 3; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
                color: Colors.white.withOpacity(0.04),
              ),
            ),
        ],
      ),
    );
  }
}

class _FlowContent extends StatelessWidget {
  const _FlowContent({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schema_outlined, color: accent),
            const SizedBox(width: 10),
            const Text(
              'Release pipeline',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _FlowPainter(accent: accent)),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: accent.withOpacity(0.6)),
                  ),
                  child: const Text(
                    'Auto sync',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlowPainter extends CustomPainter {
  _FlowPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromLTWH(20, 20, size.width - 40, size.height - 40);
    final path = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.center.dx, rect.top)
      ..lineTo(rect.center.dx, rect.bottom)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.right, rect.center.dy)
      ..lineTo(rect.left, rect.center.dy)
      ..close();

    canvas.drawPath(path, paint);

    final dashedPaint = paint
      ..color = accent.withOpacity(0.4)
      ..strokeWidth = 1.2;
    final dashPath = Path();
    const dashLength = 10;
    const gap = 6;
    double distance = 0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      while (distance < metric.length) {
        final next = distance + dashLength;
        dashPath.addPath(
          metric.extractPath(distance, math.min(next, metric.length)),
          Offset.zero,
        );
        distance = next + gap;
      }
      distance = 0;
    }
    canvas.drawPath(dashPath, dashedPaint);
  }

  @override
  bool shouldRepaint(covariant _FlowPainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}

class _TeamContent extends StatelessWidget {
  const _TeamContent({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.groups_3_outlined, color: accent),
            const SizedBox(width: 10),
            const Text(
              'Squad sync',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _teamMember('AO', accent),
            const SizedBox(width: 12),
            _teamMember('MK', accent.withOpacity(0.8)),
            const SizedBox(width: 12),
            _teamMember('VR', accent.withOpacity(0.6)),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
            color: Colors.white.withOpacity(0.05),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.chat_outlined, color: accent.withOpacity(0.8)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Вирішили: переносять мобільний реліз на середу, документація готова.',
                  style: TextStyle(color: Colors.white70, height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _teamMember(String initials, Color color) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: color.withOpacity(0.22),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BlueprintBubble extends StatelessWidget {
  const _BlueprintBubble({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withOpacity(0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BlueprintMarker extends StatelessWidget {
  const _BlueprintMarker({required this.title, required this.accent});

  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 48, color: accent.withOpacity(0.6)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withOpacity(0.6)),
          ),
          child: Text(title, style: const TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
