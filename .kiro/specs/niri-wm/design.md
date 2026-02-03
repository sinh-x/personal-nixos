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

## Current Implementation

### Monitor Setup

| Monitor | Identifier | Resolution | Position |
|---------|------------|------------|----------|
| Laptop (Main) | `LG Display 0x06AA Unknown` | 3840x2400@60Hz | x=0, y=0 |
| External | `MaxCom Technical Inc 0x1B1A 0x20230808` | 2560x1600@130Hz | x=3840, y=0 |

### Named Workspaces

#### Laptop Monitor (main-)
| Workspace | Keybind (Focus) | Keybind (Move) |
|-----------|-----------------|----------------|
| `main-browser` | `Mod+1` | `Mod+Shift+1` |
| `main-term` | `Mod+2` | `Mod+Shift+2` |
| `chat` | `Mod+3` | `Mod+Shift+3` |
| `email` | `Mod+4` | `Mod+Shift+4` |
| `main-code` | `Mod+5` | `Mod+Shift+5` |

#### External Monitor (ext-)
| Workspace | Keybind (Focus) | Keybind (Move) |
|-----------|-----------------|----------------|
| `ext-term` | `Mod+6` | `Mod+Shift+6` |
| `ext-code` | `Mod+7` | `Mod+Shift+7` |
| `ext-browser` | `Mod+8` | `Mod+Shift+8` |

### Window Rules (Auto-placement)

| App Category | Apps | Target Workspace |
|--------------|------|------------------|
| Terminal | ghostty, alacritty, kitty, foot, wezterm, konsole | `main-term` |
| Browser | zen, firefox, chromium, google-chrome, brave, vivaldi | `main-browser` |
| Code Editor | code, vscode, zed, jetbrains IDEs, sublime, atom | `main-code` |
| Email | thunderbird, evolution, geary, mailspring, kmail | `email` |
| Chat | discord, slack, telegram, signal, element, whatsapp, viber, skype, teams, zoom, wire, mattermost, zulip, etc. | `chat` |

### Keybindings Reference

#### Window Management
| Keybind | Action |
|---------|--------|
| `Mod+Q` | Close window |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen window |
| `Mod+Space` | Toggle floating |
| `Mod+O` | Toggle overview |

#### Navigation
| Keybind | Action |
|---------|--------|
| `Mod+H/L` | Focus column left/right |
| `Mod+J/K` | Focus window down/up |
| `Mod+,` | Focus monitor left |
| `Mod+.` | Focus monitor right |
| `Ctrl+Alt+Up/Down` | Focus workspace up/down |

#### Applications
| Keybind | Action |
|---------|--------|
| `Mod+Return` / `Mod+T` | Terminal (ghostty) |
| `Alt+F1` | App Launcher (rofi) |
| `Alt+F2` | Command Runner |
| `Mod+E` | File Manager (thunar) |
| `Mod+Shift+W` | Browser (zen-twilight) |

#### Rofi Menus
| Keybind | Action |
|---------|--------|
| `Mod+R` | Run as Root |
| `Mod+M` | Music Player |
| `Mod+N` | Network Manager |
| `Mod+B` | Bluetooth Manager |
| `Mod+X` | Power Menu |
| `Mod+A` | Screenshot Menu |
| `Mod+P` | Color Picker |
| `Ctrl+`` ` | Clipboard History |
| `Mod+/` | Show Hotkey Overlay |

#### Media & Hardware
| Keybind | Action |
|---------|--------|
| `XF86AudioRaiseVolume` | Volume Up |
| `XF86AudioLowerVolume` | Volume Down |
| `XF86AudioMute` | Mute Audio |
| `XF86MonBrightnessUp/Down` | Brightness control |
| `XF86Audio{Next,Prev,Play,Stop}` | Media control |

### Dependencies

#### System Packages (NixOS module)
- `xwayland-satellite` - X11 app support
- `showmethekey` - Key press overlay
- `waybar` - Status bar
- `rofi` - Application launcher
- `mako` - Notifications
- `wl-clipboard`, `cliphist` - Clipboard management
- `grim`, `slurp` - Screenshots
- `brightnessctl`, `pamixer` - Hardware control

#### Scripts
Copied from Hyprland to `~/.config/niri/scripts/` (not symlinked):
- `rofi_launcher`, `rofi_runner`, `rofi_asroot`
- `rofi_music`, `rofi_network`, `rofi_bluetooth`
- `rofi_powermenu`, `rofi_screenshot`
- `volume`, `brightness`, `colorpicker`

### Configuration Notes

- Config uses `hotkey-overlay-title` for descriptive labels in the hotkey overlay
- Window rules use case-insensitive regex matching: `r#"(?i)appname"#`
- XWayland support via `xwayland-satellite` (auto-started by niri)
- Monitor identifiers use manufacturer/model/serial for stability across ports
- Scripts reference `.config/niri` instead of `.config/hypr`

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
- [x] Terminal launches with Mod+Return
- [x] Rofi launcher opens with Mod+D
- [x] Window closes with Mod+Q
- [x] Named workspaces switch with Mod+1-8
- [x] Waybar displays correctly
- [x] Notifications work via mako
- [x] XWayland apps work (via xwayland-satellite)
- [x] Multi-monitor support with named workspaces
- [x] Window auto-placement rules

---

**Requirements Traceability**: This design addresses all requirements in requirements.md

**Review Status**: Implemented

**Last Updated**: 2026-02-03
