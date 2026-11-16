#!/usr/bin/env bash
set -Eeuo pipefail

ISARCHY_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ISARCHY_ROOT

dry_run=0
with_dev=0
target_user=""
target_home=""
target_group=""

usage() {
  cat <<'EOF'
Usage: target-install.sh [--with-dev] [--user USER] [--dry-run]

Install Isarchy into an Archinstall target. This command is intended to run as
root through Archinstall's custom_commands support.
EOF
}

while (( $# )); do
  case "$1" in
    --with-dev) with_dev=1 ;;
    --dry-run) dry_run=1 ;;
    --user)
      [[ $# -ge 2 ]] || { printf 'error: --user requires a value\n' >&2; exit 2; }
      target_user="$2"
      shift
      ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [[ -x "${ISARCHY_ROOT}/bin/isarchy-logo" ]]; then
  "${ISARCHY_ROOT}/bin/isarchy-logo"
fi

log() {
  printf '\033[1;36m==>\033[0m %s\n' "$*"
}

run() {
  printf '    '
  printf '%q ' "$@"
  printf '\n'
  if (( ! dry_run )); then
    "$@"
  fi
}

read_packages() {
  awk 'NF && $1 !~ /^#/ { print $1 }' "$1"
}

install_manifest() {
  local manifest="$1"
  local -a packages=()
  mapfile -t packages < <(read_packages "${manifest}")
  ((${#packages[@]})) || return 0
  run pacman -S --needed --noconfirm "${packages[@]}"
}

select_target_user() {
  if [[ -n "${target_user}" ]]; then
    if (( dry_run )); then
      target_home="${ISARCHY_HOME:-/home/${target_user}}"
      target_group="${ISARCHY_GROUP:-${target_user}}"
    else
      target_home="$(getent passwd "${target_user}" | cut -d: -f6)"
      target_group="$(id -gn "${target_user}")"
      [[ -n "${target_home}" ]] || {
        printf 'error: selected target user does not exist: %s\n' "${target_user}" >&2
        exit 1
      }
    fi
    return
  fi

  local -a candidates=()
  mapfile -t candidates < <(
    getent passwd |
      awk -F: '$3 >= 1000 && $3 < 60000 && $7 !~ /(nologin|false)$/ {
        print $3 ":" $1 ":" $6
      }' |
      sort -n
  )
  if ((${#candidates[@]} == 0)); then
    printf 'error: Archinstall did not create a regular desktop user\n' >&2
    exit 1
  fi

  IFS=: read -r _ target_user target_home <<<"${candidates[0]}"
  target_group="$(id -gn "${target_user}")"
  if ((${#candidates[@]} > 1)); then
    printf 'warning: multiple users found; installing defaults for %s\n' "${target_user}" >&2
  fi
}

if (( ! dry_run )); then
  (( EUID == 0 )) || {
    printf 'error: target installer must run as root\n' >&2
    exit 1
  }
  [[ -r /etc/arch-release ]] || {
    printf 'error: target installer supports Arch Linux only\n' >&2
    exit 1
  }
fi
select_target_user

log "Installing Isarchy packages"
run pacman -Syu --noconfirm
install_manifest "${ISARCHY_ROOT}/packages/base.txt"
install_manifest "${ISARCHY_ROOT}/packages/desktop.txt"
(( with_dev )) && install_manifest "${ISARCHY_ROOT}/packages/dev.txt"

log "Installing Isarchy files"
if [[ "${ISARCHY_ROOT}" != "/opt/isarchy" ]]; then
  run rm -rf -- /opt/isarchy
  run cp -a -- "${ISARCHY_ROOT}" /opt/isarchy
fi
run mkdir -p -- "${target_home}/.config" "${target_home}/.local/bin" \
  "${target_home}/.local/share/isarchy/themes"

for component in hypr waybar kitty wofi mako fastfetch; do
  if [[ -e "${target_home}/.config/${component}" ]]; then
    run mv -- "${target_home}/.config/${component}" \
      "${target_home}/.config/${component}.pre-isarchy.$(date +%Y%m%d%H%M%S)"
  fi
  run cp -a -- "${ISARCHY_ROOT}/config/${component}" "${target_home}/.config/${component}"
done
run cp -a -- "${ISARCHY_ROOT}/themes/." "${target_home}/.local/share/isarchy/themes/"
run install -m 0755 "${ISARCHY_ROOT}/bin/isarchy-theme" \
  "${target_home}/.local/bin/isarchy-theme"
run install -m 0755 "${ISARCHY_ROOT}/bin/isarchy-logo" /usr/local/bin/isarchy-logo
run chown -R "${target_user}:${target_group}" "${target_home}/.config" "${target_home}/.local"
run runuser -u "${target_user}" -- env HOME="${target_home}" \
  "${target_home}/.local/bin/isarchy-theme" default

log "Enabling Isarchy services"
run systemctl enable NetworkManager.service
run systemctl enable bluetooth.service
if (( with_dev )); then
  run systemctl enable docker.service
  run usermod -aG docker "${target_user}"
fi

run touch /run/isarchy-install.complete
printf 'Isarchy desktop installed for %s.\n' "${target_user}"
