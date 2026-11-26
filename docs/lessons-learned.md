# Lessons Learned

| # | Problem | Cause | Resolution |
|---|---|---|---|
| 1 |Running scripts is disabled on this system | Default execution policy blocks saved .ps1 files | Set execution policy to RemoteSigned (process scope, then current user)|
|2|Unable to load Analyze-Logs.ps1|PowerShell ise cannot create new files directly when launched with a non-existent filename|Created the file first using New-Item -ItemType File (or saved a new tab via Ctrl+S inside ISE)|
|3|Cannot find path ...\logs\inbox|Relative path resolved from the wrong working directory|Used $PSScriptRoot so paths are relative to the script's location|
