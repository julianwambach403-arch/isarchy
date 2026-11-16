#!/usr/bin/env bash

enable_services() {
  log "Enabling networking and Bluetooth"
  run sudo systemctl enable --now NetworkManager.service
  run sudo systemctl enable --now bluetooth.service

  if (( ISARCHY_WITH_DEV )); then
    log "Enabling Docker"
    run sudo systemctl enable --now docker.service
    run sudo usermod -aG docker "${USER}"
  fi
}
