# Isarchy

**English** · [Deutsch](#deutsch)

Isarchy is an independent, opinionated Arch Linux distribution scaffold built
around Hyprland. It combines a branded live/installer ISO, a transparent
post-install setup, editable package manifests, practical desktop defaults, and
small switchable themes.

The live ISO has one installation entry point:

```bash
isarchy-install
```

It opens Archinstall with editable Isarchy defaults. Archinstall handles disks,
partitioning, users, locale, networking, and the bootloader. During
Archinstall's post-install phase, Isarchy installs Hyprland, packages, services,
configuration, and the default theme inside the new system.

Isarchy is strongly inspired by
[Omarchy](https://github.com/basecamp/omarchy), but is an original codebase and
not a fork. No Omarchy files or snippets are included.

## Build the ISO

Build on an up-to-date Arch Linux host:

```bash
sudo pacman -Syu --needed archiso
sudo ./scripts/build-iso.sh
```

The ISO is written to `out/`. The build script copies Archiso's installed
`releng` profile to `build/profile`, applies the tracked `archiso/` overlay,
adds this repository's installer assets, brands the inherited BIOS/UEFI menu
entries, and invokes `mkarchiso`.

To inspect or invoke `mkarchiso` directly:

```bash
./scripts/prepare-profile.sh
sudo mkarchiso -v -w build/work -o out build/profile
```

Test in a disposable VM (UEFI requires an OVMF-enabled QEMU setup):

```bash
run_archiso -i out/isarchy-*.iso
# or:
qemu-system-x86_64 -enable-kvm -m 4G -cdrom out/isarchy-*.iso
```

## Install Isarchy

Boot the ISO, connect to the internet, and run:

```bash
isarchy-install
```

The preset selects Linux, NetworkManager, PipeWire-ready base packages,
systemd-boot, an `isarchy` hostname, zram swap, and US English locale defaults.
Everything remains visible and adjustable in Archinstall before installation.
Choose the disk layout, create at least one regular user, and review the
bootloader. Systemd-boot requires UEFI; select GRUB for legacy BIOS.

The Isarchy payload is staged under `/run`, which `arch-chroot` exposes inside
the target. Archinstall's `custom_commands` hook runs the target installer while
filesystems are mounted, avoiding a fragile post-reboot handoff. The first
regular user receives the desktop configuration. If several regular users were
created, Isarchy selects the lowest UID. To target a specific account, use
`isarchy-install --user USER` and create that exact user in Archinstall.

Optional developer tools and Docker can be included with:

```bash
isarchy-install --with-dev
```

Docker group membership grants root-equivalent access. Use
`isarchy-install --dry-run` to inspect orchestration without opening
Archinstall.

For an existing Arch installation, the standalone setup remains available:

```bash
./install.sh
```

Run it as the intended desktop user. `--dry-run` previews commands and
`--with-dev` enables the optional developer set.

The default choices are Kitty and Wofi. Useful bindings:

| Binding | Action |
| --- | --- |
| `Super` + `Return` | Terminal |
| `Super` + `Space` | Application launcher |
| `Super` + `E` / `F` | Files / browser |
| `Super` + `Q` | Close window |
| `Super` + `L` | Lock |
| `Super` + `1`…`5` | Change workspace |
| `Super` + `Shift` + `1`…`5` | Move window |
| `Print` | Select an area and copy a screenshot |

Switch themes without reinstalling:

```bash
isarchy-theme list
isarchy-theme dusk
isarchy-theme default
```

## Branding and system information

`isarchy-logo` prints the official Isarchy banner: the 256-color blue (`75`)
triangle, silver (`250`) ISARCHY block lettering, and `ISARCHY LINUX` tagline.
The same banner appears in the live login MOTD and at the start of both
installer paths.

Fastfetch is installed with a custom configuration that renders
`isarchy-logo` above the system summary:

```bash
fastfetch
```

The default theme uses the corresponding blue (`#5fafff`) and silver
(`#bcbcbc`) palette for borders, highlights, text, and wallpaper accents.

## Repository layout

```text
archinstall/ Archinstall preset with editable Isarchy defaults
archiso/   Isarchy overlay for Archiso's releng profile
bin/       User-facing Isarchy commands
config/    Hyprland, Waybar, Kitty, Wofi, and Mako defaults
install/   Modular package, config, and service setup stages
packages/  Plain-text package manifests
scripts/   Profile preparation and ISO build helpers
themes/    Color palettes and wallpapers
```

## Status and design decisions

This is an initial scaffold. Package names target the official Arch
repositories and the profile intentionally tracks the host's installed Archiso
`releng` assets. See [ROADMAP.md](ROADMAP.md) for planned work.

Owner decisions still open:

- Keep Kitty and Wofi, or move to Alacritty and Walker?
- Start Hyprland manually, provide a TTY auto-start option, or add a display
  manager?
- Which hardware profiles and proprietary driver paths should be officially
  supported?

## Deutsch

Isarchy ist ein eigenständiges, meinungsstarkes Arch-Linux-Distributionsgerüst
rund um Hyprland. Es verbindet ein gebrandetes Live-/Installations-ISO, eine
nachvollziehbare Desktop-Einrichtung, leicht änderbare Paketlisten, sinnvolle
Voreinstellungen und kleine wechselbare Themes.

Isarchy ist stark von
[Omarchy](https://github.com/basecamp/omarchy) inspiriert, aber eine eigene
Codebasis und **kein Fork**. Es wurden keine Omarchy-Dateien oder
Codeausschnitte übernommen.

### ISO bauen

Auf einem aktuellen Arch-Linux-System:

```bash
sudo pacman -Syu --needed archiso
sudo ./scripts/build-iso.sh
```

Das ISO landet unter `out/`. Das Build-Skript kopiert das installierte
Archiso-`releng`-Profil nach `build/profile`, legt das Isarchy-Overlay darüber,
fügt die Installer-Dateien hinzu, brandet die BIOS-/UEFI-Menüs und startet
`mkarchiso`.

Direkter Aufruf:

```bash
./scripts/prepare-profile.sh
sudo mkarchiso -v -w build/work -o out build/profile
```

### Installation

Vom Isarchy-ISO booten, eine Internetverbindung herstellen und ausführen:

```bash
isarchy-install
```

Der Befehl öffnet Archinstall mit anpassbaren Isarchy-Vorgaben. Archinstall
übernimmt Datenträger, Partitionierung, Benutzer, Sprache, Netzwerk und
Bootloader. Datenträgerlayout und Benutzer müssen gewählt werden. Systemd-boot
ist die UEFI-Vorgabe; für Legacy-BIOS muss GRUB ausgewählt werden.

Nach der Basisinstallation startet Archinstall Isarchys Ziel-Installer über
`custom_commands` im Chroot. Dieser installiert Hyprland, Pakete, Dienste,
Konfigurationen und das Standard-Theme für den ersten regulären Benutzer. Der
Zwischenschritt über einen manuellen Kopier- oder First-Boot-Prozess entfällt.
Bei mehreren Benutzern kann das Ziel mit `isarchy-install --user BENUTZER`
festgelegt werden; dieser Benutzer muss in Archinstall angelegt werden.

`isarchy-install --with-dev` installiert zusätzlich Entwicklerwerkzeuge,
aktiviert Docker und fügt den Benutzer der Docker-Gruppe hinzu; diese Gruppe
gewährt praktisch Root-Rechte. `isarchy-install --dry-run` zeigt die
Orchestrierung ohne Installation.

Auf einem bereits installierten Arch-System bleibt `./install.sh` als normaler
Desktop-Benutzer nutzbar. Danach auf einer TTY `Hyprland` starten. Themes lassen
sich mit `isarchy-theme list` anzeigen und etwa mit `isarchy-theme dusk`
wechseln.

### Branding und Systeminformationen

`isarchy-logo` zeigt das offizielle Banner: das blaue 256-Farben-Dreieck
(`75`), den silbernen ISARCHY-Schriftzug (`250`) und die Zeile
`ISARCHY LINUX`. Dasselbe Banner erscheint im Live-Login-MOTD und am Anfang
beider Installationswege.

Fastfetch wird mit einer eigenen Konfiguration installiert und zeigt dieses
Logo über den Systeminformationen. Der Aufruf lautet `fastfetch`. Das
Standard-Theme verwendet die passende Blau-/Silber-Palette für Rahmen,
Hervorhebungen, Text und Hintergrundbild.

### Aufbau

- `archinstall/`: anpassbare Isarchy-Vorgaben für Archinstall
- `archiso/`: Isarchy-Overlay für das Archiso-Releng-Profil
- `install/`: modulare Installationsschritte
- `packages/`: Paketlisten im Klartext
- `config/`: Desktop-Konfigurationen
- `themes/`: Farbpaletten und Hintergrundbilder
- `bin/`: Isarchy-Kommandos
- `scripts/`: Profilvorbereitung und ISO-Build

Die Installer-Entscheidung ist getroffen: Isarchy verwendet Archinstall mit
eigenen Vorgaben und Chroot-Handoff. Offen bleiben die endgültige
Terminal-/Launcher-Auswahl, der Startweg für Hyprland und der Umfang offiziell
unterstützter Hardware. Weitere Schritte stehen in [ROADMAP.md](ROADMAP.md).

## License

Isarchy's original files are available under the [MIT License](LICENSE).
Archiso's `releng` files are supplied by the installed Archiso package at build
time and remain under their upstream license.
