import 'dart:math' as math;
import 'dart:ui';

import 'package:devhub_gpt/core/theme/app_palette.dart';
import 'package:devhub_gpt/features/onboarding/presentation/widgets/onboarding_pager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OrbitOnboardingFlow extends StatelessWidget {
  const OrbitOnboardingFlow({
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
      slides: _buildSlides(),
      backgroundBuilder: (context, notifier) =>
          _OrbitBackground(accent: accent, pageNotifier: notifier),
      palette: OnboardingPalette(
        primaryText: Colors.white,
        secondaryText: Colors.white.withOpacity(0.74),
        buttonBackground: accent,
        buttonForeground: Colors.black,
        skipColor: Colors.white70,
        indicatorActive: accent,
        indicatorInactive: Colors.white24,
        cardColor: AppPalette.surface,
      ),
      onComplete: _complete,
      onSkip: _complete,
    );
  }

  List<OnboardingSlideContent> _buildSlides() {
    return [
      OnboardingSlideContent(
        title: 'Залишайтесь на орбіті GitHub',
        description:
            'DevHub синхронізує pull requestʼи, issue та активність у реальному часі,'
            ' щоб ваша команда завжди бачила найважливіше.',
        buildIllustration: (context, offset) =>
            _OrbitCardsIllustration(offset: offset, accent: accent),
      ),
      OnboardingSlideContent(
        title: 'Фокус на головному',
        description:
            'Віджет аналітики, активність репозиторіїв та нотатки — усе поруч, '
            'щоб ви могли реагувати швидше.',
        buildIllustration: (context, offset) =>
            _OrbitAnalyticsIllustration(offset: offset, accent: accent),
      ),
      OnboardingSlideContent(
        title: 'Командна синхронізація',
        description:
            'Сповіщення про мітки, коментарі та ревʼю відтворюють світіння, щоб ви '
            'не пропустили важливе навіть у темному режимі.',
        buildIllustration: (context, offset) =>
            _OrbitNotificationIllustration(offset: offset, accent: accent),
      ),
    ];
  }
}

class _OrbitBackground extends StatefulWidget {
  const _OrbitBackground({required this.pageNotifier, required this.accent});

  final ValueListenable<double> pageNotifier;
  final Color accent;

  @override
  State<_OrbitBackground> createState() => _OrbitBackgroundState();
}

class _OrbitBackgroundState extends State<_OrbitBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

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
        final pageShift = widget.pageNotifier.value % 1;
        final center = Alignment(
          lerpDouble(-0.25, 0.35, pageShift.abs()) ?? 0,
          -0.45,
        );
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: center,
              radius: 1.2,
              colors: const [
                Color(0xFF0A101A),
                Color(0xFF0C1823),
                Color(0xFF05080D),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _OrbitRingsPainter(
                    rotation: _controller.value,
                    accent: widget.accent,
                  ),
                ),
              ),
              _GlowingNode(
                alignment: Alignment(-0.9 + pageShift * 0.4, 0.85),
                color: widget.accent,
                size: 90,
                intensity: 0.45,
              ),
              _GlowingNode(
                alignment: Alignment(0.8 - pageShift * 0.3, -0.9),
                color: widget.accent,
                size: 66,
                intensity: 0.35,
              ),
              _GlowingNode(
                alignment: Alignment(
                  0.25 + math.sin(_controller.value * math.pi * 2) * 0.4,
                  0.35,
                ),
                color: widget.accent.withOpacity(0.9),
                size: 42,
                intensity: 0.6,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrbitRingsPainter extends CustomPainter {
  _OrbitRingsPainter({required this.rotation, required this.accent});

  final double rotation;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide * 0.65;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    for (int i = 0; i < 4; i++) {
      final radius = maxRadius * (0.35 + i * 0.16);
      final opacity = 0.16 - i * 0.028;
      paint.color = accent.withOpacity(opacity.clamp(0.04, 0.16));
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation * math.pi * (i + 1));
      canvas.translate(-center.dx, -center.dy);
      canvas.drawOval(Rect.fromCircle(center: center, radius: radius), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitRingsPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.accent != accent;
  }
}

class _GlowingNode extends StatelessWidget {
  const _GlowingNode({
    required this.alignment,
    required this.color,
    required this.size,
    required this.intensity,
  });

  final Alignment alignment;
  final Color color;
  final double size;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(intensity), color.withOpacity(0.02)],
          ),
        ),
      ),
    );
  }
}

class _OrbitCardsIllustration extends StatelessWidget {
  const _OrbitCardsIllustration({required this.offset, required this.accent});

