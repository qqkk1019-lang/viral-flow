@echo off
chcp 65001 >nul
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0MAKE_VIDEO.ps1"
if errorlevel 1 (
  echo.
  echo 產片失敗，請保留畫面並傳給我。
) else (
  echo.
  echo 完成！影片在 output\短影音.mp4
)
pause
