#!/usr/bin/env bash
set -Eeuo pipefail

ISARCHY_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly ISARCHY_ROOT
export ISARCHY_ROOT
ISARCHY_DRY_RUN=0
ISARCHY_WITH_DEV=0
export ISARCHY_DRY_RUN ISARCHY_WITH_DEV

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run] [--with-dev]

Install Isarchy's opinionated Hyprland desktop on an existing Arch Linux
installation. Run as the target desktop user, not as root.

--with-dev also enables Docker and adds the current user to the docker group,
which grants root-equivalent access through the Docker daemon.
EOF
}

while (( $# )); do
  case "$1" in
    --dry-run) ISARCHY_DRY_RUN=1 ;;
    --with-dev) ISARCHY_WITH_DEV=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done
export ISARCHY_DRY_RUN ISARCHY_WITH_DEV

if [[ -x "${ISARCHY_ROOT}/bin/isarchy-logo" ]]; then
  "${ISARCHY_ROOT}/bin/isarchy-logo"
fi

# shellcheck source=install/lib.sh
source "${ISARCHY_ROOT}/install/lib.sh"
# shellcheck source=install/10-packages.sh
source "${ISARCHY_ROOT}/install/10-packages.sh"
# shellcheck source=install/20-config.sh
source "${ISARCHY_ROOT}/install/20-config.sh"
# shellcheck source=install/30-services.sh
source "${ISARCHY_ROOT}/install/30-services.sh"

preflight
install_package_sets
install_user_config
enable_services
apply_default_theme

cat <<'EOF'

Isarchy setup complete.
Log out, sign in on a TTY, and run: Hyprland
Open the launcher with SUPER+SPACE and the terminal with SUPER+RETURN.
EOF
