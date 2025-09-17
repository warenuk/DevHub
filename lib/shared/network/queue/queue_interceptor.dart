import 'package:devhub_gpt/shared/network/queue/sync_queue.dart';
import 'package:dio/dio.dart';

/// Інтерсептор, що направляє запити через SyncQueue.
///
/// Пріоритети (більше число — вищий пріоритет):
///   repos: 40, commits: 30, activity: 20, notes: 10, інше: 0.
class QueueInterceptor extends Interceptor {
  QueueInterceptor(this.queue);
  final SyncQueue queue;

  int _priorityFor(Uri uri) {
    final p = uri.path.toLowerCase();
    if (p.contains('/repos')) return 40;
    if (p.contains('/commits')) return 30;
    if (p.contains('/activity')) return 20;
    if (p.contains('/notes')) return 10;
    return 0;
  }

  String _keyFor(Uri uri) {
    // Групуємо по першому сегменту — створює backpressure для сутності.
    final segs = uri.pathSegments;
    if (segs.isEmpty) return '/';
    return '/${segs.first}';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final pr = _priorityFor(options.uri);
    final key = _keyFor(options.uri);
    queue.enqueue<Response<dynamic>>(
      queueKey: key,
      priority: pr,
      run: () async {
        // Пропускаємо запит далі по стеку інтерсепторів.
        // У dio немає прямої можливості чекати тут, тому використовуємо lock/unlock патерн.
        // Однак, простіше — викликати handler.next тут неможливо, бо треба дочекатися відповіді.
        // Тому використовуємо fetch вручну через options.
        final dio = options.extra['dio_instance'] as Dio?;
        if (dio == null) {
          // fallback: нехай просто йде далі
          handler.next(options);
          // Повернення фіктивного Response, все одно dio продовжить пайплайн.
          return Response(requestOptions: options);
        }
        return await dio.fetch<dynamic>(options);
      },
    ).then((resp) {
      handler.resolve(resp);
    }).catchError((Object e, StackTrace s) {
      if (e is DioException) {
        handler.reject(e, true);
      } else {
        handler.reject(DioException(requestOptions: options, error: e), true);
      }
    });
  }
}
