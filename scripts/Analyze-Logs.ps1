param(
  [string]$LogPath = (Join-Path $PSScriptRoot "..\logs\inbox"),
  [string]$OutDir  = (Join-Path $PSScriptRoot "..\reports"),
  [string]$KbPath  = (Join-Path $PSScriptRoot "..\kb\knowledge-base.json"),
  [switch]$NoOpen
)

$pattern = '^(?<ts>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) \[(?<level>\w+)\] \[(?<src>[^\]]+)\] (?<msg>.*)$'

$unparsed = 0
$entries = foreach ($file in Get-ChildItem $LogPath -Filter *.log) {
  foreach ($line in Get-Content $file.FullName) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    if ($line -match $pattern) {
      [pscustomobject]@{
        Time    = [datetime]$matches['ts']
        Level   = $matches['level']
        Source  = $matches['src']
        Message = $matches['msg']
        File    = $file.Name
      }
    }
    else { $unparsed++ }
  }
}

Write-Host "Parsed $(@($entries).Count) entries, skipped $unparsed unreadable lines"

if (@($entries).Count -eq 0) {
  Write-Host "ERROR: No valid log lines found in $LogPath. Nothing to analyze."
  return
}
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
# Phase 3: match top errors to the knowledge base
$kb = Get-Content $KbPath -Raw | ConvertFrom-Json

$suggestions = foreach ($m in $topMsgs) {
  $hit = $kb | Where-Object { $m.Name -like "*$($_.pattern)*" } | Select-Object -First 1
  [pscustomobject]@{
    Count         = $m.Count
    Error         = $m.Name
    KbId          = if ($hit) { $hit.id } else { 'none' }
    Severity      = if ($hit) { $hit.severity } else { 'Unknown' }
    ProbableCause = if ($hit) { $hit.probableCause } else { 'No knowledge base entry' }
    Steps         = if ($hit) { $hit.steps -join '; ' } else { '' }
    Resolution    = if ($hit) { $hit.resolution } else { '' }
  }
}

Write-Host "`n--- Suggested fixes ---"
$suggestions | Format-List

# Phase 4: HTML report
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$enc = { param($s) [System.Net.WebUtility]::HtmlEncode([string]$s) }

$runTime   = Get-Date -Format 'yyyy-MM-dd HH:mm'
$fileCount = ($entries | Select-Object -ExpandProperty File -Unique).Count
$warnCount = ($entries | Where-Object { $_.Level -eq 'WARN' }).Count
$topSource = ($bySource | Select-Object -First 1).Name

$levelRows = ($byLevel | ForEach-Object {
  "<tr><td>$(& $enc $_.Name)</td><td>$($_.Count)</td></tr>"
}) -join "`n"

$hours = $errors | Group-Object { $_.Time.ToString('yyyy-MM-dd HH') + ':00' } | Sort-Object Name
$maxHour = ($hours | Measure-Object Count -Maximum).Maximum
$hourRows = ($hours | ForEach-Object {
  $w = [math]::Round(($_.Count / $maxHour) * 100)
  "<div class='bar-row'><span>$($_.Name)</span><div class='bar' style='width:$w%'></div><span>$($_.Count)</span></div>"
}) -join "`n"

if ($anomalies) {
  $anomalyRows = ($anomalies | ForEach-Object {
    "<tr><td>$($_.Name)</td><td>$($_.Count)</td></tr>"
  }) -join "`n"
} else {
  $anomalyRows = "<tr><td colspan='2'>No anomalies found</td></tr>"
}

