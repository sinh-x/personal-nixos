# Emberroot System Documentation

This documentation describes the complete software stack installed on the **Emberroot** system, a NixOS desktop workstation running the **Hyprland** Wayland compositor.

## Document Structure

| Document | Description |
|----------|-------------|
| [System Overview](./system-overview.md) | Hardware configuration, boot settings, core services |
| [Applications](./applications.md) | Complete list of installed applications by category |
| [Hyprland Configuration](./hyprland-config.md) | Window manager, keybindings, workspace setup |
| [Development Environment](./development.md) | Languages, tools, editors, and dev workflow |

## Quick Facts

| Property | Value |
|----------|-------|
| Hostname | `Emberroot` |
| Window Manager | Hyprland (Wayland) |
| Display Manager | greetd with tuigreet (auto-login) |
| Primary GPU | NVIDIA (proprietary drivers with PRIME sync) |
| Integrated GPU | Intel |
| Shell | Fish |
| Primary Editor | Neovim (sinh-x-nixvim) |
| Primary Browser | Zen Browser (twilight) |
| Primary Terminal | Kitty |

## Configuration Files

### NixOS System
- `systems/x86_64-linux/Emberroot/default.nix` - Main system configuration
- `systems/x86_64-linux/Emberroot/hardware-configuration.nix` - Hardware config

### Home Manager
- `home/sinh/Emberroot.nix` - User-specific configuration
- `home/sinh/global/default.nix` - Shared home config

### Key Modules Enabled
- **NixOS**: `modules.wm.hyprland`, `modules.docker`, `modules.gcloud`, `modules.python`, `modules.fcitx5`
- **Home**: `sinh-x.wm.hyprland`, `sinh-x.coding.*`, `sinh-x.apps.*`, `sinh-x.cli-apps.*`

## Last Updated

2026-01-28
