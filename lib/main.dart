import 'package:devhub_gpt/core/router/router_provider.dart';
import 'package:devhub_gpt/core/theme/app_theme.dart';
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kUseFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const ProviderScope(child: DevHubApp()));
}

class DevHubApp extends ConsumerWidget {
  const DevHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'DevHub',
      theme: AppTheme.lightTheme(null),
      darkTheme: AppTheme.darkTheme(null),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
