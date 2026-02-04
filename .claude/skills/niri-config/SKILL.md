---
name: niri-config
description: Help configure niri window manager - keybindings, window rules, workspaces, animations, monitors, and scripts
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(niri msg *, niri validate)
argument-hint: [keybindings|window-rules|workspaces|animations|monitors|scripts|waybar|rofi]
---

# Niri Configuration Helper

This skill helps configure the niri Wayland compositor for this NixOS system.

## Critical Rules

1. **Keybinding Duplicate Check (MANDATORY):** Before adding or modifying ANY keybinding, ALWAYS search `config.kdl` for the key combination to ensure it's not already in use. Use Grep to search for the key (e.g., `Mod+P`, `Ctrl+Alt+Delete`). If a duplicate is found, inform the user and ask how to proceed.

2. **Rofi Menu ESC Handling (MANDATORY):** All rofi menu scripts MUST handle ESC (empty selection) properly. After capturing the rofi selection, always check if it's empty and exit gracefully:
   ```bash
   chosen="$(run_rofi)"
   [[ -z "$chosen" ]] && exit 0
   ```
   This prevents the script from executing unintended actions when the user cancels with ESC.

3. **Rofi Menu Icons (MANDATORY):** All rofi menu options MUST have proper icons:
   - Check the `USE_ICON` flag in the .rasi theme file
   - Provide BOTH icon-only (Symbols Nerd Font) AND text+icon (Nerd Font) versions
   - Each option must have a meaningful, distinct icon
   - Use consistent icon style across related options

## File Locations

All niri configuration files are in `modules/home/wm/niri/`:

| File/Directory | Purpose |
|----------------|---------|
| `default.nix` | Home-manager module definition |
| `niri_config/config.kdl` | Main niri configuration (KDL format) |
| `niri_config/scripts/` | Helper scripts (rofi menus, volume, brightness, etc.) |
| `niri_config/rofi/` | Rofi theme files (.rasi) |
| `niri_config/waybar/` | Waybar config, modules, and styles |
| `niri_config/mako/` | Notification daemon config and icons |
| `niri_config/theme/` | Theme variables (colors, fonts) |

## Configuration Sections in config.kdl

### Input
```kdl
input {
    keyboard { xkb { layout "us" } }
    touchpad { tap; accel-speed 0.2; }
    mouse { accel-profile "flat"; }
    focus-follows-mouse max-scroll-amount="0%"
}
```

### Outputs/Monitors
```kdl
output "Monitor Name or Connector" {
    mode "3840x2400@60.000"
    scale 1.0
    position x=0 y=0
}
```

### Workspaces
Named workspaces bound to specific monitors:
- Main monitor: `main-browser`, `main-term`, `main-code`, `chat`, `email`
- External monitor: `ext-browser`, `ext-term`, `ext-code`

### Layout
```kdl
layout {
    gaps 10
    preset-column-widths { proportion 0.33333; proportion 0.5; proportion 0.66667; }
    default-column-width { proportion 0.5; }
    focus-ring { width 2; active-color "#EEB48A"; }
    border { width 2; active-color "#E4A85F"; }
}
```

### Window Rules
```kdl
window-rule {
    match app-id="app-name"          // Exact match
    match app-id=r#"(?i)pattern"#    // Regex (case-insensitive)
    match title="Window Title"
    open-floating true
    open-on-workspace "workspace-name"
    open-fullscreen true
}
```

### Keybindings

> **CRITICAL:** Before adding or modifying any keybinding, ALWAYS search config.kdl for the key combination to check for duplicates. Duplicate keybindings cause conflicts and unpredictable behavior.

```kdl
binds {
    Mod+Key { action; }
    Mod+Key hotkey-overlay-title="Description" { spawn "command"; }
    XF86AudioRaiseVolume allow-when-locked=true { spawn "script"; }
}
```

