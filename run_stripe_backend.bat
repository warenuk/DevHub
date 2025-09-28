@echo off
setlocal enabledelayedexpansion

set PORT=8899
cd /d "%~dp0server_dart"
if not exist .dart_tool (
  echo == fetching Dart deps ==
  dart pub get || goto :error
)

echo == starting backend on port %PORT% ==
set PORT=%PORT%
 dart run bin/server.dart

exit /b 0
:error
echo Backend failed to start.
exit /b 1
