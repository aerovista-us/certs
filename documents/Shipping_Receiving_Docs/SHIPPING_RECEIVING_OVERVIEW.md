# Shipping & Receiving Overview

## Purpose
The **Shipping & Receiving System** enables NXCore to handle data and file logistics between internal services (AI, n8n, monitoring) and external repositories (GitHub).

It automates:
- Receiving files (`/srv/exchange/inbox`)
- Processing via AI/n8n flows
- Archiving + quarantining inputs
- Shipping results (`/srv/exchange/outbox`) to GitHub

## Directories
| Path | Role | Description |
|------|------|-------------|
| `/srv/exchange/inbox` | Intake | Entry for new uploads |
| `/srv/exchange/processing` | Workbench | Temporary workspace |
| `/srv/exchange/archive` | Audit | Immutable copy of all inputs |
| `/srv/exchange/quarantine` | Security | Unsafe or invalid files |
| `/srv/exchange/outbox` | Shipping dock | Ready for GitHub |
| `/srv/exchange/scripts` | Automation | Watcher + worker scripts |

## Components
- **Inbox Watcher:** monitors inbox and dispatches files to n8n
- **n8n Workflow:** routes by file type for AI or transformation
- **Outbox Worker:** validates and pushes outputs to GitHub
- **Archive/Quarantine:** preserve source or isolate unsafe inputs
