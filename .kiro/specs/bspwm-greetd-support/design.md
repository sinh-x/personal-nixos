# BSPWM greetd and Monitor/Workspace Configuration Design

## Overview

This document describes the technical design for:
1. Adding greetd display manager support to the BSPWM NixOS module
2. Adding declarative monitor/workspace configuration to the BSPWM home module

The design mirrors the existing Hyprland implementation to ensure consistency across window managers.

## Architecture

### Module Structure

```
modules/nixos/wm/bspwm/default.nix
├── options.modules.wm.bspwm
│   ├── enable (existing)
│   └── greetd (new)
│       ├── enable
│       └── autoLogin
│           ├── enable
│           └── user
└── config (mkIf cfg.enable)
    ├── services.xserver (existing)
    ├── xdg.portal (existing)
    ├── environment.systemPackages (existing)
    └── services.greetd (new, mkIf cfg.greetd.enable)
```

### Session Launch Flow

```
greetd daemon
    │
    ├── [Auto-Login Enabled]
    │   └── startx ${pkgs.bspwm}/bin/bspwm (as configured user)
    │
    └── [Auto-Login Disabled]
        └── tuigreet --cmd 'startx ${pkgs.bspwm}/bin/bspwm' (as greeter user)
            └── User authenticates → session starts
```

## Components and Interfaces

### Option Definitions

```nix
options.modules.wm.bspwm = {
  enable = lib.mkEnableOption "bspwm";

  greetd = {
    enable = lib.mkEnableOption "greetd display manager with bspwm";

    autoLogin = {
      enable = lib.mkEnableOption "auto-login without greeter";

      user = lib.mkOption {
        type = lib.types.str;
        default = "sinh";
        description = "User to auto-login as";
      };
    };
  };
};
```

### greetd Configuration

```nix
services.greetd = lib.mkIf cfg.greetd.enable {
  enable = true;
  settings = {
    default_session =
      if cfg.greetd.autoLogin.enable then
        {
          command = "${pkgs.xorg.xinit}/bin/startx ${pkgs.bspwm}/bin/bspwm";
          inherit (cfg.greetd.autoLogin) user;
        }
      else
        {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd '${pkgs.xorg.xinit}/bin/startx ${pkgs.bspwm}/bin/bspwm'";
          user = "greeter";
        };
  };
};
```

## Comparison with Hyprland Implementation

| Aspect | Hyprland | BSPWM |
|--------|----------|-------|
| Session type | Wayland | X11 |
| Launch command | `${pkgs.hyprland}/bin/start-hyprland` | `${pkgs.xorg.xinit}/bin/startx ${pkgs.bspwm}/bin/bspwm` |
| Option path | `modules.wm.hyprland.greetd` | `modules.wm.bspwm.greetd` |
| Greeter sessions flag | `--sessions ${pkgs.hyprland}/share/wayland-sessions` | `--cmd 'startx ...'` |
| Monitor detection | `hyprctl monitors -j` | `xrandr` |
| Config reload | `hyprctl reload` | `bspc wm -r` / workspace reassignment |

## Monitor/Workspace Architecture

### Home Module Structure

```
modules/home/wm/bspwm/default.nix
├── options.${namespace}.wm.bspwm
│   ├── enable (existing)
│   ├── monitors (new)
│   │   ├── primary
│   │   ├── externalPosition
│   │   └── externalMaxResolution
│   └── workspaces (new)
│       └── distribution
└── config (mkIf cfg.enable)
    ├── home.packages (existing)
    ├── home.file.".config/bspwm" (existing)
    └── home.file.".config/bspwm/scripts/monitor-management.fish" (generated)
```

### Script Generation Flow

```
Nix Configuration
    │
    ├── cfg.monitors.primary → NIX_PRIMARY_MONITOR variable
    ├── cfg.monitors.externalPosition → EXTERNAL_POSITION variable
    ├── cfg.monitors.externalMaxResolution → EXT_MAX_RES variable
    └── cfg.workspaces.distribution → DISTRIBUTION variable
    │
    ▼
Generated monitor-management.fish script
    │
    ├── Runtime: Detect monitors via xrandr
    ├── Runtime: Configure displays via xrandr
    ├── Runtime: Assign workspaces via bspc
    └── Called from: bspwmrc at startup
```

