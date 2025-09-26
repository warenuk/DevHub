import 'dart:typed_data';

import 'package:devhub_gpt/features/files/application/file_compressor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('FileCompressor', () {
    test('compressPhoto reduces size and reports progress', () async {
      final compressor =
          FileCompressor(imageQuality: 60, maxImageDimension: 512);
      final image = img.Image(width: 2048, height: 1536);
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          image.setPixel(
              x, y, img.ColorRgb8((x % 256), (y % 256), ((x + y) % 256)));
        }
      }
      final originalBytes =
          Uint8List.fromList(img.encodeJpg(image, quality: 100));

      final progress = <double>[];
      final result = await compressor.compressPhoto(
        originalBytes,
        onProgress: progress.add,
      );

      expect(result.length, lessThan(originalBytes.length));
      expect(progress.isNotEmpty, isTrue);
      expect(progress.last, closeTo(1.0, 1e-9));
    });

    test('compressPhoto throws for unsupported format', () async {
      final compressor = FileCompressor();
      final data = Uint8List.fromList(List<int>.generate(32, (i) => i));

      await expectLater(
        compressor.compressPhoto(data),
        throwsA(isA<FormatException>()),
      );
    });

    test('compressVideo compresses data and reports progress', () async {
      final compressor = FileCompressor(videoChunkSize: 1024);
      final data = Uint8List.fromList(
        List<int>.generate(64 * 1024, (index) => index % 16),
      );

      final progress = <double>[];
      final result = await compressor.compressVideo(
        data,
        onProgress: progress.add,
      );

      expect(result.length, lessThan(data.length));
      expect(progress.isNotEmpty, isTrue);
      expect(progress.last, closeTo(1.0, 1e-9));
    });
  });
}
