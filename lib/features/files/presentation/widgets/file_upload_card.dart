import 'package:devhub_gpt/features/files/domain/entities/uploaded_file.dart';
import 'package:devhub_gpt/features/files/presentation/providers/file_upload_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileUploadCard extends ConsumerWidget {
  const FileUploadCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(fileUploadPanelExpandedProvider);
    final uploads = ref.watch(fileUploadControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_open, color: scheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Завантаження файлів',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    ref.read(fileUploadPanelExpandedProvider.notifier).state =
                        !expanded;
                  },
                  icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                  label: Text(expanded ? 'Сховати' : 'Показати'),
                ),
              ],
            ),
            AnimatedCrossFade(
              crossFadeState: expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => ref
                        .read(fileUploadControllerProvider.notifier)
                        .pickAndUpload(),
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Обрати файли'),
                  ),
                  const SizedBox(height: 16),
                  if (uploads.isEmpty)
                    Text(
                      'Файли ще не додані. Натисніть «Обрати файли», щоб підвантажити їх.',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (final file in uploads)
                          _UploadTile(
                            key: ValueKey(file.id),
                            file: file,
                          ),
                      ],
                    ),
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({required this.file, super.key});

  final UploadedFile file;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = file.status;
    final statusLabel = switch (status) {
      UploadStatus.preparing => 'Підготовка…',
      UploadStatus.uploading => 'Завантаження…',
      UploadStatus.completed => 'Готово',
      UploadStatus.failed => 'Помилка',
    };
    final percent = (file.progress * 100).clamp(0, 100);
    final color = switch (status) {
      UploadStatus.completed => scheme.primary,
      UploadStatus.failed => scheme.error,
      _ => scheme.primary,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                status == UploadStatus.completed
                    ? Icons.check_circle_outline
                    : status == UploadStatus.failed
                        ? Icons.error_outline
                        : Icons.insert_drive_file_outlined,
                color: color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatSize(file.size)} • $statusLabel',
                      style: TextStyle(
                        fontSize: 12,
                        color: status == UploadStatus.failed
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: status == UploadStatus.failed
                      ? scheme.error
                      : scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: status == UploadStatus.failed
                  ? file.progress.clamp(0, 1)
                  : file.progress.clamp(0, 1),
              color: color,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          if (status == UploadStatus.failed && file.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                file.errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _formatSize(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }
  return '${value.toStringAsFixed(value < 10 && unitIndex > 0 ? 1 : 0)} ${units[unitIndex]}';
}
