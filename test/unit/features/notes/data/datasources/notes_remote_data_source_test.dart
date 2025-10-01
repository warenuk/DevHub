import 'dart:async';
import 'dart:convert';

import 'package:devhub_gpt/features/notes/data/datasources/remote/dto/remote_note_dto.dart';
import 'package:devhub_gpt/features/notes/data/datasources/remote/notes_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MockDio extends Mock implements Dio {}

class FakeWebSocketChannel extends StreamChannelMixin<dynamic>
    implements WebSocketChannel {
  FakeWebSocketChannel()
      : _incoming = StreamController<dynamic>.broadcast(),
        _outgoing = StreamController<dynamic>(),
        _readyCompleter = Completer<void>() {
    _sink = _FakeWebSocketSink(_outgoing);
    _readyCompleter.complete();
    _outgoing.stream.listen(
      (event) => _incoming.add(event),
      onError: _incoming.addError,
      onDone: () => _incoming.close(),
    );
  }

  final StreamController<dynamic> _incoming;
  final StreamController<dynamic> _outgoing;
  final Completer<void> _readyCompleter;
  late final _FakeWebSocketSink _sink;

  void addIncoming(dynamic value) => _incoming.add(value);

  Future<void> close() async {
    await _outgoing.close();
    await _incoming.close();
  }

  @override
  Stream<dynamic> get stream => _incoming.stream;

  @override
  WebSocketSink get sink => _sink;

  @override
  String? get protocol => null;

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  Future<void> get ready => _readyCompleter.future;
}

class _FakeWebSocketSink implements WebSocketSink {
  _FakeWebSocketSink(this._controller);

  final StreamController<dynamic> _controller;

  @override
  void add(dynamic data) => _controller.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _controller.addError(error, stackTrace);

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    await _controller.close();
  }

  @override
  Future<void> addStream(Stream<dynamic> stream) =>
      _controller.addStream(stream);

  @override
  Future<void> get done => _controller.done;
}

void main() {
  late MockDio dio;
  late BaseOptions options;

  setUp(() {
    dio = MockDio();
    options = BaseOptions(baseUrl: 'https://api.example.com/v1');
    when(() => dio.options).thenReturn(options);
  });

  test('fetchNotes maps response list into DTOs', () async {
    when(() => dio.get<List<dynamic>>(any(),
        queryParameters: any(named: 'queryParameters'))).thenAnswer(
      (_) async => Response<List<dynamic>>(
        data: [
          {
            'id': '1',
            'title': 'A',
            'content': 'C',
            'createdAt': DateTime.utc(2024, 1, 1).toIso8601String(),
            'updatedAt': DateTime.utc(2024, 1, 2).toIso8601String(),
          }
        ],
        requestOptions: RequestOptions(path: '/notes'),
      ),
    );

    final ds = HttpNotesRemoteDataSource(dio: dio);
    final notes = await ds.fetchNotes();
    expect(notes.single.id, '1');
    expect(notes.single.title, 'A');
  });

  test('upsert returns server payload when provided', () async {
    when(() => dio.put<Map<String, dynamic>>(any(), data: any(named: 'data')))
        .thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        data: {
          'id': '42',
          'title': 'Server',
          'content': 'Body',
          'createdAt': DateTime.utc(2024, 2, 1).toIso8601String(),
          'updatedAt': DateTime.utc(2024, 2, 2).toIso8601String(),
        },
        requestOptions: RequestOptions(path: '/notes/42'),
      ),
    );

    final ds = HttpNotesRemoteDataSource(dio: dio);
    final updated = await ds.upsert(
      RemoteNoteDto(
        id: '42',
        title: 'Local',
        content: 'Body',
        createdAt: DateTime.utc(2024, 2, 1),
        updatedAt: DateTime.utc(2024, 2, 1),
      ),
    );

    expect(updated.title, 'Server');
    verify(() => dio.put<Map<String, dynamic>>(any(), data: any(named: 'data')))
        .called(1);
  });

  test('subscribe decodes websocket events and closes channel on cancel',
      () async {
    final fakeChannel = FakeWebSocketChannel();

    Uri? capturedUri;
    final ds = HttpNotesRemoteDataSource(
      dio: dio,
      channelFactory: (uri) {
        capturedUri = uri;
        return fakeChannel;
      },
    );

    final events = <NotesRealtimeEvent>[];
    final sub = ds.subscribe().listen(events.add);

    fakeChannel.addIncoming(jsonEncode({
      'type': 'upsert',
      'note': {
        'id': '99',
        'title': 'WS',
        'content': 'ws',
        'createdAt': DateTime.utc(2024, 3, 1).toIso8601String(),
        'updatedAt': DateTime.utc(2024, 3, 1).toIso8601String(),
      }
    }));
    fakeChannel.addIncoming(jsonEncode({'type': 'delete', 'id': '99'}));

    await pumpEventQueue();
    await sub.cancel();

    expect(events.length, 2);
    expect(events.first, isA<NoteUpsertedEvent>());
    expect(events.last, isA<NoteDeletedEvent>());
    expect(capturedUri, isNotNull);
    expect(capturedUri!.scheme, 'wss');
  });
}
