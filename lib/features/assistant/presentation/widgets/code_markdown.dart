import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
                await Clipboard.setData(ClipboardData(text: text));
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Copied')));
              },
            ),
          ],
        ),
        MarkdownBody(
          selectable: true,
          data: safeText,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            code: TextStyle(
              fontFamily: 'monospace',
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
      ],
    );
  }
}
