import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'devhub_gpt.sqlite'));
      return NativeDatabase.createInBackground(file);
    } on MissingPluginException {
      // Tests or platforms without path_provider: fall back to in-memory DB.
      return NativeDatabase.memory();
    }
  });
}
