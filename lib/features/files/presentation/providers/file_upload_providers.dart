import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:devhub_gpt/features/files/application/file_compressor.dart';
import 'package:devhub_gpt/features/files/domain/entities/uploaded_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meta/meta.dart';
import 'package:state_notifier/state_notifier.dart';

final fileUploadControllerProvider =
    StateNotifierProvider<FileUploadNotifier, List<UploadedFile>>((ref) {
  final compressor = FileCompressor();
  return FileUploadNotifier(compressor: compressor, ref: ref);
});

final fileUploadModeProvider = StateProvider<UploadMode>((ref) {
  return UploadMode.standard;
});

final fileUploadPanelExpandedProvider = StateProvider<bool>((ref) => false);

class FileUploadNotifier extends StateNotifier<List<UploadedFile>> {
  FileUploadNotifier({required FileCompressor compressor, Ref? ref})
      : _compressor = compressor,
        _ref = ref,
        super(const <UploadedFile>[]);

  final FileCompressor _compressor;
  final Ref? _ref;

  final Map<String, Uint8List> _originalBytes = <String, Uint8List>{};
  final Map<String, Uint8List> _processedBytes = <String, Uint8List>{};
  final Map<String, _ProgressSlices> _slices = <String, _ProgressSlices>{};

  /// IDs позначених на видалення елементів.
  final Set<String> _removedIds = <String>{};

  UploadMode get _mode {
    final ref = _ref;
    if (ref == null) {
      return UploadMode.standard;
    }
    return ref.read(fileUploadModeProvider);
  }

