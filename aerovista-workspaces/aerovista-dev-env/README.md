# AeroVista Developer Environment (Portable)

One-command dev shell for collaborators who may not have Node/Python installed.
Works with **Docker** only. Includes Node.js 20, pnpm/yarn, Python 3.12 + pip/poetry/uv, and optional Postgres/Redis.

## Quick Start

```bash
# 1) Copy files to your project root
cp -r aerovista-dev-env/* .

# 2) Create your .env
cp .env.example .env && nano .env

# 3) Start the dev shell
docker compose -f docker-compose.dev.yml run --rm dev

# (optional) Bring up data services for local testing
docker compose -f docker-compose.dev.yml --profile data up -d postgres redis
```

Inside the **dev** container you have:
- **Node 20**, `corepack` (pnpm/yarn), `npm`
- **Python 3.12**, `pip`, `pipx`, `poetry`, `uv`
- **git**, **ffmpeg**, **jq**, **ripgrep**, **zsh**

Your project is mounted at `/workspace`.

## Scripts

- `scripts/devshell.sh` — start a bash/zsh shell in the dev container
- `scripts/devshell.ps1` — same for Windows PowerShell

## VS Code (optional)

Open the folder in VS Code → it will detect `.devcontainer/devcontainer.json`.  
Click **"Reopen in Container"** to get a full-featured editor inside the container
with recommended extensions (Python, Pylance, Ruff, ESLint, Prettier, Tailwind, Docker).

## Common Tasks

```bash
# Node
pnpm install   # or yarn / npm
pnpm dev

# Python
python -m venv .venv && source .venv/bin/activate  # (or use poetry/uv)
pip install -r requirements.txt
pytest -q
```

## Notes

- If your team does not use VS Code, just run the `devshell` script and work from the terminal.
- `.env` is loaded by the compose; feel free to add project variables there.
- To pin versions, edit `Dockerfile.dev` (node versions, poetry version, etc.).
