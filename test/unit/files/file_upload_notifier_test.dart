import 'dart:typed_data';

import 'package:devhub_gpt/features/files/domain/entities/uploaded_file.dart';
import 'package:devhub_gpt/features/files/presentation/providers/file_upload_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FileUploadNotifier', () {
    late ProviderContainer container;
    late FileUploadNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(fileUploadControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'processPickedFiles transitions photo uploads to waiting state',
      () async {
        final image = img.Image(width: 64, height: 64);
        final bytes = Uint8List.fromList(img.encodeJpg(image, quality: 90));
        final file = PlatformFile(
          name: 'sample.jpg',
          size: bytes.length,
          bytes: bytes,
        );

        await notifier.processPickedFiles([file], UploadMode.photo);

        final uploads = container.read(fileUploadControllerProvider);
        expect(uploads, hasLength(1));
        final uploaded = uploads.first;
        expect(uploaded.status, UploadStatus.waitingForCompression);
        expect(uploaded.progress, greaterThan(0));
        expect(container.read(fileUploadModeLockedProvider), isTrue);
      },
    );

    test('compressPending compresses photo uploads', () async {
      final image = img.Image(width: 128, height: 128);
      final originalBytes = Uint8List.fromList(img.encodePng(image));
      final file = PlatformFile(
        name: 'large.png',
        size: originalBytes.length,
        bytes: originalBytes,
      );

      await notifier.processPickedFiles([file], UploadMode.photo);
      await notifier.compressPending();

      final uploads = container.read(fileUploadControllerProvider);
      final uploaded = uploads.single;
      expect(uploaded.status, UploadStatus.completed);
      expect(uploaded.bytes, isNotNull);
      expect(uploaded.processedSize, equals(uploaded.bytes!.length));
      expect(uploaded.bytes, isNotEmpty);
      expect(uploaded.progress, 1);
    });

    test('compressPending compresses video uploads', () async {
      final data = Uint8List.fromList(List<int>.filled(4096, 7));
      final file = PlatformFile(
        name: 'clip.mp4',
        size: data.length,
        bytes: data,
      );

      await notifier.processPickedFiles([file], UploadMode.video);
      await notifier.compressPending();

      final uploads = container.read(fileUploadControllerProvider);
      final uploaded = uploads.single;
      expect(uploaded.status, UploadStatus.completed);
      expect(uploaded.bytes, isNotNull);
      expect(uploaded.processedSize, isNotNull);
      expect(uploaded.processedSize, lessThan(uploaded.size));
    });

    test(
      'processPickedFiles fails for unsupported extension in compression mode',
      () async {
        final data = Uint8List.fromList(
          List<int>.generate(128, (index) => index),
        );
        final file = PlatformFile(
          name: 'notes.txt',
          size: data.length,
          bytes: data,
        );

        await notifier.processPickedFiles([file], UploadMode.photo);

        final uploads = container.read(fileUploadControllerProvider);
        final uploaded = uploads.single;
        expect(uploaded.status, UploadStatus.failed);
        expect(uploaded.errorMessage, contains('Формат файлу'));
      },
    );

    test('standard uploads complete immediately', () async {
      final data = Uint8List.fromList(List<int>.filled(256, 42));
      final file = PlatformFile(
        name: 'document.bin',
        size: data.length,
        bytes: data,
      );

      await notifier.processPickedFiles([file], UploadMode.standard);

      final uploads = container.read(fileUploadControllerProvider);
      final uploaded = uploads.single;
      expect(uploaded.status, UploadStatus.completed);
      expect(uploaded.bytes, isNotNull);
      expect(uploaded.processedSize, equals(uploaded.bytes!.length));
    });
  });
}
