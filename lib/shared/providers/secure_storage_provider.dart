import 'package:devhub_gpt/shared/network/token_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  return storage;
});

final tokenStoreProvider = Provider<TokenStore>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenStore(storage);
});
