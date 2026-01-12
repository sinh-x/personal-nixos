# Hyprland NixOS Integration Implementation Tasks

## Task Overview

This document breaks down the implementation of Hyprland NixOS/home-manager integration into actionable tasks. Each task follows the migration strategy defined in `design.md` and is designed to be completed incrementally with clear deliverables.

**Total Estimated Tasks**: 11 tasks organized into 5 phases

**Requirements Reference**: This implementation addresses all requirements from `requirements.md`

**Design Reference**: Technical approach defined in `design.md`

## Implementation Tasks

### Phase 1: Preparation & Backup

- [x] **1.1** Create module directory structure
  - **Description**: Create the module directory structure following Snowfall Lib conventions for home-manager modules
  - **Deliverables**:
    - Create `modules/home/wm/hyprland/` directory
    - Create `modules/home/wm/hyprland/hypr_config/` directory
  - **Requirements**: R1 (Configuration management), R3 (BSPWM pattern replication)
  - **Estimated Effort**: 1 minute
  - **Dependencies**: None
  - **Commands**:
    ```bash
    mkdir -p modules/home/wm/hyprland/hypr_config
    ```

- [x] **1.2** Copy Hyprland configuration to repository
  - **Description**: Copy all Hyprland configuration files from `~/.config/hypr/` to the repository maintaining structure
  - **Deliverables**:
    - All 105 configuration files copied to `modules/home/wm/hyprland/hypr_config/`
    - Directory structure preserved (scripts/, rofi/, waybar/, etc.)
  - **Requirements**: R1 (Configuration management), R6 (File structure preservation)
  - **Estimated Effort**: 2 minutes
  - **Dependencies**: Task 1.1
  - **Commands**:
    ```bash
    cp -r ~/.config/hypr/* modules/home/wm/hyprland/hypr_config/
    ```

- [x] **1.3** Set executable permissions on scripts
  - **Description**: Ensure all script files have executable permissions so Git tracks them correctly
  - **Deliverables**:
    - All files in `scripts/` directory have mode 755 (executable)
    - Git will track executable bit
  - **Requirements**: R6 (Script execution preservation)
  - **Estimated Effort**: 1 minute
  - **Dependencies**: Task 1.2
  - **Commands**:
    ```bash
    chmod +x modules/home/wm/hyprland/hypr_config/scripts/*
    ls -l modules/home/wm/hyprland/hypr_config/scripts/ | head -10  # Verify
    ```

### Phase 2: Module Creation

- [x] **2.1** Create home-manager module definition
  - **Description**: Create the Nix module file that defines the Hyprland home configuration following the BSPWM pattern exactly
  - **Deliverables**:
    - `modules/home/wm/hyprland/default.nix` created
    - Module uses `sinh-x.wm.hyprland` namespace
    - Module implements `home.file` deployment with recursive copy
  - **Requirements**: R1 (Configuration management), R3 (BSPWM pattern), R4 (Snowfall Lib)
  - **Estimated Effort**: 3 minutes
  - **Dependencies**: Task 1.3
  - **Implementation**:
    ```nix
    {
      lib,
      config,
      namespace,
      ...
    }:
    with lib;
    let
      cfg = config.${namespace}.wm.hyprland;
    in
    {
      options.${namespace}.wm.hyprland = {
        enable = mkEnableOption "Hyprland config using hm";
      };

      config = mkIf cfg.enable {
        home.packages = [ ];

        home.file.".config/hypr" = {
          source = ./hypr_config;
          recursive = true;
        };
      };
    }
    ```

- [x] **2.2** Verify module builds correctly
  - **Description**: Test that the Nix module evaluates without errors using dry-run build
  - **Deliverables**:
    - Module syntax is valid
    - No evaluation errors
    - Snowfall Lib detects module automatically
  - **Requirements**: R1 (Configuration management), R4 (Snowfall Lib integration)
  - **Estimated Effort**: 2 minutes
  - **Dependencies**: Task 2.1
  - **Commands**:
    ```bash
    # Dry run to check evaluation
    nix build .#homeConfigurations."sinh@Emberroot".activationPackage --dry-run
    ```

### Phase 3: Configuration Update

