import 'package:devhub_gpt/features/settings/presentation/pages/settings_page.dart';
import 'package:devhub_gpt/shared/providers/secure_storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _db = {};
  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _db[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _db.remove(key);
    } else {
      _db[key] = value;
    }
  }
}

void main() {
  testWidgets('SettingsPage renders Keys section', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageProvider.overrideWithValue(FakeSecureStorage()),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pump();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Keys'), findsOneWidget);
    expect(find.text('GitHub Token'), findsOneWidget);
    expect(find.text('AI Key'), findsOneWidget);
  });
}
