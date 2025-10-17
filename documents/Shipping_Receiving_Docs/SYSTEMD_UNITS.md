# Systemd Units

## Inbox
- `/etc/systemd/system/exchange-inbox.service`
- `/etc/systemd/system/exchange-inbox.path`

## Outbox
- `/etc/systemd/system/exchange-outbox.service`
- `/etc/systemd/system/exchange-outbox.timer`

## Commands
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now exchange-inbox.service exchange-inbox.path exchange-outbox.timer
sudo systemctl status exchange-inbox.service
sudo systemctl status exchange-outbox.timer
journalctl -u exchange-inbox.service -f
```
