# Dynamic Hyprland Workspace Configuration - Design Document

## Overview

This design refactors the Hyprland workspace configuration system from hardcoded bash scripts to a Nix-driven, parameterized approach. The solution generates customized scripts at build time while maintaining runtime monitor detection capabilities.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     BUILD TIME (nix build)                       │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐    ┌─────────────────────────────────┐   │
│  │ Nix Module       │───▶│ Generated Scripts               │   │
│  │ Options          │    │ (with interpolated values)      │   │
│  │                  │    │                                 │   │
│  │ - primaryMonitor │    │ • generate_workspace_config     │   │
│  │ - perMonitor     │    │ • monitor_watcher               │   │
│  │ - distribution   │    │                                 │   │
│  └──────────────────┘    └─────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                     RUNTIME (Hyprland startup)                   │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐    ┌─────────────────────────────────┐   │
│  │ monitor_watcher  │───▶│ generate_workspace_config       │   │
│  │ (socat listener) │    │ (uses hyprctl monitors -j)      │   │
│  └──────────────────┘    └──────────────┬──────────────────┘   │
│                                          │                      │
│                                          ▼                      │
│                          ┌─────────────────────────────────┐   │
│                          │ ~/.config/hypr/workspaces.conf  │   │
│                          │ (dynamically generated)         │   │
│                          └─────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Technology Stack

**Nix Components**
- Home-manager module with `${namespace}.wm.hyprland` options
- `pkgs.writeShellScript` for generating executable scripts
- `lib.mkIf`, `lib.mkMerge` for conditional configuration

**Runtime Components**
- `hyprctl monitors -j` - JSON monitor detection
- `jq` - JSON parsing
- `socat` - Hyprland IPC socket listener
- Bash scripts for workspace generation

## Components and Interfaces

### 1. Nix Module Options

**File**: `modules/home/wm/hyprland/default.nix`

```nix
options.${namespace}.wm.hyprland = {
  enable = mkEnableOption "Hyprland config using hm";

  monitors = {
    primary = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Primary monitor name (e.g., eDP-1). Auto-detected if null.";
      example = "eDP-1";
    };

    externalPosition = mkOption {
      type = types.enum [ "left" "right" "above" "below" ];
      default = "right";
      description = "Position of external monitors relative to primary.";
    };

    refreshRate = mkOption {
      type = types.enum [ "preferred" "highrr" "highres" ];
      default = "highrr";
      description = "Refresh rate mode for external monitors.";
    };
  };

  workspaces = {
    perMonitor = mkOption {
      type = types.int;
      default = 10;
      description = "Number of workspaces per monitor.";
    };

    distribution = mkOption {
      type = types.enum [ "split" "primary-all" ];
      default = "split";
      description = ''
        Workspace distribution strategy:
        - split: First half on primary, second half on external (1-5 primary, 6-10 external)
        - primary-all: All base workspaces (1-10) on primary, extended (11-20) on external
      '';
    };
  };

  keybindings = {
    generateFKeys = mkOption {
      type = types.bool;
      default = true;
      description = "Generate F1-F10 bindings for workspaces 11-20.";
    };
  };
};
```

### 2. Script Generation

**Generated Script**: `generate_workspace_config`

The Nix module generates this script with interpolated values:

```nix
generateWorkspaceScript = pkgs.writeShellScript "generate_workspace_config" ''
  #!/usr/bin/env bash
  CONFIG_FILE="$HOME/.config/hypr/workspaces.conf"

  # Nix-interpolated values
  PRIMARY_MONITOR="${if cfg.monitors.primary != null
                    then cfg.monitors.primary
                    else "auto"}"
  EXTERNAL_POSITION="${cfg.monitors.externalPosition}"
  REFRESH_RATE="${cfg.monitors.refreshRate}"
  WORKSPACES_PER_MONITOR=${toString cfg.workspaces.perMonitor}
  DISTRIBUTION="${cfg.workspaces.distribution}"
  GENERATE_FKEYS=${if cfg.keybindings.generateFKeys then "true" else "false"}

  # Runtime monitor detection
  MONITORS=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name')

  # Auto-detect primary if not specified
  if [ "$PRIMARY_MONITOR" = "auto" ]; then
    PRIMARY_MONITOR=$(echo "$MONITORS" | head -1)
  fi

  EXTERNAL_MONITOR=$(echo "$MONITORS" | grep -v "$PRIMARY_MONITOR" | head -1)

  # ... generation logic ...
'';
```

