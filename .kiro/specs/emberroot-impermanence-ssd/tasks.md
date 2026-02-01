# Emberroot Impermanence SSD Upgrade Implementation Tasks

## Task Overview

This document breaks down the implementation of the Emberroot impermanence SSD upgrade into actionable tasks. Each task is designed to be completed incrementally, with clear deliverables and requirements traceability.

**Total Tasks**: 25 tasks organized into 5 phases

**Requirements Reference**: This implementation addresses requirements from `requirements.md`

**Design Reference**: Technical approach defined in `design.md`

## Implementation Tasks

### Phase 1: Preparation & Configuration

- [ ] **1.1** Add impermanence flake input
  - **Description**: Add the nix-community/impermanence flake as an input to the project's flake.nix
  - **Deliverables**:
    - Modified `flake.nix` with impermanence input
    - Verify `nix flake check` passes
  - **Requirements**: Flake input requirement from design.md
  - **Dependencies**: None

- [ ] **1.2** Create NixOS impermanence module
  - **Description**: Create the NixOS module that configures system-level impermanence with tmpfs root and system persistence paths
  - **Deliverables**:
    - `modules/nixos/impermanence/default.nix`
    - Module follows Snowfall Lib patterns with `modules.impermanence` namespace
  - **Requirements**: Filesystem Requirements, Persistence Requirements
  - **Dependencies**: 1.1

- [ ] **1.3** Create home-manager impermanence module
  - **Description**: Create the home-manager module that configures user-level persistence for home directory
  - **Deliverables**:
    - `modules/home/impermanence/default.nix`
    - Module follows Snowfall Lib patterns with `sinh-x.impermanence` namespace
  - **Requirements**: Home Directory Requirements
  - **Dependencies**: 1.1

- [ ] **1.4** Cleanup and update virtualization setup
  - **Description**: Remove unused Genymotion and VirtualBox, add QEMU/KVM + virt-manager for NixOS VM testing
  - **Deliverables**:
    - Remove `modules.genymotion.enable = true` from `systems/x86_64-linux/Emberroot/default.nix`
    - Remove `linuxPackages.virtualboxGuestAdditions` from systemPackages
    - Remove `"virtualbox"` from `services.xserver.videoDrivers`
    - Add `virtualisation.libvirtd.enable = true`
    - Add `programs.virt-manager.enable = true`
    - Add `"libvirtd"` to user's extraGroups
    - Verify system builds successfully
  - **Requirements**: VM support for testing impermanence config
  - **Dependencies**: None

- [ ] **1.5** Audit current system state
  - **Description**: Run discovery script to identify all stateful data that needs persistence. Document findings.
  - **Deliverables**:
    - State discovery script in scratchpad
    - Documented list of all paths requiring persistence
    - Updated persistence lists in modules if needed
  - **Requirements**: All Persistence Requirements
  - **Dependencies**: None (can run in parallel with 1.1-1.4)

- [ ] **1.6** Create Emberroot impermanence configuration
  - **Description**: Update Emberroot system and home configs to enable impermanence modules (disabled by default, ready to enable)
  - **Deliverables**:
    - Updated `systems/x86_64-linux/Emberroot/default.nix`
    - Updated `home/sinh/Emberroot.nix`
    - Configuration compiles with `nix build`
  - **Requirements**: All requirements
  - **Dependencies**: 1.2, 1.3

- [ ] **1.7** Test configuration in VM
  - **Description**: Create a QEMU VM with the impermanence configuration to validate boot and persistence before hardware migration
  - **Deliverables**:
    - VM test script
    - Documented test results
    - Any config fixes discovered
  - **Requirements**: Boot Requirements, Success Criteria
  - **Dependencies**: 1.5

### Phase 2: Backup & Preparation

- [ ] **2.1** Create full system backup
  - **Description**: Create complete backup of current Emberroot system including /nix, /home, /var/lib, and /etc state
  - **Deliverables**:
    - Backup stored on external drive or network storage
    - Backup verification (test restore of sample files)
    - Backup manifest documenting contents
  - **Requirements**: Migration Features (Backup Strategy)
  - **Dependencies**: 1.4

- [ ] **2.2** Document current partition UUIDs and layout
  - **Description**: Record current disk layout, UUIDs, and mount points for reference during migration
  - **Deliverables**:
    - Documented current `lsblk`, `blkid` output
    - Current `/etc/fstab` saved
    - Current hardware-configuration.nix preserved
  - **Requirements**: Rollback Plan
  - **Dependencies**: None

- [ ] **2.3** Prepare NixOS USB installer
  - **Description**: Create bootable NixOS USB with latest installer for recovery and installation
  - **Deliverables**:
    - Bootable NixOS USB drive
    - Verified boot from USB works on Emberroot
  - **Requirements**: Boot Requirements (recovery options)
  - **Dependencies**: None

