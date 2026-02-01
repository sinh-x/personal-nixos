# Emberroot Impermanence SSD Upgrade Requirements

## 1. Introduction

This document specifies the requirements for upgrading Emberroot's storage to a 2TB NVMe SSD with an impermanence-based filesystem layout. The goal is to achieve a truly declarative NixOS system where the root filesystem is ephemeral (tmpfs), and only explicitly declared state persists across reboots.

**Architecture Overview**: The system will boot with a tmpfs root filesystem, with `/nix` and `/persist` mounted from the SSD. The impermanence NixOS module will manage bind-mounts and symlinks from `/persist` to their expected locations, ensuring all necessary state survives reboots while ephemeral data is wiped clean.

## 2. User Stories

### System Administrator
- **As a system admin**, I want root filesystem to reset on every reboot, so that no unexpected state accumulates over time
- **As a system admin**, I want all persistent state explicitly declared in Nix configuration, so that the system is fully reproducible
- **As a system admin**, I want to easily identify what state exists on my system, so that I can audit and manage it effectively

### Daily User
- **As a daily user**, I want my home directory essentials (SSH keys, browser profiles, app configs) to persist, so that I don't lose my work environment
- **As a daily user**, I want Docker containers and images to persist, so that I don't need to rebuild/repull after reboot
- **As a daily user**, I want the system to boot reliably, so that I can work without disruption

### Developer
- **As a developer**, I want my development environment state to persist, so that project files and tool configurations survive reboots
- **As a developer**, I want git repositories and credentials to persist, so that I can continue work seamlessly
- **As a developer**, I want the Nix store optimized for fast builds, so that development iteration is quick

## 3. Acceptance Criteria

### Filesystem Requirements
- **WHEN** the system boots, **THEN** the root filesystem (`/`) **SHALL** be mounted as tmpfs
- **WHEN** the system boots, **THEN** `/nix` **SHALL** be mounted from the SSD persistent partition
- **WHEN** the system boots, **THEN** `/persist` **SHALL** be mounted from the SSD persistent partition
- **WHEN** the system reboots, **THEN** all files outside `/nix`, `/persist`, and declared persist paths **SHALL** be wiped

### Partition Requirements
- **WHEN** partitioning the 2TB SSD, **THEN** the system **SHALL** have an EFI partition of at least 512MB
- **WHEN** partitioning the 2TB SSD, **THEN** the system **SHALL** have a dedicated `/nix` partition (recommended: 500GB-1TB)
- **WHEN** partitioning the 2TB SSD, **THEN** the system **SHALL** have a `/persist` partition for all persistent state
- **WHEN** partitioning the 2TB SSD, **THEN** the system **SHALL** have a swap partition suitable for hibernation (32-64GB)

### Persistence Requirements
- **WHEN** the system boots, **THEN** `/etc/machine-id` **SHALL** persist across reboots
- **WHEN** the system boots, **THEN** `/etc/ssh/ssh_host_*` **SHALL** persist across reboots
- **WHEN** the system boots, **THEN** NetworkManager connections **SHALL** persist across reboots
- **WHEN** the system boots, **THEN** Docker state (`/var/lib/docker`) **SHALL** persist across reboots
- **WHEN** the system boots, **THEN** Flatpak state (`/var/lib/flatpak`) **SHALL** persist across reboots
- **WHEN** the system boots, **THEN** systemd journal logs **SHALL** persist across reboots (optional, configurable)
- **WHEN** the system boots, **THEN** NVIDIA driver state **SHALL** persist if required

### Home Directory Requirements
**Critical Security & Auth:**
- **WHEN** user logs in, **THEN** SSH keys and config (`~/.ssh`) **SHALL** be available
- **WHEN** user logs in, **THEN** GPG keys (`~/.gnupg`) **SHALL** be available
- **WHEN** user logs in, **THEN** SOPS age key (`~/.config/sops/age`) **SHALL** be available
- **WHEN** user logs in, **THEN** Bitwarden vault (`~/.config/Bitwarden`) **SHALL** persist
- **WHEN** user logs in, **THEN** Google Cloud credentials (`~/.config/gcloud`) **SHALL** persist

**User Data:**
- **WHEN** user logs in, **THEN** Documents, Pictures, Videos, Music folders **SHALL** persist
- **WHEN** user logs in, **THEN** git repositories (`~/git-repos`) **SHALL** persist

