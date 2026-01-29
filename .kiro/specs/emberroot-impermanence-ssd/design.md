# Emberroot Impermanence SSD Upgrade Design Document

## Overview

This document details the technical design for migrating Emberroot to an impermanence-based NixOS setup on a new 2TB NVMe SSD. The design covers partition layout, NixOS module configuration, persistence declarations, and the integration with the existing Snowfall Lib architecture.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        BOOT PROCESS                              │
├─────────────────────────────────────────────────────────────────┤
│  1. UEFI → systemd-boot (ESP /boot/efi)                         │
│  2. Load kernel + initrd                                         │
│  3. initrd: mount /nix, /persist                                │
│  4. initrd: mount tmpfs as /                                    │
│  5. initrd: impermanence creates bind-mounts from /persist      │
│  6. Switch to real root, start systemd                          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                     RUNTIME FILESYSTEM                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  /  (tmpfs - ephemeral)                                         │
│  ├── /boot/efi    (ESP partition - persistent)                  │
│  ├── /nix         (Nix partition - persistent)                  │
│  ├── /persist     (Data partition - persistent)                 │
│  │   ├── /system/...   → bind-mounted to various /etc, /var     │
│  │   └── /home/sinh/...→ bind-mounted to ~/                     │
│  ├── /etc         (tmpfs + bind-mounts from /persist/system)    │
│  ├── /var         (tmpfs + bind-mounts from /persist/system)    │
│  └── /home/sinh   (tmpfs + bind-mounts from /persist/home)      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Partition Layout

```
2TB NVMe SSD (/dev/nvme0n1)
┌──────────────────────────────────────────────────────────────────┐
│ Partition │  Size   │  Type  │ Mount Point │ Purpose             │
├───────────┼─────────┼────────┼─────────────┼─────────────────────┤
│ nvme0n1p1 │  512 MB │ vfat   │ /boot/efi   │ EFI System Part.    │
│ nvme0n1p2 │  350 GB │ ext4   │ /nix        │ Nix store + profile │
│ nvme0n1p3 │ 1586 GB │ ext4   │ /persist    │ All persistent data │
│ nvme0n1p4 │   64 GB │ swap   │ [swap]      │ Swap + hibernation  │
└──────────────────────────────────────────────────────────────────┘
Total: ~2TB (2000 GB)
```

### Technology Stack

**NixOS Modules**
- `nix-community/impermanence` - Core impermanence module
- `home-manager` with impermanence - User-level persistence
- `systemd-boot` - Bootloader (unchanged)
- `sops-nix` - Secrets management (existing)

**Filesystem**
- `ext4` - Chosen for reliability and compatibility (Docker, Flatpak)
- `tmpfs` - RAM-based ephemeral root
- `vfat` - EFI partition (required)

**Alternative: Btrfs** (considered but not chosen for v1)
- Would enable snapshots and rollback
- More complex, can revisit in Phase 2

## Components and Interfaces

### Flake Input Addition

```nix
# flake.nix - add impermanence input
{
  inputs = {
    # ... existing inputs ...
    impermanence = {
      url = "github:nix-community/impermanence";
    };
  };
}
```

### NixOS Module: Impermanence Base

**File**: `modules/nixos/impermanence/default.nix`

```nix
{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types mkIf;
in
{
  options.modules.impermanence = {
    enable = mkEnableOption "impermanence with tmpfs root";

    persistPath = mkOption {
      type = types.str;
      default = "/persist";
      description = "Base path for persistent storage";
    };
  };

  config = mkIf config.modules.impermanence.enable {
    # Import the impermanence NixOS module
    imports = [ inputs.impermanence.nixosModules.impermanence ];

    # Configure tmpfs root
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=4G" "mode=755" ];
    };

    # System-level persistence
    environment.persistence."${config.modules.impermanence.persistPath}/system" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/docker"
        "/var/lib/flatpak"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/NetworkManager"
        "/var/lib/libvirt"         # QEMU/KVM VM images and config
        { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "0755"; }
      ];
      files = [
        "/etc/machine-id"
        "/etc/adjtime"
      ];
    };

    # Ensure /persist is mounted early
    fileSystems."/persist".neededForBoot = true;

    # SSH host keys persistence
    services.openssh.hostKeys = [
      {
        path = "${config.modules.impermanence.persistPath}/system/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "${config.modules.impermanence.persistPath}/system/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };
}
```

