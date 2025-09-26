import 'package:devhub_gpt/shared/config/remote_config/remote_config_keys.dart';

class RemoteConfigDefaults {
  static const bool welcomeBannerEnabled = true;
  static const int markdownMaxLines = 6;
  static const String supportedLocalesCsv = 'en,uk';
  static const List<String> supportedLocalesList = <String>['en', 'uk'];
  static const String appThemeMode = 'system';
  static const String welcomeMessage = 'Welcome to DevHub!';

  static Map<String, Object> asMap() => <String, Object>{
        RemoteConfigKeys.welcomeBannerEnabled: welcomeBannerEnabled,
        RemoteConfigKeys.markdownMaxLines: markdownMaxLines,
        RemoteConfigKeys.supportedLocales: supportedLocalesCsv,
        RemoteConfigKeys.appThemeMode: appThemeMode,
        // Не додаємо welcomeMessage до дефолтів, щоб у UI показувалося "лише з RC"
        // RemoteConfigKeys.welcomeMessage: welcomeMessage,
      };
}
