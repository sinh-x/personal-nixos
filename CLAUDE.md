# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### System Management
- **Rebuild system**: `sudo sys rebuild` (wrapper for `nixos-rebuild switch --flake .#`)
- **Test configuration** (ephemeral, faster): `sudo sys test` (uses `nixos-rebuild test --no-reexec --flake .#`)
- **Update flake inputs**: `nix flake update`
- **Clean Nix store**: `sys clean`

### Development
- **Enter dev shell**: `nix develop` (includes pre-commit hooks, snowfall-flake tools, nix-inspect)
- **Format code**: `nixfmt <file>` (RFC-style)
- **Check for unused code**: `deadnix --edit <file>`
- **Static analysis**: `statix check`
- **Run checks**: `nix flake check`

### Building
- **Build package**: `nix build .#<package-name>`
- **Build system**: `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel`
- **Show outputs**: `nix flake show`

## Architecture

### Snowfall Lib Organization
This repository uses **Snowfall Lib** which provides automatic module discovery. All directories follow Snowfall conventions:

- **Auto-discovered**: Modules, packages, overlays, shells, checks are automatically loaded from their respective directories
- **Namespace**: `sinh-x` for home modules; `modules.*` for NixOS modules
- **Systems**: Three hosts - Emberroot (desktop, Hyprland), Elderwood (desktop, BSPWM), Drgnfly (laptop, BSPWM)

### Directory Structure

```
systems/x86_64-linux/<hostname>/
  ├── default.nix              # System configuration
  ├── hardware-configuration.nix
  └── wifi-networks.nix (optional)

home/sinh/
  ├── global/                   # Shared home config
  └── <hostname>.nix           # Per-host home config

modules/
  ├── nixos/                    # System modules (modules.*)
  │   ├── wm/{bspwm,hyprland}
  │   ├── default-desktop
  │   └── users/sinh
  └── home/                     # Home modules (sinh-x.*)
      ├── apps/
      ├── cli-apps/
      ├── coding/
      ├── wm/
      └── security/

lib/
  ├── module/                   # Helper functions (mkOpt, enabled/disabled)
  ├── theme/                    # SCSS compilation
  └── file/                     # File utilities

packages/                       # Custom derivations
overlays/                       # Package overlays (including sinh-x projects)
```

### Configuration Flow
1. **System**: `systems/x86_64-linux/<hostname>/default.nix` defines hardware, nix settings, and enables `modules.*` options
2. **Home**: `home/sinh/<hostname>.nix` imports `./global` and enables `sinh-x.*` options
3. **Modules**: Auto-discovered by Snowfall, define namespaced options
4. **Overlays**: `overlays/sinh-x/default.nix` exposes external flake inputs (pomodoro, wallpaper, gitstatus, ip_updater, nixvim/Neve)

### Module Patterns

**NixOS modules** use `modules.*` namespace:
```nix
options.modules.<name> = {
  enable = mkEnableOption "description";
};
```

**Home modules** use `${namespace}.*` (resolves to `sinh-x.*`):
```nix
options.${namespace}.<category>.<name> = {
  enable = mkEnableOption "description";
};
```

### Custom Libraries
Located in `lib/module/default.nix`:
- `mkOpt` / `mkOpt'` - Create options with/without description
- `mkBoolOpt` / `mkBoolOpt'` - Boolean option shortcuts
- `enabled` / `disabled` - `{ enable = true/false; }` shortcuts
- `capitalize`, `boolToNum` - String/type utilities
- `default-attrs` / `nested-default-attrs` - Apply mkDefault to attrs

Available in `lib.theme/default.nix`:
- `compileSCSS` - Compile SCSS to CSS using sassc

### Secret Management
- **sops-nix** with age encryption
- Key: `age1u0h8j45ym4jqffhc6jlr8metcl4czylv7ct7ngusrxrklnfsgvmsd8qzvs`
- Config: `.sops.yaml`
- Secrets: `secrets/secrets.yaml`

### External Inputs (sinh-x projects)
Exposed via `overlays/sinh-x/default.nix`:
- `sinh-x-pomodoro` - CLI pomodoro timer
- `sinh-x-wallpaper` - Wallpaper manager
- `sinh-x-gitstatus` - Git status utility
- `sinh-x-ip_updater` - IP update service
- `sinh-x-nixvim` (Neve) - Neovim config (available as `pkgs.nixvim`)
- `zjstatus` - Zellij status bar

## Key Implementation Details

### Window Manager Setup
Two WM options exist (mutually exclusive per host):
- **BSPWM**: Extensive config in `modules/home/wm/bspwm/bspwm_config/` (scripts, themes, polybar, rofi)
- **Hyprland**: Configured via `modules/nixos/wm/hyprland/` and `modules/home/wm/hyprland/`

