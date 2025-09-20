import 'package:devhub_gpt/shared/widgets/app_progress_indicator.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: AppProgressIndicator(),
      ),
    );
  }
}
