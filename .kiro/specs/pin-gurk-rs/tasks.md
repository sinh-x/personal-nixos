# Install gurk-rs via cargo-binstall - Implementation Tasks

## Task Overview

This document tracks the implementation tasks for getting gurk-rs working on Emberroot.

**Requirements Reference**: `.kiro/specs/pin-gurk-rs/requirements.md`

**Design Reference**: `.kiro/specs/pin-gurk-rs/design.md`

## Implementation Tasks

### Phase 1: Initial Approach - Nixpkgs Pinning (Failed)

- [x] **1.1** Add pinned nixpkgs input to flake.nix
  - **Description**: Add `nixpkgs-gurk` input pointing to `nixos-24.11` stable branch
  - **Deliverables**: Modified `flake.nix` with new input
  - **Status**: Completed but ineffective - stable also has the bug

- [x] **1.2** Create gurk overlay
  - **Description**: Create `overlays/gurk/default.nix` following Snowfall conventions
  - **Deliverables**: New file `overlays/gurk/default.nix`
  - **Status**: Completed but build still fails

- [x] **1.3** Create NixOS module for gurk
  - **Description**: Create `modules/nixos/gurk/default.nix` with `modules.gurk.enable` option
  - **Deliverables**: New file `modules/nixos/gurk/default.nix`
  - **Status**: Completed, disabled (`modules.gurk.enable = false`)

- [x] **1.4** Test nixpkgs approach
  - **Description**: Run `sudo sys test` to verify build
  - **Status**: Failed - NIX_LDFLAGS error persists in both unstable and stable

### Phase 2: Alternative Approach - cargo-binstall (Success)

- [x] **2.1** Add cargo-binstall to system packages
  - **Description**: Add `cargo-binstall` to `environment.systemPackages` in Emberroot
  - **Deliverables**: Modified `systems/x86_64-linux/Emberroot/default.nix`
  - **Status**: Completed

- [x] **2.2** Configure PATH for cargo binaries
  - **Description**: Add `~/.cargo/bin` to `home.sessionPath` in home-manager
  - **Deliverables**: Modified `home/sinh/Emberroot.nix`
  - **Status**: Completed

### Phase 3: User Actions (Completed)

- [x] **3.1** Rebuild system
  - **Description**: Run `sudo sys rebuild` to apply changes
  - **Status**: Completed

- [x] **3.2** Install gurk-rs via cargo-binstall
  - **Description**: Run `cargo binstall gurk-rs`
  - **Status**: Completed

- [x] **3.3** Verify gurk-rs works
  - **Description**: Start new shell session and run `gurk`
  - **Status**: Completed - gurk-rs working

## Files Changed

### Modified
| File | Change |
|------|--------|
| `flake.nix` | Added `nixpkgs-gurk` input |
| `systems/x86_64-linux/Emberroot/default.nix` | Added cargo-binstall, set `modules.gurk.enable = false` |
| `home/sinh/Emberroot.nix` | Added `~/.cargo/bin` to sessionPath, disabled home gurk module |

### Created
| File | Purpose |
|------|---------|
| `overlays/gurk/default.nix` | Overlay to pin gurk-rs (disabled) |
| `modules/nixos/gurk/default.nix` | NixOS module for gurk (disabled) |

## Lessons Learned

1. **NIX_LDFLAGS bug** affects both nixos-unstable and nixos-24.11 stable
2. **cargo-binstall** is a reliable fallback for broken Rust packages in nixpkgs
3. **Infrastructure prepared** for when nixpkgs fixes the upstream issue

## Git Tracking

**Branch**: `feature/202601`

**Related Commits**:
- `4261ecf` - Added gurk module
- `a1d88c9` - Add gurk-rs via cargo-binstall and Kiro workflow system

**Pull Request**: N/A

---

**Task Status**: Completed

**Overall Progress**: 9/9 tasks completed (100%)

**Last Updated**: 2026-01-08