- [x] **3.1** Update home configuration to enable Hyprland module
  - **Description**: Modify `home/sinh/Emberroot.nix` to disable BSPWM and enable Hyprland module
  - **Deliverables**:
    - `home/sinh/Emberroot.nix` updated
    - `sinh-x.wm.bspwm.enable = false`
    - `sinh-x.wm.hyprland.enable = true`
  - **Requirements**: R1 (Configuration management), R3 (Mutual exclusivity)
  - **Estimated Effort**: 1 minute
  - **Dependencies**: Task 2.2
  - **Implementation**:
    Edit `home/sinh/Emberroot.nix`:
    ```nix
    sinh-x = {
      # ... other configs ...
      wm = {
        bspwm.enable = false;      # Disable BSPWM
        hyprland.enable = true;    # Enable Hyprland
      };
    };
    ```

- [x] **3.2** Stage and commit module to git
  - **Description**: Add all module files to git repository with descriptive commit message
  - **Deliverables**:
    - All files in `modules/home/wm/hyprland/` committed to git
    - Kiro spec files committed
    - Commit message follows convention
  - **Requirements**: R2 (Git version control)
  - **Estimated Effort**: 2 minutes
  - **Dependencies**: Task 3.1
  - **Commands**:
    ```bash
    git add modules/home/wm/hyprland/
    git add .kiro/specs/hyprland-nixos-integration/
    git add home/sinh/Emberroot.nix
    git status  # Verify staged files
    git commit -m "Add Hyprland home-manager integration module

    - Create sinh-x.wm.hyprland home module
    - Copy all Hyprland configs to modules/home/wm/hyprland/hypr_config/
    - Set executable permissions on scripts
    - Enable Hyprland module in Emberroot home config
    - Add Kiro workflow specs (requirements, design, tasks)

    This follows the same pattern as the BSPWM module and enables
    declarative, version-controlled management of Hyprland configuration.
    "
    ```

### Phase 4: Activation & Testing

- [x] **4.1** Backup existing Hyprland configuration
  - **Description**: Create backup of current `~/.config/hypr/` directory in Documents folder before activation
  - **Deliverables**:
    - Backup directory created at `~/Document/202601/Emberroot-system/hyprland-config-backup-<date>/`
    - All files preserved in backup
    - Existing `~/.config/hypr/` moved to backup location
  - **Requirements**: Risk mitigation (Data loss prevention)
  - **Estimated Effort**: 1 minute
  - **Dependencies**: Task 3.2
  - **Commands**:
    ```bash
    mkdir -p ~/Document/202601/Emberroot-system/hyprland-config-backup-$(date +%Y%m%d_%H%M%S)
    cp -r ~/.config/hypr ~/Document/202601/Emberroot-system/hyprland-config-backup-$(date +%Y%m%d_%H%M%S)/

    # Move original to prepare for home-manager symlinks
    mv ~/.config/hypr ~/.config/hypr.moved

    # Verify backup exists
    ls -la ~/Document/202601/Emberroot-system/ | grep hyprland
    ```

- [x] **4.2** Activate home-manager configuration
  - **Description**: Run home-manager switch to activate the new Hyprland module
  - **Deliverables**:
    - Home-manager activation succeeds
    - Symlinks created in `~/.config/hypr/`
    - All 105 files present
  - **Requirements**: R1 (Configuration management), R5 (Atomic updates)
  - **Estimated Effort**: 2 minutes
  - **Dependencies**: Task 4.1
  - **Commands**:
    ```bash
    home-manager switch --flake .#

    # Verify symlinks created
    ls -la ~/.config/hypr/

    # Count files
    find ~/.config/hypr -type f | wc -l
    # Expected: ~105 files
    ```

- [x] **4.3** Verify script permissions and functionality
  - **Description**: Check that all scripts are executable and test key scripts function correctly
  - **Deliverables**:
    - All scripts in `~/.config/hypr/scripts/` are executable
    - Test scripts execute without errors
  - **Requirements**: R6 (Script execution preservation), R4 (Functional requirements)
  - **Estimated Effort**: 3 minutes
  - **Dependencies**: Task 4.2
  - **Commands**:
    ```bash
    # Check for non-executable scripts (should return nothing)
    find ~/.config/hypr/scripts -type f -not -executable

    # Test key scripts
    ~/.config/hypr/scripts/rofi_launcher &
    # (Press Escape to close)

    ~/.config/hypr/scripts/volume --inc
    ~/.config/hypr/scripts/brightness --inc

    # Verify symlinks point to Nix store
    readlink ~/.config/hypr/hyprland.conf
    # Should show /nix/store/...
    ```

