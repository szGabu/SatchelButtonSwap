# Satchel Button Swap

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![AMX Mod X](https://img.shields.io/badge/AMXX%201.8.2-Compatible-orange)

AMX Mod X plugin that allows players to swap the primary and secondary attack buttons for the Satchel Charge, allowing them to use Legacy or HL25 controls.

## Commands

- /satchel
  - Swaps the satchel controls for the player

## Tested Games

- Half-Life
- Sven Co-op (this will effectively allow players to use the HL25 control scheme in this game)

## Supported Games

- Opposing Force
- Adrenaline Gamer
Pretty much any game that has the Satchel Charge as a weapon.

## Installation

1. Compile the .sma file or download the pre-compiled .amxx file from GitHub Releases
2. Copy the file to the following directory:
   - `satchel_button_swap.amxx` → `addons/amxmodx/plugins/`
3. Add the plugin to your `plugins.ini` file:
```
satchel_button_swap.amxx
```

## Configuration

### ConVars

```c
// Enables the plugin.
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
amx_satchel_swap_enabled "1"

// Determines if players should have their satchel controls swapped by default.
// -
// Default: "0"
// Minimum: "0.000000"
// Maximum: "1.000000"
amx_satchel_swap_on_by_default "0"
```

## Languages

The plugin supports multiple languages through the `satchel_button_swap.txt` language file. A native translation is provided for English (en) and Spanish (es). Translations for other languages were generated with AI, so their accuracy cannot be guaranteed. You're welcome to provide your own translations using the template below.

```ini
[en]
SATCHEL_CONTROLS_TITLE = Swap Satchel Controls
SATCHEL_CONTROLS_ENABLED = Enabled
SATCHEL_CONTROLS_DISABLED = Disabled
```