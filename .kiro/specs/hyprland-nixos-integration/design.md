# Hyprland NixOS Integration Design Document

## Overview

This design document specifies the technical implementation of Hyprland window manager configuration management through NixOS/home-manager. The feature enables declarative, version-controlled management of Hyprland configurations by mirroring the existing BSPWM module pattern. The implementation uses Snowfall Lib's automatic module discovery, home-manager's file management, and follows the established `sinh-x.*` namespace convention.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Git Repository Layer                      │
│  .kiro/specs/hyprland-nixos-integration/                    │
│  modules/home/wm/hyprland/                                   │
│    ├── default.nix                (Module Definition)        │
│    └── hypr_config/               (Source Configs)           │
│         ├── hyprland.conf                                    │
│         ├── hyprtheme.conf                                   │
│         ├── scripts/              (25+ executable scripts)   │
│         ├── rofi/                 (Rofi themes)              │
│         ├── waybar/               (Status bar config)        │
│         └── ...                   (105 total files)          │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ nixos-rebuild / home-manager switch
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Nix Store Layer                           │
│  /nix/store/xxxxx-home-manager-files/                       │
│    └── .config/hypr/              (Read-only)               │
│         └── [all config files]                              │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ Symlink via home.file
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    User Home Layer                           │
│  ~/.config/hypr/                  (Symlinks)                │
│    ├── hyprland.conf       -> /nix/store/.../hyprland.conf  │
│    ├── scripts/            -> /nix/store/.../scripts/       │
│    └── ...                                                   │
│                                                              │
│  Hyprland Process reads configs from symlinked locations    │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Source Phase**: User commits config changes to `modules/home/wm/hyprland/hypr_config/`
2. **Build Phase**: `home-manager` evaluates `default.nix` and copies configs to Nix store
3. **Activation Phase**: Home-manager creates symlinks from `~/.config/hypr/` to Nix store paths
4. **Runtime Phase**: Hyprland reads configuration from symlinked paths
5. **Update Phase**: On rebuild, symlinks are atomically updated to new Nix store paths

### Technology Stack

**Configuration Management**
- NixOS 26.05 (unstable)
- home-manager (integrated as NixOS module)
- Snowfall Lib (module auto-discovery)
- Nix language for module definition

**Window Manager**
- Hyprland 0.53+ (managed by `modules.wm.hyprland` system module)
- Dependencies: waybar, rofi, mako, wlogout, kitty, etc. (already in system module)

**Version Control**
- Git for configuration tracking
- `.gitignore` for excluding auto-generated files (optional)

## Components and Interfaces

### Core Components

#### 1. Home-Manager Module (`modules/home/wm/hyprland/default.nix`)

```nix
{
  lib,
  config,
  namespace,  # Provided by Snowfall Lib, resolves to "sinh-x"
  ...
}:
with lib;
let
  cfg = config.${namespace}.wm.hyprland;
in
{
  # Module options definition
  options.${namespace}.wm.hyprland = {
    enable = mkEnableOption "Hyprland config using hm";
  };

  # Module implementation
  config = mkIf cfg.enable {
    # Package list (empty, packages managed by system module)
    home.packages = [ ];

    # File deployment configuration
    home.file.".config/hypr" = {
      source = ./hypr_config;
      recursive = true;
      # All files copied recursively from hypr_config/ to ~/.config/hypr/
    };
  };
}
```

**Interface**:
- **Input**: `config.sinh-x.wm.hyprland.enable` (boolean)
- **Output**: Symlinks in `~/.config/hypr/` pointing to Nix store
- **Side Effects**: Existing `~/.config/hypr/` must not exist (conflict prevention)

#### 2. Configuration Directory Structure