- [x] **4.4** Test Hyprland session
  - **Description**: Start Hyprland and verify all functionality works (keybindings, waybar, scripts, etc.)
  - **Deliverables**:
    - Hyprland starts without errors
    - All keybindings work (SUPER+Return, SUPER+D, etc.)
    - Waybar displays correctly
    - Rofi menus function
    - Scripts execute properly
  - **Requirements**: R4 (User Experience), Success Criteria
  - **Estimated Effort**: 5 minutes
  - **Dependencies**: Task 4.3
  - **Testing Checklist**:
    ```
    [ ] Hyprland starts: `Hyprland` (if not already running)
    [ ] SUPER+Return -> kitty terminal launches
    [ ] SUPER+D -> rofi launcher appears
    [ ] SUPER+X -> powermenu appears
    [ ] SUPER+F -> window fullscreen toggles
    [ ] Waybar visible with correct modules
    [ ] Click waybar clock -> works
    [ ] Volume controls work (SUPER+Volume keys)
    [ ] Brightness controls work
    [ ] Monitor hotplug (if applicable): Connect/disconnect monitor
    [ ] Workspace switching (SUPER+1, SUPER+2, etc.)
    ```

### Phase 5: Verification & Documentation

- [x] **5.1** Test rebuild idempotency
  - **Description**: Verify that rebuilding without changes works correctly and is idempotent
  - **Deliverables**:
    - Rebuild completes successfully
    - No unnecessary changes or warnings
    - Configuration remains functional
  - **Requirements**: R5 (Atomic updates), Non-functional requirements
  - **Estimated Effort**: 2 minutes
  - **Dependencies**: Task 4.4
  - **Commands**:
    ```bash
    home-manager switch --flake .#
    # Expected output should indicate no changes or minimal changes

    # Verify Hyprland still works after rebuild
    hyprctl version
    ```

- [x] **5.2** Document completion and finalize git commit
  - **Description**: Update task status, verify all files committed, and optionally push to remote
  - **Deliverables**:
    - This tasks.md file updated with completion status
    - All changes committed to git
    - Optional: Push to remote repository
  - **Requirements**: R2 (Git version control)
  - **Estimated Effort**: 2 minutes
  - **Dependencies**: Task 5.1
  - **Commands**:
    ```bash
    # Verify git status is clean
    git status

    # Update tasks.md to mark completed
    # (Edit this file to check off completed tasks)

    # Optional: Push to remote
    git push origin feature/202601

    # List home-manager generations to verify new generation
    home-manager generations | head -5
    ```

## Task Guidelines

### Task Completion Criteria
Each task is considered complete when:
- [ ] All deliverables are implemented and functional
- [ ] Commands have been executed successfully
- [ ] Verification steps pass
- [ ] Requirements are satisfied
- [ ] No errors or warnings in output

### Task Dependencies
- Tasks MUST be completed in order within each phase
- Do not skip phases or tasks
- If a task fails, resolve the issue before proceeding
- Critical path: All tasks are sequential

### Error Recovery Procedures

**If Task 4.2 (Activation) Fails**:
```bash
# Restore from backup
rm -rf ~/.config/hypr
mv ~/.config/hypr.moved ~/.config/hypr

# Or restore from Document backup
cp -r ~/Document/202601/Emberroot-system/hyprland-config-backup-YYYYMMDD_HHMMSS/hypr ~/.config/

# Check error messages and fix module
# Re-run activation after fixing
```

**If Task 4.4 (Testing) Fails**:
```bash
# Rollback to previous generation
home-manager generations
/nix/store/xxxxx-home-manager-generation-NNN/activate

# Restore backup if needed
rm -rf ~/.config/hypr
cp -r ~/Document/202601/Emberroot-system/hyprland-config-backup-YYYYMMDD_HHMMSS/hypr ~/.config/

# Investigate and fix issues before retrying
```

### Code Quality Standards
- Module code must follow existing BSPWM pattern exactly
- Nix formatting must be consistent with repository style
- Git commits must have descriptive messages
- All files must be tracked in git

## Progress Tracking

### Milestone Checkpoints
- **Milestone 1**: ✅ Phase 1 Complete (Preparation) - Ready for module creation
- **Milestone 2**: ✅ Phase 2 Complete (Module Created) - Module builds successfully
- **Milestone 3**: ✅ Phase 3 Complete (Config Updated) - Changes committed to git (commit 825591f)
- **Milestone 4**: ✅ Phase 4 Complete (Activated) - Hyprland running from Nix config (generation 167)
- **Milestone 5**: ✅ Phase 5 Complete (Verified) - Feature fully functional and documented

