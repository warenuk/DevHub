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
    final mode = ref.watch(fileUploadModeProvider);
    final locked = ref.watch(fileUploadModeLockedProvider);
    final scheme = Theme.of(context).colorScheme;
    final workflow = mode == UploadMode.standard
        ? _UploadWorkflow.upload
        : _UploadWorkflow.compress;
    final isCompressionMode = workflow == _UploadWorkflow.compress;
    final hasPendingCompression = uploads.any(
      (file) =>
          file.mode != UploadMode.standard &&
          file.status == UploadStatus.waitingForCompression,
    );
    final isBusy = uploads.any(
      (file) =>
          file.status == UploadStatus.preparing ||
          file.status == UploadStatus.uploading ||
          file.status == UploadStatus.compressing,
    );

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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final buttonHeight =
                          constraints.maxWidth < 360 ? 40.0 : 48.0;
                      final style = ButtonStyle(
                        minimumSize: WidgetStatePropertyAll<Size>(
                          Size.fromHeight(buttonHeight),
                        ),
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SegmentedButton<_UploadWorkflow>(
                            segments: const [
                              ButtonSegment(
                                value: _UploadWorkflow.upload,
                                label: Text('Завантаження'),
                                icon: Icon(Icons.insert_drive_file_outlined),
                              ),
                              ButtonSegment(
                                value: _UploadWorkflow.compress,
                                label: Text('Компресування'),
                                icon: Icon(Icons.layers_outlined),
                              ),
                            ],
                            multiSelectionEnabled: false,
                            selected: {workflow},
                            style: style,
                            onSelectionChanged: locked
                                ? null
                                : (selection) {
                                    if (selection.isEmpty) return;
                                    final selectedWorkflow = selection.first;
                                    final modeNotifier = ref.read(
                                      fileUploadModeProvider.notifier,
                                    );
                                    if (selectedWorkflow ==
                                        _UploadWorkflow.upload) {
                                      modeNotifier.state = UploadMode.standard;
                                      return;
                                    }
                                    final target = ref.read(
                                      fileCompressionTargetProvider,
                                    );
                                    if (target == UploadMode.standard) {
                                      ref
                                          .read(
                                            fileCompressionTargetProvider
                                                .notifier,
                                          )
                                          .state = UploadMode.photo;
                                      modeNotifier.state = UploadMode.photo;
                                    } else {
                                      modeNotifier.state = target;
                                    }
                                  },
                          ),
                          if (isCompressionMode) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: SegmentedButton<UploadMode>(
                                segments: const [
                                  ButtonSegment(
                                    value: UploadMode.photo,
                                    label: Text('Фото'),
                                    icon: Icon(Icons.photo_camera_outlined),
                                  ),
                                  ButtonSegment(
                                    value: UploadMode.video,
                                    label: Text('Відео'),
                                    icon: Icon(Icons.videocam_outlined),
                                  ),
                                ],
                                multiSelectionEnabled: false,
                                selected: {
                                  mode == UploadMode.video
                                      ? UploadMode.video
                                      : UploadMode.photo,
                                },
                                style: style,
                                onSelectionChanged: locked
                                    ? null
                                    : (selection) {
                                        if (selection.isEmpty) return;
                                        final selectedMode = selection.first;
                                        ref
                                            .read(
                                              fileCompressionTargetProvider
                                                  .notifier,
                                            )
                                            .state = selectedMode;
                                        ref
                                            .read(
                                              fileUploadModeProvider.notifier,
                                            )
                                            .state = selectedMode;
                                      },
                              ),
                            ),
                          ],

                          if (isCompressionMode)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Якість компресії'),
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final q = ref.watch(compressionQualityProvider);
                                      return Slider(
                                        min: 1,
                                        max: 100,
                                        divisions: 99,
                                        value: q.toDouble(),
                                        label: '${q.toString()}%',
                                        onChanged: (v) => ref
                                            .read(compressionQualityProvider.notifier)
                                            .state = v.round(),
                                      );
                                    },
                                  ),
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final q = ref.watch(compressionQualityProvider);
                                      return Text('Стандартне значення: 80% • Поточне: ' + q.toString() + '%');
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => ref
                        .read(fileUploadControllerProvider.notifier)
                        .pickAndUpload(),
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: Text(
                      isCompressionMode
                          ? (mode == UploadMode.video
                              ? 'Обрати відео'
                              : 'Обрати фото')
                          : 'Обрати файли',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (uploads.isEmpty)
                    Text(
                      'Файли ще не додані. Натисніть «Обрати файли», щоб підвантажити їх.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    )
                  else
                    Column(
                      children: [
                        if (isCompressionMode)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: FilledButton.icon(
                                onPressed: hasPendingCompression && !isBusy
                                    ? () => ref
                                        .read(
                                          fileUploadControllerProvider.notifier,
                                        )
                                        .compressPending()
                                    : null,
                                icon: const Icon(Icons.auto_fix_high),
                                label: const Text('Компресувати'),
                              ),
                            ),
                          ),
                        for (final file in uploads)
                          _UploadTile(key: ValueKey(file.id), file: file),
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

class _UploadTile extends ConsumerWidget {
  const _UploadTile({required this.file, super.key});

  final UploadedFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final status = file.status;
    final statusLabel = switch (status) {
      UploadStatus.preparing => 'Підготовка…',
      UploadStatus.uploading => 'Завантаження…',
      UploadStatus.waitingForCompression => 'Очікує компресію',
      UploadStatus.compressing => 'Компресія…',
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
              Icon(_iconForFile(file), color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _UploadSubtitle(
                      file: file,
                      statusLabel: statusLabel,
                      color: status == UploadStatus.failed
                          ? scheme.error
                          : scheme.onSurfaceVariant,
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
              const SizedBox(width: 8),
              // Кнопка видалення відповідно до архітектури через стан
              IconButton(
                tooltip: 'Видалити файл',
                onPressed: () {
                  ref
                      .read(fileUploadControllerProvider.notifier)
                      .remove(file.id);
                },
                icon: const Icon(Icons.delete_outline),
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
                style: TextStyle(fontSize: 12, color: scheme.error),
              ),
            ),
          if (status == UploadStatus.completed &&
              file.mode != UploadMode.standard &&
              file.bytes != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _downloadCompressed(context, ref),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Завантажити'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _downloadCompressed(BuildContext context, WidgetRef ref) async {
    final bytes = file.bytes;
    if (bytes == null) {
      return;
    }
    final saver = ref.read(fileSaverProvider);
    try {
      final savedPath = await saver.save(
        filename: _compressedFileName(file),
        bytes: bytes,
      );
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final message = savedPath == null
          ? 'Компресований файл збережено'
          : 'Компресований файл збережено: $savedPath';
      messenger.showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text('Не вдалося зберегти файл: $e')),
      );
    }
  }
}

class _UploadSubtitle extends StatelessWidget {
  const _UploadSubtitle({
    required this.file,
    required this.statusLabel,
    required this.color,
  });

  final UploadedFile file;
  final String statusLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isCompressionMode = file.mode != UploadMode.standard;
    final processedSize = file.processedSize;
    final hasCompressionResult = isCompressionMode &&
        processedSize != null &&
        processedSize != file.size;

    final sizeLabel = hasCompressionResult
        ? '${_formatSize(file.size)} → ${_formatSize(processedSize!)}'
        : _formatSize(file.size);
    final parts = <String>[sizeLabel, file.mode.label, statusLabel];

    if (hasCompressionResult && file.size > 0) {
      final reduction = 1 - (processedSize! / file.size).clamp(0.0, 1.0);
      parts.add('-${(reduction * 100).clamp(0, 100).toStringAsFixed(1)}%');
    }

    return Text(
      parts.join(' • '),
      style: TextStyle(fontSize: 12, color: color),
    );
  }
}

enum _UploadWorkflow { upload, compress }

IconData _iconForFile(UploadedFile file) {
  if (file.status == UploadStatus.completed) {
    return Icons.check_circle_outline;
  }
  if (file.status == UploadStatus.failed) {
    return Icons.error_outline;
  }
  return switch (file.mode) {
    UploadMode.standard => Icons.insert_drive_file_outlined,
    UploadMode.photo => Icons.photo_camera_outlined,
    UploadMode.video => Icons.videocam_outlined,
  };
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

String _compressedFileName(UploadedFile file) {
  final baseName = _stripExtension(file.name);
  return switch (file.mode) {
    UploadMode.photo => '${baseName}_compressed.jpg',
    UploadMode.video => '${baseName}_compressed.gz',
    UploadMode.standard => file.name,
  };
}

String _stripExtension(String name) {
  final dotIndex = name.lastIndexOf('.');
  if (dotIndex <= 0) {
    return name;
  }
  return name.substring(0, dotIndex);
}
