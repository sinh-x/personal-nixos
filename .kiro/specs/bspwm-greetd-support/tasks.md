# BSPWM greetd and Monitor/Workspace Implementation Tasks

## Task Overview

This document breaks down the implementation of:
1. greetd display manager support for BSPWM
2. Declarative monitor/workspace configuration for BSPWM home module

**Total Tasks**: 10 tasks organized into 5 phases

**Requirements Reference**: `requirements.md`

**Design Reference**: `design.md`

## Implementation Tasks

### Phase 1: greetd Module Enhancement

- [x] **1.1** Add greetd options to BSPWM NixOS module
  - **Description**: Extend the BSPWM module with greetd configuration options matching Hyprland's pattern
  - **Deliverables**:
    - Modified `modules/nixos/wm/bspwm/default.nix` with new options
  - **Requirements**: Module Configuration Requirements
  - **Dependencies**: None

- [x] **1.2** Implement greetd service configuration
  - **Description**: Add conditional greetd configuration that launches X11 with BSPWM
  - **Deliverables**:
    - greetd service configuration in `modules/nixos/wm/bspwm/default.nix`
    - Support for both auto-login and tuigreet modes
  - **Requirements**: X11 Session Requirements
  - **Dependencies**: Task 1.1

### Phase 2: System Configuration (greetd)

- [x] **2.1** Update Drgnfly system configuration
  - **Description**: Switch Drgnfly from Hyprland to BSPWM with greetd auto-login
  - **Deliverables**:
    - Modified `systems/x86_64-linux/Drgnfly/default.nix`
  - **Requirements**: Compatibility Requirements
  - **Dependencies**: Tasks 1.1, 1.2

- [x] **2.2** Update Drgnfly home configuration
  - **Description**: Enable BSPWM home module and disable Hyprland
  - **Deliverables**:
    - Modified `home/sinh/Drgnfly.nix`
  - **Requirements**: Compatibility Requirements
  - **Dependencies**: Task 2.1

### Phase 3: Monitor/Workspace Home Module Enhancement

- [x] **3.1** Add monitor/workspace options to BSPWM home module
  - **Description**: Extend the BSPWM home module with declarative monitor and workspace options
  - **Deliverables**:
    - Modified `modules/home/wm/bspwm/default.nix` with new options:
      - `monitors.primary`
      - `monitors.externalPosition`
      - `monitors.externalMaxResolution`
      - `workspaces.distribution`
  - **Requirements**: Monitor Configuration Requirements
  - **Dependencies**: None

- [x] **3.2** Generate monitor-management.fish script from Nix
  - **Description**: Create a Nix-generated version of monitor-management.fish that interpolates configuration values
  - **Deliverables**:
    - Generated script at `~/.config/bspwm/scripts/monitor-management.fish`
    - Nix variables interpolated into script
  - **Requirements**: Monitor Configuration Requirements, Workspace Distribution Requirements
  - **Dependencies**: Task 3.1

- [x] **3.3** Remove host-specific monitor scripts
  - **Description**: Replace per-host scripts (Drgnfly.fish, Emberroot.fish, etc.) with the generated universal script
  - **Deliverables**:
    - Updated bspwmrc to call generic script
    - Host-specific scripts filtered out via `bspwmConfigFilter` in Nix
  - **Requirements**: Compatibility Requirements
  - **Dependencies**: Task 3.2

### Phase 4: Host Configuration (Monitors)

- [x] **4.1** Update Drgnfly home config with monitor options
  - **Description**: Add declarative monitor/workspace configuration for Drgnfly
  - **Deliverables**:
    - Modified `home/sinh/Drgnfly.nix` with monitor options:
      - `primary = "eDP-1"`
      - `externalPosition = "left"`
      - `workspaces.distribution = "split"`
  - **Requirements**: Monitor Configuration Requirements
  - **Dependencies**: Tasks 3.1, 3.2

### Phase 5: Verification

- [ ] **5.1** Test greetd and basic BSPWM startup
  - **Description**: Rebuild NixOS and verify BSPWM session starts correctly with auto-login
  - **Deliverables**:
    - Successful `sudo sys test` or `sudo sys rebuild`
    - Working BSPWM desktop after reboot
  - **Requirements**: All greetd requirements
  - **Dependencies**: Tasks 2.1, 2.2

- [ ] **5.2** Test monitor hotplug and workspace configuration
  - **Description**: Test external monitor connection and workspace distribution
  - **Deliverables**:
    - Verify single monitor: workspaces 1-10
    - Verify dual monitor: workspaces distributed per strategy
    - Verify hotplug reconfiguration works
  - **Requirements**: Monitor Configuration Requirements, Workspace Distribution Requirements
  - **Dependencies**: Tasks 4.1, 5.1

## Task Completion Criteria

Each task is considered complete when:
- [x] All deliverables are implemented and functional
- [x] Configuration follows existing module patterns (Hyprland reference)
- [x] No NixOS evaluation errors

## Git Tracking

**Branch**: `feature/202602`

**Related Commits**:
- Pending: greetd support for BSPWM module
- Pending: Drgnfly WM switch to BSPWM
- Pending: Monitor/workspace declarative configuration

---

**Task Status**: In Progress

**Current Phase**: Phase 5 - Verification

**Overall Progress**: 8/10 tasks completed (80%)

**Milestones**:
- [x] Phase 1: greetd NixOS module enhancement
- [x] Phase 2: System configuration (greetd)
- [x] Phase 3: Monitor/workspace home module enhancement
- [x] Phase 4: Host configuration (monitors)
- [ ] Phase 5: Verification

**Last Updated**: 2026-02-03