### Definition of Done
The feature is considered "Done" when:
1. **Functionality**: All 105 config files deployed and Hyprland fully functional
2. **Testing**: All test cases pass (keybindings, scripts, UI elements)
3. **Documentation**: Kiro specs complete (requirements, design, tasks)
4. **Git**: All changes committed with proper messages
5. **Integration**: Module integrates with existing system without conflicts
6. **Requirements**: All requirements from requirements.md satisfied
7. **Rollback**: Can rollback to previous generation if needed
8. **Backup**: Configuration backed up to ~/Document/202601/Emberroot-system/

## Risk Mitigation

### Technical Risks
- **Risk**: File permission issues prevent scripts from executing
  - **Mitigation**: Explicitly set chmod +x before git commit; verify after activation
  - **Affected Tasks**: 1.3, 4.3

- **Risk**: Existing ~/.config/hypr conflicts with home-manager symlinks
  - **Mitigation**: Mandatory backup in Task 4.1 with move to backup location
  - **Affected Tasks**: 4.2

- **Risk**: Dynamic files (workspaces.conf) may cause issues
  - **Mitigation**: Include current version in git; document that it may be regenerated
  - **Affected Tasks**: 1.2, 4.4

### Dependency Risks
- **Risk**: System module not enabled (Hyprland not installed)
  - **Mitigation**: Verify modules.wm.hyprland.enable = true in system config
  - **Affected Tasks**: 4.4
  - **Check**: `which Hyprland` should return path

- **Risk**: Missing packages for scripts
  - **Mitigation**: System module already includes all dependencies
  - **Affected Tasks**: 4.3, 4.4

### Timeline Risks
- **Risk**: Testing reveals issues requiring debugging
  - **Mitigation**: Rollback procedure documented; can revert to backup
  - **Affected Tasks**: 4.4, 5.1

## Resource Requirements

### Development Environment
- NixOS system with home-manager integrated
- Git repository with Snowfall Lib configured
- Currently running Hyprland session (for testing) or ability to switch to TTY

### External Dependencies
- All dependencies already installed via `modules.nixos.wm.hyprland`
- No additional packages needed
- Git already configured

### Required Knowledge
- Basic NixOS/home-manager concepts
- Snowfall Lib module structure
- Git operations (add, commit, status)
- Hyprland keybindings and configuration

## Git Tracking

**Branch**: `feature/202601` (current branch)

**Related Commits**:
- Initial spec creation (requirements.md, design.md, tasks.md)
- Module implementation commit (Task 3.2)
- Completion documentation commit (Task 5.2)

**Related Files**:
- `.kiro/specs/hyprland-nixos-integration/requirements.md`
- `.kiro/specs/hyprland-nixos-integration/design.md`
- `.kiro/specs/hyprland-nixos-integration/tasks.md` (this file)
- `modules/home/wm/hyprland/default.nix`
- `modules/home/wm/hyprland/hypr_config/` (105 files)
- `home/sinh/Emberroot.nix`

**Backup Location**: `~/Document/202601/Emberroot-system/hyprland-config-backup-<timestamp>/`

---

**Task Status**: Complete

**Current Phase**: Phase 5 Complete (All phases complete)

**Overall Progress**: 11/11 tasks completed (100%)

**Last Updated**: 2026-01-13

**Assigned Developer**: sinh (with Claude Code assistance)

**Actual Total Time**: ~25 minutes

**Final Result**: Successfully integrated Hyprland configuration into NixOS home-manager with all 105 files deployed and fully functional

## Implementation Summary

All 11 tasks across 5 phases were completed successfully:

**Phase 1 (Preparation)**: ✅ Complete
- Created module directory structure
- Copied 104 config files to repository
- Set executable permissions on all scripts

**Phase 2 (Module Creation)**: ✅ Complete
- Created `modules/home/wm/hyprland/default.nix` following BSPWM pattern
- Verified module builds without errors

**Phase 3 (Configuration Update)**: ✅ Complete
- Enabled Hyprland module in `home/sinh/Emberroot.nix`
- Committed all changes to git (commit 825591f)
- All pre-commit hooks passed

**Phase 4 (Activation & Testing)**: ✅ Complete
- Backup created at `~/Document/202601/Emberroot-system/hyprland-config-backup-20260113_013650/`
- NixOS rebuild successful (generation 167)
- All 105 files deployed as symlinks to Nix store
- All scripts executable (555 permissions)
- Full functionality verified: keybindings, waybar, rofi, volume/brightness controls

**Phase 5 (Verification)**: ✅ Complete
- Idempotent rebuild verified
- Documentation updated
- All Definition of Done criteria met
