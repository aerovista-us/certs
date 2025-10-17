#!/usr/bin/env bash
set -euo pipefail

REPO="/srv/core/nxcore"
OUTBOX_SRC="/srv/exchange/outbox"
DEST="$REPO/state/outbox"            # tracked area in repo
BRANCH="exchange-outbox"

ALLOW_EXT="\.md|\.txt|\.json|\.csv|\.yaml|\.yml|\.png|\.jpg|\.jpeg|\.webp|\.gif|\.svg|\.log\.gz|\.zip"
MAX_FILE_MB=25
MAX_TOTAL_MB=300

mkdir -p "$DEST"

# rsync outbox → repo tracked dir (preserve structure)
rsync -a --delete "$OUTBOX_SRC"/ "$DEST"/

cd "$REPO"
git fetch --prune
if ! git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
  git checkout -b "$BRANCH"
else
  git checkout "$BRANCH"
  GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_github_pull -o IdentitiesOnly=yes' \
    git pull --ff-only origin "$BRANCH" || true
fi

# safety scans
if grep -R --exclude-dir=.git -E "(BEGIN [A-Z ]*PRIVATE KEY|PASSWORD=|SECRET=|TOKEN=|AWS_|GCP_|AZURE_|Tailscale auth)" state/outbox 2>/dev/null; then
  echo "[ABORT] Potential secret detected in outbox. Refusing to push."
  exit 1
fi

# filetype & size controls
unallowed=$(find state/outbox -type f ! -regex ".*(${ALLOW_EXT})$" -printf "%p\n" || true)
[ -z "$unallowed" ] || { echo "[ABORT] Unallowed file types:\n$unallowed"; exit 1; }

total_bytes=$(du -sb state/outbox | awk '{print $1}')
[ "$total_bytes" -le $((MAX_TOTAL_MB*1024*1024)) ] || { echo "[ABORT] outbox exceeds ${MAX_TOTAL_MB}MB."; exit 1; }

while IFS= read -r f; do
  sz=$(stat -c%s "$f")
  [ "$sz" -le $((MAX_FILE_MB*1024*1024)) ] || { echo "[ABORT] $f > ${MAX_FILE_MB}MB."; exit 1; }
done < <(find state/outbox -type f -print)

# commit & push
git config user.name  "nxcore-bot"
git config user.email "nxcore-bot@users.noreply.github.com"
git add state/outbox

if git diff --cached --quiet; then
  echo "[outbox] nothing to push."
  exit 0
fi

git commit -m "chore(outbox): publish artifacts $(date -u +%Y-%m-%dT%H:%M:%SZ)"
GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_github_push -o IdentitiesOnly=yes' \
  git push -u origin "$BRANCH"