  final double offset;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, 520.0);
        final height = width * 0.75;
        final double parallax = offset * 24;
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _floatingCard(
                top: 40 - parallax,
                left: 0,
                scale: 1,
                accent: accent,
                child: _CardRepoPreview(accent: accent),
              ),
              _floatingCard(
                top: height * 0.4 + parallax,
                left: width * 0.15,
                scale: 0.85,
                accent: accent.withOpacity(0.85),
                child: _CardPullRequest(accent: accent),
              ),
              _floatingCard(
                top: height * 0.15 - parallax * 0.8,
                left: width * 0.48,
                scale: 0.7,
                accent: accent.withOpacity(0.6),
                child: _CardIssue(accent: accent),
              ),
              Positioned(
                top: height * 0.5,
                right: width * 0.12,
                child: Transform.translate(
                  offset: Offset(-parallax * 1.5, parallax * 0.6),
                  child: _GlowChip(label: 'Live sync', color: accent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _floatingCard({
    required double top,
    required double left,
    required double scale,
    required Color accent,
    required Widget child,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppPalette.surface.withOpacity(0.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.12),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _OrbitAnalyticsIllustration extends StatelessWidget {
  const _OrbitAnalyticsIllustration({
    required this.offset,
    required this.accent,
  });

  final double offset;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width, 520.0);
    final height = width * 0.65;
    final shift = offset * 22;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: Offset(shift * -1.1, shift * 0.4),
              child: _AnalyticsPanel(accent: accent),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Transform.translate(
              offset: Offset(shift * 0.9, shift * -0.4),
              child: _ActivityPulse(accent: accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitNotificationIllustration extends StatelessWidget {
  const _OrbitNotificationIllustration({
    required this.offset,
    required this.accent,
  });

  final double offset;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width, 480.0);
    final height = width * 0.72;
    final shift = offset * 18;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: Offset(shift * -0.7, shift * 0.4),
              child: _NotificationCard(
                accent: accent,
                title: 'New review request',
                message: 'Alex assigned you to review release/v2.3',
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Transform.translate(
              offset: Offset(shift * 1.1, shift * -0.5),
              child: _NotificationCard(
                accent: accent,
                title: 'Issue updated',
                message: 'Design tokens synced with Figma file',
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Transform.scale(
              scale: 1 + offset.abs() * 0.1,
              child: _GlowChip(label: 'Realtime alerts', color: accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowChip extends StatelessWidget {
  const _GlowChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _CardRepoPreview extends StatelessWidget {
  const _CardRepoPreview({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withOpacity(0.4)),
                ),
                child: const Icon(Icons.storage_rounded, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'devhub_gpt',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Main application repository',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.star_border_rounded, color: accent),
              const SizedBox(width: 8),
              const Text('1.2k stars', style: TextStyle(color: Colors.white70)),
              const Spacer(),
              Icon(Icons.fork_right_rounded, color: accent),
              const SizedBox(width: 8),
              const Text('230 forks', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardPullRequest extends StatelessWidget {
  const _CardPullRequest({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.merge_type_rounded, color: accent),
              const SizedBox(width: 8),
              const Text(
                'Pull Request #248',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '✨ Improve onboarding UX with multi-variant flows',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: accent.withOpacity(0.18),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text(
                'Waiting for review',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardIssue extends StatelessWidget {
  const _CardIssue({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report_outlined, color: accent.withOpacity(0.9)),
              const SizedBox(width: 8),
              const Text(
                'Bug · Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Fix push reminder vibration loop on Android',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsPanel extends StatelessWidget {
  const _AnalyticsPanel({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppPalette.surface.withOpacity(0.86),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.18),
            blurRadius: 28,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly impact',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: CustomPaint(painter: _SparklinePainter(accent: accent)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: accent),
              const SizedBox(width: 8),
              const Text(
                '+28% reviews completed',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final points = [
      const Offset(0, 90),
      Offset(size.width * 0.15, 70),
      Offset(size.width * 0.35, 82),
      Offset(size.width * 0.55, 40),
      Offset(size.width * 0.75, 56),
      Offset(size.width, 18),
    ];
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(points[i].dx, points[i].dy);
        continue;
      }
      final prev = points[i - 1];
      final current = points[i];
      final control1 = Offset(prev.dx + (current.dx - prev.dx) * 0.3, prev.dy);
      final control2 = Offset(
        prev.dx + (current.dx - prev.dx) * 0.7,
        current.dy,
      );
      path.cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        current.dx,
        current.dy,
      );
    }

    final paint = Paint()
      ..color = accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [accent.withOpacity(0.28), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}

class _ActivityPulse extends StatefulWidget {
  const _ActivityPulse({required this.accent});

  final Color accent;

  @override
  State<_ActivityPulse> createState() => _ActivityPulseState();
}

class _ActivityPulseState extends State<_ActivityPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 4),
    vsync: this,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.9 + _controller.value * 0.2;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [widget.accent.withOpacity(0.35), Colors.transparent],
              ),
            ),
            child: child,
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timeline_rounded, color: widget.accent),
            const SizedBox(height: 10),
            const Text(
              'Focus sessions',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.accent,
    required this.title,
    required this.message,
  });

  final Color accent;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface.withOpacity(0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.16),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}
