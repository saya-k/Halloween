@echo off
setlocal
title Halloween AR - Local Test

set "PYTHON_EXE=C:\Users\NPD\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
set "PROJECT_DIR=%~dp0"
set "TEST_PORT=8034"
set "BUILD_VERSION=1035"
set "TEST_URL=http://127.0.0.1:%TEST_PORT%/8thwall-test/?pcTest=1&build=%BUILD_VERSION%"

echo Starting Halloween AR local test...
echo Project: %PROJECT_DIR%
echo Build: %BUILD_VERSION%
echo URL: "%TEST_URL%"
echo.

if not exist "%PYTHON_EXE%" (
  echo [Error] Python runtime was not found:
  echo %PYTHON_EXE%
  echo.
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "$listener = Get-NetTCPConnection -State Listen -LocalPort %TEST_PORT% -ErrorAction SilentlyContinue; if (-not $listener) { Start-Process -FilePath '%PYTHON_EXE%' -ArgumentList @('-m','http.server','%TEST_PORT%','--bind','127.0.0.1','--directory','%PROJECT_DIR%') -WindowStyle Hidden }"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ready = $false; for ($i = 0; $i -lt 20; $i++) { try { $response = Invoke-WebRequest -Uri '%TEST_URL%' -UseBasicParsing -TimeoutSec 2; if ($response.StatusCode -eq 200) { $ready = $true; break } } catch {}; Start-Sleep -Milliseconds 250 }; if (-not $ready) { exit 1 }"

if errorlevel 1 (
  echo [Error] The local test server did not start correctly.
  echo Check whether port %TEST_PORT% is being used by another program.
  echo.
  pause
  exit /b 1
)

if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
  start "" "%ProgramFiles%\Google\Chrome\Application\chrome.exe" "%TEST_URL%"
) else if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" (
  start "" "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" "%TEST_URL%"
) else if exist "%LocalAppData%\Google\Chrome\Application\chrome.exe" (
  start "" "%LocalAppData%\Google\Chrome\Application\chrome.exe" "%TEST_URL%"
) else (
  start "" "%TEST_URL%"
)

endlocal