### Home-Manager Module: User Persistence

**File**: `modules/home/impermanence/default.nix`

```nix
{
  config,
  lib,
  inputs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types mkIf;
in
{
  options.${namespace}.impermanence = {
    enable = mkEnableOption "home-manager impermanence";

    persistPath = mkOption {
      type = types.str;
      default = "/persist/home";
      description = "Base path for home persistence";
    };
  };

  config = mkIf config.${namespace}.impermanence.enable {
    imports = [ inputs.impermanence.nixosModules.home-manager.impermanence ];

    home.persistence."${config.${namespace}.impermanence.persistPath}/${config.home.username}" = {
      allowOther = true;

      directories = [
        # === CRITICAL - Security & Auth ===
        ".ssh"
        ".gnupg"
        ".config/sops/age"         # SOPS age secret key - CRITICAL

        # === User Data Folders ===
        "Documents"
        "Pictures"
        "Videos"
        "Music"

        # === Shell & CLI ===
        ".local/share/fish"
        ".local/share/zoxide"
        ".config/atuin"            # Shell history sync config
        ".local/share/atuin"       # Shell history database

        # === Development ===
        "git-repos"
        ".cargo"
        ".rustup"
        ".npm"
        ".local/share/nvim"
        ".config/gh"
        ".config/git"
        ".docker"                  # Docker CLI config, auth, buildx

        # === Devenv & Direnv ===
        ".devenv"                  # Global devenv state, GC roots, cachix keys
        ".local/share/direnv"      # Allowed directory hashes
        ".config/direnv"           # Direnv config

        # === Browsers ===
        ".mozilla/firefox"
        ".zen"
        ".config/zen"
        ".config/BraveSoftware"    # Brave browser profile
        ".config/google-chrome"    # Chrome browser profile

        # === Password Manager ===
        ".config/Bitwarden"        # Bitwarden vault cache

        # === Cloud & Auth ===
        ".config/gcloud"           # Google Cloud credentials

        # === Input Method ===
        ".config/fcitx5"           # Fcitx5 config
        ".local/share/fcitx5"      # Fcitx5 learned words & data

        # === Chat Applications ===
        ".config/discord"
        ".config/Slack"            # Slack
        ".config/gurk"             # Signal CLI client config
        ".local/share/gurk"        # Signal CLI client data
        ".local/share/TelegramDesktop"  # Telegram

        # === Applications ===
        ".config/Code"             # VSCode
        ".config/spotify"
        ".steam"
        ".local/share/Steam"
        ".local/share/mpd"         # MPD playlists & database

        # === Desktop ===
        ".config/hypr"
        ".local/share/applications"
        ".local/share/icons"
        ".local/share/hyprland"    # Hyprland state

        # === Misc state ===
        ".local/state"

        # === Project-specific ===
        ".config/sinh-x-scripts"
      ];

      files = [
        ".config/monitors.xml"
      ];
    };
  };
}
```

### Hardware Configuration Update

**File**: `systems/x86_64-linux/Emberroot/hardware-configuration.nix` (updated)

```nix
{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      kernelModules = [ ];
      # Support early mount for impermanence
      supportedFilesystems = [ "ext4" "vfat" ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  # Root is tmpfs (ephemeral)
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=4G" "mode=755" ];
  };

  # EFI System Partition
  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/XXXX-XXXX";  # New UUID after partitioning
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # Nix store partition
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";  # New UUID
    fsType = "ext4";
    options = [ "noatime" ];
    neededForBoot = true;
  };

  # Persistent data partition
  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";  # New UUID
    fsType = "ext4";
    options = [ "noatime" ];
    neededForBoot = true;
  };

  # Swap
  swapDevices = [
    { device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"; }  # New UUID
  ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
```

### System Configuration Update

**File**: `systems/x86_64-linux/Emberroot/default.nix` (additions)

```nix
{
  # Enable impermanence
  modules.impermanence.enable = true;

  # Adjust boot for tmpfs root
  boot.tmp.useTmpfs = true;

  # Ensure critical directories exist before services start
  systemd.tmpfiles.rules = [
    "d /persist/system 0755 root root -"
    "d /persist/system/var/log 0755 root root -"
    "d /persist/system/var/lib 0755 root root -"
    "d /persist/home 0755 root root -"
    "d /persist/home/sinh 0700 sinh users -"
  ];
}
```

