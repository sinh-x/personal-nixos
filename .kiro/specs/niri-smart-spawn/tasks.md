# Niri Smart Spawn Implementation Tasks

## Task Overview

This document breaks down the implementation of the smart spawn feature into actionable tasks.

**Total Tasks**: 5 tasks in 2 phases

**Requirements Reference**: `requirements.md`

**Design Reference**: `design.md`

## Implementation Tasks

### Phase 1: Script Creation

- [ ] **1.1** Create smart_spawn script
  - **Description**: Create the `smart_spawn` bash script that implements monitor-aware workspace selection and application spawning
  - **Deliverables**:
    - `modules/home/wm/niri/niri_config/scripts/smart_spawn`
  - **Requirements**: All Monitor Detection and Workspace Selection requirements
  - **Implementation Details**:
    - Accept `terminal` or `browser` as argument
    - Use `niri msg --json outputs` to count monitors
    - Use `niri msg --json focused-output` to get current monitor
    - Implement workspace selection logic per design
    - Focus workspace then spawn application

- [ ] **1.2** Verify smart_spawn script functionality
  - **Description**: Test the script manually to ensure it works correctly before modifying config.kdl
  - **Deliverables**:
    - Verified script behavior in all scenarios
  - **Requirements**: All Workspace Selection requirements
  - **Test Cases**:
    - [ ] Script is executable (`chmod +x` applied)
    - [ ] `smart_spawn terminal` with 1 monitor → opens on `main-term`
    - [ ] `smart_spawn browser` with 1 monitor → opens on `main-browser`
    - [ ] `smart_spawn terminal` focused on eDP-1 with 2 monitors → opens on `ext-term`
    - [ ] `smart_spawn browser` focused on eDP-1 with 2 monitors → opens on `ext-browser`
    - [ ] `smart_spawn terminal` focused on external with 2 monitors → opens on `main-term`
    - [ ] `smart_spawn browser` focused on external with 2 monitors → opens on `main-browser`
    - [ ] Invalid argument shows usage message
  - **Note**: Run tests by executing the script directly from terminal before proceeding to Phase 2

### Phase 2: Configuration Updates

- [ ] **2.1** Remove terminal window rules
  - **Description**: Remove static window rules for terminal applications from config.kdl
  - **Deliverables**:
    - Modified `modules/home/wm/niri/niri_config/config.kdl`
  - **Requirements**: Configuration Cleanup Requirements
  - **Rules to Remove**:
    - `window-rule { match app-id=r#"(?i)(ghostty|alacritty|kitty|foot|wezterm|konsole)"# ... }`

- [ ] **2.2** Remove browser window rules
  - **Description**: Remove static window rules for browser applications from config.kdl
  - **Deliverables**:
    - Modified `modules/home/wm/niri/niri_config/config.kdl`
  - **Requirements**: Configuration Cleanup Requirements
  - **Rules to Remove**:
    - `window-rule { match app-id=r#"(?i)zen"# ... }`
    - `window-rule { match app-id=r#"(?i)firefox"# ... }`
    - `window-rule { match app-id=r#"(?i)chromium"# ... }`
    - `window-rule { match app-id=r#"(?i)google-chrome"# ... }`
    - `window-rule { match app-id=r#"(?i)brave"# ... }`
    - `window-rule { match app-id=r#"(?i)vivaldi"# ... }`

- [ ] **2.3** Update keybindings to use smart_spawn
  - **Description**: Modify terminal and browser keybindings to invoke the smart_spawn script instead of spawning directly
  - **Deliverables**:
    - Modified `modules/home/wm/niri/niri_config/config.kdl`
  - **Requirements**: Configuration Cleanup Requirements
  - **Keybindings to Update**:
    - `Mod+Return` → `spawn "bash" "-c" "~/.config/niri/scripts/smart_spawn terminal"`
    - `Mod+T` → `spawn "bash" "-c" "~/.config/niri/scripts/smart_spawn terminal"`
    - `Mod+Shift+W` → `spawn "bash" "-c" "~/.config/niri/scripts/smart_spawn browser"`

## Task Completion Criteria

Each task is considered complete when:
- [ ] All deliverables are implemented
- [ ] Code follows existing script patterns in the niri config
- [ ] Script is executable

## Git Tracking

**Branch**: feature/202602

---

**Task Status**: Not Started

**Overall Progress**: 0/5 tasks completed (0%)

**Last Updated**: 2026-02-06
