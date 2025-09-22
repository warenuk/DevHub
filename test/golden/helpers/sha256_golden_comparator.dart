import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

class Sha256GoldenComparator extends GoldenFileComparator {
  Sha256GoldenComparator(this._baseDir);

  final Uri _baseDir;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final fileUri = _baseDir.resolveUri(golden);
    final file = File.fromUri(fileUri);
    if (!await file.exists()) {
      stderr.writeln('Expected golden file not found at ${fileUri.toFilePath()}');
      return false;
    }

    final expectedHash = (await file.readAsString()).trim();
    final actualHash = sha256.convert(imageBytes).toString();
    if (actualHash == expectedHash) {
      return true;
    }

    final diffFile = File('${fileUri.toFilePath()}.actual');
    await diffFile.create(recursive: true);
    await diffFile.writeAsString(actualHash);
    // ignore: avoid_print
    print('Golden hash mismatch for ${fileUri.toFilePath()}');
    // ignore: avoid_print
    print('Expected: $expectedHash');
    // ignore: avoid_print
    print('Actual  : $actualHash');
    return false;
  }

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) async {
    final fileUri = _baseDir.resolveUri(golden);
    final file = File.fromUri(fileUri);
    await file.create(recursive: true);
    await file.writeAsString(sha256.convert(imageBytes).toString());
  }
}
