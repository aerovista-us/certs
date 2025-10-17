# n8n Routing Guide

## Purpose
Automate per-file-type workflows without editing scripts.

## Routing
| Type | Flow | Output |
|------|------|--------|
| `.csv` | Summarize columns → JSON summary | `/outbox/<date>/csv/summary.json` |
| `.pdf` | OCR + AI extraction | `/outbox/<date>/pdf/text.md` |
| `.zip` | Extract manifest | `/outbox/<date>/zip/manifest.json` |
| `.png` | Image tagging | `/outbox/<date>/images/tags.json` |
| `.txt` | Keyword scan | `/outbox/<date>/text/summary.md` |

## Naming
`[FileType] Processor → [Action] → Outbox Exporter`
