#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT_DIR
readonly PROFILEDEF="${ISARCHY_PROFILEDEF:-${ROOT_DIR}/archiso/profiledef.sh}"
readonly PAYLOAD_PREFIX="/usr/local/share/isarchy"

declare -A file_permissions=()
# Archiso pre-declares this associative array before sourcing profiledef.sh.
# Do the same here so the profile can be validated independently.
# shellcheck source=/dev/null
source "${PROFILEDEF}"

errors=0
declare -a payload_scripts=("${ROOT_DIR}/install.sh")
while IFS= read -r -d '' file; do
  payload_scripts+=("${file}")
done < <(find "${ROOT_DIR}/bin" "${ROOT_DIR}/install" -type f -print0)

check_profile_mode() {
  local path="$1"
  local spec="${file_permissions[${path}]-}"
  local mode mode_value

  if [[ -z "${spec}" ]]; then
    printf 'error: missing profiledef.sh file_permissions entry: %s\n' "${path}" >&2
    errors=1
    return
  fi

  mode="${spec##*:}"
  if [[ ! "${mode}" =~ ^[0-7]{3,4}$ ]]; then
    printf 'error: invalid mode for %s: %s\n' "${path}" "${mode}" >&2
    errors=1
    return
  fi
  mode_value=$((8#${mode}))
  if (( (mode_value & 0111) == 0 )); then
    printf 'error: profile mode is not executable for %s: %s\n' "${path}" "${mode}" >&2
    errors=1
  fi
}

for file in "${payload_scripts[@]}"; do
  [[ "$(head -c 2 -- "${file}")" == '#!' ]] || continue
  relative="${file#"${ROOT_DIR}/"}"

  if [[ ! -x "${file}" ]]; then
    printf 'error: source script is not executable: %s\n' "${relative}" >&2
    errors=1
  fi
  check_profile_mode "${PAYLOAD_PREFIX}/${relative}"
done

check_profile_mode "/usr/local/bin/isarchy-install"
check_profile_mode "/usr/local/bin/isarchy-logo"

if (( errors )); then
  printf 'Executable permission validation failed.\n' >&2
  exit 1
fi

printf 'Executable permission validation passed.\n'
