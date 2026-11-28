# Lessons Learned

| # | Problem | Cause | Resolution |
|---|---|---|---|
| 1 | "Running scripts is disabled on this system" | Default execution policy blocks saved `.ps1` files | Set the policy to RemoteSigned (process scope, then current user) |
| 2 | ISE: "Unable to load Analyze-Logs.ps1" | `ise` cannot create a file that does not exist | Created the file first with `New-Item`, or saved a new tab |
| 3 | "Cannot find path ...\logs\inbox" | Relative path resolved from the wrong working directory | Used `$PSScriptRoot` so paths are relative to the script |
| 4 | `Join-Path` fails with "empty string" | `$PSScriptRoot` is empty when a line is run in the console | Put the line in the script's `param` block and ran the saved file |
| 5 | `ConvertFrom-Json` piped into `Select-Object` showed blank values | PowerShell 5.1 passes a JSON array down the pipeline as one object | Assigned to a variable first, then piped the variable |
| 6 | PAD error: variable 'ScriptError' doesn't exist | The Run PowerShell script action did not create it in my version | Used `PowershellOutput`, and read the Errors list at the bottom of the designer |
| 7 | Analyzer reported 750 lines for one file | Processed files stayed in the processing folder | Moved each file to archive after processing |
| 8 | Only one ticket in `tickets.csv`, no header; ticket id had spaces and colons | "Write text to file" was set to overwrite; date format not applied | Set the action to append; set the custom format `yyyyMMdd-HHmmss` |
| 9 | A garbage log produced a ticket with empty fields | Analyzer treated zero parsed lines as a normal run; the bot only checked that a result file existed | Analyzer now stops with an error when nothing parses, so the bot routes the file to `failed` |
| 10 | `dotnet run` blocked: "Application Control policy has blocked this file" | Windows blocked the unsigned app launcher | Set `UseAppHost` to false |
| 11 | `dotnet pack` produced 1.0.0 again and the push failed | The `Version` edit in the `.csproj` had not been saved | Confirmed with `Select-String`, fixed, and listed `nupkgs` before pushing |
| 12 | Test DLL blocked again after a rebuild | Smart App Control blocks new unsigned binaries | Moved the test run to GitHub Actions instead of disabling system security |
| 13 | Parser threw `FormatException` on an impossible date | The regex checks the timestamp's shape, not whether it is a real date | Used `DateTime.TryParse` and released 1.0.1 |
| 14 | Commit contained a folder inside a folder | Git repository was initialized one level too high | Removed `.git`, changed into the project folder, and initialized again |
| 15 | `git push` would have been rejected | A file was edited on GitHub, so local and remote differed | Ran `git pull origin main` before pushing |
| 16 | A long command asked "Supply values for the following parameters" | It was pasted without its closing quote | Stopped it, then pasted the command on its own and checked it before pressing Enter |

## What I would do differently
- Test the failure path first, not last.
- Check a file is saved before running or publishing it.
- Build a test with a bad input on day one.
- Edit files in one place only (laptop or GitHub), and pull before starting.
