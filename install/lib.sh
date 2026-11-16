#!/usr/bin/env bash

log() {
  printf '\033[1;36m==>\033[0m %s\n' "$*"
}

run() {
  printf '    '
  printf '%q ' "$@"
  printf '\n'
  if (( ! ISARCHY_DRY_RUN )); then
    "$@"
  fi
}

preflight() {
  if (( EUID == 0 )); then
    printf 'Run this installer as the user who will use the desktop, not root.\n' >&2
    exit 1
  fi
  if [[ ! -r /etc/arch-release ]] && (( ! ISARCHY_DRY_RUN )); then
    printf 'Isarchy currently supports Arch Linux only.\n' >&2
    exit 1
  fi
  command -v sudo >/dev/null || {
    printf 'sudo is required.\n' >&2
    exit 1
  }
  if (( ! ISARCHY_DRY_RUN )); then
    sudo -v
  fi
}

read_packages() {
  local manifest="$1"
  awk 'NF && $1 !~ /^#/ { print $1 }' "${manifest}"
}