Each system enables one at the system level (`modules.wm.{bspwm,hyprland}`) and matching home config (`sinh-x.wm.{bspwm,hyprland}`).

### System Differences
- **Emberroot**: Desktop, Hyprland, VSCode, Docker, Claude Code, Zen Browser, high-end GPU (NVIDIA + Intel)
- **Elderwood**: Desktop, BSPWM, minimal tools (anydesk, sct), displaylink support
- **Drgnfly**: Laptop, BSPWM, CLI-focused, backup tools, displaylink support

### Pre-commit Hooks
Defined in `checks/pre-commit-hooks/default.nix`:
- **deadnix** - Auto-remove unused code (`--edit`)
- **nixfmt** - RFC-style formatting
- **statix** - Static analysis
- **luacheck** - Lua linting
- **pre-commit-hook-ensure-sops** - Verify SOPS encryption

Automatically enabled in dev shell.

## Development Workflow

### Testing Changes
Always test before committing:
```bash
sudo sys test  # Fast, ephemeral build
sudo sys rebuild  # Apply changes permanently
```

### Adding a Module
1. Create `modules/{nixos,home}/<category>/<name>/default.nix`
2. Define options under appropriate namespace
3. Snowfall auto-discovers it
4. Enable in system/home config

### Adding a Package
1. Create `packages/<name>/default.nix`
2. Snowfall auto-exposes as overlay
3. Use as `pkgs.<name>` in configs

### Fish Shell Configuration
Primary shell config in `modules/home/cli-apps/fish/default.nix`:
- Plugins managed via home-manager
- Abbreviations defined inline
- Shell environment variables set here

### BSPWM Configuration Files
Home config uses declarative file copy:
```nix
home.file.".config/bspwm" = {
  source = ./bspwm_config;
  recursive = true;
};
```

All scripts/configs in `modules/home/wm/bspwm/bspwm_config/` are copied to `~/.config/bspwm/`.

## Kiro System - Spec-Driven Development

This project uses an adaptation of Amazon's **Kiro System** for structured feature development.

### Kiro Workflow (3-Phase Approach)
1. **Requirements** (`requirements.md`) - What needs to be built
2. **Design** (`design.md`) - How it will be built
3. **Tasks** (`tasks.md`) - Step-by-step implementation plan

### Directory Structure
- `.kiro/specs/{feature-name}/` - Individual feature specifications
- `.kiro/bugs/{bug-name}/` - Bug fix documentation
- `.kiro/kiro-system-templates/` - Templates and documentation
  - `requirements_template.md` - Template for requirements
  - `design_template.md` - Template for technical design
  - `tasks_template.md` - Template for implementation tasks
  - `bug_report_template.md` - Template for bug reports
  - `how_kiro_works.md` - Detailed Kiro documentation

### How to Work with Kiro

#### When Creating New Features:
1. **Check for existing specs first**: Look in `.kiro/specs/` for any existing feature documentation
2. **Use templates**: Copy templates from `.kiro/kiro-system-templates/` when creating new specs
3. **Follow the 3-phase process**: Requirements → Design → Tasks → Implementation
4. **Require approval**: Each phase needs explicit user approval before proceeding

#### Template Usage:
- **Requirements**: Use `requirements_template.md` to create user stories and EARS acceptance criteria
- **Design**: Use `design_template.md` for technical architecture and component design
- **Tasks**: Use `tasks_template.md` to break down implementation into numbered, actionable tasks

#### During Implementation:
- **Reference requirements**: Always link tasks back to specific requirements
- **Work incrementally**: Implement tasks one at a time, not all at once
- **Validate against specs**: Ensure implementations match the design and requirements
- **Update documentation**: Keep specs updated if changes are needed

#### Key Behaviors:
- **Always suggest using Kiro** when user wants to build new features
- **Guide through templates** if user is unfamiliar with the process
- **Enforce the approval process** - don't skip phases
- **Maintain traceability** from requirements to code

### When to Use Each Workflow

| Change Type | Workflow | Documentation |
|-------------|----------|---------------|
| **Quick fix** (1-2 files, obvious solution) | Skip specs | Good commit message |
| **Bug fix** (needs investigation) | Bug workflow | `.kiro/bugs/` |
| **Small feature** (< 3 tasks) | Judgment call | Consider skipping specs |
| **Medium/Large feature** | Full Kiro | `.kiro/specs/` |

#### Bug Fix Workflow (Report → Analyze → Fix → Verify)
For bugs requiring investigation:
1. Create `.kiro/bugs/<bug-name>/report.md` using `bug_report_template.md`
2. Document the problem, root cause, solution, and verification
3. Lighter weight than full specs - no requirements/design phases needed
