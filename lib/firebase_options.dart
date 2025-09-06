import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Manual Firebase options for project devhub-48ed2 (web only).
/// Generated here to unblock development; you can replace with
/// `flutterfire configure` later for multi-platform support.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'This Firebase configuration only includes Web. '
          'Run flutterfire configure to add other platforms.',
        );
      case TargetPlatform.fuchsia:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD4-jvZFtzLrYgnQztz1uDtKRI8huMdgO0',
    appId: '1:552495400925:web:18f821221564e152539834',
    messagingSenderId: '552495400925',
    projectId: 'devhub-48ed2',
    authDomain: 'devhub-48ed2.firebaseapp.com',
    storageBucket: 'devhub-48ed2.firebasestorage.app',
    measurementId: 'G-1NT8VC7HDH',
  );
}
