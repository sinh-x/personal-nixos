# BSPWM System Documentation

This documentation describes the BSPWM window manager configuration used on **Elderwood** and **Drgnfly** systems in this NixOS repository.

## Document Structure

| Document | Description |
|----------|-------------|
| [BSPWM Configuration](./bspwm-config.md) | Window manager, keybindings, workspace setup, window rules |

## Quick Facts

| Property | Value |
|----------|-------|
| Window Manager | BSPWM (X11) |
| Hotkey Daemon | sxhkd |
| Status Bar | Polybar |
| Launcher | Rofi |
| Compositor | Picom |
| Notification | Dunst |
| Primary Terminal | Ghostty |
| Primary Browser | Zen Browser (twilight) |
| Primary Editor | Neovim |
| File Manager | Thunar |

## Systems Using BSPWM

| System | Description | Primary Monitor |
|--------|-------------|-----------------|
| Elderwood | Desktop workstation | DP-1 |
| Drgnfly | Laptop | eDP-1 |

## Configuration Files

### NixOS System
- `modules/nixos/wm/bspwm/default.nix` - System packages and services

### Home Manager
- `modules/home/wm/bspwm/default.nix` - Home module (copies config directory)
- `modules/home/wm/bspwm/bspwm_config/` - All BSPWM configuration files

### Key Config Files

| File | Purpose |
|------|---------|
| `bspwmrc` | Main BSPWM configuration, window rules, autostart |
| `sxhkdrc` | Keybindings configuration |
| `scripts/external_rules.fish` | Dynamic window rules |
| `monitors-workspaces/*.fish` | Per-host monitor/workspace setup |

## Key Modules Enabled

**NixOS**: `modules.wm.bspwm`

**Home**: `sinh-x.wm.bspwm`

## Comparison with Hyprland

Both BSPWM and Hyprland configurations are kept in sync for:
- Default applications (terminal, browser, file manager)
- Workspace assignments for common applications
- Similar keybinding patterns where possible

See [Hyprland Configuration](../emberroot-system-documentation/hyprland-config.md) for comparison.

## Last Updated

2026-02-02
