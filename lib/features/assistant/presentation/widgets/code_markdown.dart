import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class CodeMarkdown extends StatelessWidget {
  const CodeMarkdown({super.key, required this.text});
  final String text;

  bool _isSafeLink(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    if (uri.hasScheme) {
      return const {'http', 'https', 'mailto', 'tel'}.contains(uri.scheme);
    }
    // Relative links are allowed but should not contain dangerous prefixes.
    return !url.trim().toLowerCase().startsWith('javascript:');
  }

  String _sanitizeMarkdown(String input) {
    final pattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    return input.replaceAllMapped(pattern, (match) {
      final url = match.group(2) ?? '';
      if (_isSafeLink(url)) {
        return match.group(0) ?? '';
      }
      return match.group(1) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeText = _sanitizeMarkdown(text);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surfaceContainerHighest;
    final baseAlpha = (surface.a * 255).round();
    final adjustedAlpha = (baseAlpha * 0.8).round().clamp(0, 255);
    final codeBackground = surface.withAlpha(adjustedAlpha);
    final markdownConfig =
        (isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig)
            .copy(
              configs: [
                (isDark ? PreConfig.darkConfig : const PreConfig()).copy(
                  decoration: BoxDecoration(
                    color: codeBackground,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  textStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: theme.textTheme.bodyMedium?.fontSize ?? 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                CodeConfig(
                  style: TextStyle(
                    fontFamily: 'monospace',
                    backgroundColor: codeBackground,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                LinkConfig(
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                  onTap: (url) {
                    if (_isSafeLink(url)) {
                      unawaited(
                        launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Assistant',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            IconButton(
              tooltip: 'Copy',
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(ClipboardData(text: text));
                messenger.showSnackBar(const SnackBar(content: Text('Copied')));
              },
            ),
          ],
        ),
        SelectionArea(
          child: MarkdownWidget(data: safeText, config: markdownConfig),
        ),
      ],
    );
  }
}
