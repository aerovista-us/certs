# Outbox Workflow

## Function
Pushes processed results to GitHub branch `exchange-outbox`.

**Script:** `/srv/core/nxcore/scripts/push_outbox.sh`

### Steps
1. Rsync `/srv/exchange/outbox/` → `/srv/core/nxcore/state/outbox/`
2. Validate allowed filetypes and sizes
3. Commit + push
4. Runs via systemd timer every 15 min

### Allowed Extensions
`.md`, `.txt`, `.json`, `.csv`, `.png`, `.jpg`, `.zip`, `.log.gz`

### Branches
| Branch | Purpose |
|---------|----------|
| main | Base repo |
| ops-state | Internal logs |
| exchange-outbox | Artifacts |
