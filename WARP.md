# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Common Commands

### System Management
- **Rebuild system**: `sudo sys rebuild` or `sudo nixos-rebuild switch --flake .#`
- **Test configuration** (ephemeral, faster): `sudo sys test` or `sudo nixos-rebuild test --fast --flake .#`
- **Update flake inputs**: `nix flake update`
- **Clean Nix store**: `sys clean` (runs garbage collection and store optimization)

### Development Environment
- **Enter dev shell**: `nix develop` (includes pre-commit hooks, snowfall-flake tools)
- **Run pre-commit checks**: Automatically enabled when entering dev shell
- **Format Nix files**: `nixfmt` (RFC-style formatting)
- **Check for unused code**: `deadnix --edit`
- **Static analysis**: `statix check`

### Common Flake Operations
- **Check flake**: `nix flake check`
- **Show flake outputs**: `nix flake show`
- **Build specific package**: `nix build .#<package-name>`
- **Build system configuration**: `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel`

## Architecture Overview

### Flake Structure (Snowfall Lib)
This repository uses **Snowfall Lib** for organization, which provides automatic module discovery and a namespace system (`sinh-x`).

**Key directories**:
- `systems/x86_64-linux/<hostname>/` - NixOS system configurations (Emberroot, Drgnfly, Elderwood)
- `home/sinh/<hostname>.nix` - Home Manager configurations per host
- `home/sinh/global/` - Shared Home Manager configuration
- `modules/nixos/` - Custom NixOS modules
- `modules/home/` - Custom Home Manager modules
- `packages/` - Custom package derivations
- `overlays/` - Package overlays
- `lib/` - Utility functions for modules and themes
- `secrets/` - SOPS-encrypted secrets
- `shells/` - Development shells
- `checks/` - Pre-commit hooks and checks

### Module System
Modules are namespaced under `sinh-x` and use a hierarchical option structure:

**NixOS modules** (`modules.`):
- `default-desktop` - Base desktop environment configuration
- `wm.{bspwm,hyprland}` - Window managers
- `r_setup`, `python`, `nix_ld` - Language environments
- `fcitx5`, `fish`, `gcloud` - Application/tool configs
- `virtualbox`, `genymotion` - Virtualization
- `stubby` - DNS-over-TLS
- `sops` - Secret management

**Home Manager modules** (`sinh-x.`):
- `apps.*` - Application configurations (browsers, utilities, themes)
- `cli-apps.*` - Terminal, shell, multiplexers, editors
- `coding.*` - Development tools (VSCode, etc.)
- `multimedia.*` - Media tools and players
- `office.*` - Office suite
- `social-apps.*` - Communication apps
- `security.*` - Security tools (Bitwarden, SOPS)
- `wm.*` - Window manager home configurations
- `personal-scripts.*` - Custom user scripts

### Configuration Flow
1. **System level**: `systems/x86_64-linux/<hostname>/default.nix` imports hardware config and enables modules
2. **Home level**: `home/sinh/<hostname>.nix` imports global config and enables user-specific modules
3. **Modules**: Define options under namespace, automatically discovered by Snowfall
4. **Packages**: Custom packages in `packages/` available as `pkgs.sinh-x.<package>`

### Custom Libraries
- `lib.module.mkOpt*` - Option creation helpers
- `lib.module.enabled/disabled` - Shorthand for enable flags
- `lib.theme.compileSCSS` - SCSS to CSS compilation
- `lib.override-meta` - Package metadata overriding

### Secret Management
- Uses **sops-nix** with age encryption
- Age key configured in `.sops.yaml`
- Secrets stored in `secrets/secrets.yaml`
- Decrypted at activation time

### External Flake Inputs
Notable custom inputs:
- `sinh-x-pomodoro`, `sinh-x-wallpaper`, `sinh-x-gitstatus`, `sinh-x-ip_updater` - Personal tools
- `sinh-x-nixvim` (Neve) - Neovim configuration
- `hyprland` + plugins - Wayland compositor
- `zen-browser` - Browser
- `zjstatus` - Zellij status bar

## Development Practices

### Adding a New System
1. Create `systems/x86_64-linux/<hostname>/default.nix`
2. Create `home/sinh/<hostname>.nix`
3. Enable desired modules under `modules.*` and `sinh-x.*`

### Adding a New Module
1. Create module in `modules/nixos/<name>/default.nix` or `modules/home/<category>/<name>/default.nix`
2. Define options under `options.${namespace}.<name>` (NixOS) or `options.${namespace}.<category>.<name>` (Home Manager)
3. Snowfall automatically discovers and loads the module

### Testing Changes
Always test configuration changes with `sudo sys test` before committing. This builds the configuration without making it the default boot option.

### Pre-commit Hooks
The dev shell enables automatic pre-commit hooks:
- `deadnix` - Remove unused Nix code (auto-edits)
- `nixfmt` - Format with RFC-style
- `statix` - Lint and suggest improvements
- `luacheck` - Lua linting
- `pre-commit-hook-ensure-sops` - Verify SOPS secrets are encrypted

Run `nix develop` to activate hooks in your shell.