Common actions:
- `spawn "command"` - Run a command
- `close-window` - Close focused window
- `focus-column-left/right` - Navigate columns
- `move-column-left/right` - Move window
- `focus-workspace "name"` - Switch workspace
- `toggle-window-floating` - Float/tile window
- `maximize-column` / `fullscreen-window`
- `screenshot` / `screenshot-window` / `screenshot-screen`

### Animations
```kdl
animations {
    slowdown 1.0
    workspace-switch { spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001 }
    window-open { duration-ms 150; curve "ease-out-expo"; }
}
```

## Scripts

Located in `niri_config/scripts/`:

| Script | Purpose |
|--------|---------|
| `volume` | Volume control with notifications |
| `brightness` | Brightness control with notifications |
| `screenshot` | Screenshot utility |
| `screenrecord` | Screen recording with wf-recorder |
| `rofi_launcher` | Application launcher |
| `rofi_powermenu` | Power menu (shutdown, reboot, etc.) |
| `rofi_screenshot` | Screenshot menu |
| `rofi_screenrecord` | Screen recording menu |
| `rofi_music` | MPD music control |
| `rofi_network` | Network manager |
| `rofi_bluetooth` | Bluetooth manager |
| `notifications` | Notification helper |
| `statusbar` | Waybar launcher |
| `wallpaper` | Wallpaper manager (swww) |
| `colorpicker` | Screen color picker |

## Rofi Menu Configuration

### File Structure

| Location | Purpose |
|----------|---------|
| `niri_config/rofi/` | Theme files (.rasi) |
| `niri_config/rofi/shared/colors.rasi` | Color palette |
| `niri_config/rofi/shared/fonts.rasi` | Font configuration |
| `niri_config/scripts/rofi_*` | Menu scripts |

### Fonts

**Text Font** (in `shared/fonts.rasi`):
```css
* {
    font: "Iosevka 10";
}
```

**Icon Font** (in individual .rasi files for icon-only menus):
```css
element-text {
    font: "Symbols Nerd Font 20";
}
```

**Required fonts:**
- `Iosevka` - Main text font
- `Symbols Nerd Font` - Icon font for icon-only mode (size 20)
- Nerd Font (e.g., `Iosevka Nerd Font`) - For inline icons in text mode

### Icon Display Modes (USE_ICON flag)

Rofi menus support two display modes controlled by `USE_ICON` comment in .rasi files:

**Icon-only mode** (`USE_ICON=YES`):
```css
/*
USE_ICON=YES
*/
```
- Uses Symbols Nerd Font icons (single characters)
- Icons: ``, ``, ``, ``, ``, ``

**Text + Icon mode** (`USE_ICON=NO`):
```css
/*
USE_ICON=NO
*/
```
- Uses Nerd Font icons with text labels
- Example: `󰍹 Capture Desktop`, `󰩭 Capture Area`

### Script Icon Pattern

Scripts must check the `USE_ICON` flag and provide both icon sets:
```bash
layout=$(cat "$RASI" | grep 'USE_ICON' | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
    # Text + Nerd Font icon mode
    option_1="󰍹 Capture Desktop"
    option_2="󰩭 Capture Area"
    option_3="󰖯 Capture Window"
else
    # Icon-only mode (Symbols Nerd Font)
    option_1="󰍹"
    option_2="󰩭"
    option_3="󰖯"
fi
```

### Common Nerd Font Icons

| Icon | Codepoint | Description |
|------|-----------|-------------|
| 󰍹 | `\U000f0379` | Monitor/Screen |
| 󰩭 | `\U000f0a6d` | Selection/Area |
| 󰖯 | `\U000f05af` | Window |
| 󰔝 | `\U000f051d` | Timer 5s |
| 󰔜 | `\U000f051c` | Timer 10s |
| 󰓛 | `\U000f04db` | Stop |
| 󰍬 | `\U000f036c` | Audio/Microphone |
|  | Lock |
|  | Sleep/Moon |
|  | Logout |
|  | Reboot |
|  | Shutdown |
|  | Play |
|  | Pause |
|  | Stop |
|  | Previous |
|  | Next |
|  | Repeat |
|  | Random/Shuffle |

