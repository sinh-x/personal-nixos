# Shared WiFi Configuration Design Document

## Overview

This document describes the technical design for consolidating WiFi network configurations across all NixOS hosts into a single shared module using SOPS-encrypted secrets.

## Technical Feasibility

### Verified Patterns
- **Module discovery**: Snowfall Lib auto-discovers modules in `modules/nixos/`
- **Option namespace**: `modules.wifi.*` matches existing patterns (e.g., `modules.stubby`)
- **SOPS integration**: `config.sops.secrets."wifi/credentials".path` already defined in sops module
- **Network merging**: NixOS supports merging attribute sets via `//` operator

### Dependencies
- `modules.sops.enable = true` must be set (provides `config.sops.secrets."wifi/credentials"`)
- SOPS age key must exist at `/home/sinh/.config/sops/age/keys.txt` on each host

## Architecture

### Module Location
```
modules/nixos/wifi/default.nix
```

### Module Implementation

```nix
{ config, lib, ... }:

let
  cfg = config.modules.wifi;

  # All shared networks defined here
  sharedNetworks = {
    # Home networks
    "5G_Vuon Nha" = { pskRaw = "ext:vuonnha"; };
    "VINA_NHA MINH 1" = { pskRaw = "ext:nhaminh"; };
    # ... 59+ networks total

    # Open networks (no password)
    "TOCEPO" = { };
    "Starbucks" = { };
  };
in
{
  options.modules.wifi = {
    enable = lib.mkEnableOption "Shared WiFi configuration";

    extraNetworks = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Additional per-host networks to merge with shared networks";
    };

    userControlled = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow user control via wpa_cli";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure SOPS is enabled (dependency)
    assertions = [
      {
        assertion = config.modules.sops.enable;
        message = "modules.wifi requires modules.sops.enable = true";
      }
    ];

    networking.wireless = {
      enable = true;
      secretsFile = config.sops.secrets."wifi/credentials".path;
      userControlled.enable = cfg.userControlled;
      networks = sharedNetworks // cfg.extraNetworks;
    };
  };
}
```

## Network Consolidation

### Source Analysis
- **Emberroot**: 59 networks (superset)
- **Drgnfly**: 48 networks (subset of Emberroot with minor differences)
- **Elderwood**: 1 network (already in Emberroot)

### Networks to Migrate

All networks from Emberroot will be used. Key differences from Drgnfly:
| Drgnfly Name | Emberroot Name | Action |
|--------------|----------------|--------|
| `Adiuvat Home` | `Adiuvat Coffee Roasters` | Use Emberroot (both exist) |
| `LOTUS 18 NPK  L3` | `LOTUS 18 NPK L4` | Keep both |

### Hardcoded Passwords to Migrate
```nix
# Current (insecure)
"ROOM NHA NOI" = { psk = "183chauvanliem"; };
"Homestay in Tay Ninh" = { psk = "02112011"; };

# Target (secure)
"ROOM NHA NOI" = { pskRaw = "ext:roomnhanoi"; };
"Homestay in Tay Ninh" = { pskRaw = "ext:homestaytayninh"; };
```

These passwords must be added to `secrets/secrets.yaml` under `wifi/credentials`.

## Per-Host Configuration

### Emberroot
```nix
# systems/x86_64-linux/Emberroot/default.nix
modules = {
  sops.enable = true;  # Already enabled
  wifi.enable = true;  # NEW
};
# Remove: ./wifi-networks.nix import
```

### Drgnfly
```nix
# systems/x86_64-linux/Drgnfly/default.nix
modules = {
  sops.enable = true;  # Already enabled
  wifi.enable = true;  # NEW
};
# Remove: ./wifi-networks.nix import
```

### Elderwood
```nix
# systems/x86_64-linux/Elderwood/default.nix
modules = {
  sops.enable = true;  # Already enabled
  wifi.enable = true;  # NEW
};

# Keep existing static IP config (separate from wifi module)
networking.interfaces.wlo1.ipv4.addresses = [
  { address = "192.168.1.4"; prefixLength = 24; }
];
# Remove: inline networking.wireless config
```

## Files Changed

### Create
| File | Purpose |
|------|---------|
| `modules/nixos/wifi/default.nix` | Shared WiFi module with all networks |

### Modify
| File | Changes |
|------|---------|
| `systems/x86_64-linux/Emberroot/default.nix` | Remove wifi-networks.nix import, add `modules.wifi.enable` |
| `systems/x86_64-linux/Drgnfly/default.nix` | Remove wifi-networks.nix import, add `modules.wifi.enable` |
| `systems/x86_64-linux/Elderwood/default.nix` | Remove inline wifi config, add `modules.wifi.enable` |
| `secrets/secrets.yaml` | Add `roomnhanoi` and `homestaytayninh` credentials |

### Delete
| File | Reason |
|------|--------|
| `systems/x86_64-linux/Emberroot/wifi-networks.nix` | Replaced by shared module |
| `systems/x86_64-linux/Drgnfly/wifi-networks.nix` | Replaced by shared module |

## Testing Strategy

### Build Verification
```bash
# Test each host builds successfully
nix build .#nixosConfigurations.Emberroot.config.system.build.toplevel
nix build .#nixosConfigurations.Drgnfly.config.system.build.toplevel
nix build .#nixosConfigurations.Elderwood.config.system.build.toplevel
```

### Runtime Verification
```bash
# On active host
sudo sys test

# Verify networks loaded
wpa_cli list_networks | head -20

# Verify secrets file path
cat /etc/wpa_supplicant.conf | grep ext_password_backend
```

## Rollback Plan

If issues occur:
1. `git revert` the commit
2. Old wifi-networks.nix files restored from git history
3. Re-run `sudo sys rebuild`

## Security Considerations

- All WiFi passwords stored in SOPS-encrypted `secrets/secrets.yaml`
- No plain-text passwords in Nix store or git
- `wpa_supplicant` user owns the decrypted secrets file at runtime
- Age key required on each host for decryption

---

**Requirements Traceability**: Addresses all requirements from requirements.md

**Review Status**: Approved

**Last Updated**: 2026-01-13

**Implementation**: Completed - see `tasks.md`
