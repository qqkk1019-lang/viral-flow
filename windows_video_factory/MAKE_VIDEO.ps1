param(
  [switch]$SkipVoice
)

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

function Stop-WithMessage([string]$message) {
  Write-Host "[錯誤] $message" -ForegroundColor Red
  exit 1
}

if ($null -eq (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
  Stop-WithMessage '找不到 FFmpeg。請先安裝 FFmpeg 並加入 Windows PATH。'
}

$expected = 1..8 | ForEach-Object { Join-Path $root ("images\\S{0:D2}.jpg" -f $_) }
$missing = $expected | Where-Object { -not (Test-Path $_) }
if ($missing.Count -gt 0) {
  $missingNames = $missing | ForEach-Object { Split-Path $_ -Leaf }
  Stop-WithMessage ("缺少圖片：" + [string]::Join('、', $missingNames))
}

$output = Join-Path $root 'output'
New-Item -ItemType Directory -Force -Path $output | Out-Null

if ($SkipVoice) {
  if (-not (Test-Path (Join-Path $output 'narration.wav'))) {
    Stop-WithMessage '測試模式找不到 output\\narration.wav。'
  }
} else {
  Write-Host '[1/3] 產生中文配音...'
  & (Join-Path $root 'TTS.ps1')
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host '[2/3] 建立分鏡清單...'
$images = Get-ChildItem (Join-Path $root 'images') -Filter 'S*.jpg' | Sort-Object Name
$concatLines = [System.Collections.Generic.List[string]]::new()
foreach ($image in $images) {
  $safePath = $image.FullName.Replace('\\', '/')
  $concatLines.Add("file '$safePath'")
  $concatLines.Add('duration 8')
}
$concatLines.Add("file '" + $images[-1].FullName.Replace('\\', '/') + "'")
$concatFile = Join-Path $output 'images.txt'
[System.IO.File]::WriteAllLines($concatFile, $concatLines, [System.Text.UTF8Encoding]::new($false))

Write-Host '[3/3] 合成直式影片與字幕...'
$filter = 'scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,fps=30,format=yuv420p'
if (Test-Path (Join-Path $root 'subtitles.srt')) {
  $filter += ",subtitles=subtitles.srt:force_style='FontName=Microsoft JhengHei,FontSize=18,PrimaryColour=&H00FFFFFF,OutlineColour=&H90000000,BorderStyle=1,Outline=2,Alignment=2,MarginV=110'"
}

$video = Join-Path $output '短影音.mp4'
$audio = Join-Path $output 'narration.wav'
& ffmpeg -y -f concat -safe 0 -i $concatFile -i $audio -vf $filter -c:v libx264 -preset medium -crf 20 -c:a aac -b:a 192k -shortest $video
if ($LASTEXITCODE -ne 0) { Stop-WithMessage 'FFmpeg 合成失敗。' }

Write-Host "完成：$video" -ForegroundColor Green