### Colors (in `shared/colors.rasi`)

```css
* {
    background:     #391b0b;
    background-alt: #4e2510;
    foreground:     #f3ecdf;
    selected:       #EEB48A;
    active:         #F3AF71;
    urgent:         #E4A85F;
}
```

### Creating a New Rofi Menu

1. **Create the theme file** (`niri_config/rofi/your_menu.rasi`):
   ```css
   configuration {
       show-icons: false;
   }

   @import "shared/colors.rasi"
   @import "shared/fonts.rasi"

   /*
   USE_ICON=YES
   */

   /* Copy window, mainbox, listview, element styles from existing .rasi */
   ```

2. **Create the script** (`niri_config/scripts/rofi_yourmenu`):
   ```bash
   #!/usr/bin/env bash

   DIR="$HOME/.config/niri"
   RASI="$DIR/rofi/your_menu.rasi"

   prompt='Menu Name'
   mesg="Description or status"

   # Check USE_ICON flag for proper icon display
   layout=$(cat "$RASI" | grep 'USE_ICON' | cut -d'=' -f2)
   if [[ "$layout" == 'NO' ]]; then
       option_1="󰍹 Option One"
       option_2="󰩭 Option Two"
   else
       option_1="󰍹"
       option_2="󰩭"
   fi

   rofi_cmd() {
       rofi -dmenu \
           -p "$prompt" \
           -mesg "$mesg" \
           -markup-rows \
           -theme "$RASI"
   }

   run_rofi() {
       echo -e "$option_1\n$option_2" | rofi_cmd
   }

   chosen="$(run_rofi)"

   # CRITICAL: Handle ESC - exit gracefully
   [[ -z "$chosen" ]] && exit 0

   case "$chosen" in
       "$option_1") action_one ;;
       "$option_2") action_two ;;
   esac
   ```

3. **Add keybinding** (after checking for duplicates):
   ```kdl
   Mod+Key hotkey-overlay-title="Your Menu" { spawn "bash" "-c" "~/.config/niri/scripts/rofi_yourmenu"; }
   ```

## Waybar Configuration

Located in `niri_config/waybar/`:

| File | Purpose |
|------|---------|
| `config` | Main config (bar layout, module order, positioning) |
| `modules` | Module definitions (formats, icons, actions) |
| `style.css` | CSS styling (fonts, colors, spacing) |
| `colors.css` | Color variable definitions |

### Fonts (in `style.css`)

```css
* {
    font-family: "JetBrains Mono", "Symbols Nerd Font", Iosevka, archcraft, sans-serif;
    font-size: 14px;
}
```

**Required fonts:**
- `JetBrains Mono` - Primary monospace font
- `Symbols Nerd Font` - Icon font for module icons
- `Iosevka` - Fallback font

### Colors (in `colors.css`)

```css
@define-color background      #391b0b;
@define-color background-alt1 #4e2510;
@define-color background-alt2 #642f13;
@define-color foreground      #f3ecdf;
@define-color selected        #EEB48A;
@define-color red             #E4A85F;
@define-color green           #F3AF71;
@define-color yellow          #BDA089;
@define-color blue            #EEB48A;
@define-color magenta         #F7CC92;
@define-color cyan            #F7D9AD;
```

### Module Structure (in `modules`)

Each module typically has two variants:
- **Icon variant** (e.g., `battery`) - Shows only icon
- **Text variant** (e.g., `battery#2`) - Shows value/percentage

Example module definition:
```json
"battery": {
    "format": "{icon}",
    "format-icons": ["", "", "", "", ""],
    "format-charging": "",
},
"battery#2": {
    "format": "{capacity}%",
}
```

### Common Module Icons

