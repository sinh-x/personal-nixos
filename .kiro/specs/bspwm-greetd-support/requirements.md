# BSPWM greetd and Monitor/Workspace Configuration

## 1. Introduction

This document specifies the requirements for:
1. Adding greetd display manager support to the BSPWM NixOS module
2. Adding declarative monitor/workspace configuration to the BSPWM home module

**Architecture Overview**:
- **NixOS Module**: Extended with greetd configuration options that launch X11 via `startx` with BSPWM
- **Home Module**: Extended with declarative monitor/workspace options (similar to Hyprland) that generate runtime configuration scripts

## 2. User Stories

### System Administrator
- **As a system administrator**, I want to configure greetd for BSPWM declaratively in NixOS, so that I don't need manual configuration files
- **As a system administrator**, I want to enable auto-login for BSPWM, so that the system boots directly to the desktop without login prompts
- **As a system administrator**, I want the same configuration pattern as Hyprland's greetd setup, so that switching between WMs is straightforward

### End User
- **As a user**, I want my BSPWM session to start automatically on boot, so that I can begin working immediately
- **As a user**, I want the option to use a greeter (tuigreet) if auto-login is disabled, so that I can securely log in when needed

### Monitor/Workspace Configuration
- **As a system administrator**, I want to configure monitors and workspaces declaratively in Nix, so that I maintain consistency with Hyprland configuration patterns
- **As a user**, I want workspaces to be automatically distributed across monitors, so that I can immediately use external monitors when connected
- **As a user**, I want monitors to be automatically detected and configured, so that I don't need to run manual xrandr commands
- **As a user**, I want the system to handle monitor hotplug events, so that workspaces are reconfigured when I connect/disconnect monitors

## 3. Acceptance Criteria

### Module Configuration Requirements
- **WHEN** `modules.wm.bspwm.enable = true` and `modules.wm.bspwm.greetd.enable = true`, **THEN** the system **SHALL** configure greetd as the display manager
- **WHEN** `modules.wm.bspwm.greetd.autoLogin.enable = true`, **THEN** the system **SHALL** boot directly into BSPWM without showing a greeter
- **WHEN** `modules.wm.bspwm.greetd.autoLogin.enable = false`, **THEN** the system **SHALL** display tuigreet for user authentication
- **IF** `modules.wm.bspwm.greetd.autoLogin.user` is set, **THEN** the system **SHALL** use that user for auto-login

### X11 Session Requirements
- **WHEN** greetd launches BSPWM, **THEN** the system **SHALL** use `startx` to properly initialize the X11 server
- **WHEN** BSPWM starts via greetd, **THEN** the system **SHALL** execute the user's `~/.config/bspwm/bspwmrc` configuration

### Compatibility Requirements
- **WHEN** switching from Hyprland to BSPWM, **THEN** the greetd configuration **SHALL** follow the same pattern (nested options under `greetd.enable` and `greetd.autoLogin`)
- **WHEN** BSPWM greetd is enabled, **THEN** it **SHALL** not conflict with other display managers (SDDM, LightDM)

### Monitor Configuration Requirements
- **WHEN** `sinh-x.wm.bspwm.monitors.primary` is set, **THEN** the system **SHALL** use that monitor as the primary display
- **WHEN** `sinh-x.wm.bspwm.monitors.primary` is null, **THEN** the system **SHALL** auto-detect the primary monitor at runtime
- **WHEN** `sinh-x.wm.bspwm.monitors.externalPosition` is set, **THEN** the system **SHALL** position external monitors accordingly (left/right/above/below)
- **WHEN** an external monitor is connected, **THEN** the system **SHALL** automatically configure it via xrandr
- **WHEN** `sinh-x.wm.bspwm.monitors.externalMaxResolution` is set, **THEN** the system **SHALL** limit external monitor resolution

### Workspace Distribution Requirements
- **WHEN** `sinh-x.wm.bspwm.workspaces.distribution = "split"`, **THEN** the system **SHALL** assign workspaces 1-5,11-15 to left monitor and 6-10,16-20 to right monitor
- **WHEN** `sinh-x.wm.bspwm.workspaces.distribution = "primary-all"`, **THEN** the system **SHALL** assign workspaces 1-10 to primary and 11-20 to external
- **WHEN** only one monitor is connected, **THEN** the system **SHALL** assign all workspaces (1-10) to that monitor
- **WHEN** monitors change (hotplug), **THEN** the system **SHALL** reconfigure workspaces automatically

## 4. Technical Architecture

