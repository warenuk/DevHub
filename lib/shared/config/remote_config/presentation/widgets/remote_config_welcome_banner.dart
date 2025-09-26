import 'package:devhub_gpt/shared/config/remote_config/application/remote_config_controller.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_feature_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteConfigWelcomeBanner extends ConsumerWidget {
  const RemoteConfigWelcomeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RemoteConfigFeatureFlags? flags =
        ref.watch(remoteConfigFeatureFlagsProvider);
    if (flags == null ||
        !flags.welcomeBannerEnabled ||
        flags.welcomeMessage.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final int maxLines = flags.markdownMaxLines <= 0
        ? 1
        : flags.markdownMaxLines > 8
            ? 8
            : flags.markdownMaxLines;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.campaign_outlined,
                color: colors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Remote config update',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flags.welcomeMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
