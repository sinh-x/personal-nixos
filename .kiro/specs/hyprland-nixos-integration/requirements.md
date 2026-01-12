# Hyprland NixOS Integration Requirements

## 1. Introduction

This document specifies the requirements for integrating Hyprland window manager configuration into the NixOS/home-manager declarative configuration system. The feature will enable version-controlled, reproducible management of Hyprland configurations following the existing BSPWM pattern in this repository.

**Architecture Overview**: This integration will create a home-manager module that declaratively manages Hyprland configuration files by copying them from the Nix store to `~/.config/hypr/`. The approach mirrors the existing BSPWM implementation pattern, using Snowfall Lib's automatic module discovery with the `sinh-x.wm.hyprland` namespace.

## 2. User Stories

### System Administrator / NixOS User
- **As a NixOS user**, I want to manage my Hyprland configuration through home-manager, so that my desktop environment is reproducible and version-controlled
- **As a system administrator**, I want to track changes to my Hyprland config in git, so that I can revert problematic changes and review configuration history
- **As a NixOS user**, I want to switch between BSPWM and Hyprland easily, so that I can use the appropriate window manager for different systems

### Developer / Power User
- **As a developer**, I want my Hyprland scripts and configs managed by Nix, so that they persist across system rebuilds
- **As a power user**, I want to maintain custom Hyprland configurations (keybindings, themes, scripts), so that my workflow is preserved
- **As a multi-system user**, I want consistent Hyprland configuration across my machines (Emberroot desktop), so that my experience is uniform

## 3. Acceptance Criteria

### Configuration Management Requirements
- **WHEN** user enables `sinh-x.wm.hyprland` in home-manager config, **THEN** the system **SHALL** copy all Hyprland configuration files to `~/.config/hypr/`
- **WHEN** user runs `nixos-rebuild switch`, **THEN** the system **SHALL** update Hyprland configurations atomically without breaking the running session
- **IF** Hyprland config files already exist in `~/.config/hypr/`, **THEN** the system **SHALL** create symlinks from Nix store (similar to BSPWM pattern)
- **WHEN** user disables Hyprland module, **THEN** the system **SHALL** not remove existing configurations (safety measure)

### File Structure Requirements
- **WHEN** module is activated, **THEN** the system **SHALL** preserve the complete directory structure from `modules/home/wm/hyprland/hypr_config/` to `~/.config/hypr/`
- **WHEN** scripts are deployed, **THEN** the system **SHALL** maintain executable permissions on all script files
- **IF** configuration contains auto-generated files (workspaces.conf), **THEN** the system **SHALL** handle them appropriately without conflicts

### Version Control Requirements
- **WHEN** configurations are modified, **THEN** changes **SHALL** be tracked in git repository
- **WHEN** user commits changes, **THEN** all Hyprland config files **SHALL** be included in `.kiro/specs/hyprland-nixos-integration/` or `modules/home/wm/hyprland/hypr_config/`
- **IF** user makes changes to `~/.config/hypr/`, **THEN** those changes **SHALL NOT** persist after rebuild (unless committed to git)

### User Experience Requirements
- **WHEN** switching from BSPWM to Hyprland, **THEN** the system **SHALL** allow enabling only one WM module at a time in home config
- **WHEN** user enables Hyprland module, **THEN** system rebuild **SHALL** complete without manual intervention
- **WHEN** Hyprland is active, **THEN** all keybindings and scripts **SHALL** function identically to the current manual configuration

### Performance Requirements
- **WHEN** home-manager activation runs, **THEN** file copying **SHALL** complete within 5 seconds for ~105 configuration files
- **WHEN** system rebuilds, **THEN** Hyprland config updates **SHALL NOT** cause noticeable delay in activation
- **WHEN** Hyprland starts, **THEN** all sourced configuration files **SHALL** be available immediately