  Future<void> pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: kIsWeb,
      withReadStream: true,
    );
    if (result == null) return;

    for (final file in result.files) {
      unawaited(_startUpload(file, _mode));
    }
  }

  /// Видаляє файл із списку та сигналізує довгим процесам припинитися.
  void remove(String id) {
    _removedIds.add(id);
    _originalBytes.remove(id);
    _processedBytes.remove(id);
    _slices.remove(id);
    state = [
      for (final item in state)
        if (item.id != id) item,
    ];
  }

  bool _isRemoved(String id) => _removedIds.contains(id);

  Future<void> compressFile(String id) async {
    final file = _findFile(id);
    if (file == null || file.mode == UploadMode.standard) {
      return;
    }

    if (file.status != UploadStatus.awaitingCompression) {
      return;
    }

    final originalBytes = _originalBytes[id];
    if (originalBytes == null) {
      _update(id, (prev) {
        return prev.copyWith(
          status: UploadStatus.failed,
          errorMessage: 'Відсутні дані для компресії',
        );
      });
      return;
    }

    final slices = _slices[id] ?? _ProgressSlices.forMode(file.mode);
    _slices[id] = slices;

    _update(id, (prev) {
      return prev.copyWith(status: UploadStatus.compressing);
    });

    Uint8List compressedBytes;
    try {
      compressedBytes = await _compress(id, file.mode, originalBytes, slices);
    } catch (e) {
      if (_isRemoved(id)) return;
      _update(id, (prev) {
        return prev.copyWith(
          status: UploadStatus.failed,
          errorMessage: e.toString(),
        );
      });
      return;
    }

    if (_isRemoved(id)) return;

    _processedBytes[id] = compressedBytes;
    _update(id, (prev) {
      return prev.copyWith(
        status: UploadStatus.awaitingUpload,
        processedSize: compressedBytes.length,
        progress: (slices.read + slices.compression).clamp(0.0, 1.0),
      );
    });
  }

  Future<void> uploadFile(String id) async {
    final file = _findFile(id);
    if (file == null) {
      return;
    }

    if (file.status == UploadStatus.completed) {
      return;
    }

    if (file.mode != UploadMode.standard &&
        file.status != UploadStatus.awaitingUpload) {
      return;
    }

    final slices = _slices[id] ?? _ProgressSlices.forMode(file.mode);
    _slices[id] = slices;

    final Uint8List? data = _processedBytes[id] ?? _originalBytes[id];
    if (data == null) {
      _update(id, (prev) {
        return prev.copyWith(
          status: UploadStatus.failed,
          errorMessage: 'Немає даних для завантаження',
        );
      });
      return;
    }

    await _beginUpload(id, data, slices);
  }

  Future<void> _startUpload(PlatformFile file, UploadMode mode) async {
    final id = '${DateTime.now().microsecondsSinceEpoch}-${file.name}';
    final slices = _slices[id] = _ProgressSlices.forMode(mode);
    state = [
      ...state,
      UploadedFile(
        id: id,
        name: file.name,
        size: file.size,
        progress: 0,
        status: UploadStatus.preparing,
        mode: mode,
      ),
    ];

    try {
      final stream = await _resolveStream(file);
      if (stream == null) {
        if (_isRemoved(id)) return;
        _update(id, (prev) {
          return prev.copyWith(
            status: UploadStatus.failed,
            errorMessage: 'Не вдалося прочитати файл',
          );
        });
        return;
      }

      int processed = 0;
      final builder = BytesBuilder();
      final total = file.size;

      await for (final chunk in stream) {
        if (_isRemoved(id)) {
          return;
        }
        processed += chunk.length;
        builder.add(chunk);
        final baseProgress = total > 0
            ? processed / total
            : processed > 0
                ? 1.0
                : 0.0;
        final normalized =
            (baseProgress * slices.read).clamp(0.0, 1.0).toDouble();
        _update(id, (prev) => prev.copyWith(progress: normalized));
      }

      if (_isRemoved(id)) return;
      final originalBytes = builder.takeBytes();
      _originalBytes[id] = originalBytes;

      if (mode == UploadMode.standard) {
        await _beginUpload(id, originalBytes, slices);
        return;
      }

      if (_isRemoved(id)) return;

      _update(
        id,
        (prev) => prev.copyWith(
          status: UploadStatus.awaitingCompression,
          progress: slices.read,
        ),
      );
    } catch (e) {
      if (_isRemoved(id)) return;
      _update(id, (prev) {
        return prev.copyWith(
          status: UploadStatus.failed,
          errorMessage: e.toString(),
        );
      });
    }
  }

  Future<Uint8List> _compress(
    String id,
    UploadMode mode,
    Uint8List originalBytes,
    _ProgressSlices slices,
  ) async {
    void updateCompressionProgress(double value) {
      if (_isRemoved(id)) return;
      final normalized = (slices.read + (slices.compression * value))
          .clamp(0.0, 1.0)
          .toDouble();
      _update(id, (prev) => prev.copyWith(progress: normalized));
    }

    switch (mode) {
      case UploadMode.photo:
        return await _compressor.compressPhoto(
          originalBytes,
          onProgress: updateCompressionProgress,
        );
      case UploadMode.video:
        return await _compressor.compressVideo(
          originalBytes,
          onProgress: updateCompressionProgress,
        );
      case UploadMode.standard:
        return originalBytes;
    }
  }

  Future<void> _beginUpload(
    String id,
    Uint8List data,
    _ProgressSlices slices,
  ) async {
    if (_isRemoved(id)) return;

    _update(id, (prev) {
      final startProgress = math.max(
        prev.progress,
        (slices.read + slices.compression).clamp(0.0, 1.0),
      );
      return prev.copyWith(
        status: UploadStatus.uploading,
        progress: startProgress,
      );
    });

    if (data.isEmpty) {
      if (_isRemoved(id)) return;
      _finalizeUpload(id, data);
      return;
    }

    const chunkSize = 64 * 1024;
    final total = data.length;
    var processed = 0;

    while (processed < total) {
      if (_isRemoved(id)) return;
      processed = math.min(processed + chunkSize, total);
      final baseProgress = processed / total;
      final normalized =
          (slices.read + slices.compression + (baseProgress * slices.upload))
              .clamp(0.0, 1.0)
              .toDouble();
      _update(id, (prev) => prev.copyWith(progress: normalized));
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }

    if (_isRemoved(id)) return;
    _finalizeUpload(id, data);
  }

  void _finalizeUpload(String id, Uint8List data) {
    _processedBytes.remove(id);
    _originalBytes.remove(id);
    _slices.remove(id);
    _update(
      id,
      (prev) => prev.copyWith(
        progress: 1,
        status: UploadStatus.completed,
        bytes: data,
        processedSize: data.length,
      ),
    );
  }

  Future<Stream<List<int>>?> _resolveStream(PlatformFile file) async {
    if (file.readStream != null) {
      return file.readStream;
    }
    final bytes = file.bytes;
    if (bytes != null) {
      return _streamFromBytes(bytes);
    }
    return null;
  }

  Stream<List<int>> _streamFromBytes(Uint8List data) async* {
    if (data.isEmpty) {
      yield data;
      return;
    }
    const chunkSize = 64 * 1024;
    var offset = 0;
    while (offset < data.length) {
      final end = math.min(offset + chunkSize, data.length);
      yield data.sublist(offset, end);
      offset = end;
      // Дозволяємо UI промалювати прогрес.
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  void _update(String id, UploadedFile Function(UploadedFile) transform) {
    state = [
      for (final item in state)
        if (item.id == id) transform(item) else item,
    ];
  }

  UploadedFile? _findFile(String id) {
    for (final file in state) {
      if (file.id == id) {
        return file;
      }
    }
    return null;
  }

  @visibleForTesting
  String addReadyFileForTesting({
    required String name,
    required Uint8List originalData,
    required UploadMode mode,
    UploadStatus status = UploadStatus.awaitingCompression,
    Uint8List? processedData,
  }) {
    final id = 'test-${DateTime.now().microsecondsSinceEpoch}';
    final slices = _slices[id] = _ProgressSlices.forMode(mode);
    _originalBytes[id] = originalData;
    if (processedData != null) {
      _processedBytes[id] = processedData;
    } else {
      _processedBytes.remove(id);
    }

    final effectiveData = processedData ?? originalData;

    double progress;
    int? processedSize;
    switch (status) {
      case UploadStatus.awaitingCompression:
        progress = slices.read;
        processedSize = null;
        break;
      case UploadStatus.awaitingUpload:
      case UploadStatus.uploading:
        progress = (slices.read + slices.compression).clamp(0.0, 1.0);
        processedSize = effectiveData.length;
        break;
      case UploadStatus.completed:
        progress = 1;
        processedSize = effectiveData.length;
        break;
      default:
        progress = 0;
        processedSize = null;
    }

    state = [
      ...state,
      UploadedFile(
        id: id,
        name: name,
        size: originalData.length,
        progress: progress,
        status: status,
        mode: mode,
        processedSize: processedSize,
        bytes: status == UploadStatus.completed ? effectiveData : null,
      ),
    ];
    return id;
  }
}

class _ProgressSlices {
  const _ProgressSlices({
    required this.read,
    required this.compression,
    required this.upload,
  });

  factory _ProgressSlices.forMode(UploadMode mode) {
    if (mode == UploadMode.standard) {
      return const _ProgressSlices(read: 0.5, compression: 0, upload: 0.5);
    }
    return const _ProgressSlices(read: 0.3, compression: 0.4, upload: 0.3);
  }

  final double read;
  final double compression;
  final double upload;
}