### 3. Workspace Distribution Strategies

#### Strategy: `split`
Primary gets workspaces 1-5, 11-15; External gets 6-10, 16-20

```
Primary Monitor:   [1] [2] [3] [4] [5]  | [11] [12] [13] [14] [15]
External Monitor:  [6] [7] [8] [9] [10] | [16] [17] [18] [19] [20]
```

#### Strategy: `primary-all`
Primary gets workspaces 1-10; External gets 11-20

```
Primary Monitor:   [1] [2] [3] [4] [5] [6] [7] [8] [9] [10]
External Monitor:  [11] [12] [13] [14] [15] [16] [17] [18] [19] [20]
```

### 4. Keybinding Generation

**Keybinding Principle:**
| Workspaces | Keys | Modifier |
|------------|------|----------|
| 1-9 | `1-9` | `SUPER` to switch, `SUPER_SHIFT` to move |
| 10 | `0` | `SUPER` to switch, `SUPER_SHIFT` to move |
| 11-19 | `F1-F9` | `SUPER` to switch, `SUPER_SHIFT` to move |
| 20 | `F10` | `SUPER` to switch, `SUPER_SHIFT` to move |

```bash
generate_fkey_bindings() {
  if [ "$GENERATE_FKEYS" = "true" ] && [ -n "$EXTERNAL_MONITOR" ]; then
    for i in {1..10}; do
      ws=$((i + 10))
      echo "bind = SUPER, F$i, workspace, $ws"
      echo "bind = SUPER_SHIFT, F$i, movetoworkspace, $ws"
    done
  fi
}
```

## Data Flow

### Build Time Flow

```
1. User sets options in home/<user>/<hostname>.nix:
   sinh-x.wm.hyprland = {
     enable = true;
     monitors.primary = "eDP-1";
     workspaces.distribution = "split";
   };

2. Nix evaluates modules/home/wm/hyprland/default.nix

3. Scripts generated with interpolated values:
   - ~/.config/hypr/scripts/generate_workspace_config
   - ~/.config/hypr/scripts/monitor_watcher

4. Static config files copied:
   - hyprland.conf (sources workspaces.conf)
   - hyprtheme.conf
```

### Runtime Flow

```
1. Hyprland starts
   └── exec-once: monitor_watcher

2. monitor_watcher runs generate_workspace_config
   └── Queries: hyprctl monitors -j
   └── Generates: ~/.config/hypr/workspaces.conf
   └── Reloads: hyprctl reload

3. Monitor hotplug event
   └── socat receives: monitoradded/monitorremoved
   └── Triggers: generate_workspace_config
   └── Updates: workspaces.conf
   └── Reloads: hyprctl reload
```

## File Structure Changes

### Before (Current)
```
modules/home/wm/hyprland/
├── default.nix                    # Minimal, just copies files
└── hypr_config/
    ├── hyprland.conf
    ├── hyprtheme.conf
    ├── workspaces.conf            # Static/manual
    └── scripts/
        ├── generate_workspace_config   # Hardcoded values
        └── monitor_watcher             # Hardcoded values
```

### After (Proposed)
```
modules/home/wm/hyprland/
├── default.nix                    # Full module with options + script generation
└── hypr_config/
    ├── hyprland.conf              # Modified to not exec scripts directly
    ├── hyprtheme.conf             # Unchanged
    └── scripts/
        └── (other utility scripts)

# Generated at build time (via home.file or xdg.configFile):
~/.config/hypr/scripts/
├── generate_workspace_config      # Nix-generated with interpolated values
└── monitor_watcher                # Nix-generated with interpolated values
```

## Implementation Approach

### Option A: Script Template Interpolation (Recommended)

Generate scripts using Nix string interpolation:

