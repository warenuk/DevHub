bool isRunningInFlutterTest() =>
    const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);
