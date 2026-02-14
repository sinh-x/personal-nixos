# Drgnfly Btrfs Migration with Disko

**Date**: 2026-02-14
**Branch**: `feat/202602-drgnfly-btrfs-disko`

## What Changed

Replace tmpfs root + two fixed ext4 partitions (350GB `/nix`, 1.6TB `/persist`) with a single btrfs pool using subvolumes managed by disko.

### New Partition Layout

```
/dev/nvme0n1
├── p1: 512MB    vfat    /boot/efi          (ESP)
├── p2: ~1.95TB  btrfs   (label: nixos)     (single pool, shared space)
│   ├── @root        → /          (wiped on every boot)
│   ├── @nix         → /nix       (persistent)
│   ├── @persist     → /persist   (persistent)
│   └── @root-blank  (empty subvol, rollback source)
└── p3: 64GB     swap    (label: swap)       (hibernation)
```

### Benefits

- Eliminates 4GB RAM overhead from tmpfs root
- `/nix` and `/persist` share the full ~1.95TB flexibly (no fixed split)
- zstd compression on all subvolumes
- Monthly auto-scrub for data integrity

### Files Modified

| File | Change |
|------|--------|
| `flake.nix` | Added `disko` input |
| `flake.lock` | Locked disko |
| `systems/.../Drgnfly/disks.nix` | **Created** — disko btrfs config |
| `systems/.../Drgnfly/hardware-configuration.nix` | Removed fileSystems/swap, added btrfs + rollback script |
| `systems/.../Drgnfly/default.nix` | Import disko, add autoScrub + compsize |

No changes to impermanence modules — they are filesystem-agnostic.

### UUID Note

Reformatting to btrfs generates new UUIDs, but this config doesn't reference any UUIDs. Disko uses the device path (`/dev/nvme0n1`) and the rollback script uses the label (`/dev/disk/by-label/nixos`).

---

## Installation Runbook

Boot from an external SSD with NixOS, then follow these steps.

### 1. Back up persistent data

Before touching the internal drive, copy `/persist`:

```bash
mkdir -p /mnt/old-persist
mount /dev/disk/by-uuid/9e08cb02-a9ed-48c2-a3cb-1eae11c54b20 /mnt/old-persist

# Copy to external storage (adjust target path)
rsync -aAXv /mnt/old-persist/ /path/to/backup/persist/

umount /mnt/old-persist
```

### 2. Clone the repo

```bash
nix-shell -p git
git clone https://github.com/sinh-x/personal-nixos.git /tmp/nixos-config
cd /tmp/nixos-config
git checkout feat/202602-drgnfly-btrfs-disko
```

### 3. Run disko to partition + format + mount

```bash
nix run github:nix-community/disko -- --mode destroy,format,mount ./systems/x86_64-linux/Drgnfly/disks.nix
```

This wipes `/dev/nvme0n1`, creates the GPT layout (ESP + btrfs + swap), creates all subvolumes, and mounts everything under `/mnt`.

### 4. Verify

```bash
# Check mounts
mount | grep /mnt
# Should show:
#   @root   → /mnt
#   @nix    → /mnt/nix
#   @persist → /mnt/persist
#   vfat    → /mnt/boot/efi

# Check subvolumes
btrfs subvolume list /mnt
# Should list: @root, @nix, @persist, @root-blank
```

### 5. Restore persistent data

```bash
rsync -aAXv /path/to/backup/persist/ /mnt/persist/
```

### 6. Install NixOS

```bash
nixos-install --flake /tmp/nixos-config#Drgnfly --no-root-passwd
```

`--no-root-passwd` because user auth is in `/persist` already.

### 7. Reboot

```bash
umount -R /mnt
reboot
```

On first boot, the initrd rollback script wipes `@root` and restores from `@root-blank`.

---

## Post-Boot Verification

```bash
# Verify btrfs mounts
mount | grep btrfs
# Should show @root on /, @nix on /nix, @persist on /persist

# List subvolumes
sudo btrfs subvolume list /
# Should list @root, @nix, @persist, @root-blank

# Check zstd compression
sudo compsize /nix

# Verify impermanence (create test file, reboot, confirm it's gone)
touch /tmp/test-persist
# After reboot: ls /tmp/test-persist → should not exist

# Verify home persists
ls /home/sinh/git-repos

# Confirm scrub timer
systemctl list-timers | grep scrub
```
