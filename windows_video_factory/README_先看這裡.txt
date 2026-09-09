VIRAL FLOW 免費一鍵產片包（Windows）

這個工具會做什麼？
1. 讀取 script.txt 的中文口白。
2. 使用 Windows 內建語音產生 narration.wav。
3. 將 images 資料夾內 S01.jpg～S08.jpg 做成直式短片。
4. 疊上 subtitles.srt 字幕，輸出 output\短影音.mp4。

第一次只要準備一次
1. 安裝 FFmpeg，並確認在命令提示字元輸入 ffmpeg -version 有顯示版本。
2. Windows 若沒有中文語音：設定 > 時間與語言 > 語言與地區 > 新增繁體中文（台灣）語音。

每次做影片，只做三件事
1. 把 8 張 9:16 圖片放進 images，檔名依序為 S01.jpg、S02.jpg……S08.jpg。
2. 用記事本改 script.txt 與 subtitles.srt。
3. 雙擊 MAKE_VIDEO.bat，等到顯示「完成」即可。

若執行時出現紅色錯誤字，直接截圖傳給我即可；新版已改用 PowerShell 處理影片，避免 CMD 特殊字元造成指令拆壞。

注意
- 每張圖預設停留 8 秒；8 張約為 64 秒，影片會依配音長度自動截尾。
- 字幕時間可先用範例，再依實際配音調整。
- 若要使用 AI 生成畫面，可直接把 VIRAL FLOW 網站生成的分鏡提示詞拿去 Flow／剪映圖文生片，再把成品畫面截成 S01～S08。
