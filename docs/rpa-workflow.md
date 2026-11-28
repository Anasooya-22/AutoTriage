# RPA Workflow: AutoTriage-Bot (Power Automate Desktop)

Run manually from Power Automate Desktop. Attended bot: a person starts it.

## Variables (set at the start)
`ProjectRoot`, `InboxFolder`, `ProcessingFolder`, `ArchiveFolder`, `FailedFolder`, `ScriptPath`, `ResultFile`, `TicketsFile`. All paths are held in variables so a path change is made in one place.

## Steps
| # | Action | Why |
|---|---|---|
| 1 | Set variables | One place for all paths |
| 2 | Get files in folder (`*.log` in the inbox) | Finds the work |
| 3 | For each file | Processes logs one at a time |
| 4 | Move file to `processing` | A file is never half-processed or processed twice |
| 5 | Delete `last-run.json` | A failed run cannot reuse an old result |
| 6 | Run PowerShell script (analyzer, `-NoOpen`) | Does the analysis |
| 7 | Get current date and time, convert to text (`yyyyMMdd-HHmmss`) | Builds a unique ticket id |
| 8 | If `last-run.json` exists | The analyzer writes it only on success |
| 9 | Success: read JSON, write ticket row (append), move log to `archive` | Records the result and keeps the inbox clear |
| 10 | Failure: move log to `failed`, append the PowerShell output to `bot-run-log.txt` | Quarantines bad input and keeps the reason |
| 11 | After the loop: show "Done: processed N file(s)" | Confirms completion |

## Step settings that matter
- **Delete `last-run.json`:** On error is set to continue, because the file does not exist after a failed run.
- **Write text to file (ticket and failure log):** append to existing content, append new line on, encoding UTF-8 or ASCII. The header line is written with ASCII, so the encodings match.
- **Processing folder:** must be empty at the start. The analyzer reads every `.log` in it.

## Exception handling
- The analyzer exits without writing `last-run.json` when no line can be parsed. The bot uses the missing file as its failure signal.
- Failed files are moved aside and logged. They are not deleted.
- An empty inbox ends the run cleanly, with "processed 0 files".

## Known limitations
- Started manually, not scheduled.
- Failure detection depends on `last-run.json` being absent. A script crash after the file was written would be missed.
- Email notification is not implemented.
- Built in Power Automate Desktop, not in RPA Genie.
