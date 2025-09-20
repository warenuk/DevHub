import 'package:flutter/material.dart';

const bool _kInFlutterTest = bool.fromEnvironment(
  'FLUTTER_TEST',
  defaultValue: false,
);

/// A progress indicator that stays determinate during widget tests so
/// `pumpAndSettle` completes instead of hanging on forever animations.
class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({super.key, this.strokeWidth = 4, this.size});

  final double strokeWidth;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      strokeWidth: strokeWidth,
      value: _kInFlutterTest ? 0.66 : null,
    );

    if (size != null) {
      return SizedBox(height: size, width: size, child: indicator);
    }
    return indicator;
  }
}
