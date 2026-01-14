# Dynamic Hyprland Workspace Configuration Requirements

## 1. Introduction

This document specifies the requirements for refactoring the Hyprland workspace generation system to dynamically support various monitor setups without hardcoded values.

**Architecture Overview**: The current implementation uses bash scripts (`generate_workspace_config`, `monitor_watcher`) with hardcoded monitor names (eDP-1) and fixed workspace distributions. This refactoring will introduce Nix module options to parameterize the configuration per-system while maintaining runtime monitor detection capabilities.

## 2. Current State Analysis

### Hardcoded Limitations Identified
| Item | Current Value | Location |
|------|---------------|----------|
| Primary monitor name | `eDP-1` | `generate_workspace_config:5`, `monitor_watcher:4`, `hyprland.conf:738-739` |
| External monitor position | `right` | `hyprland.conf:738` |
| Workspace count | 10 (single) / 20 (dual) | `generate_workspace_config` |
| Workspace distribution | 1-5,11-15 / 6-10,16-20 | `generate_workspace_config` |
| Keybindings | 1-0 for ws 1-10, F1-F10 for ws 11-20 | `generate_workspace_config` |

## 3. User Stories

### System Administrator
- **As a NixOS user**, I want to configure my primary monitor name per-system, so that the workspace config works on different hardware
- **As a NixOS user**, I want to define workspace distribution through Nix options, so that I can customize it declaratively
- **As a NixOS user**, I want the configuration to auto-detect available monitors at runtime, so that hotplugging works correctly

### Multi-Monitor User
- **As a user with multiple monitors**, I want workspaces distributed logically across monitors, so that I can organize my workflow
- **As a user**, I want to specify monitor positions (left/right/above/below), so that workspace assignment matches my physical layout
- **As a user**, I want custom keybindings per monitor setup, so that I can efficiently switch workspaces

### Laptop User
- **As a laptop user**, I want seamless switching between docked (multi-monitor) and undocked (single monitor) modes
- **As a laptop user**, I want my workspaces to migrate gracefully when external monitors are disconnected

## 4. Acceptance Criteria

### Monitor Detection Requirements
- **WHEN** Hyprland starts, **THEN** the system **SHALL** detect all connected monitors dynamically
- **WHEN** a monitor is connected/disconnected, **THEN** the system **SHALL** regenerate workspace configuration automatically
- **IF** no primary monitor is specified, **THEN** the system **SHALL** use the first detected monitor as primary

### Nix Configuration Requirements
- **WHEN** a user specifies `primaryMonitor` option, **THEN** the generated scripts **SHALL** use that value instead of hardcoded "eDP-1"
- **WHEN** a user specifies `workspacesPerMonitor` option, **THEN** the system **SHALL** distribute that many workspaces per monitor
- **WHEN** a user specifies `externalMonitorPosition` option, **THEN** the system **SHALL** position external monitors accordingly
- **IF** options are not specified, **THEN** the system **SHALL** use sensible defaults

### Workspace Distribution Requirements
- **WHEN** in single-monitor mode, **THEN** all workspaces **SHALL** be assigned to the primary monitor
- **WHEN** in multi-monitor mode, **THEN** workspaces **SHALL** be distributed according to configuration
- **WHEN** monitor count changes, **THEN** workspace assignments **SHALL** update without losing window state

### Keybinding Requirements
- **WHEN** workspaces 1-10 are configured, **THEN** number keys **SHALL** be used (1-9 for workspaces 1-9, 0 for workspace 10)
- **WHEN** workspaces 11-20 are configured, **THEN** F-keys **SHALL** be used (F1 for 11, F2 for 12, ... F10 for 20)
- **WHEN** extra monitors are connected, **THEN** additional keybindings **SHALL** be generated for those workspaces
- **IF** custom keybindings are specified, **THEN** the system **SHALL** use those instead of defaults

## 5. Proposed Nix Module Options

```nix
options.${namespace}.wm.hyprland = {
  enable = mkEnableOption "Hyprland window manager";

  monitors = {
    primary = mkOpt types.str null "Primary monitor name (e.g., eDP-1, DP-1). Auto-detected if null.";

    externalPosition = mkOpt (types.enum ["left" "right" "above" "below"]) "right"
      "Position of external monitors relative to primary";

    defaultRefreshRate = mkOpt types.str "preferred"
      "Default refresh rate mode (preferred, highrr, highres)";
  };

  workspaces = {
    perMonitor = mkOpt types.int 10 "Number of workspaces per monitor";

    distribution = mkOpt (types.enum ["split" "primary-focus" "custom"]) "split"
      "How to distribute workspaces across monitors";

    customDistribution = mkOpt (types.attrsOf (types.listOf types.int)) {}
      "Custom workspace-to-monitor mapping";
  };

  keybindings = {
    # Keybinding principle:
    # - Workspaces 1-10: Number keys (1-9, 0 for 10)
    # - Workspaces 11-20: F-keys (F1=11, F2=12, ... F10=20)
    generateFKeys = mkOpt types.bool true
      "Generate F1-F10 bindings for workspaces 11-20 (used in multi-monitor setups)";

    extraBindings = mkOpt types.lines ""
      "Additional keybindings to include";
  };
};
```

## 6. Feature Specifications

### Core Features
1. **Parameterized Monitor Names**: Replace hardcoded "eDP-1" with configurable option
2. **Dynamic Script Generation**: Generate bash scripts from Nix with correct values baked in
3. **Runtime Monitor Detection**: Maintain ability to detect monitors at runtime
4. **Workspace Distribution Strategies**: Support multiple distribution algorithms

### Advanced Features
1. **Per-System Overrides**: Different configs for Emberroot vs future Hyprland systems
2. **Custom Workspace-Monitor Mapping**: Allow explicit workspace assignments
3. **Monitor Profile Support**: Named profiles for different docking scenarios

## 7. Technical Architecture

### Configuration Flow
```
Nix Module Options (declarative)
        ↓
Template Script Generation (build time)
        ↓
Runtime Monitor Detection (hyprctl)
        ↓
Dynamic workspaces.conf (runtime)
```

### Key Components
- **Nix Module**: `modules/home/wm/hyprland/default.nix` - Define options and generate scripts
- **Template Scripts**: Bash scripts with Nix-interpolated values
- **Monitor Watcher**: Maintains socket listener for hotplug events
- **Workspace Generator**: Creates `workspaces.conf` based on current state

## 8. Constraints and Limitations

### Technical Constraints
- Must maintain backward compatibility with current Emberroot setup
- Scripts run at Hyprland startup, before full Nix environment is available
- Monitor names vary by hardware (Intel: eDP-1, AMD: eDP, NVIDIA: DP-0, etc.)

### Design Constraints
- Follow Snowfall Lib conventions for module structure
- Use `${namespace}` pattern for home-manager options
- Keep generated scripts minimal and debuggable

## 9. Success Criteria

- **WHEN** deployed on Emberroot, **THEN** behavior **SHALL** match current functionality
- **WHEN** a new Hyprland system is added, **THEN** only Nix options need configuration (no script edits)
- **WHEN** monitors are hotplugged, **THEN** workspaces **SHALL** reconfigure within 1 second

## 10. Out of Scope

- Multi-GPU configurations
- Workspace persistence across reboots
- Per-workspace wallpaper management
- Integration with other window managers

---

**Document Status**: Draft

**Last Updated**: 2026-01-14

**Related Files**:
- `modules/home/wm/hyprland/default.nix`
- `modules/home/wm/hyprland/hypr_config/scripts/generate_workspace_config`
- `modules/home/wm/hyprland/hypr_config/scripts/monitor_watcher`
