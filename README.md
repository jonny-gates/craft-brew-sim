# craft-brew-sim

A menu-driven craft brewery management sim built in **Godot 4.6** (GDScript, GL Compatibility renderer).

## Setup

### Prerequisites

- **Godot 4.6** (Standard edition — the .NET build is not required).
- **Git** to clone the repository.

### Install Godot

#### macOS

1. Download Godot 4.6 for macOS from <https://godotengine.org/download/macos/>.
2. Unzip the archive and drag `Godot.app` into `/Applications`.
3. On first launch, macOS may block it. Open **System Settings → Privacy & Security** and click **Open Anyway**.

Optional (Homebrew):

```sh
brew install --cask godot
```

#### Windows

1. Download Godot 4.6 for Windows from <https://godotengine.org/download/windows/>.
2. Unzip anywhere (e.g. `C:\Tools\Godot`). The executable is portable — no installer.
3. Optionally pin `Godot_v4.6-stable_win64.exe` to the Start menu.

Optional (winget):

```powershell
winget install GodotEngine.GodotEngine
```

## Clone the repo

```sh
git clone https://github.com/<your-user>/craft-brew-sim.git
cd craft-brew-sim
```

## Open and run

1. Launch Godot. In the Project Manager, click **Import** and select `project.godot` at the repo root.
2. Open the project and press **F5** (or the Play button) to run. The main scene is `res://main.tscn`.

### Headless parse check

Useful as a quick smoke test from the command line.

**macOS** (assuming `Godot.app` is in `/Applications`):

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . --headless --quit
```

Tip: add an alias to your shell profile, e.g. `alias godot="/Applications/Godot.app/Contents/MacOS/Godot"`, then run `godot --path . --headless --quit`.

**Windows** (PowerShell, from the repo root):

```powershell
& "C:\Tools\Godot\Godot_v4.6-stable_win64.exe" --path . --headless --quit
```

## Project layout

See `CLAUDE.md` for architecture notes and conventions. Brief tour:

- `autoload/` — `GameState`, `EventBus`, `SimEngine` singletons (registered in `project.godot`).
- `screens/` — individual `Control` scenes swapped by `ScreenManager`.
- `data/` — `Resource` subclasses used as serializable game data.
- `main.tscn` — entry scene; instances `ScreenManager` and shows the Inbox.

There is no build toolchain, linter, or test framework — run from the Godot editor.
