import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, this.error});
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errText = error?.toString().trim();
    final hasDetails = errText != null && errText.isNotEmpty;
    final refCode = hasDetails ? errText.hashCode.toRadixString(16) : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Щось пішло не так')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_rounded,
                size: 56,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Не вдалося завантажити сторінку.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Ми вже записали помилку. Спробуйте повернутися на головну або перезавантажити сторінку.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              if (refCode != null) ...[
                const SizedBox(height: 16),
                SelectableText(
                  'ID помилки: $refCode',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                if (hasDetails)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: errText));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Трасування скопійовано'),
                            ),
                          );
                        }
                      },
                      label: const Text('Скопіювати діагностику'),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Icons.home),
                label: const Text('На головну'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Повернутися назад'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
