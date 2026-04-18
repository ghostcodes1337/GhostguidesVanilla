# GhostGuides Vanilla

<p align="center">
  <img src="./AddonPreview.png" alt="GhostGuides Vanilla Preview" width="1000">
</p>

> ⚠️ **Beta Build**
>
> GhostGuides Vanilla is currently in **beta** and still under active development.  
> The addon is already fully usable, but some UI elements, tracking systems and guide logic are still receiving additional polishing and fine tuning.

GhostGuides Vanilla is a complete overhaul based on the original **GuidelimeVanilla** project by JeromeM.

Designed for **World of Warcraft Vanilla 1.12.1**, this addon includes:

- Full **1–60 Horde leveling guides** by GhostGuides
- **Sage 1–60 Alliance leveling guides**
- Smart **step tracking**
- Separate **Current Step tracker**
- Dedicated **ongoing objective windows**
- Automatic **quest progress tracking**
- Automatic **quest accept / quest turn-in**
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
    ├── GuidelimeVanilla_Ghost
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
GhostGuides
GuidelimeVanilla_Sage
```

After installation restart the game or reload the UI.

---

## Features

### Current Step Tracker
Displays the currently active guide step in a dedicated floating tracker window above the main guide.

The Current Step tracker supports:

- automatic live updates
- multi-line step text
- quest objective progress directly under `Complete ...` lines
- completed quest markers such as `DONE` for finished objectives or already completed quests

### Ongoing Objectives
Objectives marked with `[O]` remain visible in their own dedicated windows until completed.

This is useful for:

- long-running collection quests
- optional kill objectives
- travel and side objectives that should stay visible while progressing other steps

### Automatic Quest Progress
Quest progress updates automatically in real time in:

- the main guide
- the Current Step tracker
- the navigation block under the arrow

Example:

```text
- Mottled Boar slain: 3/10
```

### Auto Accept / Auto Turn-In
The addon supports automatic quest dialog handling for Vanilla-safe quest APIs.

Included behavior:

- auto-accept for quests matching the current guide step
- automatic quest completion when a quest is ready to hand in
- automatic gossip / greeting quest selection for completed quests
- automatic dialog continuation to turn in available quests faster

### Navigation Arrow
Automatic waypoint arrow that guides you to the next objective.

Navigation improvements include:

- better multi-objective quest handling
- improved detection of the next unfinished quest action inside the same step
- more reliable arrow refresh after reloads and quest progress changes
- bolder navigation text for the active quest / objective under the arrow
- white quest progress text for improved readability

### Guide Window & UI Improvements
The interface has been modernized while keeping Vanilla compatibility.

Recent UI improvements include:

- solid, non-transparent tracker and guide backgrounds
- gold-themed frame borders
- improved dropdown positioning when opening upward or downward
- updated main frame layering so bottom-right control buttons stay clickable immediately after login
- support for `\n` inside guide text so custom guide lines can render as proper line breaks

### Persistent Progress
The following are saved automatically:

- selected guide
- checked steps
- current progress
- tracker window positions
- settings
- quest completion state used for guide synchronization

---

## Supported Version

- WoW Vanilla 1.12.1

---

## Current Status

This addon is currently in **active beta development**.

Current development focus includes:

- further UI polishing
- more guide logic improvements
- additional navigation refinements
- continued quest tracking improvements
- performance optimizations
