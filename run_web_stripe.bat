@echo off
cd /d %~dp0
flutter run -d chrome --dart-define-from-file=dart_defines.local.json