### Security Requirements
- **WHEN** configurations are deployed, **THEN** the system **SHALL** maintain proper file permissions (0644 for configs, 0755 for scripts)
- **IF** configuration contains sensitive data, **THEN** the system **SHALL** use sops-nix for encryption (future consideration)
- **WHEN** scripts execute, **THEN** they **SHALL** only have access to user-level permissions

## 4. Technical Architecture

### Frontend Architecture
- **Framework**: NixOS home-manager module system
- **State Management**: Declarative configuration through Nix expressions
- **UI Components**: N/A (configuration management only)
- **Styling**: Managed through Hyprland theme files (hyprtheme.conf)

### Backend Architecture
- **Module System**: Snowfall Lib with automatic module discovery
- **Namespace**: `sinh-x.wm.hyprland` for home module
- **File Deployment**: `home.file` with recursive directory copying
- **Integration**: Existing NixOS Hyprland module at `modules/nixos/wm/hyprland/`

### Key Libraries & Dependencies
- **Snowfall Lib**: Module auto-discovery and namespace management
- **home-manager**: File management and user environment configuration
- **Hyprland**: Window manager (already configured at system level)

## 5. Feature Specifications

### Core Features
1. **Home-Manager Module**: Create `modules/home/wm/hyprland/default.nix` following BSPWM pattern
2. **Configuration Directory**: Copy `~/.config/hypr/` to `modules/home/wm/hyprland/hypr_config/`
3. **Declarative Deployment**: Use `home.file` to deploy configs from Nix store
4. **Enable/Disable Toggle**: `sinh-x.wm.hyprland.enable` option in home config

### Configuration Components
1. **Core Configs**: hyprland.conf, hyprtheme.conf, hyprlock.conf, hypridle.conf
2. **Scripts Directory**: All executable scripts (25+ files)
3. **Application Configs**: rofi, waybar, mako, wlogout, kitty, alacritty, foot
4. **Theme Assets**: wallpapers, icons, fonts configurations

### Integration Features
1. **System Module Integration**: Works with existing `modules.wm.hyprland.enable` (system-level)
2. **Mutual Exclusivity**: Prevent BSPWM and Hyprland from being enabled simultaneously
3. **Host-Specific Config**: Enable Hyprland only on Emberroot initially

## 6. Success Criteria

### User Experience
- **WHEN** user enables Hyprland module and rebuilds, **THEN** user **SHALL** have fully functional Hyprland environment identical to current setup
- **WHEN** user modifies configs in git and rebuilds, **THEN** user **SHALL** see changes reflected in Hyprland immediately
- **WHEN** user switches from BSPWM to Hyprland on Emberroot, **THEN** system **SHALL** boot into correct WM without manual intervention

### Technical Performance
- **WHEN** home-manager activation runs, **THEN** the process **SHALL** complete within normal activation time (< 10 seconds)
- **WHEN** 105 config files are deployed, **THEN** deployment **SHALL** not cause system slowdown
- **WHEN** Hyprland loads, **THEN** startup time **SHALL** be equivalent to manual configuration

### Business Goals
- **WHEN** Hyprland config is in git, **THEN** configuration **SHALL** be reproducible on clean system install
- **WHEN** user reviews git history, **THEN** all Hyprland config changes **SHALL** be visible and revertible
- **WHEN** new Hyprland features are added, **THEN** integration process **SHALL** be simple (copy files and rebuild)

## 7. Assumptions and Dependencies

### Technical Assumptions
- User already has working Hyprland configuration in `~/.config/hypr/`
- System-level Hyprland module (`modules.nixos.wm.hyprland`) is already functional
- Snowfall Lib is properly configured for automatic module discovery
- User understands NixOS/home-manager declarative configuration

### External Dependencies
- Hyprland package (already in system module)
- home-manager (already configured)
- Snowfall Lib (already in use)
- All Hyprland scripts dependencies (rofi, waybar, mako, etc.) already installed via system module

