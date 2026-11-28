# NuGet Test Matrix: AutoTriage.LogParser

Package under test: `AutoTriage.LogParser`, method `Parser.ParseLine(string)`.
Test program: `src/AutoTriage.LogParser.Tests`, which installs the package from a local feed and runs each case.

## Version 1.0.0
Run on the development machine.

| # | Test case | Input | Expected | Actual | Result |
|---|---|---|---|---|---|
| 1 | Normal INFO line | `2026-11-23 08:01:02 [INFO] [FileWatcher] User session opened` | Parsed, level INFO | Parsed (INFO) | Pass |
| 2 | ERROR line | `2026-11-23 08:00:20 [ERROR] [AuthService] Access denied to folder C:\data\secure` | Parsed, level ERROR | Parsed (ERROR) | Pass |
| 3 | Empty string | `""` | null | null | Pass |
| 4 | Whitespace only | `"   "` | null | null | Pass |
| 5 | Garbage text | `this is not a real log file` | null | null | Pass |
| 6 | Missing bracket | `2026-11-23 08:01:02 [INFO [FileWatcher] msg` | null | null | Pass |
| 7 | Impossible date | `2026-13-45 99:99:99 [INFO] [X] msg` | null | `FormatException` thrown | **Fail** |

**Result: 6 passed, 1 failed.**
**Cause:** the regex checks the shape of the timestamp, but `DateTime.Parse` throws when the date is not real.

## Version 1.0.1
Fix: replaced `DateTime.Parse` with `DateTime.TryParse`, returning null when the date is invalid.
Run in GitHub Actions on a clean Linux runner (run #1 of "Test LogParser package").

| # | Test case | Expected | Actual | Result |
|---|---|---|---|---|
| 1 | Normal INFO line | Parsed, level INFO | Parsed (INFO) | Pass |
| 2 | ERROR line | Parsed, level ERROR | Parsed (ERROR) | Pass |
| 3 | Empty string | null | null | Pass |
| 4 | Whitespace only | null | null | Pass |
| 5 | Garbage text | null | null | Pass |
| 6 | Missing bracket | null | null | Pass |
| 7 | Impossible date | null | null | Pass |

**Result: 7 passed, 0 failed.**

## Notes
- Version 1.0.0 stays on the feed. Published versions are not overwritten.
- 1.0.1 was not run on the development machine. Windows Smart App Control blocks newly built unsigned test binaries there, so the tests run in CI instead.
- Not yet covered: very long lines, non-English text, other timestamp formats, concurrent use.
