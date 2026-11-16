#!/usr/bin/env bash

install_manifest() {
  local manifest="$1"
  local -a packages=()
  mapfile -t packages < <(read_packages "${manifest}")
  ((${#packages[@]})) || return 0
  run sudo pacman -S --needed --noconfirm "${packages[@]}"
}

install_package_sets() {
  log "Refreshing package databases"
  run sudo pacman -Syu --noconfirm

  log "Installing base utilities"
  install_manifest "${ISARCHY_ROOT}/packages/base.txt"

  log "Installing the Hyprland desktop"
  install_manifest "${ISARCHY_ROOT}/packages/desktop.txt"

  if (( ISARCHY_WITH_DEV )); then
    log "Installing development defaults"
    install_manifest "${ISARCHY_ROOT}/packages/dev.txt"
  fi
}
