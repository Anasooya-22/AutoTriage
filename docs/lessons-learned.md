# Lessons Learned

| # | Problem | Cause | Resolution |
|---|---|---|---|
|  |Running scripts is disabled on this system | Default execution policy blocks saved .ps1 files | Set execution policy to RemoteSigned (process scope, then current user)|
