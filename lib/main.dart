import 'package:devhub_gpt/core/constants/firebase_flags.dart';
import 'package:devhub_gpt/core/router/router_provider.dart';
import 'package:devhub_gpt/core/theme/app_theme.dart';
import 'package:devhub_gpt/features/auth/presentation/providers/auth_providers.dart';
import 'package:devhub_gpt/features/notifications/presentation/providers/push_notifications_providers.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/push_message.dart';
import 'package:devhub_gpt/features/notifications/push_notifications_background.dart';
import 'package:devhub_gpt/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  if (kUseFirebase) {
    try {
      FirebaseOptions? options;
      try {
        options = DefaultFirebaseOptions.currentPlatform;
      } on UnsupportedError {
        options = null;
      }
      if (options != null) {
        await Firebase.initializeApp(options: options);
      } else {
        await Firebase.initializeApp();
      }
      // Ensure web persistence so email/password session survives reloads
      if (kIsWeb && kUseFirebaseAuth) {
        await fb.FirebaseAuth.instance.setPersistence(fb.Persistence.LOCAL);
      }
      if (kUseFirebaseMessaging && isFirebaseMessagingSupportedPlatform) {
        await FirebaseMessaging.instance.setAutoInitEnabled(true);
        if (!kIsWeb) {
          FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler,
          );
        }
      }
    } catch (error, stackTrace) {
      debugPrint("Firebase init skipped: " + error.toString());
      debugPrint(stackTrace.toString());
    }
  }
  // Drift DB is provided via databaseProvider; no Hive init required

  runApp(const ProviderScope(child: DevHubApp()));
}

class DevHubApp extends ConsumerWidget {
  const DevHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kUseFirebaseMessaging && isFirebaseMessagingSupportedPlatform) {
      ref.watch(pushNotificationsBootstrapProvider);
      ref.listen<PushMessage?>(latestPushMessageProvider, (
        _,
        PushMessage? message,
      ) {
        if (message == null) {
          return;
        }
        final SnackBar snackBar = SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if ((message.title ?? '').isNotEmpty)
                Text(
                  message.title!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if ((message.body ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(message.body!),
                ),
            ],
          ),
          duration: const Duration(seconds: 4),
        );
        _scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
        ref
            .read(pushNotificationsControllerProvider.notifier)
            .acknowledgeLatestMessage();
      });
    }
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'DevHub',
      theme: AppTheme.lightTheme(null),
      darkTheme: AppTheme.darkTheme(null),
      themeMode: ThemeMode.system,
      routerConfig: router,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('en'), Locale('uk')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
