import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:crypto/crypto.dart';

void main(List<String> args) async {
  final env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
  final stripeSecret = env['STRIPE_SECRET_KEY'];
  final port = int.tryParse(env['PORT'] ?? '') ?? 8787;
  final frontendOrigin = env['FRONTEND_ORIGIN'] ?? '';

  if (stripeSecret == null || stripeSecret.isEmpty) {
    stderr.writeln('ERROR: STRIPE_SECRET_KEY is not set');
    exit(1);
  }

  final router = Router();

  router.get('/health', (Request _) => Response.ok('ok'));

  // --- minimal persistent map: user_id <-> stripe_customer_id ---
  final store = CustomerMapStore(
    file: File('data/customer_map.json'),
  );
  await store.init();

  // in-memory TTL cache for subscription status (45s)
  final statusCache = StatusCache(ttl: const Duration(seconds: 45));

  // Me-subscription: single source of truth via Stripe
  router.get('/me/subscription', (Request req) async {
    try {
      final userId = req.headers['x-user-id']?.trim();
      final userEmail = req.headers['x-user-email']?.trim();
      if ((userId == null || userId.isEmpty) && (userEmail == null || userEmail.isEmpty)) {
        return Response(401, body: jsonEncode({'message': 'unauthorized'}), headers: {'content-type': 'application/json'});
      }

      // 1) try from local map
      String? customerId = (userId != null && userId.isNotEmpty) ? await store.get(userId) : null;

      // 2) search by metadata(app_user_id) if not found
      if (customerId == null && userId != null && userId.isNotEmpty) {
        customerId = await _findCustomerByAppUserId(stripeSecret, userId);
      }

      // 3) fallback email search
      if (customerId == null && userEmail != null && userEmail.isNotEmpty) {
        customerId = await _findCustomerByEmail(stripeSecret, userEmail);
      }

      if (customerId == null) {
        return Response.ok(jsonEncode({'is_active': false}), headers: {'content-type': 'application/json'});
      }

      // cache lookup
      final cached = statusCache.get(customerId);
      if (cached != null) {
        return Response.ok(jsonEncode(cached), headers: {'content-type': 'application/json'});
      }

      // Fetch subscriptions for customer (Stripe = source of truth)
      final out = await _fetchSubscriptionSummary(stripeSecret, customerId);

      // update cache and ensure mapping (best-effort)
      statusCache.put(customerId, out);
      if (userId != null && userId.isNotEmpty) { await store.set(userId, customerId); }

      // Minimal telemetry for observability
      print('[me/subscription] user=' + (userId ?? '') + ' email=' + (userEmail ?? '') + ' customer=' + customerId + ' sub=' + (out['subscription_id']?.toString() ?? '-') + ' status=' + (out['status']?.toString() ?? '-') + ' active=' + (out['is_active']?.toString() ?? '-'));
      return Response.ok(jsonEncode(out), headers: {'content-type': 'application/json'});
    } catch (e, st) {
      stderr.writeln('me/subscription error: ' + e.toString());
      stderr.writeln(st.toString());
      return Response(500, body: jsonEncode({'message': 'Internal error'}), headers: {'content-type': 'application/json'});
    }
  });

  // Retrieve Checkout Session details for confirmation page
  router.get('/subscriptions/session', (Request req) async {
    try {
      final query = req.requestedUri.queryParameters;
      final sessionId = query['sessionId'] ?? query['session_id'];
      if (sessionId == null || sessionId.isEmpty) {
        return Response(400, body: jsonEncode({'message': 'sessionId is required'}), headers: {'content-type': 'application/json'});
      }
      final uri = Uri.parse('https://api.stripe.com/v1/checkout/sessions/' + sessionId +
          '?expand[]=subscription&expand[]=line_items&expand[]=line_items.data.price.product');
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
      final subField = data['subscription'];
      Map<String, dynamic>? sub;
      if (subField is Map<String, dynamic>) {
        sub = subField;
      } else if (subField is String) {
        sub = {'id': subField};
      } else {
        sub = null;
      }
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

      final userId = req.headers['x-user-id'] ?? '';
      final userEmail = req.headers['x-user-email'] ?? '';

      // Try to attach existing Stripe customer when possible (account-bound, multi-device)
      String? existingCustomerId;
      if (userId.isNotEmpty) {
        existingCustomerId = await store.get(userId) ?? await _findCustomerByAppUserId(stripeSecret, userId);
      }
      if (existingCustomerId == null && userEmail.isNotEmpty) {
        existingCustomerId = await _findCustomerByEmail(stripeSecret, userEmail);
      }

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
          if (userId.isNotEmpty) 'client_reference_id': userId,
          if (userId.isNotEmpty) 'subscription_data[metadata][app_user_id]': userId,
          if (existingCustomerId != null)
            'customer': existingCustomerId
          else if (userEmail.isNotEmpty)
            'customer_email': userEmail,
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
      // Minimal telemetry
      print('[create-checkout-session] user=' + userId + ' customer=' + (existingCustomerId ?? '-') + ' price=' + (priceId ?? '-') + ' session=' + sessionId.toString());
      return Response.ok(jsonEncode({'sessionId': sessionId}), headers: {'content-type': 'application/json'});
    } catch (e, st) {
      stderr.writeln('error: ' + e.toString());
      stderr.writeln(st.toString());
      return Response(500, body: jsonEncode({'message': 'Unable to create session'}), headers: {'content-type': 'application/json'});
    }
  });

  // Stripe Webhook: set customer metadata (app_user_id) after checkout.session.completed
  router.post('/stripe/webhook', (Request req) async {
    try {
      final secret = env['STRIPE_WEBHOOK_SECRET'];
      final sigHeader = req.headers['stripe-signature'];
      final payload = await req.readAsString();
      if (secret != null && secret.isNotEmpty) {
        if (!_verifyStripeSignature(payload, sigHeader, secret)) {
          return Response(400, body: 'invalid signature');
        }
      }
      final event = json.decode(payload) as Map<String, dynamic>;
      final type = event['type'] as String?;
      if (type == 'checkout.session.completed') {
        final obj = (event['data'] as Map)['object'] as Map<String, dynamic>;
        final customerId = obj['customer'] as String?;
        final userId = obj['client_reference_id'] as String?;
        if (customerId != null && userId != null) {
          // Attach mapping and metadata
          await store.set(userId, customerId);
          final uri = Uri.https('api.stripe.com', '/v1/customers/$customerId');
          await http.post(
            uri,
            headers: {
              HttpHeaders.authorizationHeader: 'Bearer ' + stripeSecret,
              HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
            },
            body: { 'metadata[app_user_id]': userId },
          );
        }
      } else if (type == 'customer.subscription.updated' || type == 'customer.subscription.deleted' || type?.startsWith('invoice.payment_') == true) {
        // bust cache for that customer to force fresh Stripe read next time
        final obj = (event['data'] as Map)['object'] as Map<String, dynamic>;
        final customerId = obj['customer'] as String?;
        if (customerId != null) { statusCache.invalidate(customerId); }
      }
      return Response.ok('ok');
    } catch (e, st) {
      stderr.writeln('webhook error: ' + e.toString());
      stderr.writeln(st.toString());
      return Response(500, body: 'error');
    }
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: {
        ACCESS_CONTROL_ALLOW_ORIGIN: frontendOrigin.isNotEmpty ? frontendOrigin : '*',
        ACCESS_CONTROL_ALLOW_HEADERS: 'Origin, Content-Type, Accept, Authorization, Stripe-Signature, X-User-Id, X-User-Email',
        ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, OPTIONS',
      }))
      .addHandler(router);

  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Listening on port ' + server.port.toString());
}

