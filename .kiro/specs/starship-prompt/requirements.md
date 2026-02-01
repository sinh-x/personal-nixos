# Starship Prompt Requirements

## 1. Introduction

This document specifies the requirements for the Starship shell prompt configuration in the personal-nixos setup. Starship replaces Tide as the primary prompt for Fish shell, providing a fast, customizable, and cross-shell compatible prompt.

**Architecture Overview**: A dedicated home-manager module (`sinh-x.cli-apps.starship`) that configures Starship prompt with sensible defaults and integration with Fish shell.

## 2. User Stories

### Shell User Experience
- **As a developer**, I want to see my current git branch and status at a glance, so that I can track my work context
- **As a developer**, I want to see when I'm in a Nix shell, so that I know my environment state
- **As a developer**, I want to see the current directory path, so that I know where I am in the filesystem
- **As a developer**, I want visual feedback for command success/failure, so that I can quickly identify issues

### Multi-Host & SSH Awareness
- **As a sysadmin**, I want to see the hostname in my prompt, so that I know which machine I'm working on during SSH sessions
- **As a sysadmin**, I want to see the username when it differs from my default, so that I know which user context I'm in
- **As a sysadmin**, I want a clear visual indicator when I'm in an SSH session, so that I don't accidentally run commands on the wrong machine

### Development Environment Awareness
- **As a developer**, I want to see the active devenv/direnv environment name, so that I know which project environment is loaded
- **As a Python developer**, I want to see the Python version and virtualenv/conda name, so that I know my exact Python environment
- **As a Rust developer**, I want to see the Rust toolchain version (stable/nightly/specific), so that I know which compiler I'm using
- **As an R developer**, I want to see the R version, so that I know my R environment
- **As a polyglot developer**, I want language indicators to only show in relevant directories, so that my prompt stays clean

### Performance
- **As a user**, I want a prompt that renders instantly, so that my shell experience is snappy
- **As a user**, I want to see how long slow commands took, so that I can identify performance issues

### Vi Mode Support
- **As a Vim user**, I want visual indication of normal vs insert mode, so that I know my editing state

### Workflow Recommendations (Additional)
- **As a developer**, I want to see background job count, so that I know if processes are running
- **As a developer**, I want optional timestamps on commands, so that I can correlate with logs
- **As a developer**, I want to see the actual exit code for failed commands, so that I can debug issues
- **As a developer**, I want Docker/container context shown when relevant, so that I know my container environment
- **As a developer**, I want a clean prompt history (transient prompt), so that scrollback is less cluttered

## 3. Acceptance Criteria

### Core Prompt Requirements
- **WHEN** the shell starts, **THEN** the system **SHALL** display the Starship prompt
- **WHEN** in a git repository, **THEN** the system **SHALL** display branch name with icon
- **WHEN** in a git repository with changes, **THEN** the system **SHALL** display status indicators (staged, modified, untracked, etc.)
- **WHEN** in a Nix shell, **THEN** the system **SHALL** display a Nix indicator with snowflake icon

### Directory Display Requirements
- **WHEN** displaying the path, **THEN** the system **SHALL** truncate to 3 directory levels
- **WHEN** inside a git repository, **THEN** the system **SHALL** truncate path relative to repo root
- **WHEN** displaying the path, **THEN** the system **SHALL** use cyan color for visibility

### Host & User Display Requirements
- **WHEN** connected via SSH, **THEN** the system **SHALL** display hostname with distinct styling
- **WHEN** connected via SSH, **THEN** the system **SHALL** display an SSH indicator icon
- **WHEN** the current user differs from default (sinh), **THEN** the system **SHALL** display username
- **WHEN** logged in as root, **THEN** the system **SHALL** display username in red/warning color

### Language/Environment Detection Requirements
- **WHEN** in a Python project, **THEN** the system **SHALL** display Python version with icon
- **WHEN** in a Python virtualenv/conda, **THEN** the system **SHALL** display environment name
- **WHEN** in a Node.js project, **THEN** the system **SHALL** display Node version with icon
- **WHEN** in a Rust project, **THEN** the system **SHALL** display Rust toolchain version with icon
- **WHEN** in a Go project, **THEN** the system **SHALL** display Go version with icon
- **WHEN** in an R project, **THEN** the system **SHALL** display R version with icon

### Devenv/Direnv Integration Requirements
- **WHEN** a direnv environment is active, **THEN** the system **SHALL** display environment indicator
- **WHEN** in a devenv shell, **THEN** the system **SHALL** display the devenv name if set via `DEVENV_ROOT`
- **WHEN** `IN_NIX_SHELL` is set, **THEN** the system **SHALL** indicate Nix environment type (pure/impure)

