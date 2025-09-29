import 'dart:convert';

import 'package:devhub_stripe_backend/server.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

Future<Response> _call(
  Handler handler,
  String method,
  String path, {
  Map<String, String>? headers,
  Object? body,
}) async {
  final uri = Uri.parse('http://localhost$path');
  return await handler(
    Request(
      method,
      uri,
      headers: headers ?? const {},
      body: body,
    ),
  );
}

void main() {
  Handler handlerWithClient(http.Client client) {
    return createServerHandler(
      stripeSecret: 'sk_test_123',
      httpClient: client,
      frontendOrigin: 'https://frontend.test',
    );
  }

  test('health', () async {
    final handler = handlerWithClient(MockClient((request) async {
      fail('health should not hit Stripe');
    }));
    final response = await _call(handler, 'GET', '/health');
    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'ok');
  });

  test('create session missing priceId', () async {
    final handler = handlerWithClient(MockClient((request) async {
      fail('should not call Stripe when payload invalid');
    }));
    final response = await _call(
      handler,
      'POST',
      '/subscriptions/create-checkout-session',
      headers: {'content-type': 'application/json'},
      body: jsonEncode({}),
    );
    expect(response.statusCode, 400);
  });

  test('subscription status missing id', () async {
    final handler = handlerWithClient(MockClient((request) async {
      fail('should not call Stripe when query missing id');
    }));
    final response = await _call(handler, 'GET', '/subscriptions/status');
    expect(response.statusCode, 400);
  });

  test('fetch subscription status success', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/v1/subscriptions/sub_123');
      return http.Response(
        jsonEncode({
          'id': 'sub_123',
          'status': 'active',
          'customer': 'cus_789',
          'current_period_end': 123456,
          'current_period_start': 123000,
          'cancel_at_period_end': false,
          'items': {
            'data': [
              {
                'price': {
                  'id': 'price_456',
                  'product': {'id': 'prod_999'},
                },
              }
            ],
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final handler = handlerWithClient(client);
    final response = await _call(
      handler,
      'GET',
      '/subscriptions/status?subscriptionId=sub_123',
    );
    expect(response.statusCode, 200);
    final body =
        jsonDecode(await response.readAsString()) as Map<String, dynamic>;
    expect(body['subscriptionId'], 'sub_123');
    expect(body['priceId'], 'price_456');
    expect(body['productId'], 'prod_999');
  });

  test('fetch subscription status returns 404 when Stripe not found', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/v1/subscriptions/sub_missing');
      return http.Response('not found', 404);
    });
    final handler = handlerWithClient(client);
    final response = await _call(
      handler,
      'GET',
      '/subscriptions/status?subscriptionId=sub_missing',
    );
    expect(response.statusCode, 404);
  });

  test('fetch session success parses Stripe response', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/v1/checkout/sessions/sess_123');
      return http.Response(
        jsonEncode({
          'id': 'sess_123',
          'payment_status': 'paid',
          'status': 'complete',
          'customer': 'cus_123',
          'subscription': {
            'id': 'sub_123',
            'status': 'active',
            'current_period_start': 100,
            'current_period_end': 200,
            'cancel_at_period_end': false,
          },
          'line_items': {
            'data': [
              {
                'price': {
                  'id': 'price_123',
                  'product': {
                    'id': 'prod_123',
                  },
                },
              },
            ],
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final handler = handlerWithClient(client);
    final response = await _call(
      handler,
      'GET',
      '/subscriptions/session?sessionId=sess_123',
    );
    expect(response.statusCode, 200);
    final body =
        jsonDecode(await response.readAsString()) as Map<String, dynamic>;
    expect(body['subscriptionId'], 'sub_123');
    expect(body['priceId'], 'price_123');
    expect(body['productId'], 'prod_123');
  });

  test('create checkout session success returns session id', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/v1/checkout/sessions');
      expect(request.method, 'POST');
      expect(request.bodyFields['line_items[0][price]'], 'price_abc');
      expect(
        request.bodyFields['success_url'],
        'https://frontend.test/subscriptions/success?session_id={CHECKOUT_SESSION_ID}',
      );
      return http.Response(
        jsonEncode({'id': 'sess_new'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final handler = handlerWithClient(client);
    final response = await _call(
      handler,
      'POST',
      '/subscriptions/create-checkout-session',
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'priceId': 'price_abc'}),
    );
    expect(response.statusCode, 200);
    final body =
        jsonDecode(await response.readAsString()) as Map<String, dynamic>;
    expect(body['sessionId'], 'sess_new');
  });
}