- [ ] **2.4** Prepare partition script
  - **Description**: Create script with exact partitioning commands for the new 2TB SSD
  - **Deliverables**:
    - `partition-ssd.sh` script with exact commands
    - Script reviewed and validated
  - **Requirements**: Partition Requirements
  - **Dependencies**: None

### Phase 3: Hardware & Partitioning

- [ ] **3.1** Install new 2TB SSD
  - **Description**: Physically install the new NVMe SSD in Emberroot (may require keeping old SSD temporarily)
  - **Deliverables**:
    - New SSD installed and detected by system
    - Verify with `lsblk` from live USB
  - **Requirements**: Hardware Requirements
  - **Dependencies**: 2.1, 2.2, 2.3

- [ ] **3.2** Partition new SSD
  - **Description**: Create partition layout on new SSD: EFI (512MB), /nix (350GB), /persist (1.6TB), swap (64GB)
  - **Deliverables**:
    - Partitions created per design.md layout
    - Filesystems formatted (vfat, ext4, swap)
    - UUIDs recorded
  - **Requirements**: Partition Requirements
  - **Dependencies**: 3.1, 2.4

- [ ] **3.3** Mount partitions for installation
  - **Description**: Mount the new partitions in preparation for NixOS installation
  - **Deliverables**:
    - `/mnt/nix` mounted
    - `/mnt/persist` mounted
    - `/mnt/boot/efi` mounted
    - tmpfs mounted at `/mnt`
  - **Requirements**: Filesystem Requirements
  - **Dependencies**: 3.2

### Phase 4: Installation & Data Migration

- [ ] **4.1** Copy Nix store from backup
  - **Description**: Restore /nix/store from backup to new /nix partition to preserve existing derivations
  - **Deliverables**:
    - /nix/store copied to new partition
    - Permissions verified
    - Nix database intact
  - **Requirements**: Performance Requirements (fast builds)
  - **Dependencies**: 3.3, 2.1

- [ ] **4.2** Update hardware-configuration.nix with new UUIDs
  - **Description**: Generate or update hardware-configuration.nix with new partition UUIDs and tmpfs root
  - **Deliverables**:
    - Updated `hardware-configuration.nix` with correct UUIDs
    - tmpfs root configuration in place
    - neededForBoot flags set correctly
  - **Requirements**: Filesystem Requirements, Boot Requirements
  - **Dependencies**: 3.2

- [ ] **4.3** Run nixos-install
  - **Description**: Install NixOS to the new SSD with impermanence configuration
  - **Deliverables**:
    - Successful `nixos-install --root /mnt --flake .#Emberroot`
    - Bootloader installed
    - Initial boot configuration present
  - **Requirements**: Boot Requirements
  - **Dependencies**: 4.1, 4.2, 1.5

- [ ] **4.4** Create persist directory structure
  - **Description**: Create the directory structure under /persist for system and home persistence
  - **Deliverables**:
    - `/persist/system/` structure created
    - `/persist/home/sinh/` structure created
    - Correct ownership and permissions set
  - **Requirements**: Persistence Requirements
  - **Dependencies**: 4.3

- [ ] **4.5** Migrate system state to /persist
  - **Description**: Copy essential system state from backup to /persist/system/
  - **Deliverables**:
    - `/etc/machine-id` migrated
    - SSH host keys migrated
    - NetworkManager connections migrated
    - Docker state migrated
    - Flatpak state migrated
    - All system persistence paths populated
  - **Requirements**: Persistence Requirements
  - **Dependencies**: 4.4, 2.1

- [ ] **4.6** Migrate home state to /persist
  - **Description**: Copy user home directory state from backup to /persist/home/sinh/
  - **Deliverables**:
    - SSH keys migrated
    - GPG keys migrated
    - Browser profiles migrated
    - Development configs migrated
    - Shell history migrated
    - All home persistence paths populated
  - **Requirements**: Home Directory Requirements
  - **Dependencies**: 4.4, 2.1

### Phase 5: Validation & Finalization

- [ ] **5.1** First boot and basic validation
  - **Description**: Boot into new system and verify basic functionality
  - **Deliverables**:
    - System boots successfully
    - Can log in as sinh
    - Network connectivity works
    - Basic commands work
  - **Requirements**: Boot Requirements, Success Criteria
  - **Dependencies**: 4.6

- [ ] **5.2** Verify tmpfs root and mounts
  - **Description**: Confirm that root is tmpfs and all persist bind-mounts are active
  - **Deliverables**:
    - `df -T /` shows tmpfs
    - `mount | grep persist` shows bind-mounts
    - All expected paths are bind-mounted
  - **Requirements**: Filesystem Requirements, Technical Success
  - **Dependencies**: 5.1

- [ ] **5.3** Test persistence across reboot
  - **Description**: Create test files in persisted and non-persisted locations, reboot, verify behavior
  - **Deliverables**:
    - Files in /persist survive reboot
    - Files outside persist are wiped
    - All declared state intact after reboot
  - **Requirements**: Functional Success
  - **Dependencies**: 5.2

