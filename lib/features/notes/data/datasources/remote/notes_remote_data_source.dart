import 'dart:async';
import 'dart:convert';

import 'package:devhub_gpt/features/notes/data/datasources/remote/dto/remote_note_dto.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef WebSocketChannelFactory = WebSocketChannel Function(Uri uri);

abstract class NotesRemoteDataSource {
  Future<List<RemoteNoteDto>> fetchNotes({DateTime? updatedSince});
  Future<RemoteNoteDto> upsert(RemoteNoteDto note);
  Future<void> delete(String id);
  Stream<NotesRealtimeEvent> subscribe({DateTime? updatedSince});
}

sealed class NotesRealtimeEvent {
  const NotesRealtimeEvent();
}

class NoteUpsertedEvent extends NotesRealtimeEvent {
  const NoteUpsertedEvent(this.note);
  final RemoteNoteDto note;
}

class NoteDeletedEvent extends NotesRealtimeEvent {
  const NoteDeletedEvent({required this.noteId, this.updatedAt});
  final String noteId;
  final DateTime? updatedAt;
}

class HttpNotesRemoteDataSource implements NotesRemoteDataSource {
  HttpNotesRemoteDataSource({
    required Dio dio,
    WebSocketChannelFactory? channelFactory,
    String notesPath = '/notes',
    String realtimePath = '/notes/stream',
  })  : _dio = dio,
        _notesPath = notesPath,
        _realtimePath = realtimePath,
        _channelFactory = channelFactory ?? WebSocketChannel.connect;

  final Dio _dio;
  final String _notesPath;
  final String _realtimePath;
  final WebSocketChannelFactory _channelFactory;

  @override
  Future<List<RemoteNoteDto>> fetchNotes({DateTime? updatedSince}) async {
    final query = <String, dynamic>{};
    if (updatedSince != null) {
      query['updated_since'] = updatedSince.toUtc().toIso8601String();
    }
    final response = await _dio.get<List<dynamic>>(
      _notesPath,
      queryParameters: query.isEmpty ? null : query,
    );
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(RemoteNoteDto.fromJson)
        .toList();
  }

  @override
  Future<RemoteNoteDto> upsert(RemoteNoteDto note) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '${_notesPath.endsWith('/') ? _notesPath.substring(0, _notesPath.length - 1) : _notesPath}/${Uri.encodeComponent(note.id)}',
      data: note.toJson(),
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      return note;
    }
    return RemoteNoteDto.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete(
      '${_notesPath.endsWith('/') ? _notesPath.substring(0, _notesPath.length - 1) : _notesPath}/${Uri.encodeComponent(id)}',
    );
  }

  @override
  Stream<NotesRealtimeEvent> subscribe({DateTime? updatedSince}) {
    final uri = _buildRealtimeUri(updatedSince: updatedSince);
    final channel = _channelFactory(uri);

    StreamSubscription? subscription;
    final controller = StreamController<NotesRealtimeEvent>.broadcast();

    controller.onListen = () {
      subscription = channel.stream.listen(
        (event) {
          try {
            controller.add(_decodeEvent(event));
          } catch (error, stackTrace) {
            controller.addError(error, stackTrace);
          }
        },
        onError: controller.addError,
        onDone: controller.close,
      );
    };

    controller.onCancel = () async {
      await subscription?.cancel();
      await channel.sink.close();
    };

    return controller.stream;
  }

  NotesRealtimeEvent _decodeEvent(dynamic event) {
    final Map<String, dynamic> payload;
    if (event is String) {
      payload = jsonDecode(event) as Map<String, dynamic>;
    } else if (event is List<int>) {
      payload = jsonDecode(utf8.decode(event)) as Map<String, dynamic>;
    } else if (event is Map<String, dynamic>) {
      payload = event;
    } else {
      throw StateError(
          'Unsupported realtime payload type: ${event.runtimeType}');
    }

    final type = payload['type'] as String?;
    switch (type) {
      case 'upsert':
        final note = RemoteNoteDto.fromJson(
          (payload['note'] ?? payload) as Map<String, dynamic>,
        );
        return NoteUpsertedEvent(note);
      case 'delete':
        final id = payload['id'] as String?;
        if (id == null) {
          throw StateError('Realtime delete event missing id');
        }
        final updatedAtStr = payload['updatedAt'] as String?;
        return NoteDeletedEvent(
          noteId: id,
          updatedAt: updatedAtStr != null ? DateTime.parse(updatedAtStr) : null,
        );
      default:
        throw StateError('Unknown realtime event type: $type');
    }
  }

  Uri _buildRealtimeUri({DateTime? updatedSince}) {
    final base = Uri.parse(_dio.options.baseUrl);
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    final segments = <String>[
      ...base.pathSegments.where((segment) => segment.isNotEmpty),
      ..._realtimePath.split('/').where((segment) => segment.isNotEmpty),
    ];
    final query = <String, String>{};
    if (updatedSince != null) {
      query['updated_since'] = updatedSince.toUtc().toIso8601String();
    }
    return Uri(
      scheme: scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      pathSegments: segments,
      queryParameters: query.isEmpty ? null : query,
    );
  }
}
