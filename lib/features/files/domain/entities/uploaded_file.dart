import 'dart:typed_data';

enum UploadStatus {
  preparing,
  awaitingCompression,
  compressing,
  awaitingUpload,
  uploading,
  completed,
  failed,
}

enum UploadMode { standard, photo, video }

extension UploadModeX on UploadMode {
  String get label => switch (this) {
    UploadMode.standard => 'Звичайний файл',
    UploadMode.photo => 'Фото',
    UploadMode.video => 'Відео',
  };
}

class UploadedFile {
  UploadedFile({
    required this.id,
    required this.name,
    required this.size,
    required this.progress,
    required this.status,
    required this.mode,
    this.errorMessage,
    this.bytes,
    this.processedSize,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final int size;
  final double progress;
  final UploadStatus status;
  final UploadMode mode;
  final String? errorMessage;
  final Uint8List? bytes;
  final int? processedSize;
  final DateTime createdAt;

  UploadedFile copyWith({
    double? progress,
    UploadStatus? status,
    String? errorMessage,
    Uint8List? bytes,
    int? processedSize,
  }) {
    return UploadedFile(
      id: id,
      name: name,
      size: size,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      mode: mode,
      errorMessage: errorMessage ?? this.errorMessage,
      bytes: bytes ?? this.bytes,
      processedSize: processedSize ?? this.processedSize,
      createdAt: createdAt,
    );
  }
}
