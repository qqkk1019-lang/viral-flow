@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
cd /d "%~dp0"

where ffmpeg >nul 2>nul
if errorlevel 1 (
  echo [錯誤] 找不到 FFmpeg。請先安裝 FFmpeg 並加入 PATH。
  pause
  exit /b 1
)

if not exist "images\S01.jpg" (
  echo [錯誤] 請先將 S01.jpg～S08.jpg 放進 images 資料夾。
  pause
  exit /b 1
)

if not exist output mkdir output
echo [1/3] 產生中文配音...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0TTS.ps1"
if errorlevel 1 (
  echo [錯誤] 配音失敗，請查看上方訊息。
  pause
  exit /b 1
)

echo [2/3] 建立分鏡清單...
> "output\images.txt" (
  for %%F in (images\S*.jpg) do (
    echo file '%%~fF'
    echo duration 8
  )
  for %%F in (images\S*.jpg) do set "LAST=%%~fF"
  echo file '!LAST!'
)

set "VF=scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,fps=30,format=yuv420p"
if exist "subtitles.srt" set "VF=!VF!,subtitles=subtitles.srt:force_style='FontName=Microsoft JhengHei,FontSize=18,PrimaryColour=&H00FFFFFF,OutlineColour=&H90000000,BorderStyle=1,Outline=2,Alignment=2,MarginV=110'"

echo [3/3] 合成直式影片與字幕...
ffmpeg -y -f concat -safe 0 -i "output\images.txt" -i "output\narration.wav" -vf "!VF!" -c:v libx264 -preset medium -crf 20 -c:a aac -b:a 192k -shortest "output\短影音.mp4"

if errorlevel 1 (
  echo [錯誤] 合成失敗。請確認圖片與字幕檔可正常開啟。
  pause
  exit /b 1
)

echo.
echo 完成！影片位置：output\短影音.mp4
pause
