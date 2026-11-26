# Lessons Learned

| # | Problem | Cause | Resolution |
|---|---|---|---|
| 1 |Running scripts is disabled on this system | Default execution policy blocks saved .ps1 files | Set execution policy to RemoteSigned (process scope, then current user)|
|2|Unable to load Analyze-Logs.ps1|PowerShell ise cannot create new files directly when launched with a non-existent filename|Created the file first using New-Item -ItemType File (or saved a new tab via Ctrl+S inside ISE)|
|3|Cannot find path ...\logs\inbox|Relative path resolved from the wrong working directory|Used $PSScriptRoot so paths are relative to the script's location|

I used fixed 10-minute windows, so a burst that straddles a boundary can be split and under-counted. A sliding window would fix that, and I'd use the median instead of the average so big bursts don't inflate the threshold
| 4 | Error bursts split across window boundaries (under-counted) | Fixed 10-minute windows split bursts that straddle a boundary, and using the average allows large bursts to inflate the threshold | Use a sliding window to prevent boundary splits and calculate the threshold using the median instead of the average |
