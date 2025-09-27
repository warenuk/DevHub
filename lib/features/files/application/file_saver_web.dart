// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'file_saver_interface.dart';

class WebFileSaver implements FileSaver {
  @override
  Future<String?> save({
    required String filename,
    required Uint8List bytes,
  }) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = filename
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
    return null;
  }
}

FileSaver createPlatformFileSaver() => WebFileSaver();
