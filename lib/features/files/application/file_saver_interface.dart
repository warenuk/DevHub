import 'dart:typed_data';

abstract class FileSaver {
  Future<String?> save({required String filename, required Uint8List bytes});
}
