import 'dart:convert';
import 'dart:io';

const _kDartDefinePrefix = '--dart-define';

Future<void> main(List<String> args) async {
  final fileDefines = await _loadFileDefines();
  final envDefines = _loadEnvDefines();
  final cliDefines = _extractDefinesFromArgs(args);

  final combinedDefines = <String, String>{}
    ..addAll(fileDefines)
    ..addAll(envDefines)
    ..addAll(cliDefines);

  final command = args.isNotEmpty ? args.first : null;
  final requiresDefineInjection = command == 'run' || command == 'build';
  final providedDefineKeys = _extractProvidedDefineKeys(args);

  final defineArgs = requiresDefineInjection
      ? _buildDefineArgs(combinedDefines, providedDefineKeys)
      : const <String>[];

  final targetsWeb = _targetsWeb(args);
  final vapidKey = combinedDefines['FIREBASE_WEB_VAPID_KEY']?.trim() ?? '';

  if (targetsWeb && vapidKey.isEmpty) {
    stderr.writeln(
      '[flutterw] FIREBASE_WEB_VAPID_KEY is missing. Configure dart_defines.local.json, '
      'dart_defines.json or the FIREBASE_WEB_VAPID_KEY environment variable before targeting web.',
    );
    exitCode = ExitCode.config.code;
    return;
  }

  final flutterArgs = requiresDefineInjection
      ? _mergeWithDefines(args, defineArgs)
      : args;

  final flutterExecutable = _flutterExecutable();
  final process = await Process.start(
    flutterExecutable,
    flutterArgs,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );

  final exit = await process.exitCode;
  exitCode = exit;
}

List<String> _buildDefineArgs(
  Map<String, String> defines,
  Set<String> excludeKeys,
) {
  if (defines.isEmpty) {
    return const <String>[];
  }

  final args = <String>[];
  for (final entry in defines.entries) {
    final key = entry.key;
    final value = entry.value;
    if (value.isEmpty || excludeKeys.contains(key)) {
      continue;
    }
    args.add('$_kDartDefinePrefix=$key=$value');
  }
  return args;
}

List<String> _mergeWithDefines(
  List<String> originalArgs,
  List<String> defineArgs,
) {
  if (defineArgs.isEmpty) {
    return originalArgs;
  }
  if (originalArgs.isEmpty) {
    return [...defineArgs];
  }

  final command = originalArgs.first;
  if (command != 'run' && command != 'build') {
    return originalArgs;
  }

  final merged = <String>[];
  merged.add(command);

  var startIndex = 1;
  if (command == 'build' &&
      originalArgs.length > 1 &&
      !originalArgs[1].startsWith('-')) {
    merged.add(originalArgs[1]);
    startIndex = 2;
  }

  merged.addAll(defineArgs);
  merged.addAll(originalArgs.sublist(startIndex));
  return merged;
}

bool _targetsWeb(List<String> args) {
  if (args.isEmpty) {
    return false;
  }

  final command = args.first;
  if (command == 'build') {
    if (args.length > 1) {
      final target = args[1].toLowerCase();
      return target == 'web';
    }
    return false;
  }

  if (command == 'run') {
    for (var i = 1; i < args.length; i++) {
      final value = args[i];
      if (value == '-d' && i + 1 < args.length) {
        if (_isWebDeviceId(args[i + 1])) {
          return true;
        }
        i++;
        continue;
      }

      if (value.startsWith('--device-id=')) {
        final id = value.split('=').last;
        if (_isWebDeviceId(id)) {
          return true;
        }
      }

      if (value.startsWith('--web-')) {
        return true;
      }
    }
  }

  return false;
}

bool _isWebDeviceId(String id) {
  final lower = id.toLowerCase();
  return lower.contains('chrome') ||
      lower.contains('edge') ||
      lower.contains('firefox') ||
      lower.contains('safari') ||
      lower.contains('web');
}

Future<Map<String, String>> _loadFileDefines() async {
  final candidates = ['dart_defines.local.json', 'dart_defines.json'];

  final defines = <String, String>{};
  for (final name in candidates) {
    final file = File(name);
    if (await file.exists()) {
      final decoded =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        final key = entry.key.trim();
        final value = entry.value;
        if (key.isEmpty || value == null) {
          continue;
        }
        defines[key] = value.toString();
      }
      break;
    }
  }

  return defines;
}

Map<String, String> _loadEnvDefines() {
  final defines = <String, String>{};

  final envVapid = Platform.environment['FIREBASE_WEB_VAPID_KEY'];
  if (envVapid != null && envVapid.trim().isNotEmpty) {
    defines['FIREBASE_WEB_VAPID_KEY'] = envVapid.trim();
  }

  final serverKey = Platform.environment['FIREBASE_FCM_SERVER_KEY'];
  if (serverKey != null && serverKey.trim().isNotEmpty) {
    defines['FIREBASE_FCM_SERVER_KEY'] = serverKey.trim();
  }

  return defines;
}

Map<String, String> _extractDefinesFromArgs(List<String> args) {
  final defines = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg.startsWith('$_kDartDefinePrefix=')) {
      final pair = _parseDefinePair(
        arg.substring(_kDartDefinePrefix.length + 1),
      );
      if (pair != null) {
        defines[pair.key] = pair.value;
      }
    } else if (arg == _kDartDefinePrefix && i + 1 < args.length) {
      final pair = _parseDefinePair(args[i + 1]);
      if (pair != null) {
        defines[pair.key] = pair.value;
      }
      i++;
    }
  }
  return defines;
}

Set<String> _extractProvidedDefineKeys(List<String> args) {
  final keys = <String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg.startsWith('$_kDartDefinePrefix=')) {
      final pair = _parseDefinePair(
        arg.substring(_kDartDefinePrefix.length + 1),
      );
      if (pair != null) {
        keys.add(pair.key);
      }
    } else if (arg == _kDartDefinePrefix && i + 1 < args.length) {
      final pair = _parseDefinePair(args[i + 1]);
      if (pair != null) {
        keys.add(pair.key);
      }
      i++;
    }
  }
  return keys;
}

MapEntry<String, String>? _parseDefinePair(String raw) {
  final index = raw.indexOf('=');
  if (index <= 0) {
    return null;
  }
  final key = raw.substring(0, index).trim();
  final value = raw.substring(index + 1).trim();
  if (key.isEmpty) {
    return null;
  }
  return MapEntry(key, value);
}

String _flutterExecutable() {
  if (Platform.environment.containsKey('FLUTTERW_FLUTTER')) {
    return Platform.environment['FLUTTERW_FLUTTER']!;
  }
  if (Platform.isWindows) {
    return 'flutter.bat';
  }
  return 'flutter';
}

enum ExitCode {
  ok(0),
  config(78);

  const ExitCode(this.code);
  final int code;
}
