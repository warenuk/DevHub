import 'package:devhub_gpt/core/constants/firebase_flags.dart';
import 'package:devhub_gpt/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kUseFirebaseMessaging) {
    return;
  }
  try {
    if (Firebase.apps.isEmpty) {
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
    }
  } catch (error, stackTrace) {
    debugPrint('Background Firebase init failed: $error');
    debugPrint(stackTrace.toString());
  }
  debugPrint('Received background message: ${message.messageId}');
}