// ================= Helpers & storage =================

Future<String?> _findCustomerByAppUserId(String stripeSecret, String userId) async {
  final q = "metadata['app_user_id']:'$userId'";
  final uri = Uri.https('api.stripe.com', '/v1/customers/search', {'query': q, 'limit': '1'});
  final resp = await http.get(uri, headers: { HttpHeaders.authorizationHeader: 'Bearer ' + stripeSecret });
  if (resp.statusCode >= 200 && resp.statusCode < 300) {
    final list = json.decode(resp.body) as Map<String, dynamic>;
    final data = (list['data'] as List?) ?? const [];
    if (data.isNotEmpty) return (data.first as Map<String, dynamic>)['id'] as String?;
  }
  return null;
}

Future<String?> _findCustomerByEmail(String stripeSecret, String email) async {
  final uri = Uri.https('api.stripe.com', '/v1/customers', {'email': email, 'limit': '1'});
  final resp = await http.get(uri, headers: { HttpHeaders.authorizationHeader: 'Bearer ' + stripeSecret });
  if (resp.statusCode >= 200 && resp.statusCode < 300) {
    final list = json.decode(resp.body) as Map<String, dynamic>;
    final data = (list['data'] as List?) ?? const [];
    if (data.isNotEmpty) return (data.first as Map<String, dynamic>)['id'] as String?;
  }
  return null;
}

