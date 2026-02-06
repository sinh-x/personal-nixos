# Niri Smart Spawn Design Document

## Overview

The smart spawn feature replaces static window rules with a bash script that dynamically determines the appropriate workspace for terminal and browser applications based on the current monitor configuration and focus state.

## Architecture

### High-Level Flow

```
User presses keybinding (Mod+Return, Mod+T, Mod+Shift+W)
         │
         ▼
    smart_spawn script
         │
         ▼
  Query niri for outputs ──► Count monitors
         │
         ▼
  Query focused output ──► Determine current monitor
         │
         ▼
  Apply workspace logic:
  ┌─────────────────────────────────────────────────┐
  │ 1 monitor:  Always use main-* workspace         │
  │ 2 monitors: Use OTHER monitor's workspace       │
  │             (main → ext, ext → main)            │
  └─────────────────────────────────────────────────┘
         │
         ▼
  focus-workspace → spawn application
```

## Components

### 1. smart_spawn Script

**Location**: `modules/home/wm/niri/niri_config/scripts/smart_spawn`

**Interface**:
```bash
smart_spawn <terminal|browser>
```

**Dependencies**:
- `niri` - Wayland compositor with IPC
- `jq` - JSON parsing

### 2. Configuration Constants

```bash
# Output names
MAIN_OUTPUT="eDP-1"      # Built-in laptop display

# Applications
TERMINAL="ghostty"
BROWSER="zen-twilight"

# Workspace mapping
# terminal → main-term / ext-term
# browser  → main-browser / ext-browser
```

## Script Logic

### Monitor Detection

```bash
# Get number of connected outputs
output_count=$(niri msg --json outputs | jq 'length')

# Get currently focused output name
focused_output=$(niri msg --json focused-output | jq -r '.name')
```

### Workspace Selection Algorithm

```
INPUT: app_type (terminal|browser), output_count, focused_output
OUTPUT: target_workspace

IF output_count == 1:
    RETURN "main-{app_type_suffix}"

IF focused_output == MAIN_OUTPUT:
    RETURN "ext-{app_type_suffix}"
ELSE:
    RETURN "main-{app_type_suffix}"
```

### App Type to Suffix Mapping

| App Type | Suffix  |
|----------|---------|
| terminal | term    |
| browser  | browser |

## Config Changes

### Window Rules to Remove

```kdl
// REMOVE: Terminal apps rule (lines 300-305)
window-rule {
    match app-id=r#"(?i)(ghostty|alacritty|kitty|foot|wezterm|konsole)"#
    open-on-workspace "main-term"
    open-maximized true
}

// REMOVE: Browser apps rules (lines 307-336)
window-rule { match app-id=r#"(?i)zen"# ... }
window-rule { match app-id=r#"(?i)firefox"# ... }
// etc.
```

### Keybindings to Update

| Current | New |
|---------|-----|
| `Mod+Return { spawn "ghostty"; }` | `Mod+Return { spawn "bash" "-c" "~/.config/niri/scripts/smart_spawn terminal"; }` |
| `Mod+T { spawn "ghostty"; }` | `Mod+T { spawn "bash" "-c" "~/.config/niri/scripts/smart_spawn terminal"; }` |
| `Mod+Shift+W { spawn "zen-twilight"; }` | `Mod+Shift+W { spawn "bash" "-c" "~/.config/niri/scripts/smart_spawn browser"; }` |

## Error Handling

| Scenario | Handling |
|----------|----------|
| Invalid app_type argument | Print usage and exit 1 |
| niri IPC fails | Let command fail naturally (user sees error) |
| jq not available | Script fails (required dependency) |

## Testing Strategy

### Manual Test Cases

1. **Single monitor - terminal**: Should open on `main-term`
2. **Single monitor - browser**: Should open on `main-browser`
3. **Two monitors, focused on eDP-1 - terminal**: Should open on `ext-term`
4. **Two monitors, focused on eDP-1 - browser**: Should open on `ext-browser`
5. **Two monitors, focused on external - terminal**: Should open on `main-term`
6. **Two monitors, focused on external - browser**: Should open on `main-browser`

---

**Requirements Traceability**: This design addresses all requirements from `requirements.md`

**Review Status**: Draft

**Last Updated**: 2026-02-06