```
modules/home/wm/hyprland/hypr_config/
├── hyprland.conf                    # Main Hyprland config (752 lines)
├── hyprtheme.conf                   # Theme variables
├── hyprlock.conf                    # Lock screen config
├── hypridle.conf                    # Idle management config
├── workspaces.conf                  # Monitor/workspace config
├── scripts/                         # Executable scripts (28 files)
│   ├── alacritty
│   ├── brightness
│   ├── colorpicker
│   ├── generate_workspace_config    # Dynamic workspace generator
│   ├── kitty
│   ├── lockscreen
│   ├── monitor_watcher              # Monitor hotplug handler
│   ├── rofi_launcher
│   ├── rofi_powermenu
│   ├── screenshot
│   ├── startup                      # Autostart script
│   ├── volume
│   └── ...
├── rofi/                            # Rofi theme files
│   ├── launcher.rasi
│   ├── powermenu.rasi
│   ├── screenshot.rasi
│   └── shared/
│       ├── colors.rasi
│       └── fonts.rasi
├── waybar/                          # Status bar config
│   ├── config                       # Waybar modules config
│   ├── style.css                    # Waybar styling
│   └── modules                      # Custom modules
├── mako/                            # Notification daemon
│   ├── config
│   └── icons/
├── wlogout/                         # Logout menu
│   ├── layout
│   ├── style.css
│   └── icons/
├── alacritty/                       # Terminal emulator configs
│   ├── alacritty.toml
│   ├── colors.toml
│   └── fonts.toml
├── kitty/
│   ├── kitty.conf
│   ├── colors.conf
│   └── fonts.conf
├── foot/
│   ├── foot.ini
│   ├── colors.ini
│   └── fonts.ini
├── wallpapers/
│   ├── wallpaper.png
│   └── lockscreen.png -> wallpaper.png
└── theme/
    ├── theme.sh                     # Theme switcher
    ├── current.bash                 # Current theme state
    └── default.bash                 # Default theme
```

#### 3. User Configuration Entry Point (`home/sinh/Emberroot.nix`)

```nix
{
  imports = [ ./global ];

  sinh-x = {
    # ... other configs ...

    wm = {
      bspwm.enable = false;      # Disable BSPWM
      hyprland.enable = true;    # Enable Hyprland
    };
  };
}
```

### Integration Points

#### System Module Integration (`modules/nixos/wm/hyprland/default.nix`)

```nix
# Already exists - provides system-level setup
{
  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = pkgs.hyprland;
    };

    environment.systemPackages = with pkgs; [
      # All Hyprland dependencies
      waybar mako wofi rofi kitty foot
      hyprpicker hyprshot wl-clipboard cliphist
      # ... (50+ packages)
    ];
  };
}
```

**Integration Flow**:
1. System module (`modules.wm.hyprland`) installs Hyprland + packages
2. Home module (`sinh-x.wm.hyprland`) deploys user configurations
3. Both modules must be enabled for full functionality

### Snowfall Lib Integration

```nix
# Automatic module discovery by Snowfall Lib
# No manual imports needed in flake.nix

# Module path determines namespace:
# modules/home/wm/hyprland/default.nix
#   → sinh-x.wm.hyprland (auto-discovered)

# Snowfall provides:
# - namespace parameter (resolves to "sinh-x")
# - Automatic loading from modules/home/**/*.nix
# - Integration with home-manager
```

## File Deployment Strategy

### Home-Manager File Management

```nix
home.file.".config/hypr" = {
  source = ./hypr_config;
  recursive = true;
};
```

**Behavior**:
- **Copy Phase**: `hypr_config/` → `/nix/store/xxxxx-home-manager-files/.config/hypr/`
- **Link Phase**: `~/.config/hypr/` → `/nix/store/xxxxx-home-manager-files/.config/hypr/` (symlink)
- **Permissions**: Preserve from source (scripts remain executable if set in git)
- **Atomicity**: Symlink updates are atomic (generation switching)

### Handling Dynamic Files

**Observation**: `workspaces.conf` is auto-generated by `scripts/generate_workspace_config`

**Design Decision**: Include current version in git
- File can be regenerated at runtime if monitors change
- Keep tracked version as baseline/fallback
- Scripts will overwrite as needed (symlink allows this through persistence)

**Note**: Since Nix store is read-only, runtime generation would need to write elsewhere. Current implementation likely already handles this by having the script generate to a writable location or update through hyprctl.

### Script Execution Permissions

**Implementation**:
```bash
# Before copying to git, ensure scripts are executable
cd ~/.config/hypr/scripts
chmod +x *

# Git will track executable bit (mode 100755)
git add scripts/
git commit -m "Add executable scripts"
```