- [ ] **5.4** Validate all services and applications
  - **Description**: Test all major services and applications work correctly
  - **Deliverables**:
    - Docker containers run
    - Flatpak apps launch
    - Hyprland desktop works
    - Browsers have profiles
    - SSH keys work
    - Development environment functional
  - **Requirements**: User Experience Success
  - **Dependencies**: 5.3

- [ ] **5.5** Multiple reboot stress test
  - **Description**: Perform 5+ reboot cycles to ensure stability and persistence reliability
  - **Deliverables**:
    - System boots reliably every time
    - No data loss across reboots
    - Performance consistent
  - **Requirements**: Reliability, Success Criteria
  - **Dependencies**: 5.4

- [ ] **5.6** Final cleanup and documentation
  - **Description**: Remove temporary configs, update documentation, mark migration complete
  - **Deliverables**:
    - Old SSD can be safely wiped/repurposed (user decision)
    - CLAUDE.md updated if needed
    - Any learnings documented
    - Kiro spec marked complete
  - **Requirements**: Maintainability
  - **Dependencies**: 5.5

## Task Guidelines

### Task Completion Criteria
Each task is considered complete when:
- [ ] All deliverables are implemented and functional
- [ ] Configuration passes `nix flake check` where applicable
- [ ] System boots and functions correctly
- [ ] Requirements are satisfied and verified

### Task Dependencies
- Tasks within Phase 1 can mostly run in parallel
- Phase 2 must complete before Phase 3
- Phases 3-5 are sequential (hardware work)
- Critical path: 1.1 → 1.2 → 1.3 → 1.5 → 2.1 → 3.1 → 4.3 → 5.1

### Testing Requirements
- **Config Tests**: `nix flake check`, `nix build .#nixosConfigurations.Emberroot.config.system.build.toplevel`
- **VM Tests**: QEMU testing before hardware migration
- **Integration Tests**: Full boot and service validation
- **Persistence Tests**: Reboot cycles with state verification

### Risk Mitigation Checkpoints

| After Task | Checkpoint |
|------------|------------|
| 1.6 | Config works in VM - safe to proceed with hardware |
| 2.1 | Full backup verified - safe to modify hardware |
| 3.2 | Partitions correct - can proceed with install |
| 4.3 | NixOS installed - can attempt first boot |
| 5.3 | Persistence verified - migration functionally complete |
| 5.5 | Stress test passed - migration fully validated |

## Progress Tracking

### Milestone Checkpoints
- **Milestone 1**: Configuration Ready (Phase 1 Complete)
- **Milestone 2**: Backup Complete (Phase 2 Complete)
- **Milestone 3**: SSD Prepared (Phase 3 Complete)
- **Milestone 4**: System Installed (Phase 4 Complete)
- **Milestone 5**: Migration Validated (Phase 5 Complete)

### Definition of Done
A task is considered "Done" when:
1. **Functionality**: All specified functionality is implemented
2. **Testing**: Relevant tests pass
3. **Requirements**: All linked requirements are satisfied
4. **Verification**: Task deliverables verified working

## Resource Requirements

### Development Environment
- Current working Emberroot system
- Access to this NixOS configuration repository
- Network access for flake inputs

### Hardware Requirements
- 2TB NVMe SSD (new)
- External storage for backup (≥500GB recommended)
- USB drive for NixOS installer (≥8GB)
- Screwdriver for SSD installation

### Backup Storage
- Sufficient space for:
  - /nix/store (varies, potentially 50-200GB)
  - /home/sinh (varies)
  - /var/lib critical state (Docker images, etc.)
  - /etc custom state

## Emergency Recovery

### If boot fails after installation:
1. Boot from NixOS USB
2. Mount /nix and /persist partitions
3. Check `/persist/system/` structure
4. Verify hardware-configuration.nix UUIDs
5. Chroot and rebuild if needed

### If data is missing after reboot:
1. Check bind-mounts: `mount | grep persist`
2. Verify impermanence module enabled
3. Check persistence path declarations
4. Add missing paths and rebuild

### Full rollback:
1. Shutdown, reinstall original SSD
2. Boot from original system
3. Analyze what went wrong
4. Retry with fixes

## Git Tracking

**Branch**: `feature/emberroot-impermanence`

**Related Files**:
- `flake.nix`
- `modules/nixos/impermanence/default.nix`
- `modules/home/impermanence/default.nix`
- `systems/x86_64-linux/Emberroot/default.nix`
- `systems/x86_64-linux/Emberroot/hardware-configuration.nix`
- `home/sinh/Emberroot.nix`

---

**Task Status**: Not Started

**Current Phase**: Phase 1 - Preparation & Configuration

**Overall Progress**: 0/24 tasks completed (0%)

**Last Updated**: 2025-01-27

**Assigned Developer**: sinh

