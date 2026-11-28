# Troubleshooting Runbook

Each entry: symptom, likely cause, check, fix. All entries come from problems that happened while building AutoTriage.

| # | Symptom | Likely cause | Check | Fix |
|---|---|---|---|---|
| 1 | "Running scripts is disabled on this system" | Default execution policy blocks `.ps1` files | `Get-ExecutionPolicy -List` | `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned` (use `-Scope Process` for one window only) |
| 2 | ISE says "Unable to load ...ps1: Could not find file" | `ise` cannot create a file that does not exist | `Test-Path .\scripts\Analyze-Logs.ps1` | Create it first with `New-Item`, or save a new ISE tab with Ctrl+S |
| 3 | "Cannot find path ...\logs\inbox" | Relative path resolved from the wrong working directory | Look at the console prompt path | Use `$PSScriptRoot` in the script, or `cd` to the project root |
| 4 | `Join-Path` fails with "empty string" | `$PSScriptRoot` is empty when a line is run in the console | Was the line run from a saved script? | Run the saved script, not pasted lines |
| 5 | `ConvertFrom-Json \| Select-Object` shows blank values | PowerShell 5.1 passes a JSON array down the pipeline as one object | `$kb.Count` after assigning to a variable | Assign to a variable first, then pipe the variable |
| 6 | Analyzer reports more lines than the file has | Earlier files were still in the processing folder | `Get-ChildItem .\logs\processing` | Move processed files to `archive` after each run |
| 7 | `tickets.csv` has only one ticket and no header | "Write text to file" was set to overwrite | Open the action settings | Set "If file exists" to append, and rewrite the header line |
| 8 | Ticket with empty error, severity, and KB id | A file with no valid lines was treated as a normal run | Open the ticket's report | Analyzer must stop with an error when nothing parses (done). Move the file to `failed` |
| 9 | PAD error "Variable 'ScriptError' doesn't exist" | Run PowerShell script action did not create that variable | Variables pane and the Errors list | Use `PowershellOutput` |
| 10 | Popup "Done" appears once per file | The message step is inside the loop | Check indentation of the step | Move the step below the loop's End |
| 11 | `dotnet run` blocked: "Application Control policy has blocked this file" | Windows Smart App Control blocks unsigned local builds | Windows Security notification | Add `UseAppHost` false to the test project. If a DLL is also blocked, test in CI. Do not disable system security |
| 12 | `dotnet pack` produced 1.0.0 again, push says "File does not exist" | `Version` in the `.csproj` was not saved | `Select-String ...csproj -Pattern Version` | Fix the version, save, check `.\nupkgs`, then pack and push |
| 13 | `NU1102: Unable to find package ... version` | That version is not on the feed | `Get-ChildItem C:\LocalFeed` | Push the package to the feed first |
| 14 | `git push` rejected: "failed to push some refs" | GitHub has commits you do not have locally (file edited on the website) | `git status` | `git pull origin main`, then push |
| 15 | GitHub shows a folder inside a folder | Git repository was created one level too high | Paths in the commit output | Remove `.git`, `cd` into the project folder, `git init` again |
| 16 | A long command prompts "Supply values for the following parameters" | A command was pasted without its closing quote or its text | Read the prompt | Press Ctrl+C and paste the command on its own |

## General approach
1. Read the exact error message and the line it points to.
2. Check the most recent change first.
3. Reproduce with the smallest input.
4. Fix one thing, retest, and write it in `docs/lessons-learned.md`.
5. Escalate with a clear note if unresolved: what you ran, what you expected, what happened, what you tried.
