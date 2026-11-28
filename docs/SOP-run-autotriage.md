# SOP: Running AutoTriage

**Purpose:** analyze application logs, produce a report, and record a ticket.
**Audience:** anyone who can open PowerShell and Power Automate Desktop on the project machine.

## 1. Prerequisites
- Windows with PowerShell 5.1
- Script execution allowed for your user: `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`
- Power Automate Desktop with the `AutoTriage-Bot` flow (only for the automated run)
- The project folder, with the structure described in the README

## 2. Generate sample logs (test data only)
1. Open PowerShell in the project root.
2. Run `.\scripts\New-SampleLogs.ps1`.
3. Confirm that four `.log` files of 250 lines each appear in `logs\inbox`.

## 3. Run the analyzer manually
1. Put one or more `.log` files in a folder (for a manual test use `logs\inbox`).
2. Run `.\scripts\Analyze-Logs.ps1`. Add `-NoOpen` to stop the report opening in a browser.
3. Read the console output: entries by level, errors by source, top errors, anomaly windows, suggested fixes.
4. Open the newest `reports\report-<timestamp>.html`.
5. Check `reports\last-run.json` for the summary (top error, severity, KB id, error count, report path).

**Expected result:** a line `Parsed N entries, skipped M unreadable lines`, followed by the summaries. If it prints `ERROR: No valid log lines found`, see section 6.

## 4. Run the automated flow
1. Place new `.log` files in `logs\inbox`.
2. Open Power Automate Desktop and open `AutoTriage-Bot`.
3. Click **Run** and wait until the status reads **Ready**.
4. Click **OK** on the final "Done" message.

## 5. Check the results
| Check | Command | Expected |
|---|---|---|
| Tickets created | `Get-Content .\tickets\tickets.csv` | One row per processed log |
| Logs archived | `Get-ChildItem .\logs\archive` | The processed logs |
| Nothing left over | `Get-ChildItem .\logs\inbox, .\logs\processing` | Only `.gitkeep` |
| Reports created | `Get-ChildItem .\reports` | One report per log |

## 6. If a file failed
1. Look in `logs\failed` for the file.
2. Read `tickets\bot-run-log.txt` for the reason.
3. Open the file and check whether it is a real log in the expected format: `yyyy-MM-dd HH:mm:ss [LEVEL] [Source] message`.
4. Fix or replace the file, put it back in `logs\inbox`, and run again.
5. If the cause is not obvious, see the [troubleshooting runbook](troubleshooting-runbook.md).

## 7. Housekeeping
- Delete old reports you no longer need: keep the newest, remove the rest.
- To reset a test run: move logs from `archive` back to `inbox` and rewrite the header line of `tickets.csv` (`TicketId,Created,TopError,Severity,KbId,ErrorCount,ReportPath,Status`).
- To add a known error, add an entry to `kb\knowledge-base.json` (id, pattern, severity, probableCause, steps, resolution) and re-run.
- Commit documentation and code changes with a clear message.
