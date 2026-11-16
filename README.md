# Isarchy

**English** · [Deutsch](#deutsch)

Isarchy is an independent, opinionated Arch Linux distribution scaffold built
around Hyprland. It combines a branded live/installer ISO, a transparent
post-install setup, editable package manifests, practical desktop defaults, and
small switchable themes.

The workflow is deliberately split in two:

1. Boot the Isarchy ISO and install a minimal Arch system with `archinstall`
   (or manually).
2. Copy the bundled Isarchy setup into the installed system before rebooting,
   or clone this repository there later.
3. Boot that system as the intended desktop user and run `install.sh` to add
   the Isarchy desktop.

The setup script does **not** partition disks, create users, or install a
bootloader. This keeps destructive installation work in the well-tested Arch
installer for the first release.

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

## Install the desktop

When installing from the ISO, copy the bundled setup after `archinstall`
returns. First verify Archinstall's target mount, then copy into it:

```bash
findmnt /mnt/archinstall
install -d /mnt/archinstall/opt
cp -a /usr/local/share/isarchy /mnt/archinstall/opt/isarchy
```

Then boot the installed system and run `/opt/isarchy/install.sh` as your normal
user. Alternatively, install Git (`sudo pacman -S --needed git`), clone this
repository, and run:

```bash
./install.sh
```

Use `./install.sh --dry-run` to inspect commands. The optional
`./install.sh --with-dev` set adds developer tools and enables Docker; membership
in the Docker group grants root-equivalent access. Existing managed config
directories are renamed with a `.pre-isarchy.TIMESTAMP` suffix before new
defaults are copied. Reboot or log out, sign in on a TTY, then run `Hyprland`.

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

## Repository layout

```text
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
- Continue using `archinstall` for disk installation, wrap it with a guided
  Isarchy profile, or build a custom installer?
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

1. Vom Isarchy-ISO booten und mit `archinstall` (oder manuell) ein minimales
   Arch-System inklusive Benutzer und Bootloader installieren.
2. Vor dem Neustart Archinstalls Ziel-Einhängepunkt prüfen und die
   mitgelieferten Dateien dorthin kopieren:

```bash
findmnt /mnt/archinstall
install -d /mnt/archinstall/opt
cp -a /usr/local/share/isarchy /mnt/archinstall/opt/isarchy
```

3. Das installierte System booten und als normaler Desktop-Benutzer ausführen:

```bash
/opt/isarchy/install.sh
```

Alternativ Git mit `sudo pacman -S --needed git` installieren, dieses Repository
klonen und `./install.sh` starten. `--dry-run` zeigt die geplanten Befehle.
`--with-dev` installiert Entwicklerwerkzeuge, aktiviert Docker und fügt den
Benutzer der Docker-Gruppe hinzu; diese Gruppe gewährt praktisch Root-Rechte.
Das Skript partitioniert **keine** Datenträger und installiert keinen
Bootloader. Bestehende verwaltete Konfigurationsordner werden vor dem Kopieren
mit einem Zeitstempel gesichert.

Danach abmelden, auf einer TTY anmelden und `Hyprland` starten. Themes lassen
sich mit `isarchy-theme list` anzeigen und zum Beispiel mit
`isarchy-theme dusk` wechseln.

### Aufbau

- `archiso/`: Isarchy-Overlay für das Archiso-Releng-Profil
- `install/`: modulare Installationsschritte
- `packages/`: Paketlisten im Klartext
- `config/`: Desktop-Konfigurationen
- `themes/`: Farbpaletten und Hintergrundbilder
- `bin/`: Isarchy-Kommandos
- `scripts/`: Profilvorbereitung und ISO-Build

Offene Produktentscheidungen sind die endgültige Terminal-/Launcher-Auswahl,
`archinstall` gegenüber einem eigenen Installer, der Startweg für Hyprland und
der Umfang offiziell unterstützter Hardware. Weitere Schritte stehen in
[ROADMAP.md](ROADMAP.md).

## License

Isarchy's original files are available under the [MIT License](LICENSE).
Archiso's `releng` files are supplied by the installed Archiso package at build
time and remain under their upstream license.