### Resource Assumptions
- User has ~105 configuration files totaling < 5MB
- Git repository has sufficient space for configuration files
- System has existing BSPWM module as reference implementation

## 8. Constraints and Limitations

### Technical Constraints
- Configuration files from Nix store are read-only by default
- Auto-generated files (workspaces.conf) may need special handling
- Symlinks from Nix store may conflict with applications expecting writable files
- Script shebangs must be compatible with NixOS environment

### Business Constraints
- Must maintain compatibility with existing BSPWM pattern
- Should not break existing Emberroot configuration
- Implementation should be completed in single session
- Must follow existing Snowfall Lib conventions

### Regulatory Constraints
- N/A (personal configuration management)

## 9. Risk Assessment

### Technical Risks
- **Risk**: File permissions may be incorrect after deployment from Nix store
  - **Likelihood**: Medium
  - **Impact**: High (scripts won't execute)
  - **Mitigation**: Test script execution after deployment; use explicit permission settings in module

- **Risk**: Auto-generated workspaces.conf may cause conflicts
  - **Likelihood**: High
  - **Impact**: Medium (monitor config won't update dynamically)
  - **Mitigation**: Exclude from git or make directory writable; document behavior

- **Risk**: Existing `~/.config/hypr/` may conflict with home-manager symlinks
  - **Likelihood**: High (first activation)
  - **Impact**: Medium (activation failure)
  - **Mitigation**: Backup and remove existing directory before first activation

### User Experience Risks
- **Risk**: User modifies files in `~/.config/hypr/` expecting changes to persist
  - **Likelihood**: High
  - **Impact**: Medium (confusion when changes disappear)
  - **Mitigation**: Document that changes must be made in git repo; consider warning in config comments

### Implementation Risks
- **Risk**: Missing dependencies cause scripts to fail
  - **Likelihood**: Low (already verified working)
  - **Impact**: High
  - **Mitigation**: Verify all dependencies are in system module package list

## 10. Non-Functional Requirements

### Scalability
- Configuration should support adding new WM modules (sway, river) using same pattern
- Pattern should scale to larger config directories (200+ files)
- Module should handle host-specific overrides for multi-system setups

### Availability
- Configuration deployment must not interrupt running Hyprland session
- Failed activation should not leave system in broken state
- Rollback via generation switching must restore previous configs

### Maintainability
- Module code should follow existing BSPWM pattern for consistency
- Configuration structure should match upstream Hyprland conventions
- Documentation should be minimal (pattern is self-explanatory)
- Changes to configs should be simple file edits followed by rebuild

### Usability
- Enable/disable should be single boolean toggle in home config
- No manual intervention required after module creation
- Error messages should clearly indicate configuration issues
- Compatible with existing NixOS generation rollback mechanism

## 11. Future Considerations

### Phase 2 Features
- Host-specific Hyprland configurations (Emberroot vs Elderwood vs Drgnfly)
- Dynamic workspace generation integration with NixOS
- Home-manager native Hyprland configuration (wayland.windowManager.hyprland)
- Per-host theme variations

### Integration Opportunities
- Unified WM switching mechanism (abstracted WM interface)
- Shared scripts directory for common functionality across WMs
- Theme management system for consistent styling across WMs and applications
- Integration with sinh-x-wallpaper for automated wallpaper management

### Technical Debt
- Current implementation uses file copying rather than native home-manager Hyprland module
- Some configuration is duplicated between NixOS and home-manager modules
- Scripts contain hardcoded paths that could be parameterized
- No validation of Hyprland configuration syntax before activation

---

**Document Status**: Draft

**Last Updated**: 2026-01-12

**Stakeholders**: sinh (system owner and developer)

**Related Documents**:
- `.kiro/kiro-system-templates/requirements_template.md`
- `modules/home/wm/bspwm/default.nix` (reference implementation)
- `modules/nixos/wm/hyprland/default.nix` (system-level module)

**Version**: 1.0
