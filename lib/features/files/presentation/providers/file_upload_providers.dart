import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:devhub_gpt/features/files/application/file_compressor.dart';
import 'package:devhub_gpt/features/files/application/file_saver.dart';
import 'package:devhub_gpt/features/files/domain/entities/uploaded_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';

final fileUploadControllerProvider =
    StateNotifierProvider<FileUploadNotifier, List<UploadedFile>>((ref) {
  final compressor = FileCompressor();
  return FileUploadNotifier(compressor: compressor, ref: ref);
});

final fileUploadModeLockedProvider = StateProvider<bool>((ref) => false);

final fileUploadModeProvider = StateProvider<UploadMode>((ref) {
  return UploadMode.standard;
});

final fileCompressionTargetProvider = StateProvider<UploadMode>(
  (ref) => UploadMode.photo,
);

final fileSaverProvider = Provider<FileSaver>((ref) => createFileSaver());

final fileUploadPanelExpandedProvider = StateProvider<bool>((ref) => false);

/// Доля якості компресії з повзунка (1-100), дефолт 80.
final compressionQualityProvider = StateProvider<int>((ref) => 80);

class FileUploadNotifier extends StateNotifier<List<UploadedFile>> {
  FileUploadNotifier({required FileCompressor compressor, Ref? ref})
      : _compressor = compressor,
        _ref = ref,
        super(const <UploadedFile>[]);

  static const double _readPortion = 0.6;
  static const double _compressionPortion = 0.4;
  static const Set<String> _photoExtensions = <String>{
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
    'tif',
    'tiff',
  };
  static const Set<String> _videoExtensions = <String>{
    'mp4',
    'mov',
    'mkv',
    'avi',
    'webm',
    'm4v',
  };

  final FileCompressor _compressor;
  final Ref? _ref;

  /// IDs позначених на видалення елементів.
  final Set<String> _removedIds = <String>{};
  final Map<String, Uint8List> _pendingOriginalBytes = <String, Uint8List>{};

  UploadMode get _mode {
    final ref = _ref;
    if (ref == null) {
      return UploadMode.standard;
    }
    return ref.read(fileUploadModeProvider);
  }

  void _lockMode() {
    final ref = _ref;
    if (ref == null) {
      return;
    }
    final notifier = ref.read(fileUploadModeLockedProvider.notifier);
    if (!notifier.state) {
      notifier.state = true;
    }
  }

  Future<void> pickAndUpload() async {
    final mode = _mode;
    final pickerConfig = _pickerConfigurationFor(mode);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: kIsWeb,
      withReadStream: !kIsWeb,
      type: pickerConfig.type,
      allowedExtensions: pickerConfig.allowedExtensions,
    );
    if (result == null || result.files.isEmpty) return;

