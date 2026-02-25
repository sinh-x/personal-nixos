# Niri Window Manager Module Requirements

## 1. Introduction

This document specifies the requirements for adding Niri window manager support to the personal-nixos configuration. Niri is a scrollable-tiling Wayland compositor that provides an alternative to Hyprland with a unique infinite horizontal workspace paradigm.

**Architecture Overview**: Two NixOS modules (system + home-manager) following existing Hyprland patterns, with KDL-based configuration files.

## 2. User Stories

### System Administrator
- **As a sysadmin**, I want to enable Niri via a simple module option, so that I can quickly set up the window manager
- **As a sysadmin**, I want greetd integration with auto-login support, so that the system boots directly into Niri

### Desktop User
- **As a user**, I want familiar keybindings matching my Hyprland setup, so that I can switch between WMs without relearning shortcuts
- **As a user**, I want my rofi menus, waybar, and notification configs to work, so that I have a consistent experience
- **As a user**, I want window rules for my applications, so that windows open in the correct state

## 3. Acceptance Criteria

### NixOS Module Requirements
- **WHEN** `modules.wm.niri.enable = true`, **THEN** the system **SHALL** install Niri and required Wayland packages
- **WHEN** `modules.wm.niri.greetd.enable = true`, **THEN** the system **SHALL** configure greetd with Niri session
- **IF** `modules.wm.niri.greetd.autoLogin.enable = true`, **THEN** the system **SHALL** auto-login the specified user

### Home Module Requirements
- **WHEN** `sinh-x.wm.niri.enable = true`, **THEN** home-manager **SHALL** deploy Niri configuration files to `~/.config/niri/`
- **WHEN** config files are deployed, **THEN** the system **SHALL** include keybindings, window rules, and startup commands

### Compatibility Requirements
- **WHEN** Niri starts, **THEN** waybar **SHALL** display correctly
- **WHEN** Niri starts, **THEN** rofi menus **SHALL** function for app launching
- **WHEN** Niri starts, **THEN** mako notifications **SHALL** work

## 4. Feature Specifications

### Core Features
1. **NixOS Module**: System-level Niri setup with XDG portal, pipewire, polkit
2. **Home Module**: User configuration deployment
3. **Keybindings**: Matching Hyprland shortcuts (SUPER+Return, SUPER+D, etc.)
4. **Window Rules**: Floating, workspace assignment rules

### Shared Components (reuse from Hyprland)
1. **Rofi**: App launcher, power menu, network menu
2. **Waybar**: Status bar
3. **Mako**: Notifications
4. **Scripts**: Volume, brightness, screenshots

## 5. Success Criteria

- **WHEN** enabled on Drgnfly, **THEN** Niri **SHALL** start successfully via greetd
- **WHEN** using keybindings, **THEN** user **SHALL** be able to launch terminal, app launcher, and navigate workspaces
- **WHEN** building configuration, **THEN** `nix flake check` **SHALL** pass

## 6. Assumptions and Dependencies

### Technical Assumptions
- NixOS 24.11+ with `programs.niri.enable` available
- NVIDIA hybrid graphics compatibility (same as Hyprland)

### External Dependencies
- niri package from nixpkgs
- Shared Wayland tools (waybar, rofi, mako, etc.)

---

**Document Status**: Draft

**Last Updated**: 2026-02-02

**Version**: 1.0
