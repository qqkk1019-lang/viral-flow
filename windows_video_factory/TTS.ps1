[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
Add-Type -AssemblyName System.Speech

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptPath = Join-Path $root 'script.txt'
$outputPath = Join-Path $root 'output\narration.wav'

if (-not (Test-Path $scriptPath)) { throw '找不到 script.txt' }
New-Item -ItemType Directory -Force -Path (Join-Path $root 'output') | Out-Null

$text = Get-Content -Raw -Encoding UTF8 $scriptPath
if ([string]::IsNullOrWhiteSpace($text)) { throw 'script.txt 沒有內容' }

$speaker = [System.Speech.Synthesis.SpeechSynthesizer]::new()
$voice = $speaker.GetInstalledVoices() |
  Where-Object { $_.VoiceInfo.Culture.Name -match '^zh' } |
  Select-Object -First 1

if ($null -eq $voice) {
  throw '找不到中文語音。請在 Windows 安裝「繁體中文（台灣）語音」後再執行。'
}

$speaker.SelectVoice($voice.VoiceInfo.Name)
$speaker.Rate = 0
$speaker.SetOutputToWaveFile($outputPath)
$speaker.Speak($text)
$speaker.Dispose()
Write-Host "配音完成：$outputPath"
