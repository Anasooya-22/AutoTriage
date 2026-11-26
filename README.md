# AutoTriage

Automated log analysis and incident reporting toolkit.

> Status: in progress. See `docs/daily-log.md` for progress.

## Goal
Parse application logs, group errors by pattern and severity, suggest fixes from a
troubleshooting knowledge base, generate an HTML report, and log a mock support ticket,
all triggered by an RPA workflow.

## Planned components
- [ ] PowerShell log analyzer (`scripts/`)
- [ ] Troubleshooting knowledge base (`kb/`)
- [ ] HTML dashboard report (`reports/`)
- [ ] RPA workflow (Power Automate Desktop)
- [ ] Custom NuGet package (`src/`)
- [ ] SOP, runbook, coding standards (`docs/`)

## Folder structure
| Folder | Purpose |
|---|---|
| logs/ | Sample logs (inbox, processing, archive, failed) |
| kb/ | Knowledge base JSON |
| scripts/ | PowerShell scripts |
| reports/ | Generated HTML reports |
| tickets/ | Mock ticket CSV |
| src/ | C# NuGet library and test app |
| docs/ | Documentation |

## How to run
Coming soon.

## Known limitations
Coming soon.
