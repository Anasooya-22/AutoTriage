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
