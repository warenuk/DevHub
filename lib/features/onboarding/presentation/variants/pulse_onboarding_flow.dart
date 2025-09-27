import 'dart:math' as math;
import 'dart:ui';

import 'package:devhub_gpt/core/theme/app_palette.dart';
import 'package:devhub_gpt/features/onboarding/presentation/widgets/onboarding_pager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PulseOnboardingFlow extends StatelessWidget {
  const PulseOnboardingFlow({
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
          _PulseBackground(accent: accent, pageNotifier: notifier),
      palette: OnboardingPalette(
        primaryText: Colors.white,
        secondaryText: Colors.white.withOpacity(0.82),
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

  List<OnboardingSlideContent> _slides() {
    return [
      OnboardingSlideContent(
        title: 'Пульс команди в реальному часі',
        description:
            'Кастомні віджети з активністю GitHub, швидкістю ревʼю та статусом релізу'
            ' допомагають одразу бачити, де потрібна увага.',
        buildIllustration: (context, offset) =>
            _PulseDashboardIllustration(accent: accent, offset: offset),
      ),
      OnboardingSlideContent(
        title: 'Розумні сповіщення',
        description:
            'PUSH, email та in-app сповіщення синхронізовані та згруповані, щоб'
            ' ви отримували лише потрібне.',
        buildIllustration: (context, offset) =>
            _PulseNotificationsIllustration(accent: accent, offset: offset),
      ),
      OnboardingSlideContent(
        title: 'Налаштування під себе',
        description:
            'Миттєво перемикайте теми, автофокус на тасках та AI-підказки для'
            ' ревʼю — ваш робочий простір адаптується до темпу команди.',
        buildIllustration: (context, offset) =>
            _PulseCustomizationIllustration(accent: accent, offset: offset),
      ),
    ];
  }
}

class _PulseBackground extends StatefulWidget {
  const _PulseBackground({required this.accent, required this.pageNotifier});

  final Color accent;
  final ValueListenable<double> pageNotifier;

  @override
  State<_PulseBackground> createState() => _PulseBackgroundState();
}

class _PulseBackgroundState extends State<_PulseBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 7),
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
      animation: Listenable.merge([_controller, widget.pageNotifier]),
      builder: (context, _) {
        final pageShift = (widget.pageNotifier.value % 1);
        final scale = 1.05 + _controller.value * 0.25;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.2 + pageShift * 0.4),
              radius: scale * 1.2,
              colors: const [
                Color(0xFF1B100B),
                Color(0xFF140D0C),
                Color(0xFF090606),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _PulseRayPainter(
                    progress: _controller.value,
                    accent: widget.accent,
                  ),
                ),
              ),
              Align(
                alignment: Alignment(
                  math.sin(_controller.value * math.pi * 2) * 0.5,
                  0.9,
                ),
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.accent.withOpacity(0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PulseRayPainter extends CustomPainter {
  _PulseRayPainter({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..shader = SweepGradient(
        center: FractionalOffset.center,
        startAngle: 0,
        endAngle: math.pi * 2,
        transform: GradientRotation(progress * math.pi * 2),
        colors: [
          Colors.transparent,
          accent.withOpacity(0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 0.08, 0.16],
      ).createShader(
        Rect.fromCircle(center: center, radius: size.shortestSide),
      );
    canvas.drawCircle(center, size.shortestSide, paint);
  }

  @override
  bool shouldRepaint(covariant _PulseRayPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}

class _PulseDashboardIllustration extends StatelessWidget {
  const _PulseDashboardIllustration({
    required this.accent,
    required this.offset,
  });

  final Color accent;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width, 520.0);
    final height = width * 0.68;
    final shift = offset * 24;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: Offset(-shift, shift * 0.5),
              child: _PulseCard(
                accent: accent,
                width: width * 0.9,
                child: _DashboardContent(accent: accent),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Transform.translate(
              offset: Offset(shift * 1.1, -shift * 0.3),
              child: _PulseMiniCard(
                accent: accent,
                child: _VelocityGauge(accent: accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseNotificationsIllustration extends StatelessWidget {
  const _PulseNotificationsIllustration({
    required this.accent,
    required this.offset,
  });

  final Color accent;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width, 520.0);
    final height = width * 0.7;
    final shift = offset * 20;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(shift * -0.6, shift * 0.4),
              child: _PulseCard(
                accent: accent,
                width: width * 0.88,
                child: _NotificationsTimeline(accent: accent),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: Offset(-shift * 0.8, -shift * 0.5),
              child: _NotificationBubble(
                accent: accent,
                title: 'PR merged',
                subtitle: 'feature/realtime-dashboard',
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Transform.translate(
              offset: Offset(shift * 1.0, -shift * 0.4),
              child: _NotificationBubble(
                accent: accent.withOpacity(0.85),
                title: 'New mention',
                subtitle: '@you в issue #1021',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseCustomizationIllustration extends StatelessWidget {
  const _PulseCustomizationIllustration({
    required this.accent,
    required this.offset,
  });

  final Color accent;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width, 520.0);
    final height = width * 0.68;
    final shift = offset * 22;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(shift * 0.8, 0),
              child: _PulseCard(
                accent: accent,
                width: width * 0.92,
                child: _CustomizationContent(accent: accent),
              ),
            ),
          ),
          Align(
            alignment: Alignment(-0.9, -0.6),
            child: Transform.translate(
              offset: Offset(-shift * 0.9, shift * 0.4),
              child: _FloatingToggle(
                accent: accent,
                label: 'AI assist',
                value: true,
              ),
            ),
          ),
          Align(
            alignment: Alignment(0.9, 0.8),
            child: Transform.translate(
              offset: Offset(shift * 1.2, -shift * 0.6),
              child: _FloatingToggle(
                accent: accent,
                label: 'Focus mode',
                value: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseCard extends StatelessWidget {
  const _PulseCard({
    required this.accent,
    required this.width,
    required this.child,
  });

  final Color accent;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppPalette.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withOpacity(0.35)),
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

class _PulseMiniCard extends StatelessWidget {
  const _PulseMiniCard({required this.accent, required this.child});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppPalette.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.22),
            blurRadius: 24,
            spreadRadius: 3,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.dashboard_customize_rounded, color: accent),
            const SizedBox(width: 10),
            const Text(
              'Live dashboard',
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
            Expanded(child: _sparkCard(accent, 'Merge rate', '+18%')),
            const SizedBox(width: 16),
            Expanded(
              child: _sparkCard(accent.withOpacity(0.8), 'Review time', '12h'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          height: 74,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: accent),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'На цьому тижні зекономили 6 годин завдяки автоматизованим ревʼю.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sparkCard(Color color, String title, String value) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _VelocityGauge extends StatefulWidget {
  const _VelocityGauge({required this.accent});

  final Color accent;

  @override
  State<_VelocityGauge> createState() => _VelocityGaugeState();
}

class _VelocityGaugeState extends State<_VelocityGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
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
      builder: (context, _) {
        final angle = lerpDouble(-math.pi / 3, math.pi / 3, _controller.value)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Velocity', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: CustomPaint(
                painter: _GaugePainter(angle: angle, accent: widget.accent),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.angle, required this.accent});

  final double angle;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = size.width / 2.2;
    final arcPaint = Paint()
      ..color = accent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      arcPaint,
    );

    final needlePaint = Paint()
      ..color = accent
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final end = Offset(
      center.dx + radius * math.cos(math.pi + angle),
      center.dy + radius * math.sin(math.pi + angle),
    );
    canvas.drawLine(center, end, needlePaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.accent != accent;
  }
}

class _NotificationsTimeline extends StatelessWidget {
  const _NotificationsTimeline({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notifications_active_rounded, color: accent),
            const SizedBox(width: 10),
            const Text(
              'Today',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _timelineItem(accent, '09:24', 'Pull request #231 готовий до merge'),
        const SizedBox(height: 12),
        _timelineItem(
          accent.withOpacity(0.85),
          '11:02',
          'Мітка "urgent" у issue #998',
        ),
        const SizedBox(height: 12),
        _timelineItem(
          accent.withOpacity(0.7),
          '14:17',
          'CI pipeline завершено без помилок',
        ),
      ],
    );
  }

  Widget _timelineItem(Color color, String time, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 260,
              child: Text(
                text,
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotificationBubble extends StatelessWidget {
  const _NotificationBubble({
    required this.accent,
    required this.title,
    required this.subtitle,
  });

  final Color accent;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.2),
            blurRadius: 20,
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
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _CustomizationContent extends StatelessWidget {
  const _CustomizationContent({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune_rounded, color: accent),
            const SizedBox(width: 10),
            const Text(
              'Workspace modes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _toggleRow('Темна тема', true),
        const SizedBox(height: 16),
        _toggleRow('Автофокус на задачі', true),
        const SizedBox(height: 16),
        _toggleRow('AI-підказки для ревʼю', false),
      ],
    );
  }

  Widget _toggleRow(String label, bool value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ),
        Switch(
          value: value,
          onChanged: (_) {},
          activeColor: accent,
          inactiveThumbColor: Colors.white24,
          inactiveTrackColor: Colors.white12,
        ),
      ],
    );
  }
}

class _FloatingToggle extends StatelessWidget {
  const _FloatingToggle({
    required this.accent,
    required this.label,
    required this.value,
  });

  final Color accent;
  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.2),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            value ? Icons.check_circle : Icons.radio_button_unchecked,
            color: accent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
