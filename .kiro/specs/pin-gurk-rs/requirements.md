# Install gurk-rs via cargo-binstall - Requirements

## 1. Introduction

This document specifies the requirements for installing gurk-rs (Signal Messenger terminal client) on the Emberroot system. The nixpkgs package is broken with a `NIX_LDFLAGS` error, so an alternative approach using cargo-binstall was chosen.

**Problem**: nixos-unstable gurk-rs fails with:
```
error: The `env` attribute set can only contain derivation, string, boolean or integer attributes. The `NIX_LDFLAGS` attribute is of type list.
```

**Solution**: Use cargo-binstall to download pre-built binaries from GitHub releases instead of building from nixpkgs.

## 2. User Stories

### System Administrator
- **As a NixOS user**, I want gurk-rs (Signal client) available on my system, so that I can use Signal from the terminal
- **As a NixOS user**, I want an easy way to install Rust binaries from GitHub, so that I can bypass broken nixpkgs packages
- **As a NixOS user**, I want cargo binaries in my PATH automatically, so that I don't have to manually configure PATH

## 3. Acceptance Criteria

### Installation Requirements
- **WHEN** `cargo binstall gurk-rs` is run, **THEN** gurk-rs **SHALL** be downloaded and installed to `~/.cargo/bin`
- **WHEN** a new shell session starts, **THEN** `~/.cargo/bin` **SHALL** be in the PATH

### System Build Requirements
- **WHEN** `sudo sys rebuild` is run, **THEN** the system **SHALL** build successfully
- **WHEN** the system is rebuilt, **THEN** cargo-binstall **SHALL** be available as a system command

## 4. Technical Approach

### Final Implementation
- **cargo-binstall**: Added to `environment.systemPackages` in Emberroot system config
- **PATH configuration**: Added `~/.cargo/bin` to `home.sessionPath` in home-manager
- **NixOS module (disabled)**: Infrastructure created but disabled (`modules.gurk.enable = false`)

### Approaches Attempted (Failed)
1. **Pin nixpkgs to stable**: Created overlay with `nixpkgs-gurk` input - still failed to build
2. **NixOS module**: Created `modules/nixos/gurk/default.nix` - build failed due to upstream issue

## 5. Success Criteria

- [x] System builds without errors
- [x] cargo-binstall is available after rebuild
- [x] `~/.cargo/bin` is in PATH after login
- [x] `gurk` command works after `cargo binstall gurk-rs`

## 6. Assumptions and Dependencies

### Technical Assumptions
- gurk-rs has pre-built binaries available on GitHub releases
- cargo-binstall can find and download the correct binary for x86_64-linux

### External Dependencies
- GitHub releases for gurk-rs
- cargo-binstall package from nixpkgs (working)

## 7. Artifacts Created

### Files Modified
- `systems/x86_64-linux/Emberroot/default.nix` - Added cargo-binstall to systemPackages
- `home/sinh/Emberroot.nix` - Added `~/.cargo/bin` to sessionPath

### Files Created (Infrastructure for future use)
- `flake.nix` - Added `nixpkgs-gurk` input (can be removed if not needed)
- `overlays/gurk/default.nix` - Overlay for pinned gurk-rs (disabled)
- `modules/nixos/gurk/default.nix` - NixOS module for gurk (disabled)

---

**Document Status**: Approved

**Last Updated**: 2026-01-08

**Version**: 2.0
