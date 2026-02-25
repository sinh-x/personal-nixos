# Niri Window Manager Module Implementation Tasks

## Task Overview

This document breaks down the implementation of the Niri window manager module into actionable coding tasks.

**Total Estimated Tasks**: 8 tasks organized into 4 phases

**Requirements Reference**: This implementation addresses requirements from `requirements.md`

**Design Reference**: Technical approach defined in `design.md`

**Test System**: Drgnfly

## Implementation Tasks

### Phase 1: NixOS Module

- [x] **1.1** Create NixOS Niri Module
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

- [x] **2.1** Create Home Manager Module Structure
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

- [x] **2.2** Create Main Niri Configuration
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

- [x] **3.1** Set Up Shared Rofi Configuration
  - **Description**: Copy or symlink rofi configs from Hyprland
  - **Deliverables**:
    - `modules/home/wm/niri/niri_config/rofi/` (symlink or copy)
  - **Implementation**:
    - Symlink to ../hyprland/hypr_config/rofi/
    - Or copy configs if modifications needed
  - **Requirements**: REQ-COMPAT-*
  - **Dependencies**: 2.1

- [x] **3.2** Set Up Shared Waybar Configuration
  - **Description**: Copy or symlink waybar configs from Hyprland
  - **Deliverables**:
    - `modules/home/wm/niri/niri_config/waybar/` (symlink or copy)
  - **Implementation**:
    - Symlink to ../hyprland/hypr_config/waybar/
    - May need minor adjustments for niri compatibility
  - **Requirements**: REQ-COMPAT-*
  - **Dependencies**: 2.1

- [x] **3.3** Set Up Shared Scripts and Mako
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

- [x] **4.1** Enable Module on Drgnfly
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

- [x] **4.2** Build and Functional Testing
  - **Description**: Test build and verify functionality
  - **Implementation**:
    1. Run `sudo sys test` - verify no build errors
    2. Run `sudo sys rebuild` - apply changes
    3. Reboot and test:
       - [x] Niri starts via greetd
       - [x] SUPER+Return opens terminal
       - [x] SUPER+D opens rofi
       - [x] SUPER+C closes window
       - [x] SUPER+1-8 switches named workspaces
       - [x] Waybar displays correctly with niri/workspaces module
       - [x] Mako notifications work
  - **Requirements**: REQ-SUCCESS-*
  - **Dependencies**: 4.1

### Phase 5: Waybar & Window Rules Refinement

- [x] **5.1** Configure Native Niri Waybar Support
  - **Description**: Update waybar to use native niri/workspaces module
  - **Deliverables**:
    - Updated `waybar/config` with correct include path
    - Updated `waybar/modules` with niri/workspaces module
    - Updated `waybar/style.css` with workspace styling
  - **Implementation**:
    - Replace hyprland/workspaces with niri/workspaces
    - Set `all-outputs: false` for per-monitor display
    - Add format-icons for named workspaces (browser, term, code, chat, email)
    - Fix all script paths from ~/.config/hypr/ to ~/.config/niri/
    - Update CSS with blue color scheme for focused/active states
  - **Requirements**: REQ-COMPAT-*
  - **Dependencies**: 4.2

- [x] **5.2** Add Application Window Rules
  - **Description**: Configure window rules for specific applications
  - **Deliverables**:
    - Updated `config.kdl` with new window rules
  - **Implementation**:
    - Super Productivity -> open on "email" workspace
    - Zoom main window -> fullscreen + focus on open
    - Zoom dialogs -> floating
    - Launch waybar via statusbar script for correct config
  - **Requirements**: REQ-WINDOW-*
  - **Dependencies**: 4.2

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

**Task Status**: Complete

**Current Phase**: Phase 5 (Refinement)

**Overall Progress**: 10/10 tasks completed (100%)

**Last Updated**: 2026-02-04

**Notes**:
- All core functionality tested and working
- Waybar updated with native niri/workspaces module support
- Per-monitor workspace display with custom icons
- Window rules added for Super Productivity and Zoom
- All script paths corrected from hypr to niri
