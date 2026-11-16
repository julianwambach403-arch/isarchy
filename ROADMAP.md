# Isarchy roadmap

## Next

- Pin and continuously test a known-compatible Archiso release.
- Add CI for ShellCheck, package-manifest validation, and profile preparation.
- Add an `archinstall` profile with an Isarchy-guided handoff.
- Verify BIOS and UEFI boot paths in QEMU and on physical hardware.
- Add NVIDIA, AMD, Intel, laptop, HiDPI, and virtual-machine profiles.
- Add an opt-in TTY auto-start or a lightweight display-manager path.

## Later

- Package Isarchy commands and defaults as signed Arch packages.
- Publish a repository and reproducible, checksummed ISO releases.
- Add rollback/uninstall support and idempotent config migrations.
- Expand accessible themes and first-run keyboard/locale selection.
- Add a menu-driven settings and maintenance workflow.
- Document a contribution and security-update policy.

## Open product choices

- Kitty + Wofi versus Alacritty + Walker.
- `archinstall` integration versus a custom disk installer.
- Rolling against current Arch packages versus tested snapshots.
- The boundary between minimal defaults and optional application bundles.
