# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A menu-driven craft brewery management sim built in **Godot 4.6** (GDScript, GL Compatibility renderer). There is no real-time gameplay: the player reads an inbox, makes menu decisions, clicks Continue, one week simulates, and they land back on the inbox. See `.claude/context/scope.md` for the original design brief — it remains the source of truth for scope and architectural discipline.

## Running the project

There is no CLI build/test toolchain. Open the project in the Godot 4.6 editor and press Play (F5). Main scene is `res://main.tscn`, which instances `ScreenManager` and shows the Inbox.

To run headless from the command line (useful for smoke-checking parse errors):

```
godot --path . --headless --quit
```

No linter, no test framework. Do not introduce one without asking — the brief explicitly rejects tests at this stage.

## Architecture

Three autoloaded singletons + a screen manager. Each has a narrow, enforced responsibility — do not blur them.

- **`GameState`** (`autoload/game_state.gd`) — **pure serializable data only**. Ints, floats, strings, bools, arrays, dicts, `Resource` subclasses. No `Node` references, no `Callable`s, no signal connections, no logic. This is the invariant that keeps future save/load trivial. `save_version` exists from day one; bump it when the schema changes incompatibly. `reset()` is the only method.
- **`EventBus`** (`autoload/event_bus.gd`) — **global signals only, no state**. Systems emit here; screens listen here. Add new signals here rather than wiring cross-screen connections directly.
- **`SimEngine`** (`autoload/sim_engine.gd`) — the weekly tick. `advance_week()` runs phases in a **fixed order**: `_run_production()` → `_run_sales()` → `_run_finance()` → `_generate_events()`, then increments `GameState.week` and emits `EventBus.week_advanced` + `EventBus.inbox_updated`. Extend by filling in the phase stubs; keep the ordering and the single public entry point.
- **`ScreenManager`** (`screens/screen_manager.gd`) — a `Control` filling the viewport that owns exactly one child screen at a time. `show_screen(path)` swaps. Screens are sibling `Control` scenes under `screens/` and navigate by calling back into `ScreenManager`.

Flow: user clicks Continue on a screen → screen calls `SimEngine.advance_week()` → SimEngine mutates `GameState` and emits on `EventBus` → screens react via `EventBus` connections and re-render from `GameState`. Screens should not mutate `GameState` directly for weekly-tick concerns; route through `SimEngine` or dedicated action methods.

## Conventions

- **Typed GDScript everywhere**: `var x: int`, `func foo() -> void`, typed arrays (`Array[InboxMessage]`).
- **No narrating comments.** `# TODO:` markers in sim phase stubs are fine; anything else should justify its existence.
- **Keep files small.** If a file pushes past ~80 lines at this stage, the abstraction is probably wrong.
- **Serializability of `GameState` is load-bearing.** When adding fields, they must be serializable primitives or `Resource` subclasses (see `data/inbox_message.gd` as the template: `extends Resource`, `class_name`, `@export` fields).
- **Autoloads are registered in `project.godot`** under `[autoload]`. When adding a new autoload, append there — do not rely on scene-tree lookups.
- **`.uid` files** next to `.gd`/`.tscn` are Godot 4.4+ resource identifiers; commit them alongside the source file, don't hand-edit.

