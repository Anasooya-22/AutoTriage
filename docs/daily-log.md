# Daily Log

Format: what I did / what broke / how I fixed it / what I learned.
(Edit each entry into your own words and adjust the day numbers and dates.)

## Day 1 - Project setup
- **Did:** Installed Git, VS Code, .NET SDK and Power Automate Desktop. Created the folder structure and the GitHub repository, and pushed the first commit.
- **Broke:** The first commit was made from one folder too high, so GitHub would have shown a folder inside a folder. The push also waited for a browser sign-in that I could not find at first.
- **Fixed:** Deleted `.git`, moved into the inner project folder, ran `git init` again and pushed. Completed the GitHub sign-in in the browser.
- **Learned:** Check the paths in the commit output before pushing.

## Day 2 - Sample logs
- **Did:** Wrote `New-SampleLogs.ps1` to generate four logs of 250 lines with a burst of 15 timeout errors in each.
- **Broke:** Windows blocked running scripts.
- **Fixed:** Set the execution policy to RemoteSigned for the current session, then for my user.
- **Learned:** Why an execution policy exists and why RemoteSigned is a sensible setting.

## Day 3 - Parse and summarize
- **Did:** Built `Analyze-Logs.ps1` with a regex using named groups, then grouped entries by level, source and error message. Broke a log line on purpose and saw the count drop from 1000 to 999.
- **Broke:** `ise` could not open a script file that did not exist yet. Later, the script could not find `logs\inbox` when it was run from my home folder.
- **Fixed:** Created the file with `New-Item` first. Switched to `$PSScriptRoot` so paths are relative to the script.
- **Learned:** Relative paths depend on where you run the script.

## Day 4 - Anomaly check and knowledge base
- **Did:** Added a check that counts errors in 10-minute windows and flags windows above three times the average. Created a JSON knowledge base of six known errors and matched each top error to its cause, steps and resolution.
- **Broke:** `ConvertFrom-Json` piped into `Select-Object` showed blank values. A line using `$PSScriptRoot` failed when I ran it in the console instead of in the script.
- **Fixed:** Assigned the JSON to a variable first. Put the line inside the script's `param` block.
- **Learned:** PowerShell 5.1 passes a JSON array down the pipeline as one object. Also, fixed windows can split a burst across two windows, so one flagged window showed 11 errors instead of 15.

## Day 5 - HTML report
- **Did:** Generated an HTML report with summary cards, a table of top errors with suggested fixes, flagged bursts and an errors-per-hour bar chart. Used HTML encoding on log text.
- **Broke:** Nothing major.
- **Learned:** Why untrusted text must be encoded before it goes into HTML.

## Day 6 - RPA workflow
- **Did:** Added a `-NoOpen` switch and a `last-run.json` result file so the bot can read the outcome. Built the Power Automate Desktop flow: pick up each log, run the analyzer, write a ticket row, archive the log.
- **Broke:** A variable called `ScriptError` did not exist. The analyzer reported 750 lines for one file because processed files stayed in the processing folder. Only one ticket appeared in the CSV and the header was missing. The ticket id had spaces and colons.
- **Fixed:** Used `PowershellOutput`. Moved each file to archive after processing. Changed "Write text to file" from overwrite to append. Set the custom date format `yyyyMMdd-HHmmss`. Moved the final message out of the loop.
- **Learned:** Test with more than one file, and check each output file after each run.

## Day 7 - Failure path
- **Did:** Tested the bot with a garbage log file.
- **Broke:** The bot created a ticket with empty fields and archived the file as if it had worked.
- **Fixed:** Made the analyzer count unreadable lines and stop with an error when nothing can be parsed, so no result file is written and the bot sends the file to `failed` and logs the reason.
- **Learned:** Test the failure path early. A run that "succeeds" with no data is worse than one that fails clearly.

## Day 8 - NuGet package
- **Did:** Built `AutoTriage.LogParser` in C#, packed it, published it to a local folder feed and installed it into a test app. Wrote seven edge-case tests.
- **Broke:** The test run found a bug in 1.0.0: an impossible date caused a `FormatException`. Packing again produced 1.0.0 because the version edit had not been saved. Windows blocked the unsigned test app and DLL.
- **Fixed:** Switched to `DateTime.TryParse`, saved the version change and released 1.0.1. Set `UseAppHost` to false, then moved the tests to GitHub Actions rather than weakening Windows security.
- **Learned:** Semantic versioning, why published versions are never overwritten, and why edge-case tests matter.

## Day 9 - Documentation and CI
- **Did:** Added a GitHub Actions workflow that packs the library and runs the tests: 7 passed, 0 failed on 1.0.1. Wrote the README, SOP, runbook, coding standards, test matrix and lessons learned.
- **Broke:** Nothing major.
- **Learned:** Writing the runbook from real problems made me see which ones came from the same root cause (paths, saved files, and unsigned builds).
