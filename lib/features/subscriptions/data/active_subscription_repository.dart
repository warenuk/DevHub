import 'dart:convert';

import 'package:devhub_gpt/features/subscriptions/domain/active_subscription.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveSubscriptionRepository {
  ActiveSubscriptionRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _storageKey = 'active_subscription';

  Future<ActiveSubscription?> load() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      return ActiveSubscription.fromJson(data);
    } catch (_) {
      await _prefs.remove(_storageKey);
      return null;
    }
  }

  Future<void> save(ActiveSubscription subscription) async {
    final encoded = jsonEncode(subscription.toJson());
    await _prefs.setString(_storageKey, encoded);
  }

  Future<void> clear() async {
    await _prefs.remove(_storageKey);
  }
}