### Home Configuration Update

**File**: `home/sinh/Emberroot.nix` (additions)

```nix
{
  sinh-x.impermanence.enable = true;
}
```

## Persistence Inventory

### System Persistence (`/persist/system/`)

| Path | Purpose | Required |
|------|---------|----------|
| `/etc/machine-id` | Unique machine identifier | Yes |
| `/etc/adjtime` | Hardware clock state | Yes |
| `/etc/ssh/ssh_host_*` | SSH host keys | Yes |
| `/var/log` | System logs | Recommended |
| `/var/lib/docker` | Docker images, containers, volumes | Yes |
| `/var/lib/flatpak` | Flatpak applications | Yes |
| `/var/lib/bluetooth` | Bluetooth pairings | Yes |
| `/var/lib/nixos` | NixOS state (uid/gid maps) | Yes |
| `/var/lib/NetworkManager` | Network connections | Yes |
| `/var/lib/libvirt` | QEMU/KVM VM images and config | Yes |
| `/var/lib/colord` | Color profiles | Optional |
| `/var/lib/systemd/coredump` | Core dumps | Optional |

### Home Persistence (`/persist/home/sinh/`)

| Path | Purpose | Required |
|------|---------|----------|
| **Security & Auth** | | |
| `.ssh` | SSH keys and config | Critical |
| `.gnupg` | GPG keys | Critical |
| `.config/sops/age` | SOPS age secret key | Critical |
| `.config/Bitwarden` | Password manager | Critical |
| `.config/gcloud` | Google Cloud credentials | Critical |
| **User Data** | | |
| `Documents` | Documents folder | Yes |
| `Pictures` | Pictures folder | Yes |
| `Videos` | Videos folder | Yes |
| `Music` | Music library | Yes |
| `git-repos` | All git repositories | Yes |
| **Shell & CLI** | | |
| `.local/share/fish` | Fish shell history | Yes |
| `.local/share/zoxide` | Zoxide database | Yes |
| `.config/atuin`, `.local/share/atuin` | Shell history sync | Yes |
| **Development** | | |
| `.cargo`, `.rustup` | Rust toolchain | Yes |
| `.npm` | NPM cache/config | Yes |
| `.local/share/nvim` | Neovim state | Yes |
| `.config/gh` | GitHub CLI | Yes |
| `.config/Code` | VSCode settings | Yes |
| `.docker` | Docker CLI config, auth, buildx | Yes |
| `.devenv` | Devenv global state, GC roots | Yes |
| `.local/share/direnv`, `.config/direnv` | Direnv state | Yes |
| **Input Method** | | |
| `.config/fcitx5`, `.local/share/fcitx5` | Fcitx5 input method | Yes |
| **Browsers** | | |
| `.mozilla/firefox` | Firefox profile | Yes |
| `.zen`, `.config/zen` | Zen browser profile | Yes |
| `.config/BraveSoftware` | Brave browser profile | Yes |
| `.config/google-chrome` | Chrome browser profile | Yes |
| **Chat Applications** | | |
| `.config/discord` | Discord | Yes |
| `.config/Slack` | Slack | Yes |
| `.config/gurk`, `.local/share/gurk` | Signal (gurk) | Yes |
| `.local/share/TelegramDesktop` | Telegram | Yes |
| **Applications** | | |
| `.steam`, `.local/share/Steam` | Steam games | Yes |
| `.local/share/mpd` | MPD playlists & database | Yes |
| `.config/sinh-x-scripts` | Custom script configs | Yes |
| **Desktop** | | |
| `.config/hypr` | Hyprland config | Yes |
| `.local/share/hyprland` | Hyprland state | Yes |
| `.local/share/applications` | Desktop entries | Yes |
| `.local/share/icons` | Icons | Yes |

## Error Handling

### Boot Failure Recovery

```
If system fails to boot:
1. Boot from NixOS USB installer
2. Mount /nix and /persist partitions
3. Chroot into system
4. Fix configuration
5. Rebuild and retry
```

### Missing Persistence Recovery