**Development:**
- **WHEN** user logs in, **THEN** devenv state (`~/.devenv`) **SHALL** persist
- **WHEN** user logs in, **THEN** direnv allowed directories (`~/.local/share/direnv`) **SHALL** persist
- **WHEN** user logs in, **THEN** Docker CLI config (`~/.docker`) **SHALL** persist
- **WHEN** user logs in, **THEN** development toolchains (cargo, npm) **SHALL** persist

**Browsers:**
- **WHEN** user logs in, **THEN** browser profiles (Firefox, Zen, Brave, Chrome) **SHALL** persist

**Chat Applications:**
- **WHEN** user logs in, **THEN** Signal/gurk state **SHALL** persist
- **WHEN** user logs in, **THEN** Telegram state **SHALL** persist
- **WHEN** user logs in, **THEN** Slack state **SHALL** persist
- **WHEN** user logs in, **THEN** Discord state **SHALL** persist

**Input & Shell:**
- **WHEN** user logs in, **THEN** fcitx5 input method state **SHALL** persist
- **WHEN** user logs in, **THEN** shell history (fish, atuin) **SHALL** persist

**Applications:**
- **WHEN** user logs in, **THEN** VSCode settings **SHALL** persist
- **WHEN** user logs in, **THEN** Steam games and state **SHALL** persist
- **WHEN** user logs in, **THEN** MPD playlists and database **SHALL** persist

### Boot Requirements
- **WHEN** the system boots, **THEN** systemd-boot **SHALL** load successfully from EFI partition
- **WHEN** the system boots, **THEN** initrd **SHALL** mount tmpfs as root before switching
- **WHEN** the system boots, **THEN** impermanence bind-mounts **SHALL** be established before services start
- **IF** boot fails, **THEN** the system **SHALL** provide recovery options via bootloader

### Performance Requirements
- **WHEN** the system is running, **THEN** tmpfs root **SHALL** use no more than 4GB RAM under normal load
- **WHEN** building Nix derivations, **THEN** `/nix` partition **SHALL** provide adequate I/O performance
- **WHEN** the system boots, **THEN** boot time **SHALL** not significantly increase compared to current setup

### Security Requirements
- **WHEN** the system reboots, **THEN** any malware or unauthorized modifications outside persist paths **SHALL** be wiped
- **WHEN** persisting sensitive data, **THEN** the system **SHALL** use appropriate permissions
- **IF** secrets are persisted, **THEN** they **SHALL** be managed via sops-nix

## 4. Technical Architecture

### Storage Architecture
- **Boot**: EFI System Partition (ESP) - 512MB, vfat
- **Nix Store**: Dedicated partition - 350GB, ext4 or btrfs
- **Persistent Data**: Dedicated partition - 1.6TB, ext4 or btrfs
- **Swap**: Swap partition - 64GB (for hibernation support)
- **Root**: tmpfs (RAM-based, ephemeral)

### Key Components
- **nix-community/impermanence**: NixOS module for managing persistent state
- **systemd-boot**: Bootloader (existing)
- **initrd**: Must support early mounting of persistent partitions

### Partition Layout (2TB SSD)
```
/dev/nvme0n1
├── p1: 512MB   EFI    /boot/efi
├── p2: 350GB   ext4   /nix
├── p3: 1.6TB   ext4   /persist
└── p4: 64GB    swap   [swap]

/ → tmpfs (4GB default, can grow)
```

## 5. Feature Specifications

### Core Features
1. **Ephemeral Root**: Root filesystem mounted as tmpfs, wiped on every reboot
2. **Declarative Persistence**: All persistent paths declared in Nix configuration
3. **Home Persistence**: User home directory state managed via home-manager impermanence
4. **System Persistence**: Critical system state persisted via NixOS impermanence module

### Persistence Categories
1. **System State**: machine-id, SSH host keys, hardware-specific state
2. **Service State**: Docker, Flatpak, databases, logs
3. **Network State**: NetworkManager/wpa_supplicant connections, certificates
4. **User State**: SSH keys, GPG, browser profiles, app configs, shell history, devenv/direnv state

### Migration Features
1. **Backup Strategy**: Full backup of current system before migration
2. **State Discovery**: Tools/process to identify all state needing persistence
3. **Rollback Plan**: Ability to revert if migration fails