### Workflow Enhancement Requirements
- **WHEN** background jobs are running, **THEN** the system **SHALL** display job count
- **WHEN** a command fails, **THEN** the system **SHALL** display the exit code (not just color change)
- **WHEN** in a Docker context, **THEN** the system **SHALL** display container context
- **IF** transient prompt is enabled, **THEN** previous prompts **SHALL** collapse to minimal form

### Vi Mode Requirements
- **WHEN** in Fish vi normal mode, **THEN** the system **SHALL** display `❮` character
- **WHEN** in Fish vi insert mode, **THEN** the system **SHALL** display `❯` character
- **WHEN** the last command failed, **THEN** the character **SHALL** be red
- **WHEN** the last command succeeded, **THEN** the character **SHALL** be green

### Performance Requirements
- **WHEN** a command takes longer than 2 seconds, **THEN** the system **SHALL** display duration
- **WHEN** rendering the prompt, **THEN** the system **SHALL** complete in under 50ms

## 4. Technical Architecture

### Module Structure
- **Location**: `modules/home/cli-apps/starship/default.nix`
- **Namespace**: `sinh-x.cli-apps.starship`
- **Integration**: Fish shell via `enableFishIntegration`

### Dependencies
- **Starship**: Provided by home-manager's `programs.starship`
- **Nerd Fonts**: Required for icons (handled by system font configuration)
- **Fish Shell**: Primary shell integration

## 5. Feature Specifications

### Core Features (Implemented)
1. **Git Integration**: Branch display with icon, comprehensive status indicators
2. **Directory Display**: Truncated path with repo-aware truncation
3. **Nix Shell Indicator**: Snowflake icon with shell state
4. **Vi Mode Support**: Different symbols for normal/insert mode
5. **Command Duration**: Shows timing for slow commands
6. **Language Detection**: Python, Node.js, Rust, Go indicators

### Priority Features (To Implement)
1. **SSH/Host Awareness**: Hostname display on SSH, SSH indicator icon
2. **Username Display**: Show when not default user, highlight root
3. **Enhanced Python**: Show virtualenv/conda environment name
4. **R Language Support**: R version detection for R projects
5. **Devenv/Direnv Name**: Display active development environment name
6. **Background Jobs**: Show count of running background jobs
7. **Exit Code Display**: Show actual exit code on command failure

### Future Features (Planned)
1. **Transient Prompt**: Collapse previous prompts for cleaner scrollback
2. **Right Prompt**: Move secondary info (time, hostname) to right side
3. **Custom Color Themes**: Support for different color palettes (Tokyo Night, Catppuccin)
4. **Kubernetes Context**: Show current k8s context/namespace
5. **AWS/Cloud Profile**: Show active cloud profile
6. **Docker Context**: Show active Docker context
7. **Time Display**: Optional timestamp in prompt
8. **Battery Status**: For laptop usage (Drgnfly)
9. **Toolchain Versions**: More granular Rust toolchain info (stable/nightly/MSRV)

## 6. Success Criteria

### User Experience
- **WHEN** using the terminal daily, **THEN** the prompt **SHALL** provide all necessary context without visual clutter
- **WHEN** switching between projects, **THEN** the language/environment context **SHALL** update automatically

### Technical Performance
- **WHEN** measuring prompt render time, **THEN** it **SHALL** be under 50ms on all systems

## 7. Assumptions and Dependencies

### Technical Assumptions
- Nerd Fonts are installed on all systems (handled by `sinh-x.apps.themes`)
- Fish shell is the primary interactive shell
- Terminal emulator supports Unicode and 256 colors (Kitty, Warp)
- Direnv is configured and integrated with Fish shell
- Devenv projects set `DEVENV_ROOT` or similar environment variables

### External Dependencies
- home-manager `programs.starship` module
- Starship binary (provided by nixpkgs)
- direnv integration (already configured in system)
- Language toolchains provide version info via standard mechanisms

## 8. Constraints and Limitations

### Technical Constraints
- Must work across all three hosts (Emberroot, Elderwood, Drgnfly)
- Must not significantly impact shell startup time
- Must integrate seamlessly with Fish vi mode

---

**Document Status**: Approved

**Last Updated**: 2026-02-01

**Related Documents**:
- `design.md` - Technical design
- `tasks.md` - Implementation tasks

**Version**: 1.0
