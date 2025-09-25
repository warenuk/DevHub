import 'dart:typed_data';

enum UploadStatus { preparing, uploading, completed, failed }

class UploadedFile {
  UploadedFile({
    required this.id,
    required this.name,
    required this.size,
    required this.progress,
    required this.status,
    this.errorMessage,
    this.bytes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final int size;
  final double progress;
  final UploadStatus status;
  final String? errorMessage;
  final Uint8List? bytes;
  final DateTime createdAt;

  UploadedFile copyWith({
    double? progress,
    UploadStatus? status,
    String? errorMessage,
    Uint8List? bytes,
  }) {
    return UploadedFile(
      id: id,
      name: name,
      size: size,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      bytes: bytes ?? this.bytes,
      createdAt: createdAt,
    );
  }
}
