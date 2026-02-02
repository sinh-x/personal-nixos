# Niri Window Manager Module Design Document

## Overview

Create NixOS and home-manager modules for Niri WM, following the established Hyprland module patterns in this repository. Niri is a scrollable-tiling Wayland compositor that arranges windows in an infinite horizontal desktop.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     NixOS System                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  modules/nixos/wm/niri/default.nix                  │   │
│  │  - programs.niri.enable                              │   │
│  │  - XDG portal, pipewire, polkit                     │   │
│  │  - greetd display manager                           │   │
│  │  - System packages (waybar, rofi, mako, etc.)       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Home Manager                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  modules/home/wm/niri/default.nix                   │   │
│  │  - Deploy niri_config/ to ~/.config/niri/           │   │
│  │  - Monitor configuration options                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                              │
│                              ▼                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  niri_config/                                       │   │
│  │  ├── config.kdl (main niri config)                  │   │
│  │  ├── scripts/ (startup, utilities)                  │   │
│  │  ├── rofi/ (shared with hyprland)                   │   │
│  │  ├── waybar/ (shared with hyprland)                 │   │
│  │  └── mako/ (shared with hyprland)                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Module Structure

```
modules/
├── nixos/wm/niri/
│   └── default.nix          # System module (modules.wm.niri)
└── home/wm/niri/
    ├── default.nix          # Home module (sinh-x.wm.niri)
    └── niri_config/
        ├── config.kdl       # Main Niri configuration
        ├── scripts/         # Niri-specific and shared scripts
        ├── rofi/            # Symlink from hyprland
        ├── waybar/          # Symlink from hyprland
        └── mako/            # Symlink from hyprland
```

## Components and Interfaces

### NixOS Module Interface

```nix
options.modules.wm.niri = {
  enable = lib.mkEnableOption "niri";

  greetd = {
    enable = lib.mkEnableOption "greetd display manager with niri";

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

### Home Module Interface

```nix
options.${namespace}.wm.niri = {
  enable = mkEnableOption "Niri config using hm";

  monitors = {
    primary = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Primary monitor name (e.g., eDP-1). Auto-detected if null.";
    };
  };
};
```

### Configuration Mapping (Hyprland → Niri KDL)

| Hyprland | Niri KDL |
|----------|----------|
| `bind = SUPER, Return, exec, ghostty` | `Mod+Return { spawn "ghostty"; }` |
| `bind = SUPER, D, exec, rofi -show drun` | `Mod+D { spawn "rofi" "-show" "drun"; }` |
| `bind = SUPER, C, killactive` | `Mod+C { close-window; }` |
| `bind = SUPER, F, fullscreen, 0` | `Mod+F { maximize-column; }` |
| `bind = SUPER, Space, togglefloating` | `Mod+Space { toggle-window-floating; }` |
| `bind = SUPER, left, movefocus, l` | `Mod+Left { focus-column-left; }` |
| `bind = SUPER, right, movefocus, r` | `Mod+Right { focus-column-right; }` |
| `bind = SUPER, 1, workspace, 1` | `Mod+1 { focus-workspace 1; }` |
| `bind = SUPER_SHIFT, 1, movetoworkspace, 1` | `Mod+Shift+1 { move-window-to-workspace 1; }` |
| `windowrule = float, class:pavucontrol` | `window-rule { match app-id="pavucontrol"; open-floating true; }` |

### Data Models

#### Niri KDL Configuration Structure

```kdl
// Input configuration
input {
    keyboard {
        xkb { layout "us" }
    }
    touchpad {
        tap
        natural-scroll
    }
}

// Output/monitor configuration
output "eDP-1" {
    mode "3840x2400"
    scale 1.0
}

// Layout settings
layout {
    gaps 16
    focus-ring { width 2; active-color "#50FA7B"; }
    border { width 2; active-color "#BD93F9"; }
}

// Keybindings
binds {
    Mod+Return { spawn "ghostty"; }
    Mod+D { spawn "rofi" "-show" "drun"; }
    Mod+C { close-window; }
}

// Window rules
window-rule {
    match app-id="pavucontrol"
    open-floating true
}

// Startup
spawn-at-startup "waybar"
spawn-at-startup "mako"
```

## Platform-Specific Considerations

### NVIDIA Hybrid Graphics (Drgnfly)

Session variables required for NVIDIA compatibility:

```nix
environment.sessionVariables = {
  WLR_NO_HARDWARE_CURSORS = "1";
  NIXOS_OZONE_WL = "1";
  XDG_CURRENT_DESKTOP = "niri";
  XDG_SESSION_TYPE = "wayland";
  XDG_SESSION_DESKTOP = "niri";
  LIBVA_DRIVER_NAME = "nvidia";
  NVD_BACKEND = "direct";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
};
```

### Shared Components

These components from the Hyprland config can be reused:
- **rofi/**: All rofi themes and launcher configs
- **waybar/**: Status bar config (may need minor adjustments)
- **mako/**: Notification daemon config
- **scripts/**: volume, brightness, colorpicker, rofi_* scripts

## Testing Strategy

### Build Test
```bash
sudo sys test  # Verify module evaluates without errors
```

### Boot Test
1. Enable Niri in Drgnfly configs
2. Rebuild: `sudo sys rebuild`
3. Reboot and verify greetd starts Niri

### Functional Test
- [ ] Terminal launches with SUPER+Return
- [ ] Rofi launcher opens with SUPER+D
- [ ] Window closes with SUPER+C
- [ ] Workspaces switch with SUPER+1-0
- [ ] Waybar displays correctly
- [ ] Notifications work via mako

---

**Requirements Traceability**: This design addresses all requirements in requirements.md

**Review Status**: Draft

**Last Updated**: 2026-02-02