```nix
# Add this to catch missing persist paths gracefully
environment.persistence."/persist/system" = {
  # ... directories ...
  # Use mkIf to conditionally include based on service enablement
};
```

### Rollback Strategy

1. Keep backup of current SSD until migration is verified
2. Store known-good NixOS generation in bootloader
3. Document exact steps for rollback

## Testing Strategy

### Pre-Migration Testing

1. **VM Test**: Create QEMU VM with identical config, test full boot cycle
2. **Config Validation**: `nixos-rebuild build` to verify config compiles
3. **Persistence Audit**: Run discovery script to find all state

### Post-Migration Testing

| Test | Command | Expected Result |
|------|---------|-----------------|
| Root is tmpfs | `df -T /` | Shows `tmpfs` |
| Persist mounted | `mount \| grep persist` | Shows bind-mounts |
| Reboot survives | Create file in persisted dir, reboot, verify | File exists |
| Ephemeral works | Create file in `/tmp`, reboot, verify | File gone |
| Docker works | `docker run hello-world` | Success |
| SSH keys intact | `ssh-add -l` | Shows keys |
| Browser profile | Open Firefox | Bookmarks present |

### State Discovery Script

```bash
#!/usr/bin/env bash
# Run before migration to discover state

echo "=== Files modified in /etc ==="
find /etc -type f -newer /etc/NIXOS 2>/dev/null

echo "=== Directories in /var/lib ==="
du -sh /var/lib/* 2>/dev/null | sort -h

echo "=== Home directory sizes ==="
du -sh ~/.* ~/* 2>/dev/null | sort -h

echo "=== Running services with state ==="
systemctl list-units --type=service --state=running
```

## Migration Process Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    MIGRATION PHASES                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Phase 1: PREPARATION                                           │
│  ├── Audit current state                                        │
│  ├── Create full backup                                         │
│  ├── Write NixOS configs                                        │
│  └── Test in VM                                                 │
│                                                                  │
│  Phase 2: HARDWARE                                              │
│  ├── Shutdown system                                            │
│  ├── Install new 2TB SSD                                        │
│  ├── Boot from USB installer                                    │
│  └── Partition new SSD                                          │
│                                                                  │
│  Phase 3: INSTALLATION                                          │
│  ├── Mount partitions                                           │
│  ├── Copy /nix from backup                                      │
│  ├── Install bootloader                                         │
│  ├── Generate hardware-config                                   │
│  └── nixos-install                                              │
│                                                                  │
│  Phase 4: DATA MIGRATION                                        │
│  ├── Copy persist data from backup                              │
│  ├── Set permissions                                            │
│  └── First boot                                                 │
│                                                                  │
│  Phase 5: VALIDATION                                            │
│  ├── Verify all services                                        │
│  ├── Test persistence                                           │
│  ├── Multiple reboot cycles                                     │
│  └── Mark migration complete                                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Security Considerations

### Secrets Management
- sops-nix secrets continue to work (mounted from Nix store)
- Ensure age key is in persisted location or derived from hardware

### Permissions
- `/persist/home/sinh` must be owned by sinh:users with 0700
- System persist paths maintain original permissions via impermanence

### Future: Encryption
- Phase 2 can add LUKS encryption to `/persist` partition
- Key can be stored on USB or derived from TPM

## Performance Considerations

### tmpfs Sizing
- Default 4GB for root tmpfs
- Can adjust with `size=XG` in mount options
- Monitor with `df -h /`

### Nix Store Optimization
- `noatime` mount option reduces writes
- Consider `auto-optimise-store` for deduplication
- Periodic `nix store gc` to manage size

### I/O Patterns
- `/nix` sees heavy reads, moderate writes during builds
- `/persist` sees moderate reads/writes
- tmpfs `/` absorbs ephemeral I/O in RAM

## Assumptions and Dependencies

### Technical Assumptions
- NVMe SSD supports standard partitioning (GPT)
- ext4 is sufficient (no need for btrfs features in v1)
- 32GB RAM handles tmpfs + workload comfortably

### External Dependencies
- `nix-community/impermanence` flake must be accessible
- Existing backup solution for migration
- USB boot media for installation

---

**Requirements Traceability**: This design addresses all requirements from requirements.md sections 3-5

**Review Status**: Draft

**Last Updated**: 2025-01-27

**Reviewers**: sinh
