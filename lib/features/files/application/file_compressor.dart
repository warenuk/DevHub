import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:image/image.dart' as img;

typedef CompressionProgressCallback = void Function(double value);

class FileCompressor {
  const FileCompressor({
    this.imageQuality = 70,
    this.maxImageDimension = 1920,
    this.videoChunkSize = 256 * 1024,
  });

  final int imageQuality;
  final int maxImageDimension;
  final int videoChunkSize;

  Future<Uint8List> compressPhoto(
    Uint8List data, {
    CompressionProgressCallback? onProgress,
  }) async {
    onProgress?.call(0);
    final decoded = img.decodeImage(data);
    if (decoded == null) {
      throw const FormatException('Unsupported image format');
    }

    onProgress?.call(0.2);
    final resized = _resizeIfNeeded(decoded);
    onProgress?.call(0.6);
    final jpg = img.encodeJpg(resized, quality: imageQuality);
    onProgress?.call(1.0);
    return Uint8List.fromList(jpg);
  }

  Future<Uint8List> compressVideo(
    Uint8List data, {
    CompressionProgressCallback? onProgress,
  }) async {
    onProgress?.call(0);
    if (data.isEmpty) {
      onProgress?.call(1);
      return data;
    }

    final total = data.length;

    var processed = 0;
    while (processed < total) {
      processed = math.min(processed + videoChunkSize, total);
      onProgress?.call((processed / total).clamp(0.0, 0.95));
      // Дозволяємо UI оновити прогрес.
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }

    final encoded = GZipEncoder().encode(data);
    if (encoded == null) {
      throw const FormatException('Failed to compress video data');
    }
    onProgress?.call(1.0);

    return Uint8List.fromList(encoded);
  }

  img.Image _resizeIfNeeded(img.Image image) {
    final maxSide = math.max(image.width, image.height);
    if (maxSide <= maxImageDimension) {
      return image;
    }

    final scale = maxImageDimension / maxSide;
    final width = (image.width * scale).round();
    final height = (image.height * scale).round();
    return img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.average,
    );
  }
}
