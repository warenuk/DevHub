import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  final base = Platform.environment['TEST_BASE'] ?? 'http://localhost:8787';

  test('health', () async {
    final r = await http.get(Uri.parse(base + '/health'));
    expect(r.statusCode, 200);
    expect(r.body, 'ok');
  });

  test('create session missing priceId', () async {
    final r = await http.post(Uri.parse(base + '/subscriptions/create-checkout-session'),
        headers: {'content-type': 'application/json'}, body: jsonEncode({}));
    expect(r.statusCode, 400);
  });
}
