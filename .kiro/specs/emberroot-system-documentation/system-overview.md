# Emberroot System Overview

## Hardware Configuration

### Graphics
| Component | Configuration |
|-----------|---------------|
| Primary GPU | NVIDIA (proprietary, PRIME sync mode) |
| Integrated GPU | Intel (PCI:0:2:0) |
| NVIDIA Bus ID | PCI:1:0:0 |
| Power Management | Enabled |
| Modesetting | Enabled |
| Force Full Composition | Enabled |

### Input Devices
| Device | Configuration |
|--------|---------------|
| TrackPoint | TPPS/2 IBM TrackPoint |
| TrackPoint Sensitivity | 250 (default: 128) |
| TrackPoint Speed | 120 (default: 97) |
| TrackPoint Drift Time | 25 (fixes cursor drift) |
| Keyboard | QMK-compatible (udev rules enabled) |

### Display
| Setting | Value |
|---------|-------|
| Primary Monitor | eDP-1 |
| Resolution | 3840x2400 |
| External Monitor Position | left |

### Audio
| Service | Status |
|---------|--------|
| PipeWire | Enabled |
| ALSA Support | Enabled (32-bit) |
| PulseAudio Compat | Enabled |
| JACK Support | Enabled |

## Boot Configuration

```nix
boot = {
  loader.systemd-boot.enable = true;
  loader.efi.canTouchEfiVariables = true;
  loader.efi.efiSysMountPoint = "/boot/efi";
  kernelParams = [ "mem_sleep_default=deep" ];
  blacklistedKernelModules = [ "nouveau" ];
};
```

## Enabled NixOS Modules

| Module | Status | Description |
|--------|--------|-------------|
| `modules.wm.hyprland` | Enabled | Hyprland compositor with greetd |
| `modules.docker` | Enabled | Container runtime |
| `modules.gcloud` | Enabled | Google Cloud SDK |
| `modules.python` | Enabled | Python development |
| `modules.fcitx5` | Enabled | Input method framework |
| `modules.fish` | Enabled | Fish shell |
| `modules.nix_ld` | Enabled | Dynamic linker for non-Nix binaries |
| `modules.genymotion` | Enabled | Android emulator |
| `modules.stubby` | Enabled | DNS-over-TLS |
| `modules.wifi` | Enabled | Wireless networking |
| `modules.sops` | Enabled | Secrets management |
| `modules.antigravity` | Enabled | Custom module |

## System Services

### Enabled Services
| Service | Purpose |
|---------|---------|
| OpenSSH | Remote access (key-only, no root) |
| Printing (CUPS) | Print daemon with PDF and Brother laser |
| Flatpak | Containerized application distribution |
| upower | Battery/power information |
| picom | Compositor for X11 fallback |
| ip_updater | Dynamic IP update service |

### Security Settings
- SSH root login: **Disabled**
- SSH password auth: **Disabled**
- Trusted users: root, sinh
- Firewall TCP ports: 22 (SSH)

## Nix Configuration

```nix
nix.settings = {
  experimental-features = [ "nix-command" "flakes" "ca-derivations" ];
  trusted-users = [ "root" "sinh" ];
  auto-optimise-store = true;
};
nix.gc = {
  automatic = false;
  dates = "weekly";
  options = "--delete-older-than 28d";
};
```

## Environment Variables

### System-Level
| Variable | Value |
|----------|-------|
| `WLR_NO_HARDWARE_CURSORS` | 1 |
| `NIXOS_OZONE_WL` | 1 |
| `XDG_CURRENT_DESKTOP` | Hyprland |
| `XDG_SESSION_TYPE` | wayland |
| `XDG_SESSION_DESKTOP` | Hyprland |

### User-Level
| Variable | Value |
|----------|-------|
| `EDITOR` | nvim |
| `BROWSER` | zen-twilight |
| `LEFT_MONITOR` | eDP-1 |
| `IMSETTINGS_MODULE` | fcitx |
