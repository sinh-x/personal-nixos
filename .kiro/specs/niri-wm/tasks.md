# Niri Window Manager Module Implementation Tasks

## Task Overview

This document breaks down the implementation of the Niri window manager module into actionable coding tasks.

**Total Estimated Tasks**: 8 tasks organized into 4 phases

**Requirements Reference**: This implementation addresses requirements from `requirements.md`

**Design Reference**: Technical approach defined in `design.md`

**Test System**: Drgnfly

## Implementation Tasks

### Phase 1: NixOS Module

- [ ] **1.1** Create NixOS Niri Module
  - **Description**: Create system-level module for Niri window manager
  - **Deliverables**:
    - `modules/nixos/wm/niri/default.nix`
  - **Implementation**:
    - `programs.niri.enable = true`
    - XDG portal setup (wlr, gtk)
    - Pipewire audio services
    - Polkit authentication agent
    - Session variables for Wayland/NVIDIA
    - System packages (waybar, rofi, mako, grim, slurp, etc.)
    - greetd display manager configuration
    - Font configuration
  - **Requirements**: REQ-NIXOS-*
  - **Dependencies**: None

### Phase 2: Home Module

- [ ] **2.1** Create Home Manager Module Structure
  - **Description**: Create home module with options and file deployment
  - **Deliverables**:
    - `modules/home/wm/niri/default.nix`
  - **Implementation**:
    - Define `sinh-x.wm.niri` options
    - Monitor configuration options
    - Deploy niri_config/ to ~/.config/niri/
    - Install user packages (jq, socat)
  - **Requirements**: REQ-HOME-*
  - **Dependencies**: 1.1

- [ ] **2.2** Create Main Niri Configuration
  - **Description**: Create KDL configuration file with all settings
  - **Deliverables**:
    - `modules/home/wm/niri/niri_config/config.kdl`
  - **Implementation**:
    - Input configuration (keyboard, touchpad)
    - Layout settings (gaps 16, borders, focus ring)
    - Keybindings matching Hyprland shortcuts
    - Window rules for floating apps
    - Workspace configuration
    - Startup commands (waybar, mako, etc.)
  - **Requirements**: REQ-KEYBIND-*, REQ-WINDOW-*
  - **Dependencies**: 2.1

### Phase 3: Shared Configurations

- [ ] **3.1** Set Up Shared Rofi Configuration
  - **Description**: Copy or symlink rofi configs from Hyprland
  - **Deliverables**:
    - `modules/home/wm/niri/niri_config/rofi/` (symlink or copy)
  - **Implementation**:
    - Symlink to ../hyprland/hypr_config/rofi/
    - Or copy configs if modifications needed
  - **Requirements**: REQ-COMPAT-*
  - **Dependencies**: 2.1

- [ ] **3.2** Set Up Shared Waybar Configuration
  - **Description**: Copy or symlink waybar configs from Hyprland
  - **Deliverables**:
    - `modules/home/wm/niri/niri_config/waybar/` (symlink or copy)
  - **Implementation**:
    - Symlink to ../hyprland/hypr_config/waybar/
    - May need minor adjustments for niri compatibility
  - **Requirements**: REQ-COMPAT-*
  - **Dependencies**: 2.1

- [ ] **3.3** Set Up Shared Scripts and Mako
  - **Description**: Copy or symlink scripts and mako from Hyprland
  - **Deliverables**:
    - `modules/home/wm/niri/niri_config/scripts/`
    - `modules/home/wm/niri/niri_config/mako/`
  - **Implementation**:
    - Symlink to ../hyprland/hypr_config/scripts/
    - Symlink to ../hyprland/hypr_config/mako/
    - Create niri_startup script
  - **Requirements**: REQ-COMPAT-*
  - **Dependencies**: 2.1

### Phase 4: Testing & Integration

- [ ] **4.1** Enable Module on Drgnfly
  - **Description**: Add niri configuration to Drgnfly system
  - **Deliverables**:
    - Updates to `systems/x86_64-linux/Drgnfly/default.nix`
    - Updates to `home/sinh/Drgnfly.nix`
  - **Implementation**:
    ```nix
    # System config
    modules.wm.niri = {
      enable = true;
      greetd.enable = true;
      greetd.autoLogin.enable = true;
    };

    # Home config
    sinh-x.wm.niri = {
      enable = true;
      monitors.primary = "eDP-1";
    };
    ```
  - **Requirements**: REQ-SUCCESS-*
  - **Dependencies**: 1.1, 2.2, 3.1, 3.2, 3.3

- [ ] **4.2** Build and Functional Testing
  - **Description**: Test build and verify functionality
  - **Implementation**:
    1. Run `sudo sys test` - verify no build errors
    2. Run `sudo sys rebuild` - apply changes
    3. Reboot and test:
       - [ ] Niri starts via greetd
       - [ ] SUPER+Return opens terminal
       - [ ] SUPER+D opens rofi
       - [ ] SUPER+C closes window
       - [ ] SUPER+1-0 switches workspaces
       - [ ] Waybar displays correctly
       - [ ] Mako notifications work
  - **Requirements**: REQ-SUCCESS-*
  - **Dependencies**: 4.1

## Task Guidelines

### Task Completion Criteria
Each task is considered complete when:
- [ ] All deliverables are created
- [ ] Code follows project patterns (Snowfall Lib conventions)
- [ ] Module evaluates without errors (`nix flake check`)

### Task Dependencies
```
1.1 (NixOS Module)
     ↓
2.1 (Home Module) → 2.2 (config.kdl)
     ↓
3.1, 3.2, 3.3 (Shared Configs)
     ↓
4.1 (Enable on Drgnfly) → 4.2 (Testing)
```

## Progress Tracking

### Milestone Checkpoints
- **Milestone 1**: Phase 1 Complete - NixOS module created
- **Milestone 2**: Phase 2 Complete - Home module and config.kdl created
- **Milestone 3**: Phase 3 Complete - Shared configs linked
- **Milestone 4**: Phase 4 Complete - Tested on Drgnfly

## Git Tracking

**Branch**: feature/202602

---

**Task Status**: Not Started

**Current Phase**: Phase 1

**Overall Progress**: 0/8 tasks completed (0%)

**Last Updated**: 2026-02-02
