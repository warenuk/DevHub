import 'package:devhub_gpt/shared/config/remote_config/application/remote_config_controller.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_feature_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteConfigWelcomeBanner extends ConsumerWidget {
  const RemoteConfigWelcomeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Компонент-вимикач: банер RC відключено повністю.
    return const SizedBox.shrink();
  }
}
