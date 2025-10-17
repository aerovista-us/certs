#!/usr/bin/env bash
set -euo pipefail

log(){ echo -e "\e[32m[+] $*\e[0m"; }
warn(){ echo -e "\e[33m[!] $*\e[0m"; }
err(){ echo -e "\e[31m[!] $*\e[0m" >&2; }

require_root(){
  if [[ $EUID -ne 0 ]]; then
    err "Run as root: sudo bash $0"
    exit 1
  fi
}

require_root
export DEBIAN_FRONTEND=noninteractive

log "Update system & install base packages"
apt-get update -y
apt-get upgrade -y
apt-get install -y \
  build-essential curl wget ca-certificates gnupg lsb-release \
  git unzip zip jq htop net-tools \
  software-properties-common \
  openssh-client openssh-server \
  direnv

log "Install Python 3.12 + tools"
apt-get install -y python3.12 python3.12-venv python3-pip
python3.12 -m pip install --upgrade pip
# pipx for global-safe CLIs
apt-get install -y pipx || true
pipx ensurepath || true
# Poetry (isolated)
pipx install poetry || true

log "Install nvm + Node LTS + package managers"
if [[ ! -d /usr/local/nvm ]]; then
  mkdir -p /usr/local/nvm
  export NVM_DIR=/usr/local/nvm
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  # system-wide load
  cat >/etc/profile.d/nvm.sh <<'EOS'
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
EOS
fi
# load nvm in this script
export NVM_DIR=/usr/local/nvm
source /etc/profile.d/nvm.sh
nvm install --lts=Hydrogen || nvm install --lts
nvm alias default 'lts/*'
node -v

# Corepack (manages PNPM/Yarn)
corepack enable
corepack prepare pnpm@latest --activate || true
npm i -g yarn@latest npm-check-updates turbo @biomejs/biome

log "Install Docker Engine + Compose (optional)"
if ! command -v docker >/dev/null 2>&1; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo $VERSION_CODENAME) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  usermod -aG docker ${SUDO_USER:-$USER} || true
fi

log "Git sane defaults"
sudo -u ${SUDO_USER:-$USER} git config --global init.defaultBranch main
sudo -u ${SUDO_USER:-$USER} git config --global pull.rebase false
sudo -u ${SUDO_USER:-$USER} git config --global core.autocrlf input
sudo -u ${SUDO_USER:-$USER} git config --global credential.helper store

log "direnv hook for bash/zsh"
if grep -q "/etc/profile.d/direnv.sh" /etc/profile 2>/dev/null; then :; else
  echo 'eval "$(direnv hook bash)"' >> /etc/bash.bashrc
fi
if command -v zsh >/dev/null 2>&1; then
  echo 'eval "$(direnv hook zsh)"' >> /etc/zsh/zshrc || true
fi

log "Done. Restart your shell or log out/in to load docker group and nvm."
