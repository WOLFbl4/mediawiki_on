#!/usr/bin/env bash

set -euo pipefail

VENV_DIR="${HOME}/ansible-venv"
ACTIVATE_LINE='source "$HOME/ansible-venv/bin/activate"'
PATH_LINE='export PATH="$HOME/ansible-venv/bin:$PATH"'

log() {
  printf '[install_ansible] %s\n' "$1"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Error: required command not found: %s\n' "$1" >&2
    exit 1
  fi
}

append_if_missing() {
  local line="$1"
  local file="$2"

  touch "$file"
  if ! grep -qxF "$line" "$file"; then
    printf '%s\n' "$line" >> "$file"
  fi
}

require_command sudo
require_command apt
require_command python3

log "Removing Ansible installed from apt if present"
sudo apt remove -y ansible ansible-core || true

log "Removing Ansible installed from pip if present"
if command -v pip >/dev/null 2>&1; then
  pip uninstall -y ansible ansible-core || true
fi
if command -v pip3 >/dev/null 2>&1; then
  pip3 uninstall -y ansible ansible-core || true
fi

log "Installing OS dependencies"
sudo apt update
sudo apt install -y python3-pip python3-venv

log "Recreating Python virtual environment at ${VENV_DIR}"
rm -rf "${VENV_DIR}"
python3 -m venv "${VENV_DIR}"

log "Upgrading pip inside the virtual environment"
"${VENV_DIR}/bin/python" -m pip install --upgrade pip

log "Installing Ansible inside the virtual environment"
"${VENV_DIR}/bin/pip" install ansible

log "Adding virtual environment activation to ~/.bashrc if needed"
append_if_missing "${ACTIVATE_LINE}" "${HOME}/.bashrc"
append_if_missing "${PATH_LINE}" "${HOME}/.bashrc"

log "Checking installed Ansible version"
"${VENV_DIR}/bin/ansible" --version

log "Installation completed"
log "Run: source \"${VENV_DIR}/bin/activate\""
