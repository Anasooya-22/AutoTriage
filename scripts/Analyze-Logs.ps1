param(
  [string]$LogPath = ".\logs\inbox",
  [string]$OutDir  = ".\reports"
)

$pattern = '^(?<ts>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) \[(?<level>\w+)\] \[(?<src>[^\]]+)\] (?<msg>.*)$'

$entries = foreach ($file in Get-ChildItem $LogPath -Filter *.log) {
  foreach ($line in Get-Content $file.FullName) {
    if ($line -match $pattern) {
      [pscustomobject]@{
        Time    = [datetime]$matches['ts']
        Level   = $matches['level']
        Source  = $matches['src']
        Message = $matches['msg']
        File    = $file.Name
      }
    }
  }
}

Write-Host "Parsed $($entries.Count) entries"
$entries | Select-Object -First 5 | Format-Table

$errors = $entries | Where-Object { $_.Level -in 'ERROR','FATAL' }

$byLevel  = $entries | Group-Object Level  | Sort-Object Count -Descending
$bySource = $errors  | Group-Object Source | Sort-Object Count -Descending
$topMsgs  = $errors  | Group-Object Message | Sort-Object Count -Descending | Select-Object -First 10

Write-Host "`n--- Entries by level ---"
$byLevel | Select-Object Name, Count | Format-Table -AutoSize

Write-Host "--- Errors by source ---"
$bySource | Select-Object Name, Count | Format-Table -AutoSize

Write-Host "--- Top 10 error messages ---"
$topMsgs | Select-Object Count, Name | Format-Table -AutoSize -Wrap

# Step C: find unusually busy error windows
$windowMinutes = 10

$buckets = $errors | Group-Object {
  $t = $_.Time
  $start = $t.Date.AddMinutes([math]::Floor($t.TimeOfDay.TotalMinutes / $windowMinutes) * $windowMinutes)
  $start.ToString('yyyy-MM-dd HH:mm')
}

$avg = ($buckets | Measure-Object Count -Average).Average
$threshold = [math]::Max(5, 3 * $avg)
$anomalies = $buckets | Where-Object { $_.Count -gt $threshold } | Sort-Object Name

Write-Host "`n--- Anomaly check (window = $windowMinutes min, flag if more than $([math]::Round($threshold,1)) errors) ---"
if ($anomalies) {
  $anomalies | Select-Object @{n='WindowStart';e={$_.Name}}, Count | Format-Table -AutoSize
} else {
  Write-Host "No anomalies found"
}