# Shared WiFi Configuration Implementation Tasks

## Task Overview

This document breaks down the implementation of the shared WiFi configuration module into actionable tasks.

**Total Tasks**: 9 tasks organized into 3 phases

**Requirements Reference**: `requirements.md`

**Design Reference**: `design.md`

## Implementation Tasks

### Phase 1: Create Shared Module

- [x] **1.1** Create WiFi module directory and file
  - **Description**: Create the new module at `modules/nixos/wifi/default.nix` with basic structure
  - **Deliverables**:
    - `modules/nixos/wifi/default.nix` with options and empty networks
  - **Requirements**: Module Structure Requirements
  - **Dependencies**: None

- [x] **1.2** Add all shared networks to module
  - **Description**: Copy all 59+ networks from Emberroot's wifi-networks.nix into the module's `sharedNetworks` attribute set
  - **Deliverables**:
    - Complete `sharedNetworks` attribute set with all networks
  - **Requirements**: Network Configuration Requirements
  - **Dependencies**: 1.1

- [x] **1.3** Migrate hardcoded passwords to external refs
  - **Description**: Change `psk = "..."` to `pskRaw = "ext:keyname"` for ROOM NHA NOI and Homestay in Tay Ninh
  - **Deliverables**:
    - Updated network entries using `pskRaw`
  - **Requirements**: Security Requirements
  - **Dependencies**: 1.2

### Phase 2: Update SOPS Secrets

- [x] **2.1** Add new WiFi credentials to secrets.yaml
  - **Description**: Add `roomnhanoi` and `homestaytayninh` keys to the wifi/credentials section in secrets.yaml using `sops secrets/secrets.yaml`
  - **Deliverables**:
    - Updated `secrets/secrets.yaml` with new credentials
  - **Requirements**: Security Requirements
  - **Dependencies**: 1.3

### Phase 3: Migrate Hosts

- [x] **3.1** Update Emberroot configuration
  - **Description**: Remove `./wifi-networks.nix` import, add `modules.wifi.enable = true`
  - **Deliverables**:
    - Modified `systems/x86_64-linux/Emberroot/default.nix`
  - **Requirements**: Module Structure Requirements
  - **Dependencies**: 2.1

- [x] **3.2** Update Drgnfly configuration
  - **Description**: Remove `./wifi-networks.nix` import, add `modules.wifi.enable = true`
  - **Deliverables**:
    - Modified `systems/x86_64-linux/Drgnfly/default.nix`
  - **Requirements**: Module Structure Requirements
  - **Dependencies**: 2.1

- [x] **3.3** Update Elderwood configuration
  - **Description**: Remove inline `networking.wireless` config (keep static IP), add `modules.wifi.enable = true`
  - **Deliverables**:
    - Modified `systems/x86_64-linux/Elderwood/default.nix`
  - **Requirements**: Module Structure Requirements
  - **Dependencies**: 2.1

- [x] **3.4** Delete old wifi-networks.nix files
  - **Description**: Remove the now-unused wifi-networks.nix files from Emberroot and Drgnfly
  - **Deliverables**:
    - Deleted `systems/x86_64-linux/Emberroot/wifi-networks.nix`
    - Deleted `systems/x86_64-linux/Drgnfly/wifi-networks.nix`
  - **Requirements**: Maintainability
  - **Dependencies**: 3.1, 3.2

- [x] **3.5** Test and verify
  - **Description**: Build all three host configurations to verify they compile successfully
  - **Deliverables**:
    - Successful `nix build` for all three hosts
    - `sudo sys test` on current host (Emberroot)
  - **Requirements**: Success Criteria
  - **Dependencies**: 3.4

## Task Completion Criteria

Each task is considered complete when:
- [ ] All deliverables are implemented
- [ ] NixOS configuration builds without errors
- [ ] Changes follow existing module patterns in the codebase

## Git Tracking

**Branch**: `feature/202601`

**Related Commits**:
- `fd62340` - Add shared WiFi module with SOPS integration

**Verified**: `sudo sys test` passed on Emberroot

---

**Task Status**: Completed

**Current Phase**: All phases complete

**Overall Progress**: 9/9 tasks completed (100%)

**Last Updated**: 2026-01-13
