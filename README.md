# GhostGuides Vanilla

<p align="center">
  <img src="./AddonPreview.png" alt="GhostGuides Vanilla Preview" width="1000">
</p>

> Beta Build
>
> GhostGuides Vanilla is currently in active development.  
> The addon is fully usable, but guide logic, automation, and UI behavior are still being refined.

GhostGuides Vanilla is a heavily expanded overhaul based on the original **GuidelimeVanilla** project by JeromeM.

Built for **World of Warcraft Vanilla 1.12.1**, it combines leveling guides, smart quest handling, a modernized tracker UI, waypoint navigation, and talent support in one addon.

## Features

### Guide Support

- Full **1-60 Horde leveling guides** by GhostGuides
- **Sage Alliance leveling guides**
- Automatic loading of the **next logical guide** when the current guide is completed
- Manual guide re-selection now **resets that guide's progress** and starts it fresh
- Persistent guide progress and per-guide saved state

### Current Step Tracker

- Separate floating **CurrentStep** window
- Automatically resizes to the actual text height
- Resizes upward so it does not push down into the main guide frame
- By default it stays **docked directly above** the main guide window
- Optional setting to **detach and move** the CurrentStep window freely
- Detached position is saved between reloads and relogs
- Supports `\n` inside guide text to force a new line in the same tracker window

### Quest Tracking

- Real-time quest objective tracking inside the CurrentStep window
- If a step contains multiple `QC` / `Complete Quest` lines, progress is shown **under each matching quest**
- Finished complete quests can show a green **DONE** marker in the CurrentStep display
- Ongoing objective tracking for relevant steps

### Quest Automation

- **Auto Accept** for the current guide step only
- **Auto Turn-In** for the current guide step only
- The addon will not accept unrelated quests
- The addon will not turn in unrelated quests
- The addon will **not choose quest rewards automatically**
- Auto dialog handling can click through quest gossip/dialog when it matches the current step
- Option in settings to disable auto accept / turn-in entirely
- Optional hold keybind to temporarily disable auto accept / turn-in while the key is pressed

### Navigation

- Automatic waypoint arrow / navigation system
- Arrow tracking prefers the still-incomplete objective when multiple quest-complete targets exist in the same current step
- Arrow can be reset back to the screen center with a command
- Navigation arrow scale is separate from the general addon UI scale
- Current quest text under the arrow uses bold styling and white quest progress text

### UI / Visuals

- Solid non-transparent tracker backgrounds
- Golden border styling on the main UI and dropdown
- Dropdown opens above or below based on available space
- Improved anchoring when the guide dropdown opens upward
- Guide window layer / frame strata setting
- Addon-wide UI scale command

### Talents

- Talent recommendation support
- Toast / popup support
- Saved toast position

## Commands

### Slash Commands

- `/glvscale <value>`
- `/glvscale reset`
- `/glvuiscale <value>`
- `/glvuiscale reset`
- `/glvarrowreset`
- `/glv arrowreset`
- `/glv show`

Examples:

```text
/glvscale 1.15
/glvscale reset
/glvarrowreset
```

## Key Bindings

GhostGuides Vanilla adds a key binding for:

- **Hold to disable Auto Accept / Turn-In**

This can be configured in the game's key binding menu and will suppress quest dialog automation only while the key is held down.

## Installation

Copy all addon folders into:

```text
World of Warcraft/
└── Interface/
    └── AddOns/
```

Required folders:

```text
GhostguidesVanilla
GuidelimeVanilla_Ghost
GuidelimeVanilla_Sage
```

After installation restart the game or reload the UI.

## Required Folder Structure

The folder structure should remain like this:

```text
Interface/
└── AddOns/
    ├── GhostguidesVanilla
    ├── GuidelimeVanilla_Ghost
    └── GuidelimeVanilla_Sage
```

`GhostguidesVanilla` must be on the same directory level as the guide packs so they can be detected and loaded correctly.

## Guide Notes

For linking a guide to the next one, use the **guide name** from the `[N ...]` tag, not the file name.

Example:

```lua
[N 1-6 Orc/Troll Leveling]
[NX 6-12 Orc/Troll Leveling]
```

And the next guide:

```lua
[N 6-12 Orc/Troll Leveling]
```

## Supported Version

- WoW Vanilla 1.12.1

## Credits

This project is based on:

- **GuidelimeVanilla** by JeromeM  
  https://github.com/JeromeM/GuidelimeVanilla

Integrated guide packs:

- **GhostGuides 1-60 Horde leveling guides**
- **Sage Alliance guides**

Special thanks to the original authors and the Vanilla addon community.
