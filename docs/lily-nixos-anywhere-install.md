# Lily — nixos-anywhere Remote Install Guide

> **Host:** Lily (Lenovo IdeaPad 3 15ADA05)
> **Disk:** `/dev/nvme0n1` (238.5GB NVMe) — **WILL BE WIPED**
> **Installer:** FireFly USB booted on the laptop
> **Source:** Drgnfly (run all commands from here)
> **Tailscale hostname of FireFly on laptop:** `firefly`
> **Last updated:** 2026-03-16

This guide installs the Lily NixOS configuration remotely via `nixos-anywhere`.
The laptop must be booted from the FireFly USB and reachable via tailscale.

---

## Architecture Notes

### Disk Layout (after install)

```
nvme0n1 (238.5GB, GPT):
  nvme0n1p1  512MB   ESP (vfat)      → /boot/efi
  nvme0n1p2  8GB     swap            (resume device)
  nvme0n1p3  100%    Btrfs (lily)
    @root     →  /          (wiped on every boot via initrd rollback)
    @nix      →  /nix       (persistent)
    @persist  →  /persist   (persistent)
    @root-blank              (empty subvolume → rollback source)
```

**No LUKS encryption.** disko creates all subvolumes including `@root-blank`.
The initrd (see `hardware-configuration.nix`) snapshots `@root-blank` to restore
`@root` on every boot — this is the impermanence mechanism.

### SOPS / Age Key

Lily uses impermanence, so sops-nix reads the age key from:
```
/persist/system/sops/age/keys.txt
```

Lily has its **own** age key (separate from Drgnfly's). Both keys are listed in
`.sops.yaml` so `secrets.yaml` can be decrypted by either. Lily's private key
was generated with `age-keygen` and stored at `/tmp/lily-age-key.txt` on Drgnfly.

Seed Lily's private key (not Drgnfly's) via `--extra-files`.

### SSH Host Keys (impermanence)

The impermanence module configures openssh to store host keys at:
```
/persist/system/etc/ssh/ssh_host_ed25519_key
/persist/system/etc/ssh/ssh_host_rsa_key
```

**Do NOT** seed to `/etc/ssh/` — those files are ephemeral and will be ignored
after boot. Seed into `/persist/system/etc/ssh/` via `--extra-files`.

### User Home Directories

Impermanence bind-mounts:
- `/home/sinh` → `/persist/home/sinh`
- `/home/doangia` → `/persist/home/doangia`

If these paths don't exist in `/persist`, first boot will fail to mount them.
Seed empty directories via `--extra-files`.

---

## Pre-flight Checklist

Run all steps on Drgnfly. **Do not proceed to install until all pass.**

```bash
# Step 1: Verify Lily config builds cleanly
cd ~/git-repos/sinh-x/personal-nixos
nix build .#nixosConfigurations.Lily.config.system.build.toplevel
echo "Build exit: $?"

# Step 2: Confirm age key exists on Drgnfly
ls -la ~/.config/sops/age/keys.txt
# Must show the file. If missing, stop — install will fail at SOPS decryption.

# Step 3: Verify tailscale sees FireFly
tailscale status | grep -i firefly
# Must show 'firefly' as a connected peer.

# Step 4: Verify SSH access to FireFly and confirm disk target
ssh sinh@firefly "lsblk"
# Must show nvme0n1 as the internal NVMe.
# Confirm no important data on nvme0n1 before continuing!

# Step 5: nixos-anywhere availability
nixos-anywhere --version
# Must succeed. nixos-anywhere is in Drgnfly's home.packages.
```

---

## Secrets Seeding

Run on Drgnfly after all pre-flight checks pass.

