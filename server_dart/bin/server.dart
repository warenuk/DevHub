import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart' as dotenv;

void main(List<String> args) async {
  final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
  final stripeSecret = env['STRIPE_SECRET_KEY'];
  final port = int.tryParse(env['PORT'] ?? '') ?? 8787;

  if (stripeSecret == null || stripeSecret.isEmpty) {
    stderr.writeln('ERROR: STRIPE_SECRET_KEY is not set');
    exit(1);
  }

  final router = Router();

  router.get('/health', (Request _) => Response.ok('ok'));

  // Retrieve Checkout Session details for confirmation page
  router.get('/subscriptions/session', (Request req) async {
    try {
      final query = req.requestedUri.queryParameters;
      final sessionId = query['sessionId'] ?? query['session_id'];
      if (sessionId == null || sessionId.isEmpty) {
        return Response(400, body: jsonEncode({'message': 'sessionId is required'}), headers: {'content-type': 'application/json'});
      }
      final uri = Uri.https('api.stripe.com', '/v1/checkout/sessions/' + sessionId, {
        'expand[]': 'subscription',
        'expand[]': 'line_items',
        'expand[]': 'line_items.data.price.product'
      });
      final resp = await http.get(
        uri,
        headers: { HttpHeaders.authorizationHeader: 'Bearer ' + stripeSecret },
      ).timeout(const Duration(seconds: 10));
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        return Response(
          502,
          body: jsonEncode({'message': 'Stripe error', 'status': resp.statusCode, 'body': resp.body}),
          headers: {'content-type': 'application/json'},
        );
      }
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final sub = data['subscription'] as Map<String, dynamic>?;
      final items = (data['line_items']?['data'] as List?) ?? const [];
      String? productId;
      String? priceId;
      if (items.isNotEmpty) {
        final first = items.first as Map<String, dynamic>;
        final price = first['price'] as Map<String, dynamic>?;
        final product = price?['product'];
        priceId = price?['id'] as String?;
        if (product is String) {
          productId = product;
        } else if (product is Map<String, dynamic>) {
          productId = product['id'] as String?;
        }
      }
      final out = <String, dynamic>{
        'id': data['id'],
        'payment_status': data['payment_status'],
        'status': data['status'],
        'customer': data['customer'],
        'subscriptionId': sub?['id'],
        'current_period_start': sub?['current_period_start'],
        'current_period_end': sub?['current_period_end'],
        'cancel_at_period_end': sub?['cancel_at_period_end'],
        'productId': productId,
        'priceId': priceId,
      };
      return Response.ok(jsonEncode(out), headers: {'content-type': 'application/json'});
    } catch (e, st) {
      stderr.writeln('error: ' + e.toString());
      stderr.writeln(st.toString());
      return Response(500, body: jsonEncode({'message': 'Unable to fetch session'}), headers: {'content-type': 'application/json'});
    }
  });

  router.post('/subscriptions/create-checkout-session', (Request req) async {
    try {
      final body = json.decode(await req.readAsString()) as Map<String, dynamic>?;
      String? priceId = body?['priceId'] as String?;
      final String? productId = body?['productId'] as String?;

      // Resolve product -> price if only productId provided
      if ((priceId == null || priceId.isEmpty) && productId != null && productId.isNotEmpty) {
        // Try product.default_price
        final productUri = Uri.https('api.stripe.com', '/v1/products/' + productId);
        final productResp = await http.get(
          productUri,
          headers: { HttpHeaders.authorizationHeader: 'Bearer ' + stripeSecret },
        ).timeout(const Duration(seconds: 10));
        if (productResp.statusCode >= 200 && productResp.statusCode < 300) {
          final prod = json.decode(productResp.body) as Map<String, dynamic>;
          final dp = prod['default_price'];
          if (dp is String && dp.isNotEmpty) { priceId = dp; }
        }
        // Fallback: first active recurring price
        if (priceId == null || priceId.isEmpty) {
          final pricesUri = Uri.https('api.stripe.com', '/v1/prices', { 'product': productId, 'active': 'true', 'limit': '10' });
          final pricesResp = await http.get(
            pricesUri,
            headers: { HttpHeaders.authorizationHeader: 'Bearer ' + stripeSecret },
          ).timeout(const Duration(seconds: 10));
          if (pricesResp.statusCode >= 200 && pricesResp.statusCode < 300) {
            final list = json.decode(pricesResp.body) as Map<String, dynamic>;
            final data = (list['data'] as List?)?.cast<dynamic>() ?? const [];
            Map<String, dynamic>? recurring;
            for (final item in data) {
              final m = item as Map<String, dynamic>;
              if (m['recurring'] != null) { recurring = m; break; }
            }
            final candidate = (recurring ?? (data.isNotEmpty ? data.first as Map<String, dynamic> : <String, dynamic>{}))['id'];
            if (candidate is String && candidate.isNotEmpty) { priceId = candidate; }
          }
        }
      }

      if (priceId == null || priceId.isEmpty) {
        return Response(400, body: jsonEncode({'message': 'priceId is required (or provide productId with default price)'}), headers: {'content-type': 'application/json'});
      }

      final uri = Uri.https('api.stripe.com', '/v1/checkout/sessions');

      // Build success/cancel URLs based on request Origin header or env FRONTEND_ORIGIN
      final reqOrigin = req.headers['origin'];
      final envOrigin = env['FRONTEND_ORIGIN'];
      final origin = (reqOrigin != null && reqOrigin.isNotEmpty)
          ? reqOrigin
          : (envOrigin != null && envOrigin.isNotEmpty)
              ? envOrigin
              : 'http://localhost:8899';

      final resp = await http.post(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + stripeSecret,
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        },
        body: {
          'mode': 'subscription',
          'line_items[0][price]': priceId,
          'line_items[0][quantity]': '1',
          // Send session_id back to frontend for confirmation page
          'success_url': origin + '/subscriptions/success?session_id={CHECKOUT_SESSION_ID}',
          'cancel_url': origin + '/subscriptions/cancel',
          'payment_method_types[]': 'card',
        },
      ).timeout(const Duration(seconds: 10));

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        return Response(
          502,
          body: jsonEncode({'message': 'Stripe error', 'status': resp.statusCode, 'body': resp.body}),
          headers: {'content-type': 'application/json'},
        );
      }

      final data = json.decode(resp.body) as Map<String, dynamic>;
      final sessionId = data['id'];
      if (sessionId == null) {
        return Response(500, body: jsonEncode({'message': 'Invalid Stripe response'}), headers: {'content-type': 'application/json'});
      }
      return Response.ok(jsonEncode({'sessionId': sessionId}), headers: {'content-type': 'application/json'});
    } catch (e, st) {
      stderr.writeln('error: ' + e.toString());
      stderr.writeln(st.toString());
      return Response(500, body: jsonEncode({'message': 'Unable to create session'}), headers: {'content-type': 'application/json'});
    }
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: {
        ACCESS_CONTROL_ALLOW_ORIGIN: '*',
        ACCESS_CONTROL_ALLOW_HEADERS: 'Origin, Content-Type, Accept, Authorization',
        ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, OPTIONS',
      }))
      .addHandler(router);

  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Listening on port ' + server.port.toString());
}
