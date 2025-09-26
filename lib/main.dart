import 'package:devhub_gpt/core/constants/firebase_flags.dart';
import 'package:devhub_gpt/core/router/router_provider.dart';
import 'package:devhub_gpt/core/theme/app_theme.dart';
import 'package:devhub_gpt/features/notifications/domain/entities/push_message.dart';
import 'package:devhub_gpt/features/notifications/presentation/providers/push_notifications_providers.dart';
import 'package:devhub_gpt/features/notifications/push_notifications_background.dart';
import 'package:devhub_gpt/firebase_options.dart';
import 'package:devhub_gpt/shared/config/remote_config/application/remote_config_controller.dart';
import 'package:devhub_gpt/shared/config/remote_config/domain/entities/remote_config_feature_flags.dart';
import 'package:devhub_gpt/shared/config/remote_config/remote_config_providers.dart';
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
      debugPrint('Firebase init skipped: ${error.toString()}');
      debugPrint(stackTrace.toString());
    }
  }

  // Drift DB is provided via databaseProvider; no Hive init required
  runApp(const ProviderScope(child: DevHubApp()));
}

class DevHubApp extends ConsumerStatefulWidget {
  const DevHubApp({super.key});

  @override
  ConsumerState<DevHubApp> createState() => _DevHubAppState();
}

class _DevHubAppState extends ConsumerState<DevHubApp> {
  ProviderSubscription<PushMessage?>? _latestMessageSubscription;

  @override
  void initState() {
    super.initState();
    if (kUseFirebaseMessaging && isFirebaseMessagingSupportedPlatform) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final controller =
            ref.read(pushNotificationsControllerProvider.notifier);
        // ignore: unawaited_futures
        controller.initialize();
      });

      _latestMessageSubscription = ref.listenManual<PushMessage?>(
        latestPushMessageProvider,
        _onLatestMessageChanged,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final featureFlags = ref.watch(remoteConfigFeatureFlagsProvider);
    final ThemeMode themeMode =
        featureFlags?.forcedThemeMode ?? ThemeMode.system;
    final List<Locale> supportedLocales =
        _buildSupportedLocales(featureFlags) ??
            const [Locale('en'), Locale('uk')];
    return MaterialApp.router(
      title: 'DevHub',
      theme: AppTheme.lightTheme(null),
      darkTheme: AppTheme.darkTheme(null),
      themeMode: themeMode,
      routerConfig: router,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  @override
  void dispose() {
    _latestMessageSubscription?.close();
    super.dispose();
  }
  void _onLatestMessageChanged(
    PushMessage? previous,
    PushMessage? message,
  ) {
    if (message == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final messenger = _scaffoldMessengerKey.currentState;
      if (messenger == null) {
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
      messenger.showSnackBar(snackBar);
      WidgetsBinding.instance.addPostFrameCallback((__) {
        if (!mounted) {
          return;
        }
        ref
            .read(pushNotificationsControllerProvider.notifier)
            .acknowledgeLatestMessage();
      });
    });
  }

  List<Locale>? _buildSupportedLocales(RemoteConfigFeatureFlags? flags) {
    if (flags == null) {
      return null;
    }
    final locales = flags.supportedLocales
        .map((code) {
          final trimmed = code.trim();
          if (trimmed.isEmpty) {
            return null;
          }
          final normalized = trimmed.replaceAll('-', '_');
          final parts = normalized.split('_');
          if (parts.length == 1) {
            return Locale(parts.first);
          }
          return Locale(parts.first, parts.sublist(1).join('_'));
        })
        .whereType<Locale>()
        .toList(growable: false);
    if (locales.isEmpty) {
      return null;
    }
    return locales;
  }
}

