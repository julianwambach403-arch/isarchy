#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="isarchy"
iso_label="ISARCHY_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Isarchy Project"
iso_application="Isarchy Live Installer"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="isarchy"
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86,arm64' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/isarchy-install"]="0:0:755"
  ["/usr/local/bin/isarchy-logo"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/share/isarchy/install.sh"]="0:0:755"
  ["/usr/local/share/isarchy/bin/isarchy-install"]="0:0:755"
  ["/usr/local/share/isarchy/bin/isarchy-logo"]="0:0:755"
  ["/usr/local/share/isarchy/bin/isarchy-theme"]="0:0:755"
  ["/usr/local/share/isarchy/install/10-packages.sh"]="0:0:755"
  ["/usr/local/share/isarchy/install/20-config.sh"]="0:0:755"
  ["/usr/local/share/isarchy/install/30-services.sh"]="0:0:755"
  ["/usr/local/share/isarchy/install/lib.sh"]="0:0:755"
  ["/usr/local/share/isarchy/install/target-install.sh"]="0:0:755"
)