### Monitor Management Script Design

```fish
#!/usr/bin/env fish

# Nix-interpolated values (with fallback to auto-detect)
set NIX_PRIMARY_MONITOR "${primaryMonitor}"
set EXTERNAL_POSITION "${externalPosition}"
set EXT_MAX_RES ${externalMaxResolution}
set DISTRIBUTION "${distribution}"

# Resolve primary monitor: Nix config > auto-detect
if test "$NIX_PRIMARY_MONITOR" != "auto"
    set INTERNAL_MONITOR "$NIX_PRIMARY_MONITOR"
else
    # Auto-detect first connected monitor
    set INTERNAL_MONITOR (xrandr | grep " connected " | head -1 | awk '{print $1}')
end

# Display configuration via xrandr
function set_display
    # Parse xrandr output
    # Configure monitors with proper positioning
    # Handle resolution limits for external monitors
end

# Workspace assignment
function assign_workspaces
    set monitors_count (xrandr | grep -c " connected ")

    if test $monitors_count -eq 1
        # Single monitor: workspaces 1-10
        bspc monitor $INTERNAL_MONITOR -d 1 2 3 4 5 6 7 8 9 10
    else
        # Dual monitor: based on distribution strategy
        if test "$DISTRIBUTION" = "split"
            # Left: 1-5, 11-15; Right: 6-10, 16-20
        else
            # Primary: 1-10; External: 11-20
        end
    end
end
```

### Home Module Options

```nix
options.${namespace}.wm.bspwm = {
  enable = mkEnableOption "Bspwm config using hm";

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

    externalMaxResolution = mkOption {
      type = types.nullOr types.int;
      default = 4000;
      description = "Max width for external monitors. If exceeded, uses secondary resolution.";
    };
  };

  workspaces = {
    distribution = mkOption {
      type = types.enum [ "split" "primary-all" ];
      default = "split";
      description = ''
        Workspace distribution strategy:
        - split: Left monitor gets 1-5,11-15; Right gets 6-10,16-20
        - primary-all: Primary gets 1-10; External gets 11-20
      '';
    };
  };
};
```

### Workspace Distribution Strategies

#### Split Distribution (default)
```
┌─────────────────┐  ┌─────────────────┐
│  Left Monitor   │  │  Right Monitor  │
│                 │  │                 │
│  Workspaces:    │  │  Workspaces:    │
│  1, 2, 3, 4, 5  │  │  6, 7, 8, 9, 10 │
│  11,12,13,14,15 │  │  16,17,18,19,20 │
└─────────────────┘  └─────────────────┘
```

#### Primary-All Distribution
```
┌─────────────────┐  ┌─────────────────┐
│ Primary Monitor │  │External Monitor │
│                 │  │                 │
│  Workspaces:    │  │  Workspaces:    │
│  1-10           │  │  11-20          │
└─────────────────┘  └─────────────────┘
```

## Error Handling

### X11 Initialization Failures
- If X11 fails to start, greetd will restart the session after timeout
- User can switch to another TTY (Ctrl+Alt+F2) for recovery
- Journal logs available via `journalctl -u greetd`

### bspwmrc Missing
- If `~/.config/bspwm/bspwmrc` is missing, bspwm starts with defaults
- Home-manager module (`sinh-x.wm.bspwm.enable`) ensures config is deployed

## Testing Strategy

### Manual Testing
1. Enable BSPWM with greetd auto-login
2. Rebuild system: `sudo sys rebuild`
3. Reboot and verify direct boot to BSPWM desktop
4. Verify sxhkd, polybar, and other autostart apps launch correctly

### Configuration Testing
1. Toggle auto-login off and verify tuigreet appears
2. Verify login with credentials works
3. Verify session starts correctly after authentication

## Platform-Specific Considerations

### NixOS Integration
- Uses `lib.mkIf` for conditional configuration
- greetd service managed by systemd
- X11 server configuration handled by `services.xserver` (already in BSPWM module)

### X11 vs Wayland
- X11 requires `startx` wrapper to initialize display server
- Wayland compositors (Hyprland) handle display server internally
- Both use greetd as session manager, only launch command differs

---

**Requirements Traceability**: This design addresses all requirements from `requirements.md`

**Review Status**: Implemented

**Last Updated**: 2026-02-03
