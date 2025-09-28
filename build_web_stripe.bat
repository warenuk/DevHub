@echo off
cd /d %~dp0
flutter build web --release --dart-define-from-file=dart_defines.local.json
