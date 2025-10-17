# Security and QA

## Policies
- No execution of inbound code.
- All files MIME-scanned and redacted.
- Quarantine unknown, binary, or secret-filled uploads.

## Triggers
Regex match: `SECRET=`, `PRIVATE KEY`, `PASSWORD=`.

## GitHub Hygiene
- Secrets excluded via `.gitignore`
- `.env` and certs never committed

## QA
- Review logs daily via `journalctl`
- Optional n8n alert when quarantine triggered
