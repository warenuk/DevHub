import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:devhub_gpt/features/files/application/file_compressor.dart';
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

final fileUploadModeProvider = StateProvider<UploadMode>((ref) {
  return UploadMode.standard;
});

final fileUploadPanelExpandedProvider = StateProvider<bool>((ref) => false);

class FileUploadNotifier extends StateNotifier<List<UploadedFile>> {
  FileUploadNotifier({
    required FileCompressor compressor,
    Ref? ref,
  })  : _compressor = compressor,
        _ref = ref,
        super(const <UploadedFile>[]);

  static const double _readPortion = 0.6;
  static const double _compressionPortion = 0.4;

  final FileCompressor _compressor;
  final Ref? _ref;

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
    state = [
      for (final item in state)
        if (item.id != id) item,
    ];
  }

  bool _isRemoved(String id) => _removedIds.contains(id);

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
      final compressionPortion = shouldCompress ? _compressionPortion : 0.0;

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
      _update(
        id,
        (prev) => prev.copyWith(
          isCompressing: true,
          progress: readPortion,
        ),
      );

      void updateCompressionProgress(double value) {
        if (_isRemoved(id)) return;
        final normalized = (readPortion + (compressionPortion * value))
            .clamp(0.0, 1.0)
            .toDouble();
        _update(id, (prev) => prev.copyWith(progress: normalized));
      }

      Uint8List compressedBytes;
      try {
        compressedBytes = switch (mode) {
          UploadMode.photo => await _compressor.compressPhoto(originalBytes,
              onProgress: updateCompressionProgress),
          UploadMode.video => await _compressor.compressVideo(originalBytes,
              onProgress: updateCompressionProgress),
          UploadMode.standard => originalBytes,
        };
      } catch (e) {
        if (_isRemoved(id)) return;
        _update(id, (prev) {
          return prev.copyWith(
            status: UploadStatus.failed,
            errorMessage: e.toString(),
            isCompressing: false,
          );
        });
        return;
      }

      if (_isRemoved(id)) return;
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
