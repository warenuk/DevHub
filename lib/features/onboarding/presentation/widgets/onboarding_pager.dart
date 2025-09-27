import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef OnboardingBackgroundBuilder = Widget Function(
    BuildContext context, ValueListenable<double> pageNotifier);

typedef OnboardingIllustrationBuilder = Widget Function(
    BuildContext context, double pageOffset);

class OnboardingSlideContent {
  const OnboardingSlideContent({
    required this.title,
    required this.description,
    required this.buildIllustration,
  });

  final String title;
  final String description;
  final OnboardingIllustrationBuilder buildIllustration;
}

class OnboardingPalette {
  const OnboardingPalette({
    required this.primaryText,
    required this.secondaryText,
    required this.buttonBackground,
    required this.buttonForeground,
    required this.skipColor,
    required this.indicatorActive,
    required this.indicatorInactive,
    required this.cardColor,
  });

  final Color primaryText;
  final Color secondaryText;
  final Color buttonBackground;
  final Color buttonForeground;
  final Color skipColor;
  final Color indicatorActive;
  final Color indicatorInactive;
  final Color cardColor;
}

class OnboardingPager extends StatefulWidget {
  const OnboardingPager({
    super.key,
    required this.slides,
    required this.backgroundBuilder,
    required this.palette,
    required this.onComplete,
    required this.onSkip,
  });

  final List<OnboardingSlideContent> slides;
  final OnboardingBackgroundBuilder backgroundBuilder;
  final OnboardingPalette palette;
  final Future<void> Function() onComplete;
  final Future<void> Function() onSkip;

  @override
  State<OnboardingPager> createState() => _OnboardingPagerState();
}

class _OnboardingPagerState extends State<OnboardingPager> {
  late final PageController _controller = PageController();
  late final ValueNotifier<double> _pageNotifier = ValueNotifier<double>(0);
  int _currentIndex = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_syncPageValue);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncPageValue);
    _controller.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  void _syncPageValue() {
    final page = _controller.page;
    if (page != null) {
      _pageNotifier.value = page;
    }
  }

  Future<void> _handleNext() async {
    if (_busy) return;
    if (_currentIndex >= widget.slides.length - 1) {
      await _complete();
      return;
    }
    await _controller.nextPage(
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handleSkip() async {
    if (_busy) return;
    setState(() => _busy = true);
    await widget.onSkip();
  }

  Future<void> _complete() async {
    if (_busy) return;
    setState(() => _busy = true);
    await widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final palette = widget.palette;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: widget.backgroundBuilder(context, _pageNotifier),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.55),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _busy ? null : _handleSkip,
                        child: Text(
                          'Пропустити',
                          style: TextStyle(
                            color: palette.skipColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = math.min(constraints.maxWidth, 720.0);
                        return Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: maxWidth,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              color: palette.cardColor.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: palette.indicatorActive.withOpacity(
                                  0.35,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: PageView.builder(
                                    controller: _controller,
                                    itemCount: widget.slides.length,
                                    onPageChanged: (index) {
                                      setState(() => _currentIndex = index);
                                    },
                                    itemBuilder: (context, index) =>
                                        _OnboardingPageTile(
                                      content: widget.slides[index],
                                      index: index,
                                      pageNotifier: _pageNotifier,
                                      primaryText: palette.primaryText,
                                      secondaryText: palette.secondaryText,
                                      textTheme: textTheme,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _Indicator(
                                  current: _currentIndex,
                                  total: widget.slides.length,
                                  activeColor: palette.indicatorActive,
                                  inactiveColor: palette.indicatorInactive,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.buttonBackground,
                        foregroundColor: palette.buttonForeground,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _busy
                            ? SizedBox(
                                key: const ValueKey('progress'),
                                height: 22,
                                width: 22,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _currentIndex == widget.slides.length - 1
                                    ? 'Розпочати'
                                    : 'Далі',
                                key: ValueKey(_currentIndex),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageTile extends StatelessWidget {
  const _OnboardingPageTile({
    required this.content,
    required this.index,
    required this.pageNotifier,
    required this.primaryText,
    required this.secondaryText,
    required this.textTheme,
  });

  final OnboardingSlideContent content;
  final int index;
  final ValueListenable<double> pageNotifier;
  final Color primaryText;
  final Color secondaryText;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ValueListenableBuilder<double>(
            valueListenable: pageNotifier,
            builder: (context, page, _) {
              final current = page.isFinite ? page : index.toDouble();
              final offset = (current - index).clamp(-1, 1).toDouble();
              return content.buildIllustration(context, offset);
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          content.title,
          style: textTheme.headlineSmall?.copyWith(
            color: primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content.description,
          style: textTheme.titleMedium?.copyWith(
            color: secondaryText,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.current,
    required this.total,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int current;
  final int total;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final selected = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 8,
          width: selected ? 32 : 12,
          decoration: BoxDecoration(
            color: selected ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}