### NixOS Module Structure
- **Module Path**: `modules/nixos/wm/bspwm/default.nix`
- **Option Namespace**: `modules.wm.bspwm.greetd`
- **Dependencies**: `pkgs.xorg.xinit`, `pkgs.bspwm`, `pkgs.greetd.tuigreet`

### Home Module Structure
- **Module Path**: `modules/home/wm/bspwm/default.nix`
- **Option Namespace**: `sinh-x.wm.bspwm.monitors`, `sinh-x.wm.bspwm.workspaces`
- **Dependencies**: `xrandr`, `bspc`, `fish`

### NixOS Configuration Options (greetd)
```nix
modules.wm.bspwm = {
  enable = mkEnableOption "bspwm";
  greetd = {
    enable = mkEnableOption "greetd display manager with bspwm";
    autoLogin = {
      enable = mkEnableOption "auto-login without greeter";
      user = mkOption {
        type = types.str;
        default = "sinh";
        description = "User to auto-login as";
      };
    };
  };
};
```

### Home Configuration Options (monitors/workspaces)
```nix
sinh-x.wm.bspwm = {
  enable = mkEnableOption "Bspwm config using hm";

  monitors = {
    primary = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Primary monitor name (e.g., eDP-1). Auto-detected if null.";
    };
    externalPosition = mkOption {
      type = types.enum [ "left" "right" "above" "below" ];
      default = "right";
      description = "Position of external monitors relative to primary.";
    };
    externalMaxResolution = mkOption {
      type = types.nullOr types.int;
      default = 4000;
      description = "Max width for external monitors (use secondary resolution if exceeded).";
    };
  };

  workspaces = {
    distribution = mkOption {
      type = types.enum [ "split" "primary-all" ];
      default = "split";
      description = "Workspace distribution: split (1-5 left, 6-10 right) or primary-all (1-10 primary, 11-20 external).";
    };
  };
};
```

## 5. Feature Specifications

### Core Features (greetd)
1. **greetd Enable Option**: Toggle greetd display manager for BSPWM
2. **Auto-Login Support**: Direct boot to BSPWM desktop without authentication prompt
3. **User Selection**: Configurable user for auto-login
4. **Fallback Greeter**: tuigreet support when auto-login is disabled

### Monitor/Workspace Features
1. **Declarative Monitor Config**: Configure primary monitor and external position via Nix options
2. **Auto-Detection**: Runtime detection of monitors via xrandr when options are null
3. **Resolution Management**: Support for limiting external monitor resolution
4. **Workspace Distribution Strategies**:
   - `split`: Left monitor gets 1-5,11-15; Right monitor gets 6-10,16-20
   - `primary-all`: Primary gets 1-10; External gets 11-20
5. **Hotplug Support**: Automatic reconfiguration on monitor connect/disconnect
6. **Generated Scripts**: Nix generates fish scripts with interpolated configuration values

### Current vs New Implementation Comparison

| Aspect | Current BSPWM | New BSPWM (Hyprland-style) |
|--------|---------------|----------------------------|
| Monitor config | Per-host fish scripts | Declarative Nix options |
| Workspace distribution | Hardcoded in fish | Configurable via `distribution` option |
| External position | Per-host hardcoded | Configurable via `externalPosition` option |
| Primary monitor | Per-host hardcoded | Configurable or auto-detected |
| Resolution limits | Environment variable | Nix option `externalMaxResolution` |

## 6. Success Criteria

### Functional Success
- **WHEN** system boots with auto-login enabled, **THEN** user **SHALL** see BSPWM desktop within normal boot time
- **WHEN** system boots with auto-login disabled, **THEN** user **SHALL** see tuigreet login prompt

### Configuration Success
- **WHEN** switching from Hyprland to BSPWM, **THEN** only WM-specific options need to change (not greetd structure)

## 7. Assumptions and Dependencies

### Technical Assumptions
- X11 server is properly configured via `services.xserver.enable = true` (handled by BSPWM module)
- User has a valid `~/.config/bspwm/bspwmrc` configuration file
- `startx` can properly initialize X11 session

### External Dependencies
- `pkgs.xorg.xinit` for startx command
- `pkgs.bspwm` for the window manager
- `pkgs.greetd.tuigreet` for non-auto-login greeter

## 8. Constraints and Limitations

### Technical Constraints
- greetd runs on a single TTY (vt=1 by default)
- X11 sessions require proper `DISPLAY` environment setup (handled by startx)
- Cannot use both greetd and SDDM simultaneously

---

**Document Status**: Implemented

**Last Updated**: 2026-02-03

**Version**: 1.0