**Nix Handling**:
- home-manager preserves executable bits from git
- Scripts with mode `100755` in git → executable in Nix store
- Verification: `ls -l ~/.config/hypr/scripts/` after activation

## Error Handling

### Activation Conflicts

**Scenario**: Existing `~/.config/hypr/` directory conflicts with home-manager

```
Error: Existing file '/home/sinh/.config/hypr/hyprland.conf' would be clobbered
```

**Resolution Strategy**:
```bash
# Manual backup (recommended approach)
# User must backup before first activation
mv ~/.config/hypr ~/.config/hypr.backup.$(date +%Y%m%d)
home-manager switch --flake .#
```

**Alternative** (if needed):
```nix
# Force overwrite in module (use with caution)
home.file.".config/hypr" = {
  source = ./hypr_config;
  recursive = true;
  force = true;  # Override existing files
};
```

**Design Decision**: Require manual backup to prevent accidental data loss

### Module Conflicts

**Scenario**: Both BSPWM and Hyprland enabled simultaneously

**Detection** (optional enhancement):
```nix
config = mkIf cfg.enable {
  assertions = [
    {
      assertion = !(config.sinh-x.wm.bspwm.enable && cfg.enable);
      message = "Cannot enable both BSPWM and Hyprland. Disable one in home config.";
    }
  ];

  # ... rest of config
};
```

**Design Decision**: Assertion optional; rely on user to manage WM selection

### Missing System Module

**Scenario**: Home module enabled without system module

**Impact**: Configs deployed but Hyprland binary not installed

**Mitigation**: Documentation warning; system will fail gracefully (configs present but WM not launchable)

## Testing Strategy

### Testing Checklist

**Phase 1: Build Verification**
- [ ] Module syntax is valid (Nix evaluation succeeds)
- [ ] All config files copied to Nix store
- [ ] Directory structure preserved
- [ ] Script permissions maintained (executable bit)

**Phase 2: Activation Verification**
- [ ] Symlinks created in `~/.config/hypr/`
- [ ] All 105 files present
- [ ] No permission errors
- [ ] No file conflicts

**Phase 3: Functional Verification**
- [ ] Hyprland starts without errors
- [ ] All keybindings work (SUPER+Return, SUPER+D, etc.)
- [ ] Scripts execute correctly (rofi_launcher, volume, brightness)
- [ ] Waybar displays properly
- [ ] Mako notifications work
- [ ] Monitor hotplug detection works
- [ ] Workspace configuration loads

**Phase 4: Integration Verification**
- [ ] No conflicts when BSPWM disabled
- [ ] System module packages available
- [ ] Environment variables set correctly

**Phase 5: Rollback Verification**
- [ ] Previous generation restores correctly
- [ ] Symlinks revert to previous state
- [ ] Hyprland functionality preserved after rollback

### Testing Commands

```bash
# Build test
nix build .#homeConfigurations.sinh@Emberroot.activationPackage

# Dry run
home-manager switch --flake .# --dry-run

# Activation
home-manager switch --flake .#

# Verification
ls -la ~/.config/hypr/
find ~/.config/hypr/scripts -type f -not -executable
hyprctl version

# Rollback test
home-manager generations
/nix/store/xxxxx-home-manager-generation-NNN/activate
```

## Migration Strategy

### Initial Migration Steps

**Step 1: Backup**
```bash
# No action - documentation only
# User will perform manual backup before activation
```

**Step 2: Copy Configuration**
```bash
mkdir -p modules/home/wm/hyprland/hypr_config
cp -r ~/.config/hypr/* modules/home/wm/hyprland/hypr_config/
```

**Step 3: Set Permissions**
```bash
chmod +x modules/home/wm/hyprland/hypr_config/scripts/*
```

**Step 4: Create Module**
```bash
# Create modules/home/wm/hyprland/default.nix
# (Content specified in Components section)
```

**Step 5: Update Home Config**
```nix
# Edit home/sinh/Emberroot.nix
sinh-x.wm = {
  bspwm.enable = false;
  hyprland.enable = true;
};
```

**Step 6: Git Commit**
```bash
git add modules/home/wm/hyprland/
git commit -m "Add Hyprland home-manager module"
```

**Step 7: Backup Existing**
```bash
mv ~/.config/hypr ~/.config/hypr.backup.$(date +%Y%m%d)
```