```nix
config = mkIf cfg.enable {
  home.file.".config/hypr/scripts/generate_workspace_config" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      PRIMARY_MONITOR="${cfg.monitors.primary or "auto"}"
      # ... rest of script with ${} interpolations
    '';
  };

  # Copy static configs
  home.file.".config/hypr" = {
    source = lib.cleanSourceWith {
      src = ./hypr_config;
      filter = path: type:
        !(lib.hasSuffix "generate_workspace_config" path) &&
        !(lib.hasSuffix "monitor_watcher" path);
    };
    recursive = true;
  };
};
```

**Pros:**
- Simple to implement
- Easy to debug (scripts are readable bash)
- Maintains current architecture

**Cons:**
- Script logic in Nix strings (harder to edit)

### Option B: Pure Nix Generation

Generate `workspaces.conf` directly in Nix, no runtime script:

```nix
home.file.".config/hypr/workspaces.conf".text =
  lib.concatStringsSep "\n" (generateWorkspaceLines cfg);
```

**Pros:**
- Fully declarative
- No runtime dependencies

**Cons:**
- Cannot adapt to runtime monitor changes
- Breaks hotplug functionality

### Recommendation: Option A

Option A preserves the runtime flexibility while eliminating hardcoded values. The scripts become "templates" that Nix fills in at build time.

## Migration Strategy

### Backward Compatibility

The default values ensure existing Emberroot behavior is preserved:

| Option | Default | Current Behavior |
|--------|---------|------------------|
| `monitors.primary` | `null` (auto-detect, fallback to first) | Works like current eDP-1 hardcode |
| `monitors.externalPosition` | `"right"` | Matches current |
| `workspaces.perMonitor` | `10` | Matches current |
| `workspaces.distribution` | `"split"` | Matches current 1-5/6-10 split |
| `keybindings.generateFKeys` | `true` | Matches current |

### Migration Steps

1. Update module with new options (defaults match current behavior)
2. Generate scripts instead of copying them
3. Test on Emberroot - should work identically
4. Optionally set explicit `monitors.primary = "eDP-1"` for clarity

## Testing Strategy

### Manual Testing Checklist

1. **Single Monitor Mode**
   - [ ] Workspaces 1-10 on primary monitor
   - [ ] Number keys 1-0 work correctly
   - [ ] No F-key bindings generated (no external monitor)

2. **Dual Monitor Mode**
   - [ ] Workspaces distributed per `distribution` setting
   - [ ] F-keys F1-F10 map to workspaces 11-20
   - [ ] Monitor hotplug triggers regeneration

3. **Configuration Variations**
   - [ ] `monitors.primary = null` auto-detects correctly
   - [ ] `monitors.primary = "DP-1"` uses specified monitor
   - [ ] `distribution = "primary-all"` works correctly

### Validation Commands

```bash
# Check generated script values
grep "PRIMARY_MONITOR" ~/.config/hypr/scripts/generate_workspace_config

# Verify workspaces.conf
cat ~/.config/hypr/workspaces.conf

# Test monitor detection
hyprctl monitors -j | jq -r '.[].name'

# Test hotplug (connect/disconnect monitor, check regeneration)
```

## Error Handling

### Fallback Behaviors

| Scenario | Handling |
|----------|----------|
| No monitors detected | Use "FALLBACK" as monitor name, log warning |
| Primary monitor not found | Use first available monitor |
| hyprctl not available | Skip generation, use existing workspaces.conf |
| jq not available | Fall back to grep-based parsing |

### Error Logging

```bash
log_error() {
  echo "[$(date)] ERROR: $1" >> "$HOME/.config/hypr/workspace-gen.log"
}

if ! command -v hyprctl &>/dev/null; then
  log_error "hyprctl not found, skipping workspace generation"
  exit 0
fi
```

## Dependencies

### Build-time Dependencies
- `lib` (nixpkgs lib functions)
- `pkgs.writeShellScript` or `home.file` with text

### Runtime Dependencies
- `hyprctl` (part of Hyprland)
- `jq` (JSON parsing)
- `socat` (IPC socket)
- `bash` (script execution)

All runtime dependencies should be added to `home.packages` if not already present.

---

**Requirements Traceability**: This design addresses all requirements from requirements.md sections 3-6.

**Review Status**: Draft

**Last Updated**: 2026-01-14

**Related Documents**:
- `requirements.md` - Feature requirements
- `modules/home/wm/hyprland/default.nix` - Implementation target
