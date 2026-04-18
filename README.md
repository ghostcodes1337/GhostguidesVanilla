# GhostGuides Vanilla

<p align="center">
  <img src="./AddonPreview.png" alt="GhostGuides Vanilla Preview" width="1000">
</p>

> ⚠️ **Beta Build**
>
> GhostGuides Vanilla is currently in **beta** and still under active development.  
> The addon is already fully usable, but some UI elements, tracking systems and guide logic are still receiving additional polishing and fine tuning.

GhostGuides Vanilla is a complete overhaul based on the original **GuidelimeVanilla** project by JeromeM.

Designed for **World of Warcraft Classic Vanilla 1.12.1**, this addon includes:

- Full **1–60 Horde leveling guides** by GhostGuides
- **Sage 1–60 Alliance leveling guides**
- Smart **step tracking**
- Separate **active step tracker**
- Dedicated **ongoing objective windows**
- Automatic **quest progress tracking**
- Automatic **quest accept / turn-in support**
- Automatic **navigation arrow / waypoint system**
- Talent recommendations
- Improved modernized UI
- Persistent saved guide progress

---

## Credits

This project is based on:

- **GuidelimeVanilla** by JeromeM  
  https://github.com/JeromeM/GuidelimeVanilla

Integrated guide packs:

- **GhostGuides 1–60 Horde leveling guides**
- **Sage 1–60 Alliance leveling guides**

Special thanks to the original authors and the Vanilla addon community.

---

## Required Folder Structure

The folder structure **must remain exactly like this**.

`GhostGuidesVanilla` must be placed on the **same directory level** as both guide folders.

```text
Interface/
└── AddOns/
    ├── GhostGuidesVanilla
    ├── GhostGuides
    └── GuidelimeVanilla_Sage
```

This structure is required so the addon can correctly detect and load all available guide packs.

If folders are renamed, nested or moved, guide loading may fail.

---

## Installation

Copy all folders into:

```text
World of Warcraft/
└── Interface/
    └── AddOns/
```

Required folders:

```text
GhostGuidesVanilla
GuidelimeVanilla_Ghost
GuidelimeVanilla_Sage
```

After installation restart the game or reload the UI.

---

## Features

### Active Step Tracker
Displays the current active step in a separate floating tracker window.

### Ongoing Objectives
Objectives marked with `[O]` remain visible in their own dedicated windows until completed.

### Automatic Quest Progress
Quest progress updates automatically in real time in the guide, tracker windows, and navigation area.

Example:

```text
Collect Harpy Wings (3/8)
```

### Current Step Improvements

- quest progress is shown directly under `Complete ...` lines
- multiple `QuestComplete` lines can each show their own matching progress
- finished quests can be marked with `DONE`
- already completed quests can still display as finished even when no longer in the quest log

### Auto Accept / Turn-In

- auto-accepts quests for the exact current step
- auto-completes and turns in available quests
- can automatically click through greeting / gossip quest dialogs

### Navigation Arrow
Automatic waypoint arrow that guides you to the next objective.

Recent navigation improvements include:

- improved target resolution for multi-objective steps
- better refresh after reloads and quest progress changes
- stronger text styling under the arrow for readability
- white quest progress text under the arrow
- arrow reset support if it goes off-screen

### UI Improvements

- solid non-transparent tracker and guide backgrounds
- gold-themed frame borders
- improved dropdown anchoring
- safer layering for bottom-right control buttons
- support for `\n` inside guide text for explicit line breaks
- addon-wide UI scaling via command

### Persistent Progress
The following are saved automatically:

- selected guide
- checked steps
- current progress
- tracker window positions
- settings

---

## Commands

### Main Commands

- `/glv show`  
  Shows the guide window.

- `/glv hide`  
  Hides the guide window.

- `/glv settings`  
  Opens the settings window.

- `/glv editor`  
  Toggles the integrated guide editor.

### UI Scale Commands

- `/glvscale`  
  Shows the current addon UI scale.

- `/glvscale 1.15`  
  Sets the addon UI scale to a custom value.

- `/glvscale 0.90`  
  Shrinks the addon UI.

- `/glvscale reset`  
  Resets the addon UI scale back to `1.00`.

- `/glvuiscale 1.10`  
  Alias for the same scale command.

Notes:

- UI scale affects the main guide UI and tracker windows.
- The navigation arrow is intentionally **not** scaled together with the main addon UI.

### Arrow Reset Commands

- `/glvarrowreset`
- `/glv arrowreset`

These commands reset the navigation arrow position back near the center of the screen.

---

## Supported Version

- WoW Vanilla 1.12.1

---

## Current Status

This addon is currently in **active beta development**.

Upcoming improvements may include:

- UI polishing
- additional guide improvements
- better quest progress detection
- additional tracker improvements
- performance optimizations
