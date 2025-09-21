@echo off
setlocal enabledelayedexpansion

REM === НАЛАШТУВАННЯ ===
set "WORKDIR=C:\Flutter\mcp_gateway_modif"
set "PORT=8787"
set "NGROK_DOMAIN=agueda-licenseless-constrainingly.ngrok-free.app"

REM === ПЕРЕВІРКИ ===
if not exist "%WORKDIR%" (
  echo [ПОМИЛКА] Директорія "%WORKDIR%" не знайдена.
  echo Виправте шлях у змінній WORKDIR у цьому .bat-файлі.
  pause
  exit /b 1
)

where node >nul 2>nul
if errorlevel 1 (
  echo [ПОПЕРЕДЖЕННЯ] Node.js не знайдено у PATH. npm може не запуститися.
)

where ngrok >nul 2>nul
if errorlevel 1 (
  echo [ПОМИЛКА] ngrok не знайдено у PATH. Встановіть ngrok або додайте його до PATH.
  pause
  exit /b 1
)

REM === ПЕРЕХІД У РОБОЧУ ДИРЕКТОРІЮ ===
cd /d "%WORKDIR%"

REM === ЗАПУСК MCP-МЕНЕДЖЕРА В ОКРЕМОМУ ВІКНІ ===
start "MCP Manager" cmd /k "npm start"

REM Невелика пауза, щоб сервер встиг піднятися (за потреби відкоригуйте)
timeout /t 2 /nobreak >nul

REM === ЗАПУСК NGROK-ТУНЕЛЮ В ДРУГОМУ ВІКНІ ===
start "ngrok %PORT%" cmd /k "ngrok http --domain=%NGROK_DOMAIN% %PORT%"

echo Обидва процеси запущено у окремих вікнах.
endlocal
