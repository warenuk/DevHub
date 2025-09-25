/// Firebase web-specific configuration.
///
/// VAPID key is a **public** key used for WebPush (safe to commit).
/// Make sure it corresponds to the same Firebase project as `firebase-messaging-sw.js`.
class FirebaseWeb {
  static const String vapidKey = "BCicgvCkg8RlnXl3_Q1h8ekbYSUMpEo_-gsDp8TStnCb301YeQf9B1bdbxRiax9AS6oKXS16qmWHal4wearrKa8";
}
