---
name: niri-config
description: Help configure niri window manager - keybindings, window rules, workspaces, animations, monitors, and scripts
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(niri msg *, niri validate)
argument-hint: [keybindings|window-rules|workspaces|animations|monitors|scripts|waybar]
---

# Niri Configuration Helper

This skill helps configure the niri Wayland compositor for this NixOS system.

## Critical Rules

1. **Keybinding Duplicate Check (MANDATORY):** Before adding or modifying ANY keybinding, ALWAYS search `config.kdl` for the key combination to ensure it's not already in use. Use Grep to search for the key (e.g., `Mod+P`, `Ctrl+Alt+Delete`). If a duplicate is found, inform the user and ask how to proceed.

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

## Waybar Configuration

Located in `niri_config/waybar/`:

| File | Purpose |
|------|---------|
| `config` | Main waybar config (JSON-like) |
| `modules` | Module definitions |
| `style.css` | Styling |
| `colors.css` | Color variables |

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
1. Create script in `niri_config/scripts/`
2. Create theme in `niri_config/rofi/` (copy from existing .rasi)
3. Add keybinding in `config.kdl`

### Modify waybar
1. Edit modules in `niri_config/waybar/modules`
2. Update `config` to include/arrange modules
3. Style in `style.css`
