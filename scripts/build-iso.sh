#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT_DIR
readonly PROFILE_DIR="${ROOT_DIR}/build/profile"
readonly WORK_DIR="${WORK_DIR:-${ROOT_DIR}/build/work}"
readonly OUT_DIR="${OUT_DIR:-${ROOT_DIR}/out}"

if (( EUID != 0 )); then
  printf 'error: mkarchiso must run as root; use sudo %s\n' "$0" >&2
  exit 1
fi
if ! command -v mkarchiso >/dev/null; then
  printf 'error: mkarchiso not found; install the archiso package\n' >&2
  exit 1
fi

"${ROOT_DIR}/scripts/prepare-profile.sh" "${PROFILE_DIR}"
rm -rf -- "${WORK_DIR}"
mkdir -p -- "${OUT_DIR}"

exec mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" "${PROFILE_DIR}"
