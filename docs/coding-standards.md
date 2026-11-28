# Coding Standards

## General
- Prefer clear names over comments. Add a comment where the reason is not obvious.
- Keep scripts runnable from any folder: build paths from the script location, not the working directory.
- Never hard-code credentials, tokens, or personal data. None are used in this project.
- Handle bad input explicitly. A script that finds nothing to process should say so and stop.

## PowerShell
- Script files: `Verb-Noun.ps1` with an approved verb (`Analyze-Logs.ps1`, `New-SampleLogs.ps1`).
- Variables: `$camelCase`. Parameters: `PascalCase` with a type, in a `param()` block at the top.
- Paths: `Join-Path $PSScriptRoot "..\folder"`, not relative paths from the console.
- Write a status line for each major step (`Write-Host`) so the bot's captured output is readable.
- Use `Where-Object`, `Group-Object`, and `Sort-Object` instead of manual loops where possible.
- Assign JSON to a variable before piping (PowerShell 5.1 array behavior).
- Encode untrusted text with `HtmlEncode` before putting it in HTML.
- Exit without writing the result file when the run fails, so the bot can detect the failure.

## C# (NuGet package)
- One public type per file where practical, namespace matching the package id.
- Public methods validate input and return `null` for bad input rather than throwing.
- Use `TryParse` for values that come from text.
- Version with semantic versioning: patch for fixes, minor for new features, major for breaking changes. Never overwrite a published version.

## HTML and CSS (report)
- Single file with inline CSS, so the report can be opened or emailed on its own.
- Wide tables scroll inside their own container. The page does not scroll sideways.

## RPA flows
- Variables for every path and name, declared at the top.
- One clear responsibility per step, with a short reason documented in `docs/rpa-workflow.md`.
- Every flow has a failure path that keeps the input file and records why.
- Test with good, bad, and empty input before calling a flow done.

## Git
- Commit small and often, with a message that says what changed (`Day 7: analyzer rejects bad input`).
- Run `git pull` before starting work if a file was edited on GitHub.
- Do not commit generated output (reports, tickets, logs, build folders). The `.gitignore` covers these.

## Documentation
- Every script has a README mention and, where run by people, an SOP.
- Every problem that cost more than ten minutes is added to `docs/lessons-learned.md`.
