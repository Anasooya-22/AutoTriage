# Lessons Learned

| # | Problem | Cause | Resolution |
|---|---|---|---|
| 1 |Running scripts is disabled on this system | Default execution policy blocks saved .ps1 files | Set execution policy to RemoteSigned (process scope, then current user)|
|3|Cannot find path ...\logs\inbox|Relative path resolved from the wrong working directory|Used $PSScriptRoot so paths are relative to the script's location|
