import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'file_saver_interface.dart';

class IoFileSaver implements FileSaver {
  IoFileSaver({Directory? targetDirectory})
    : _targetDirectory = targetDirectory;

  final Directory? _targetDirectory;

  @override
  Future<String?> save({
    required String filename,
    required Uint8List bytes,
  }) async {
    final directory = await _resolveDirectory();
    await directory.create(recursive: true);
    final sanitizedName = filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final file = File(p.join(directory.path, sanitizedName));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<Directory> _resolveDirectory() async {
    final override = _targetDirectory;
    if (override != null) {
      return override;
    }
    final downloads = await _findDownloadsDirectory();
    if (downloads != null) {
      return downloads;
    }
    return Directory.systemTemp;
  }

  Future<Directory?> _findDownloadsDirectory() async {
    final env = Platform.environment;
    if (Platform.isMacOS || Platform.isLinux) {
      final home = env['HOME'];
      if (home != null) {
        final directory = Directory(p.join(home, 'Downloads'));
        if (await directory.exists()) {
          return directory;
        }
      }
    } else if (Platform.isWindows) {
      final userProfile = env['USERPROFILE'];
      if (userProfile != null) {
        final directory = Directory(p.join(userProfile, 'Downloads'));
        if (await directory.exists()) {
          return directory;
        }
      }
    }
    return null;
  }
}

FileSaver createPlatformFileSaver() => IoFileSaver();
