# Niri Smart Spawn Requirements

## 1. Introduction

This document specifies the requirements for a smart application spawning system in niri that dynamically selects the target workspace based on the current monitor configuration and focus.

**Purpose**: Replace static window rules for terminal and browser applications with a dynamic script that spawns applications on the appropriate workspace based on monitor context.

## 2. User Stories

### Multi-Monitor User
- **As a multi-monitor user**, I want applications to spawn on the OTHER monitor, so that I can keep my current view while opening new apps
- **As a multi-monitor user**, I want terminals and browsers to spawn on dedicated workspaces on the external monitor when I'm on the laptop screen (and vice versa), so that my workflow is distributed across screens

### Single-Monitor User
- **As a single-monitor user**, I want applications to spawn on the main workspaces, so that my workflow remains consistent when I don't have an external monitor connected

## 3. Acceptance Criteria

### Monitor Detection Requirements
- **WHEN** the system has only one monitor connected, **THEN** the script **SHALL** spawn applications on `main-*` workspaces
- **WHEN** the system has two monitors connected, **THEN** the script **SHALL** detect which monitor is currently focused

### Workspace Selection Requirements (Two Monitors)
- **WHEN** the user is focused on the main monitor (eDP-1) AND requests a terminal, **THEN** the script **SHALL** switch to `ext-term` workspace and spawn the terminal
- **WHEN** the user is focused on the main monitor (eDP-1) AND requests a browser, **THEN** the script **SHALL** switch to `ext-browser` workspace and spawn the browser
- **WHEN** the user is focused on an external monitor AND requests a terminal, **THEN** the script **SHALL** switch to `main-term` workspace and spawn the terminal
- **WHEN** the user is focused on an external monitor AND requests a browser, **THEN** the script **SHALL** switch to `main-browser` workspace and spawn the browser

### Workspace Selection Requirements (Single Monitor)
- **WHEN** only one monitor is connected AND the user requests a terminal, **THEN** the script **SHALL** switch to `main-term` workspace and spawn the terminal
- **WHEN** only one monitor is connected AND the user requests a browser, **THEN** the script **SHALL** switch to `main-browser` workspace and spawn the browser

### Configuration Cleanup Requirements
- **WHEN** the feature is implemented, **THEN** the static window rules for terminals **SHALL** be removed from config.kdl
- **WHEN** the feature is implemented, **THEN** the static window rules for browsers **SHALL** be removed from config.kdl
- **WHEN** the feature is implemented, **THEN** the keybindings for terminal/browser **SHALL** use the smart_spawn script

## 4. Technical Context

### Current State
- Window rules in `config.kdl` statically assign terminals to `main-term` and browsers to `main-browser`
- No conditional logic based on monitor configuration

### Target State
- A `smart_spawn` script handles terminal/browser spawning with monitor-aware logic
- Keybindings (`Mod+Return`, `Mod+T`, `Mod+Shift+W`) invoke the script
- Static window rules for terminal and browser apps are removed

### Dependencies
- `niri msg --json outputs` - Get list of connected monitors
- `niri msg --json focused-output` - Get currently focused monitor
- `niri msg action focus-workspace` - Switch to target workspace
- `jq` - Parse JSON output from niri

## 5. Applications

### Terminal Applications
- Default: `ghostty`
- Workspace names: `main-term`, `ext-term`

### Browser Applications
- Default: `zen-twilight`
- Workspace names: `main-browser`, `ext-browser`

---

**Document Status**: Draft

**Last Updated**: 2026-02-06
