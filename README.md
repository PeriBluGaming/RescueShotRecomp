# RescueShot Recompiled

<!-- retcomm-readme-metrics -->
[![GitHub downloads (all assets, all releases)](https://img.shields.io/github/downloads/PeriBluGaming/RescueShotRecomp/total)](https://github.com/PeriBluGaming/RescueShotRecomp/releases)
[![GitHub downloads (latest release)](https://img.shields.io/github/downloads/PeriBluGaming/RescueShotRecomp/latest/total)](https://github.com/PeriBluGaming/RescueShotRecomp/releases/latest)
[![GitHub release](https://img.shields.io/github/v/release/PeriBluGaming/RescueShotRecomp)](https://github.com/PeriBluGaming/RescueShotRecomp/releases/latest)
<!-- /retcomm-readme-metrics -->

Static recompilation of **RescueShot** built on
[psxrecomp](https://github.com/mstan/psxrecomp) and
[recomp-ui](https://github.com/RetroPortingToolKit/recomp-ui).

**RescueShot Recompiled** brings the PlayStation light-gun shooter *Rescue Shot* to modern PCs through static recompilation powered by [PSXRecomp](https://github.com/mstan/psxrecomp).

Experience the original game with modern hardware and optional **native PlayStation Mouse (SCPH-1030) support**, including precise mouse aiming, shooting, and menu navigation.

Unlike conventional mouse-to-analog-stick mappings, RescueShot Recompiled emulates the original PlayStation Mouse device.

The original game disc is required.

| | |
|---|---|
| Players | 2 |
| Region | Europe, Japan |
| Publisher | Namco |
| Year | 2000 |

Scaffolded with the New Project Layout. See
`psxrecomp/docs/GAME_PROJECT_SETUP.md` for the full flow.

<!-- retcomm-readme-launcher -->
## Retro Launcher

You can run this title **standalone** (download the release zip, point it at
your disc, play), or manage installs, updates, and disc/BIOS wiring with
**[Retro Launcher](https://github.com/RetroPortingToolKit/Retro-Launcher)** —
the Retro Compilation Manager hub for self-compiling recomps.

[Downloads](https://github.com/RetroPortingToolKit/Retro-Launcher/releases) ·
[Full README & features](https://github.com/RetroPortingToolKit/Retro-Launcher#readme)

<p align="center">
  <img src="https://raw.githubusercontent.com/RetroPortingToolKit/Retro-Launcher/main/docs/screenshots/hub-and-game-launcher.png" alt="Retro hub with a background build, next to a title’s recomp-ui launcher" width="720">
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/RetroPortingToolKit/Retro-Launcher/main/docs/screenshots/queue-and-background-build.png" alt="Background cmake build with titles queued" width="720">
</p>

Retro checks for updates, installs the prebuilt release zips, and automates
BIOS/ROM/save plumbing so you are not stuck repeating each game’s first run by hand.
<!-- /retcomm-readme-launcher -->

## Legal

You must own the original game. Disc images under `disc/` are gitignored and
must never be committed. Retail BIOS dumps are not redistributed and no C
derived from one may be committed; releases run on the bundled MIT OpenBIOS.

`generated/` (the recompiled game C) **is committed**: releases ship the
compiled game, built by CI from that tree. Regenerate and commit it whenever
seeds or the framework pin change.

Default app icon: `assets/psxrecomp.ico` (and `.png` / `.svg`) — Retro-themed controller mark from `psxrecomp/assets/`. Windows builds embed it via `APP_ICON`.

Optional box art under `launcher_assets/img/` may come from
[libretro-thumbnails](https://github.com/libretro-thumbnails/libretro-thumbnails)
(`Named_Boxarts`); see `BOXART_SOURCE.txt` when present.

## PlayStation Mouse Support

RescueShot Recompiled supports the original **PlayStation Mouse (SCPH-1030)** through native mouse input emulation.

### Features

- **Native mouse aiming** — smooth, precise movement using your computer mouse.
- **Left-click shooting** — fire directly with the mouse button.
- **Menu navigation** — navigate the game's menus using your mouse.
- **Real PlayStation Mouse emulation** — communicates through the emulated SIO0 controller interface.
- **Launcher integration** — select *PlayStation Mouse* directly from the controller settings.
- **Persistent configuration** — your selected input device is saved between sessions.
- **Optional support** — standard controller input remains available.

### How to enable

1. Start RescueShot Recompiled.
2. Open the launcher controller settings.
3. Select **PlayStation Mouse** as your input device.
4. Launch the game and enjoy native mouse controls.

The feature is enabled through the project's `game.toml`:

```toml
[controller]
default_mode = "digital"
supports_ps_mouse = true
```

The launcher stores the selected device as `p1_device = "mouse"` in its settings.

---

## Local Framework Patches

RescueShot Recompiled includes project-specific patches for **PSXRecomp** and **recomp-ui** to provide native PlayStation Mouse functionality.

These patches allow the game to support the original PlayStation Mouse **without requiring the corresponding upstream pull requests to be merged**.

### Included patches

| Framework | Patch | Description |
|---|---|---|
| PSXRecomp | `patches/psxrecomp/0001-native-ps-mouse.patch` | Native PlayStation Mouse protocol, SDL3 host input, and runtime integration |
| recomp-ui | `patches/recomp-ui/0001-ps-mouse-launcher.patch` | PlayStation Mouse selection in the launcher |

The patches cover **34 framework files** across both repositories.

### Automatic patch application

After initializing the Git submodules, the patches can be applied manually:

```bash
git submodule update --init --recursive
./scripts/apply-framework-patches.sh
```

**Manual application is not required for normal builds.** The project's `CMakeLists.txt` automatically executes the patch script during CMake configuration.

The script:

- Applies patches that have not yet been installed.
- Detects and skips already applied patches.
- Stops with an error if a patch is incompatible.

### Framework compatibility

The patches were tested against these specific framework commits:

| Framework | Base commit |
|---|---|
| PSXRecomp | `a38bf783e4540bf98fe6ddd0afdca1bd181c65ec` |
| recomp-ui | `3f1d6f122a58823614abce14f5b86f4d165a629c` |

Both frameworks remain regular Git submodules. Their original commit references are preserved.

When updating either framework, patch compatibility must be verified. Once the corresponding functionality becomes available upstream, the local patch can be removed.

### Building from source

```bash
git clone --recurse-submodules https://github.com/PeriBluGaming/RescueShotRecomp.git
cd RescueShotRecomp

cmake -S . -B build-release -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-release --target psx-runtime
```

CMake automatically applies the required framework patches before configuring the runtime.

The generated game code is already committed to the repository. A normal build does not require regenerating it.

## Quick start (dev)

```bash
git submodule update --init --recursive
./psxrecomp/tools/ci/build_emitters.sh
python3 psxrecomp/psxrecomp_cli.py generate \
  --config game.toml --project-root . --disc disc/<your>.cue
git add generated && git commit -m "Regenerate game C"
cmake -S . -B build-release -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-release --target psx-runtime
```

Releases: tag `vX.Y.Z` (or run the *Release builds* workflow). CI builds the
committed `generated/` C on Linux, Windows and macOS and attaches
`rescueshot-<version>-<platform>.zip`, the compiled game. Locally:
`scripts/package_release.sh build-release linux-x64`.

## Symbols

Progressive map: `symbols.toml` → `python3 tools/sync_symbols.py` →
`psx_symbols.h` (`PSX_FN_*`). See `psxrecomp/docs/SYMBOLS.md`.

## Framework pins

Submodule gitlinks (`psxrecomp`, optional `recomp-ui`, nested `recomp-net`)
are authoritative. `framework_pins.txt` is an optional scaffold snapshot;
release CI logs SHAs with `record_pins.sh` but builds whatever the gitlinks
resolve to. Bump submodules deliberately — do not float on `main`/`master`
in release CI.

<!-- retcomm-readme-raid -->
---

<p align="center">
  <sub><b>R.A.I.D. — Retro AI Development</b> · a Discord for AI-assisted retro reverse-engineering, decomp &amp; recomp</sub>
</p>

<p align="center">
  <a href="https://discord.gg/Ad9BwSzctP"><img src=".github/raid-discord.png" alt="Join the Retro AI Development (R.A.I.D.) Discord" width="200"></a>
</p>
<!-- /retcomm-readme-raid -->