## 6. Success Criteria

### Functional Success
- **WHEN** system reboots, **THEN** all declared state **SHALL** be intact
- **WHEN** system reboots, **THEN** non-declared state **SHALL** be wiped
- **WHEN** `nixos-rebuild switch` runs, **THEN** system **SHALL** rebuild successfully
- **WHEN** user logs in after reboot, **THEN** working environment **SHALL** be fully functional

### Technical Success
- **WHEN** running `df -h /`, **THEN** root **SHALL** show as tmpfs
- **WHEN** running `mount | grep persist`, **THEN** bind-mounts **SHALL** be active
- **WHEN** checking RAM usage, **THEN** tmpfs **SHALL** use < 4GB under normal operation

### User Experience Success
- **WHEN** daily workflow is performed, **THEN** no data loss **SHALL** occur
- **WHEN** Docker containers are used, **THEN** they **SHALL** persist across reboots
- **WHEN** browser is opened, **THEN** sessions/bookmarks **SHALL** be preserved

## 7. Assumptions and Dependencies

### Technical Assumptions
- 2TB NVMe SSD is compatible with Emberroot hardware
- 32GB RAM is sufficient for tmpfs root + normal workload
- Current NixOS version supports impermanence module
- systemd-boot can boot from new partition layout

### External Dependencies
- **nix-community/impermanence** flake input
- **home-manager** with impermanence support
- Backup storage for migration (external drive or network)

### Hardware Requirements
- Emberroot system with NVMe slot
- 2TB NVMe SSD (new)
- Backup storage device
- USB drive for rescue/installation (if needed)

## 8. Constraints and Limitations

### Technical Constraints
- tmpfs size limited by available RAM (32GB total)
- Some applications may not work well with ephemeral `/tmp` or `/var`
- NVIDIA drivers may have specific persistence requirements
- Hibernation requires swap >= RAM size

### Migration Constraints
- System will be offline during SSD swap and initial setup
- All persistent state must be identified before migration
- Some state discovery is trial-and-error

### Compatibility Constraints
- Docker storage driver must support the filesystem (ext4/btrfs)
- Flatpak requires specific directory structure
- Some proprietary software may have undocumented state locations

## 9. Risk Assessment

### Technical Risks
- **Risk**: Missing critical persistent state causes broken functionality
  - **Likelihood**: Medium
  - **Impact**: High
  - **Mitigation**: Thorough state audit, incremental migration, maintain backup

- **Risk**: Boot failure due to incorrect initrd/fstab configuration
  - **Likelihood**: Medium
  - **Impact**: High
  - **Mitigation**: Test in VM first, keep rescue USB ready, document rollback

- **Risk**: Performance degradation from tmpfs overhead
  - **Likelihood**: Low
  - **Impact**: Low
  - **Mitigation**: Monitor RAM usage, adjust tmpfs size limits

### Data Risks
- **Risk**: Data loss during migration
  - **Likelihood**: Low
  - **Impact**: Critical
  - **Mitigation**: Full backup before any changes, verify backup integrity

### Operational Risks
- **Risk**: Extended downtime during migration
  - **Likelihood**: Medium
  - **Impact**: Medium
  - **Mitigation**: Plan migration during low-usage period, prepare all configs in advance

## 10. Non-Functional Requirements

### Reliability
- System must boot reliably after migration
- Persistent data must survive unexpected power loss
- Recovery must be possible from bootloader

### Maintainability
- Persistence configuration must be clearly documented
- Adding new persistent paths must be straightforward
- System state must be auditable

### Performance
- Boot time should not increase significantly
- Normal operation should not be impacted by tmpfs root
- Nix builds should perform well on dedicated partition

## 11. Future Considerations

### Phase 2 Features
- Encrypted `/persist` partition (LUKS)
- Automatic state discovery tooling
- Impermanence for other systems (Elderwood, Drgnfly)

### Potential Enhancements
- Btrfs with snapshots for `/persist` rollback
- Automated backup of `/persist` partition
- Boot environment selection (persist vs clean)

---

**Document Status**: Draft

**Last Updated**: 2025-01-27

**Stakeholders**: sinh (system owner)

**Related Documents**: design.md, tasks.md

**Version**: 1.0
