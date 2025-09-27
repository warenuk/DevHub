import 'dart:typed_data';

import 'package:devhub_gpt/features/files/application/file_compressor.dart';
import 'package:devhub_gpt/features/files/domain/entities/uploaded_file.dart';
import 'package:devhub_gpt/features/files/presentation/providers/file_upload_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('FileUploadNotifier', () {
    late FileUploadNotifier notifier;

    setUp(() {
      notifier = FileUploadNotifier(compressor: const FileCompressor());
    });

    test('compresses photo files before upload', () async {
      final image = img.Image(width: 8, height: 8);
      final originalBytes = Uint8List.fromList(img.encodePng(image));
      final id = notifier.addReadyFileForTesting(
        name: 'sample.png',
        originalData: originalBytes,
        mode: UploadMode.photo,
      );

      await notifier.compressFile(id);

      final fileAfterCompression = notifier.state.singleWhere(
        (file) => file.id == id,
      );
      expect(fileAfterCompression.status, UploadStatus.awaitingUpload);
      expect(fileAfterCompression.processedSize, isNotNull);
      expect(fileAfterCompression.progress, closeTo(0.7, 0.05));

      await notifier.uploadFile(id);

      final fileAfterUpload = notifier.state.singleWhere(
        (file) => file.id == id,
      );
      expect(fileAfterUpload.status, UploadStatus.completed);
      expect(fileAfterUpload.progress, 1);
      expect(fileAfterUpload.bytes, isNotNull);
      expect(fileAfterUpload.bytes!.length, fileAfterUpload.processedSize);
    });

    test('ignores upload requests before compression', () async {
      final data = Uint8List.fromList(List<int>.generate(32, (index) => index));
      final id = notifier.addReadyFileForTesting(
        name: 'video.mp4',
        originalData: data,
        mode: UploadMode.video,
      );

      await notifier.uploadFile(id);

      final file = notifier.state.singleWhere((item) => item.id == id);
      expect(file.status, UploadStatus.awaitingCompression);
      expect(file.progress, closeTo(0.3, 0.05));
    });

    test('uploads processed bytes when available', () async {
      final original = Uint8List.fromList(
        List<int>.generate(512, (i) => i % 256),
      );
      final processed = Uint8List.fromList(List<int>.filled(128, 42));
      final id = notifier.addReadyFileForTesting(
        name: 'clip.mp4',
        originalData: original,
        processedData: processed,
        mode: UploadMode.video,
        status: UploadStatus.awaitingUpload,
      );

      await notifier.uploadFile(id);

      final file = notifier.state.singleWhere((item) => item.id == id);
      expect(file.status, UploadStatus.completed);
      expect(file.processedSize, processed.length);
      expect(file.bytes, isNotNull);
      expect(file.bytes!, orderedEquals(processed));
    });
  });
}