| Module | Icons Used |
|--------|------------|
| Battery | ``, ``, `` (charging), `󰂄` (plugged) |
| Backlight | ``, ``, `` |
| Pulseaudio | ``, ``, ``, `` (muted) |
| Network | `󰤨` (wifi), `󰈀` (ethernet), `󰤭` (disconnected) |
| Bluetooth | ``, `` |
| Clock | `` |
| CPU | `` |
| Memory | `` |
| Disk | `` |
| MPD | `󰒮` (prev), `` (play), `` (pause), `󰒭` (next) |
| Power | `󰐥` |
| Menu | `` |

### Workspace Icons (in `modules`)

```json
"niri/workspaces": {
    "format-icons": {
        "main-browser": "󰈹",
        "main-term": "",
        "main-code": "󰨞",
        "chat": "󰻞",
        "email": "󰇮",
        "ext-term": "",
        "ext-code": "󰨞",
        "ext-browser": "󰈹",
        "default": ""
    }
}
```

### Adding a Waybar Module

1. Define module in `modules`:
   ```json
   "custom/mymodule": {
       "format": "󰣇 {}",
       "exec": "script-to-run",
       "interval": 5,
       "on-click": "action-on-click"
   }
   ```

2. Add to module order in `config`:
   ```json
   "modules-right": ["custom/mymodule", "clock", ...]
   ```

3. Style in `style.css`:
   ```css
   #custom-mymodule {
       color: @blue;
       background-color: @background-alt1;
       /* ... */
   }
   ```

## Applying Changes

After modifying niri configuration:
1. Edit files in `modules/home/wm/niri/niri_config/`
2. Rebuild: `sudo sys rebuild` or `sudo sys test`
3. Reload niri config: `niri msg action reload-config`

## Validation

Validate niri config syntax:
```bash
niri validate
```

## Common Tasks

### Add a keybinding

**IMPORTANT: Always check for duplicate keybindings before adding or modifying!**

1. First, search for existing usage of the key combination:
   ```bash
   grep -E "^\s*(Mod|Alt|Ctrl|Shift).*\+KeyName" modules/home/wm/niri/niri_config/config.kdl
   ```
   Or use Grep tool to search for the specific key in config.kdl.

2. If the keybinding already exists, either:
   - Choose a different key combination
   - Ask the user if they want to replace/reassign the existing binding

3. Only after confirming no conflicts, add to `binds { }` section:
   ```kdl
   Mod+Key hotkey-overlay-title="Description" { action; }
   ```

Example duplicate check for `Mod+P`:
```bash
grep "Mod+P" modules/home/wm/niri/niri_config/config.kdl
```

### Add a window rule
Edit `config.kdl`, add a `window-rule { }` block before `binds { }`:
```kdl
window-rule {
    match app-id="app-name"
    open-on-workspace "workspace-name"
}
```

### Add a new rofi menu
1. Create script in `niri_config/scripts/` following this template:
   ```bash
   #!/usr/bin/env bash

   DIR="$HOME/.config/niri"
   RASI="$DIR/rofi/your_menu.rasi"

   # Options
   option_1="Option 1"
   option_2="Option 2"

   rofi_cmd() {
     rofi -dmenu -p "Prompt" -mesg "Message" -theme "$RASI"
   }

   run_rofi() {
     echo -e "$option_1\n$option_2" | rofi_cmd
   }

   # Get selection
   chosen="$(run_rofi)"

   # CRITICAL: Handle ESC (empty selection) - exit gracefully
   [[ -z "$chosen" ]] && exit 0

   # Process selection
   case "$chosen" in
     "$option_1") do_something ;;
     "$option_2") do_something_else ;;
   esac
   ```
2. Create theme in `niri_config/rofi/` (copy from existing .rasi)
3. Add keybinding in `config.kdl` (after checking for duplicates)

### Modify waybar
1. Edit modules in `niri_config/waybar/modules`
2. Update `config` to include/arrange modules
3. Style in `style.css`
