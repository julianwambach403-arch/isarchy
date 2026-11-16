#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT_DIR
readonly OVERLAY_DIR="${ROOT_DIR}/archiso"
readonly OUTPUT_DIR="${1:-${ROOT_DIR}/build/profile}"
readonly RELENG_DIR="${RELENG_DIR:-/usr/share/archiso/configs/releng}"

if [[ ! -d "${RELENG_DIR}" ]]; then
  printf 'error: releng profile not found at %s\n' "${RELENG_DIR}" >&2
  printf 'Install archiso, or set RELENG_DIR to a releng profile.\n' >&2
  exit 1
fi

rm -rf -- "${OUTPUT_DIR}"
mkdir -p -- "${OUTPUT_DIR}"
cp -a -- "${RELENG_DIR}/." "${OUTPUT_DIR}/"

# Overlay Isarchy-owned profile files without vendoring Arch's boot assets.
cp -a -- "${OVERLAY_DIR}/." "${OUTPUT_DIR}/"

# The overlay manifest contains additions. Keep releng's required packages and
# de-duplicate the combined result.
{
  cat -- "${RELENG_DIR}/packages.x86_64"
  cat -- "${OVERLAY_DIR}/packages.x86_64"
} | awk 'NF && $1 !~ /^#/ && !seen[$0]++' | sort >"${OUTPUT_DIR}/packages.x86_64"

# Brand inherited boot menus while retaining upstream kernel parameters and
# architecture-specific entries.
while IFS= read -r -d '' entry; do
  sed -i \
    -e 's/Arch Linux install medium/Isarchy live installer/g' \
    -e 's/Arch Linux Install Medium/Isarchy Live Installer/g' \
    -e 's/Arch Linux/Isarchy/g' \
    -e 's/ARCH_/ISARCHY_/g' \
    "${entry}"
done < <(find "${OUTPUT_DIR}/efiboot" "${OUTPUT_DIR}/syslinux" "${OUTPUT_DIR}/grub" \
  -type f -print0 2>/dev/null)

install -d \
  "${OUTPUT_DIR}/airootfs/usr/local/bin" \
  "${OUTPUT_DIR}/airootfs/usr/local/share/isarchy"
cp -a \
  "${ROOT_DIR}/install.sh" \
  "${ROOT_DIR}/install" \
  "${ROOT_DIR}/packages" \
  "${ROOT_DIR}/config" \
  "${ROOT_DIR}/themes" \
  "${ROOT_DIR}/bin" \
  "${OUTPUT_DIR}/airootfs/usr/local/share/isarchy/"

cat >"${OUTPUT_DIR}/airootfs/usr/local/bin/isarchy-install" <<'EOF'
#!/usr/bin/env bash
exec /usr/local/share/isarchy/install.sh "$@"
EOF
chmod 0755 "${OUTPUT_DIR}/airootfs/usr/local/bin/isarchy-install"

printf 'Prepared Isarchy archiso profile: %s\n' "${OUTPUT_DIR}"