Future<Map<String, dynamic>> _fetchSubscriptionSummary(String stripeSecret, String customerId) async {
  final subsUri = Uri.https('api.stripe.com', '/v1/subscriptions', {'customer': customerId, 'limit': '3'});
  final sResp = await http.get(subsUri, headers: { HttpHeaders.authorizationHeader: 'Bearer ' + stripeSecret });
  if (sResp.statusCode < 200 || sResp.statusCode >= 300) {
    return {'message': 'Stripe error', 'status': sResp.statusCode, 'is_active': false, 'customer_id': customerId};
  }
  final sList = json.decode(sResp.body) as Map<String, dynamic>;
  final sData = (sList['data'] as List?) ?? const [];
  if (sData.isEmpty) {
    return {'is_active': false, 'customer_id': customerId};
  }
  sData.sort((a, b) {
    final ma = (a as Map<String, dynamic>)['created'] as int? ?? 0;
    final mb = (b as Map<String, dynamic>)['created'] as int? ?? 0;
    return mb.compareTo(ma);
  });
  final sub = (sData.first as Map<String, dynamic>);
  final status = sub['status'] as String?;
  final currentPeriodEnd = sub['current_period_end'] as int?;
  final cancelAtPeriodEnd = sub['cancel_at_period_end'] as bool?;
  String? priceId;
  String? productId;
  try {
    final items = (sub['items']?['data'] as List?) ?? const [];
    if (items.isNotEmpty) {
      final price = (items.first as Map<String, dynamic>)['price'] as Map<String, dynamic>?;
      priceId = price?['id'] as String?;
      final product = price?['product'];
      if (product is String) productId = product;
      if (product is Map<String, dynamic>) productId = product['id'] as String?;
    }
  } catch (_) {}
  final isActive = (status == 'active' || status == 'trialing') && (currentPeriodEnd ?? 0) > (DateTime.now().millisecondsSinceEpoch ~/ 1000);
  return {
    'customer_id': customerId,
    'subscription_id': sub['id'],
    'status': status,
    'is_active': isActive,
    'current_period_end': currentPeriodEnd,
    'cancel_at_period_end': cancelAtPeriodEnd,
    'priceId': priceId,
    'productId': productId,
  };
}

Future<String?> _resolvePriceForProduct(String stripeSecret, String productId) async {
  // Try product.default_price
  final productUri = Uri.https('api.stripe.com', '/v1/products/' + productId);
  final productResp = await http.get(productUri, headers: { HttpHeaders.authorizationHeader: 'Bearer ' + stripeSecret }).timeout(const Duration(seconds: 10));
  if (productResp.statusCode >= 200 && productResp.statusCode < 300) {
    final prod = json.decode(productResp.body) as Map<String, dynamic>;
    final dp = prod['default_price'];
    if (dp is String && dp.isNotEmpty) return dp;
  }
  // Fallback: first active recurring price
  final pricesUri = Uri.https('api.stripe.com', '/v1/prices', { 'product': productId, 'active': 'true', 'limit': '10' });
  final pricesResp = await http.get(pricesUri, headers: { HttpHeaders.authorizationHeader: 'Bearer ' + stripeSecret }).timeout(const Duration(seconds: 10));
  if (pricesResp.statusCode >= 200 && pricesResp.statusCode < 300) {
    final list = json.decode(pricesResp.body) as Map<String, dynamic>;
    final data = (list['data'] as List?)?.cast<dynamic>() ?? const [];
    for (final item in data) {
      final m = item as Map<String, dynamic>;
      if (m['recurring'] != null) return m['id'] as String?;
    }
    if (data.isNotEmpty) return (data.first as Map<String, dynamic>)['id'] as String?;
  }
  return null;
}

class StatusCache {
  StatusCache({required this.ttl});
  final Duration ttl;
  final _map = <String, _CacheEntry>{};
  Map<String, dynamic>? get(String key) {
    final e = _map[key];
    if (e == null) return null;
    if (DateTime.now().difference(e.storedAt) > ttl) { _map.remove(key); return null; }
    return e.value;
  }
  void put(String key, Map<String, dynamic> value) { _map[key] = _CacheEntry(value); }
  void invalidate(String key) { _map.remove(key); }
}
class _CacheEntry {
  _CacheEntry(this.value): storedAt = DateTime.now();
  final Map<String, dynamic> value;
  final DateTime storedAt;
}

class CustomerMapStore {
  CustomerMapStore({required this.file});
  final File file;
  Map<String, String> _mem = {};
  Future<void> init() async {
    if (!await file.exists()) { await file.create(recursive: true); await file.writeAsString('{}'); }
    final txt = await file.readAsString();
    final Map<String, dynamic> jsonMap = (txt.trim().isEmpty) ? {} : json.decode(txt) as Map<String, dynamic>;
    _mem = jsonMap.map((k, v) => MapEntry(k, v.toString()));
  }
  Future<void> set(String userId, String customerId) async {
    _mem[userId] = customerId;
    await file.writeAsString(json.encode(_mem));
  }
  Future<String?> get(String userId) async { return _mem[userId]; }
}

bool _verifyStripeSignature(String payload, String? sigHeader, String secret) {
  if (sigHeader == null || sigHeader.isEmpty) return false;
  try {
    // Stripe header example: t=timestamp,v1=signature
    final parts = sigHeader.split(',');
    String? t;
    String? v1;
    for (final p in parts) {
      final kv = p.split('=');
      if (kv.length != 2) continue;
      if (kv[0] == 't') t = kv[1];
      if (kv[0] == 'v1') v1 = kv[1];
    }
    if (t == null || v1 == null) return false;
    final signedPayload = '$t.$payload';
    final key = utf8.encode(secret);
    final bytes = utf8.encode(signedPayload);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    final computed = digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return computed.toLowerCase() == v1.toLowerCase();
  } catch (_) {
    return false;
  }
}