$suggestRows = ($suggestions | ForEach-Object {
  $sevClass = 'sev-' + $_.Severity.ToLower()
  "<tr><td>$($_.Count)</td><td>$(& $enc $_.Error)</td><td>$($_.KbId)</td><td><span class='badge $sevClass'>$($_.Severity)</span></td><td>$(& $enc $_.ProbableCause)</td><td>$(& $enc $_.Steps)</td><td>$(& $enc $_.Resolution)</td></tr>"
}) -join "`n"

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>AutoTriage Report</title>
<style>
  body { font-family: Segoe UI, Arial, sans-serif; margin: 0; background: #f4f6f8; color: #1f2933; }
  header { background: #1f3a5f; color: #fff; padding: 20px 32px; }
  header h1 { margin: 0 0 4px; font-size: 24px; }
  header p { margin: 0; opacity: 0.85; font-size: 14px; }
  main { padding: 24px 32px; max-width: 1200px; margin: 0 auto; }
  .cards { display: flex; flex-wrap: wrap; gap: 16px; margin-bottom: 24px; }
  .card { background: #fff; border-radius: 8px; padding: 16px 20px; min-width: 160px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
  .card .num { font-size: 28px; font-weight: 700; }
  .card .lbl { font-size: 13px; color: #52606d; }
  section { background: #fff; border-radius: 8px; padding: 16px 20px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
  h2 { margin-top: 0; font-size: 18px; }
  .scroll { overflow-x: auto; }
  table { border-collapse: collapse; width: 100%; font-size: 14px; }
  th, td { text-align: left; padding: 8px 10px; border-bottom: 1px solid #e4e7eb; vertical-align: top; }
  th { background: #f0f4f8; }
  .bar-row { display: grid; grid-template-columns: 150px 1fr 40px; align-items: center; gap: 10px; margin: 4px 0; font-size: 13px; }
  .bar { background: #d64545; height: 14px; border-radius: 3px; }
  .badge { padding: 2px 8px; border-radius: 10px; font-size: 12px; font-weight: 600; }
  .sev-high { background: #fde8e8; color: #b42318; }
  .sev-medium { background: #fef3c7; color: #92400e; }
  .sev-low { background: #dcfce7; color: #166534; }
  .sev-unknown { background: #e4e7eb; color: #3e4c59; }
</style>
</head>
<body>
<header>
  <h1>AutoTriage Report</h1>
  <p>Generated $runTime | $fileCount log files analyzed</p>
</header>
<main>
  <div class="cards">
    <div class="card"><div class="num">$($entries.Count)</div><div class="lbl">Log lines parsed</div></div>
    <div class="card"><div class="num">$($errors.Count)</div><div class="lbl">Errors</div></div>
    <div class="card"><div class="num">$warnCount</div><div class="lbl">Warnings</div></div>
    <div class="card"><div class="num">$topSource</div><div class="lbl">Source with most errors</div></div>
  </div>

  <section>
    <h2>Top errors and suggested fixes</h2>
    <div class="scroll"><table>
      <tr><th>Count</th><th>Error</th><th>KB</th><th>Severity</th><th>Probable cause</th><th>Steps</th><th>Resolution</th></tr>
      $suggestRows
    </table></div>
  </section>

  <section>
    <h2>Error bursts (anomalies)</h2>
    <table>
      <tr><th>Window start (10 min)</th><th>Errors</th></tr>
      $anomalyRows
    </table>
  </section>

  <section>
    <h2>Errors per hour</h2>
    $hourRows
  </section>

  <section>
    <h2>Entries by level</h2>
    <table>
      <tr><th>Level</th><th>Count</th></tr>
      $levelRows
    </table>
  </section>
</main>
</body>
</html>
"@

$reportPath = Join-Path $OutDir ("report-{0:yyyyMMdd-HHmmss}.html" -f (Get-Date))
Set-Content -Path $reportPath -Value $html -Encoding UTF8
Write-Host "`nReport written to $reportPath"
if (-not $NoOpen) { Start-Process $reportPath }





# Result summary for the RPA bot
$top = $suggestions | Select-Object -First 1
$summary = [pscustomobject]@{
  RunTime        = $runTime
  TotalLines     = $entries.Count
  ErrorCount     = $errors.Count
  TopError       = $top.Error
  TopSeverity    = $top.Severity
  KbId           = $top.KbId
  AnomalyWindows = $(if ($anomalies) { @($anomalies).Count } else { 0 }) 
  ReportPath     = (Resolve-Path $reportPath).Path
    UnparsedLines  = $unparsed
}
$summary | ConvertTo-Json | Set-Content (Join-Path $OutDir 'last-run.json') -Encoding ASCII