    await processPickedFiles(result.files, mode);
  }

  Future<void> processPickedFiles(
    List<PlatformFile> files,
    UploadMode mode,
  ) async {
    if (files.isEmpty) {
      return;
    }
    _lockMode();
    final uploads = [for (final file in files) _startUpload(file, mode)];
    await Future.wait(uploads);
  }

  ({FileType type, List<String>? allowedExtensions}) _pickerConfigurationFor(
    UploadMode mode,
  ) {
    if (mode == UploadMode.standard) {
      return (type: FileType.any, allowedExtensions: null);
    }
    final extensions =
        (mode == UploadMode.photo ? _photoExtensions : _videoExtensions).toList(
      growable: false,
    );
    return (type: FileType.custom, allowedExtensions: extensions);
  }

  /// Видаляє файл із списку та сигналізує довгим процесам припинитися.
  void remove(String id) {
    _removedIds.add(id);
    state = [
      for (final item in state)
        if (item.id != id) item,
    ];
    _pendingOriginalBytes.remove(id);
  }

  bool _isRemoved(String id) => _removedIds.contains(id);

  bool _isFileAllowed(PlatformFile file, UploadMode mode) {
    if (mode == UploadMode.standard) {
      return true;
    }
    final extension = file.extension?.toLowerCase();
    if (extension == null || extension.isEmpty) {
      return false;
    }
    final allowed =
        mode == UploadMode.photo ? _photoExtensions : _videoExtensions;
    return allowed.contains(extension);
  }

  Future<void> _startUpload(PlatformFile file, UploadMode mode) async {
    final id = '${DateTime.now().microsecondsSinceEpoch}-${file.name}';
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
      if (!_isFileAllowed(file, mode)) {
        if (_isRemoved(id)) return;
        _update(id, (prev) {
          return prev.copyWith(
            status: UploadStatus.failed,
            errorMessage: 'Формат файлу не підтримується для обраного режиму',
          );
        });
        return;
      }

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
      if (_isRemoved(id)) return;
      _update(id, (prev) => prev.copyWith(status: UploadStatus.uploading));

      final shouldCompress = mode != UploadMode.standard;
      final readPortion = shouldCompress ? _readPortion : 1.0;

      await for (final chunk in stream) {
        if (_isRemoved(id)) {
          // Припиняємо обробку, більше ніяких оновлень стану для цього id.
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
            (baseProgress * readPortion).clamp(0.0, 1.0).toDouble();
        _update(id, (prev) => prev.copyWith(progress: normalized));
      }

      if (_isRemoved(id)) return;
      final originalBytes = builder.takeBytes();

      if (!shouldCompress) {
        _update(
          id,
          (prev) => prev.copyWith(
            progress: 1,
            status: UploadStatus.completed,
            bytes: originalBytes,
            processedSize: originalBytes.length,
          ),
        );
        return;
      }

      if (_isRemoved(id)) return;
      _pendingOriginalBytes[id] = originalBytes;
      _update(
        id,
        (prev) => prev.copyWith(
          status: UploadStatus.waitingForCompression,
          progress: readPortion,
          processedSize: null,
          isCompressing: false,
        ),
      );
    } catch (e) {
      if (_isRemoved(id)) return;
      _pendingOriginalBytes.remove(id);
      _update(id, (prev) {
        return prev.copyWith(
          status: UploadStatus.failed,
          errorMessage: e.toString(),
          isCompressing: false,
        );
      });
    }
  }

  Future<void> compressPending() async {
    final files = List<UploadedFile>.from(state);
    for (final file in files) {
      if (file.mode == UploadMode.standard) continue;
      if (file.status != UploadStatus.waitingForCompression) continue;
      if (_isRemoved(file.id)) continue;
      await _compressFile(file);
    }
  }

  Future<void> _compressFile(UploadedFile file) async {
    final ref = _ref;
    final id = file.id;
    final originalBytes = _pendingOriginalBytes[id];
    if (originalBytes == null) {
      if (_isRemoved(id)) return;
      _update(id, (prev) {
        return prev.copyWith(
          status: UploadStatus.failed,
          errorMessage: 'Дані для компресії недоступні',
          isCompressing: false,
        );
      });
      return;
    }

    if (_isRemoved(id)) return;
    _update(
      id,
      (prev) => prev.copyWith(
        status: UploadStatus.compressing,
        isCompressing: true,
        progress: math.max(prev.progress, _readPortion),
      ),
    );

    final readPortion = _readPortion;
    final compressionPortion = _compressionPortion;

    void updateCompressionProgress(double value) {
      if (_isRemoved(id)) return;
      final normalized = (readPortion + (compressionPortion * value))
          .clamp(0.0, 1.0)
          .toDouble();
      _update(id, (prev) => prev.copyWith(progress: normalized));
    }

    try {
      final int? q = ref?.read(compressionQualityProvider);
      final compressedBytes = switch (file.mode) {
        UploadMode.photo => await _compressor.compressPhoto(
            originalBytes,
            quality: q,
            onProgress: updateCompressionProgress,
          ),
        UploadMode.video => await _compressor.compressVideo(
            originalBytes,
            onProgress: updateCompressionProgress,
          ),
        UploadMode.standard => originalBytes,
      };

      if (_isRemoved(id)) return;
      _pendingOriginalBytes.remove(id);
      _update(
        id,
        (prev) => prev.copyWith(
          progress: 1,
          status: UploadStatus.completed,
          bytes: compressedBytes,
          processedSize: compressedBytes.length,
          isCompressing: false,
        ),
      );
    } catch (e) {
      if (_isRemoved(id)) return;
      _pendingOriginalBytes.remove(id);
      _update(id, (prev) {
        return prev.copyWith(
          status: UploadStatus.failed,
          errorMessage: e.toString(),
          isCompressing: false,
        );
      });
    }
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
}
