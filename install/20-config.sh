#!/usr/bin/env bash

backup_path() {
  local path="$1"
  [[ -e "${path}" || -L "${path}" ]] || return 0
  run mv -- "${path}" "${path}.pre-isarchy.$(date +%Y%m%d%H%M%S)"
}

install_user_config() {
  log "Installing user configuration"
  run mkdir -p -- "${HOME}/.config" "${HOME}/.local/bin" "${HOME}/.local/share/isarchy"

  local component
  for component in hypr waybar kitty wofi mako fastfetch; do
    backup_path "${HOME}/.config/${component}"
    run cp -a -- "${ISARCHY_ROOT}/config/${component}" "${HOME}/.config/${component}"
  done

  run cp -a -- "${ISARCHY_ROOT}/themes/." "${HOME}/.local/share/isarchy/themes/"
  run install -m 0755 "${ISARCHY_ROOT}/bin/isarchy-theme" "${HOME}/.local/bin/isarchy-theme"
  run sudo install -m 0755 "${ISARCHY_ROOT}/bin/isarchy-logo" /usr/local/bin/isarchy-logo
}

apply_default_theme() {
  log "Applying the default Isarchy theme"
  run "${HOME}/.local/bin/isarchy-theme" default
}
