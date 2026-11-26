# Lessons Learned

| # | Problem | Cause | Resolution |
|---|---|---|---|
| 1 |Running scripts is disabled on this system | Default execution policy blocks saved .ps1 files | Set execution policy to RemoteSigned (process scope, then current user)|
|2|Unable to load Analyze-Logs.ps1|PowerShell ise cannot create new files directly when launched with a non-existent filename|Created the file first using New-Item -ItemType File (or saved a new tab via Ctrl+S inside ISE)|
|3|Cannot find path ...\logs\inbox|Relative path resolved from the wrong working directory|Used $PSScriptRoot so paths are relative to the script's location|
|4|Join-Path fails with "empty string" | $PSScriptRoot is empty when the line is run in the console instead of from a saved script | Put the line inside the script's param block and run the saved file|
|5|ConvertFrom-Json | Select-Object showed blank values|PowerShell 5.1 passes a JSON array down the pipeline as a single object|Assign to a variable first ($kb = ... | ConvertFrom-Json), then pipe $kb|