**Step 8: Activate**
```bash
home-manager switch --flake .#
```

**Step 9: Verify**
```bash
# Test all functionality (see Testing Strategy)
```

**Step 10: Final Commit**
```bash
# If verification successful
git push  # Optional: push to remote

# If issues found
# Rollback and investigate
home-manager generations
/nix/store/xxxxx-previous-generation/activate
```

### Rollback Strategy

**Immediate Rollback**:
```bash
# List generations
home-manager generations

# Activate previous generation
/nix/store/xxxxx-home-manager-generation-NNN/activate
```

**Full Revert**:
```bash
# Option 1: Disable module
# Edit home/sinh/Emberroot.nix
sinh-x.wm.hyprland.enable = false;
home-manager switch --flake .#

# Option 2: Restore manual backup
rm -rf ~/.config/hypr
mv ~/.config/hypr.backup.YYYYMMDD ~/.config/hypr

# Option 3: Git revert
git revert <commit-hash>
home-manager switch --flake .#
```

## Performance Considerations

### Build Performance
- **File Count**: ~105 files
- **Total Size**: < 5MB
- **Copy Time**: < 1 second
- **Store Impact**: ~5MB per generation (negligible)

### Activation Performance
- **Symlink Operations**: O(n) for n files
- **Activation Time**: < 2 seconds total
- **No Runtime Impact**: Existing sessions unaffected

### Runtime Performance
- **Config Loading**: Identical to manual setup
- **Script Execution**: No overhead (standard filesystem access)
- **Memory Usage**: No change

## Security Considerations

### File Permissions
- **Configs**: 0644 (world-readable)
- **Scripts**: 0755 (world-executable)
- **Symlinks**: Follow target permissions

### Nix Store Properties
- **Immutability**: Files in `/nix/store/` are read-only
- **Atomicity**: Updates are atomic via symlink switching
- **Rollback**: Previous generations preserved

### Secret Management
- **No Secrets**: Hyprland configs don't contain sensitive data
- **Future**: If needed, use sops-nix integration

### Trust Model
- **Source**: User's git repository (trusted)
- **Execution**: Scripts run with user privileges
- **Isolation**: No privileged operations

## Assumptions and Dependencies

### Technical Assumptions
- Hyprland 0.53+ installed via system module
- Git repository initialized and functional
- Snowfall Lib configured correctly
- home-manager integrated as NixOS module
- User understands declarative configuration

### External Dependencies
**System Packages** (via `modules.nixos.wm.hyprland`):
- Core: hyprland, waybar, mako, rofi, wofi
- Terminals: kitty, foot, alacritty
- Utilities: wl-clipboard, cliphist, grim, slurp
- Controls: brightnessctl, pamixer
- Total: 50+ packages

**System Services**:
- pipewire (audio)
- polkit (authentication)
- xdg-desktop-portal-hyprland (portals)

**Environment Variables**:
- `XDG_CURRENT_DESKTOP=Hyprland`
- `NIXOS_OZONE_WL=1`
- `WLR_NO_HARDWARE_CURSORS=1`

### Risk Mitigation
- **Data Loss**: Mandatory manual backup before first activation
- **Rollback**: NixOS/home-manager generation system
- **Version Control**: Git history for all changes
- **Idempotency**: Safe to rebuild multiple times

---

**Requirements Traceability**:

This design addresses all requirements from `requirements.md`:

| Requirement | Design Element | Status |
|------------|----------------|--------|
| Configuration management via home-manager | Module with `home.file` deployment | ✓ |
| Git version control | All configs in git repository | ✓ |
| BSPWM pattern replication | Identical structure and approach | ✓ |
| Snowfall Lib integration | Auto-discovered module with namespace | ✓ |
| Atomic updates | Symlink switching via generations | ✓ |
| Script execution | Executable bit preservation | ✓ |
| File structure preservation | Recursive directory copy | ✓ |
| Performance targets | < 5 seconds activation | ✓ |
| Security through immutability | Nix store read-only | ✓ |
| Multi-host potential | Designed for host-specific configs | ✓ |

**Review Status**: Draft

**Last Updated**: 2026-01-12

**Reviewers**: sinh (awaiting approval)
