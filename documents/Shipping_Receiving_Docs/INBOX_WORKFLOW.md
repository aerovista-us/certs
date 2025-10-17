# Inbox Workflow

## Watcher
**File:** `/srv/exchange/scripts/watch_inbox.sh`
**Service:** `exchange-inbox.service`

### Behavior
1. Watches `/srv/exchange/inbox` via `inotifywait`
2. Moves file → `/processing/<date>/`
3. Copies file → `/archive/<date>/`
4. Detects MIME type
5. Sends metadata to n8n webhook:
```json
{ "filepath": "...", "filename": "...", "mimetype": "...", "ext": ".csv" }
```
6. Retries 3× on failure.

### n8n Integration
- Webhook: `http://localhost:5678/webhook/shipping-receiving`
- Switch node routes by file extension.
- Output written to `/srv/exchange/outbox/<date>/...`.
