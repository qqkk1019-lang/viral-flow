# Windows CI verification entry point. Logs are captured by the workflow.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

New-Item -ItemType Directory -Force -Path images, output | Out-Null
1..8 | ForEach-Object {
  $image = Join-Path $root ("images\\S{0:D2}.jpg" -f $_)
  & ffmpeg -y -f lavfi -i "color=c=0x1b4fa3:s=1080x1920:d=0.1" -frames:v 1 $image | Out-Null
}
& ffmpeg -y -f lavfi -i "anullsrc=r=44100:cl=mono" -t 3 (Join-Path $root 'output\\narration.wav') | Out-Null

& (Join-Path $root 'MAKE_VIDEO.ps1') -SkipVoice
if ($LASTEXITCODE -ne 0) { throw '產片程式回傳失敗。' }

$video = Join-Path $root 'output\\短影音.mp4'
if (-not (Test-Path $video)) { throw '找不到 MP4 成品。' }
$duration = & ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $video
if ([double]$duration -le 0) { throw 'MP4 成品無有效長度。' }
Write-Host "PASS: MP4 generated ($duration seconds)"
