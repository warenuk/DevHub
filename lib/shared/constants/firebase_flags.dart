const kUseFirebase = bool.fromEnvironment('USE_FIREBASE', defaultValue: true);
const String kFirebaseWebVapidKey = String.fromEnvironment(
  'FIREBASE_WEB_VAPID_KEY',
  defaultValue: '',
);
