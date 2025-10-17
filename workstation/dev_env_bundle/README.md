# AeroVista Developer Environment Bundle
_Last updated: 2025-10-12_

Standardized dev setup for Ubuntu 24.04 workstations (Linux-only). Installs:
- Node.js (LTS), PNPM, Yarn, Corepack
- Python 3.12 + venv, pipx, Poetry
- Git, SSH, common CLI tools
- Docker Engine + Compose plugin (optional)
- direnv + .envrc template
- VS Code extensions list
- Dev Container config (Node + Python in one image)

## Quick start
```bash
sudo bash scripts/bootstrap_dev.sh
# then log out/in (for docker group), or run:
newgrp docker
```

Optional: enable direnv in your shell and allow project `.envrc` files.

### Dev Container (VS Code)
Open a project folder in VS Code and hit “Reopen in Container.” The `.devcontainer` here gives you Node + Python + useful tools preinstalled.

## Versions (defaults)
- Node: 22.x (LTS) via nvm
- Python: 3.12 (system) + virtualenvs per project
- Poetry latest via pipx
- PNPM via Corepack
