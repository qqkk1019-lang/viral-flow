@echo off
setlocal
cd /d "%~dp0"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0MAKE_VIDEO.ps1"
echo.
echo Press any key to close this window.
pause >nul
