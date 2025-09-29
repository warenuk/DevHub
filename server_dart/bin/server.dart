import 'dart:io';

import 'package:devhub_stripe_backend/server.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:http/http.dart' as http;
import 'package:shelf/shelf_io.dart';

Future<void> main(List<String> args) async {
  final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
  final stripeSecret = env['STRIPE_SECRET_KEY'];
  final port = int.tryParse(env['PORT'] ?? '') ?? 8787;

  if (stripeSecret == null || stripeSecret.isEmpty) {
    stderr.writeln('ERROR: STRIPE_SECRET_KEY is not set');
    exit(1);
  }

  final frontendOrigin = env['FRONTEND_ORIGIN'];
  final client = http.Client();
  final handler = createServerHandler(
    stripeSecret: stripeSecret,
    httpClient: client,
    frontendOrigin: frontendOrigin,
  );

  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Listening on port ${server.port}');

  var shuttingDown = false;
  Future<void> shutdown() async {
    if (shuttingDown) {
      return;
    }
    shuttingDown = true;
    await server.close(force: true);
    client.close();
  }

  ProcessSignal.sigint.watch().listen((_) async {
    await shutdown();
    exit(0);
  });
  ProcessSignal.sigterm.watch().listen((_) async {
    await shutdown();
    exit(0);
  });
}
