# Scope

## Context

You are setting up the foundational infrastructure for a menu-driven craft brewery management sim built in Godot 4. The game has no real-time gameplay — the player interacts with menus, clicks Continue, a week simulates, and they land back on an inbox screen to deal with events and make decisions.


## Architecture

Three autoloaded singletons plus a screen manager. Keep singletons narrow:

- **`GameState`** — pure data. Week number, cash, owned plots, recipes, inventory, reputation, inbox messages. No logic, no node references, no callables. Everything here must be serializable (ints, floats, strings, bools, arrays, dicts, or `Resource` subclasses) so that future save/load is trivial. Include a `save_version := 1` field from day one.
- **`EventBus`** — global signals only. Declare `week_advanced(new_week: int)`, `cash_changed(new_cash: int)`, `inbox_updated()`. No state. Other systems emit/listen via this.
- **`SimEngine`** — the weekly tick. Exposes one public method `advance_week()` that mutates `GameState` in a fixed, documented order (production → sales → finance → event generation), then emits `EventBus.week_advanced`. Each phase is a private method so they're easy to extend later.

Plus:

- **`ScreenManager`** — a `Control` node that owns the current screen and swaps between them. Child screens are `Control` scenes (Inbox, Brewing, Plots, Marketing, Finance — only Inbox needs to be real for now; the others can be stubs with a Back button).

## Files to create

Create this directory layout:

```
res://
  autoload/
    game_state.gd
    event_bus.gd
    sim_engine.gd
  screens/
    screen_manager.gd
    screen_manager.tscn
    inbox/
      inbox.gd
      inbox.tscn
    stubs/
      stub_screen.gd
      stub_screen.tscn
  data/
    inbox_message.gd        # Resource subclass: id, week_received, title, body, read
  main.tscn                 # sets ScreenManager as root, starts on Inbox
```

### File specs

**`autoload/game_state.gd`** — `extends Node`. Fields:
```
var save_version: int = 1
var week: int = 1
var cash: int = 10000
var inbox: Array[InboxMessage] = []
```
Add a `reset()` method that re-initializes to defaults. No other logic.

**`autoload/event_bus.gd`** — `extends Node`. Only signal declarations:
```
signal week_advanced(new_week: int)
signal cash_changed(new_cash: int)
signal inbox_updated()
```

**`autoload/sim_engine.gd`** — `extends Node`. Public `advance_week()` calls `_run_production()`, `_run_sales()`, `_run_finance()`, `_generate_events()` in order, increments `GameState.week`, then emits `EventBus.week_advanced(GameState.week)` and `EventBus.inbox_updated()`. Each phase is a stub with a `# TODO` comment. For now, `_generate_events()` should append one placeholder `InboxMessage` per week so the inbox has something to display and the loop is observable.

**`data/inbox_message.gd`** — `extends Resource`, `class_name InboxMessage`. Exported fields: `id: String`, `week_received: int`, `title: String`, `body: String`, `read: bool`. Keep it a `Resource` so it serializes cleanly later.

**`screens/screen_manager.gd` + `.tscn`** — a `Control` filling the viewport. Method `show_screen(path: String)` instantiates the scene at that path, removes the previous child, adds the new one. On `_ready`, shows `res://screens/inbox/inbox.tscn`.

**`screens/inbox/inbox.gd` + `.tscn`** — `Control` with:
- A header `Label` showing `"Week %d — $%d" % [GameState.week, GameState.cash]`
- A `VBoxContainer` (or `ItemList`) listing messages from `GameState.inbox`
- A `Continue` button that calls `SimEngine.advance_week()`

Connect to `EventBus.week_advanced` and `EventBus.inbox_updated` in `_ready` to refresh the UI. Disconnect in `_exit_tree` (or use `CONNECT_ONE_SHOT` isn't right here — use normal connections and trust the tree).

**`screens/stubs/stub_screen.gd` + `.tscn`** — placeholder `Control` with a label showing its name and a Back button that calls `ScreenManager.show_screen("res://screens/inbox/inbox.tscn")`. Not wired into navigation yet, but exists so future menus can copy it.

**`main.tscn`** — root is `ScreenManager`. Set this as the main scene in `project.godot`.

## Registering AutoLoads

Append to `project.godot` (create the section if missing):

```
[autoload]

GameState="*res://autoload/game_state.gd"
EventBus="*res://autoload/event_bus.gd"
SimEngine="*res://autoload/sim_engine.gd"
```

Also set the main scene:

```
[application]

run/main_scene="res://main.tscn"
```

Preserve any existing keys in `[application]` (e.g. `config/name`, `config/features`) — merge, don't overwrite.

## Acceptance criteria

The agent is done when:

1. Opening the project in Godot and pressing Play shows the Inbox screen.
2. The header reads `Week 1 — $10000`.
3. Clicking Continue advances to `Week 2`, the cash display still updates via the signal, and a new placeholder message appears in the inbox list.
4. Repeated clicks keep advancing the week with no errors in the output panel.
5. `GameState` contains no `Node` references, `Callable`s, or signal connections — only serializable data.
6. No GDScript parse errors; no runtime errors in the debugger.