```bash
# Step 6: Create extra-files directory
mkdir -p /tmp/lily-extra/persist/system/sops/age/
mkdir -p /tmp/lily-extra/persist/system/etc/ssh/
mkdir -p /tmp/lily-extra/persist/home/sinh
mkdir -p /tmp/lily-extra/persist/home/doangia

# Step 7: Copy Lily's own age key (NOT Drgnfly's — each host has its own key)
# Lily's private key was generated separately and stored at /tmp/lily-age-key.txt
cp /tmp/lily-age-key.txt \
   /tmp/lily-extra/persist/system/sops/age/keys.txt
chmod 600 /tmp/lily-extra/persist/system/sops/age/keys.txt

# Step 8: Generate stable SSH host keys for Lily
# (prevents "host key changed" warnings on future reinstalls)
ssh-keygen -t ed25519 -N "" \
  -f /tmp/lily-extra/persist/system/etc/ssh/ssh_host_ed25519_key -C ""
ssh-keygen -t rsa -b 4096 -N "" \
  -f /tmp/lily-extra/persist/system/etc/ssh/ssh_host_rsa_key -C ""

# Verify extra-files structure
find /tmp/lily-extra -type f | sort
# Expected:
#   /tmp/lily-extra/persist/system/sops/age/keys.txt
#   /tmp/lily-extra/persist/system/etc/ssh/ssh_host_ed25519_key
#   /tmp/lily-extra/persist/system/etc/ssh/ssh_host_ed25519_key.pub
#   /tmp/lily-extra/persist/system/etc/ssh/ssh_host_rsa_key
#   /tmp/lily-extra/persist/system/etc/ssh/ssh_host_rsa_key.pub
#   /tmp/lily-extra/persist/home/sinh/   (empty dir)
#   /tmp/lily-extra/persist/home/doangia/ (empty dir)
```

---

## Installation

⚠️ **This step WIPES nvme0n1 on the target laptop. There is no undo.**

Confirm the disk target one more time via SSH before running:
```bash
ssh sinh@firefly "lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT"
```

Then run nixos-anywhere:

```bash
# Step 9: Run nixos-anywhere — THIS WIPES nvme0n1
nixos-anywhere \
  --flake ~/git-repos/sinh-x/personal-nixos#Lily \
  --target-host sinh@firefly \
  --extra-files /tmp/lily-extra
```

nixos-anywhere will:
1. SSH into FireFly as `sinh@firefly`
2. Transfer the flake to the target
3. Run disko (wipes and partitions nvme0n1, creates all btrfs subvolumes)
4. Run `nixos-install`
5. Reboot

This takes approximately 5–15 minutes depending on network speed.

---

## Post-install Verification

Wait 1–2 minutes after reboot for Lily to come online.

```bash
# Step 10: Wait for Lily to appear in tailscale
tailscale status
# Look for 'lily' or 'Lily' as a connected peer.
# Tailscale auto-connects using the reusable auth key from SOPS.

# Step 11: Verify SSH access
ssh sinh@lily "whoami && hostname && ls /persist"
# Expected output:
#   sinh
#   Lily
#   home  system  (at minimum)

# Step 12: Verify impermanence is working
ssh sinh@lily "ls / | sort"
# /etc, /nix, /persist, /home, /boot should exist
# /etc/hostname should NOT exist (ephemeral root)
ssh sinh@lily "ls /etc/hostname 2>/dev/null || echo 'ephemeral root OK'"

# Step 13: Verify tailscale on Lily itself
ssh sinh@lily "tailscale status"

# Step 14: Verify doangia home mount
ssh sinh@lily "ls /home/doangia"
# Should show an empty home (or greetd creates it on first login)
```

---

## Troubleshooting

### SSH host key changed warning
After reinstall, remove the old host key:
```bash
ssh-keygen -R lily
ssh-keygen -R <lily-tailscale-ip>
```

### Tailscale not connecting after boot
The auth key may have been consumed. Check tailscale admin:
- If consumed: regenerate the key in tailscale admin
- Update `secrets/secrets.yaml` with new key: `sops secrets/secrets.yaml`
- Key path in secrets: `tailscale/Lily`

### SOPS decryption fails on boot
Means the age key was not found at `/persist/system/sops/age/keys.txt`.
Boot into recovery, mount `/persist`, and manually place the key:
```bash
mount -t btrfs -o subvol=@persist /dev/nvme0n1p3 /mnt/persist
mkdir -p /mnt/persist/system/sops/age
# then copy keys.txt from USB or Drgnfly via tailscale
```

### /home/doangia mount failure
If `/persist/home/doangia` doesn't exist, systemd will fail to bind mount.
Boot with `init=/bin/sh` or enter emergency shell:
```bash
mkdir -p /persist/home/doangia
chown doangia:users /persist/home/doangia
```

---

## Cleanup

After successful install:
```bash
# Remove temporary extra-files (contains age private key — clean up!)
rm -rf /tmp/lily-extra
```

---

## Repeating for a New Install

To reinstall Lily from scratch, repeat all steps from Pre-flight. The tailscale
auth key must still be valid (reusable keys do not expire). SSH host key warnings
can be cleared with `ssh-keygen -R lily`.
