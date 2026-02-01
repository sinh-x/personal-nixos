# Starship Prompt Implementation Tasks

## Task Overview

This document breaks down the implementation of Starship prompt customizations into actionable coding tasks. Each task builds on the existing module to add new features.

**Total Tasks**: 12 tasks organized into 4 phases

**Requirements Reference**: `requirements.md`

**Design Reference**: `design.md`

**Implementation File**: `modules/home/cli-apps/starship/default.nix`

## Implementation Tasks

### Phase 1: SSH & User Awareness

- [x] **1.1** Add username display configuration
  - **Description**: Configure username module to show when not default user or when root
  - **Deliverables**:
    - Add `username` block to starship settings
    - Style root user in red for warning
  - **Requirements**: Multi-Host & SSH Awareness user stories
  - **Code Changes**:
    ```nix
    username = {
      show_always = false;
      style_user = "bold blue";
      style_root = "bold red";
      format = "[$user]($style)";
    };
    ```

- [x] **1.2** Add hostname display for SSH sessions
  - **Description**: Show hostname only when connected via SSH
  - **Deliverables**:
    - Add `hostname` block to starship settings
    - Configure SSH-only display
  - **Requirements**: Multi-Host & SSH Awareness user stories
  - **Code Changes**:
    ```nix
    hostname = {
      ssh_only = true;
      style = "bold yellow";
      format = "@[$hostname]($style) ";
    };
    ```

- [x] **1.3** Update format string for user/host
  - **Description**: Ensure username and hostname appear at the start of the prompt
  - **Deliverables**:
    - Update `format` to include `$username` and `$hostname` at beginning
  - **Dependencies**: 1.1, 1.2

### Phase 2: Enhanced Language Support

- [x] **2.1** Enhance Python module with virtualenv display
  - **Description**: Show virtualenv/conda environment name alongside Python version
  - **Deliverables**:
    - Update `python` block with virtualenv format
  - **Requirements**: Development Environment Awareness user stories
  - **Code Changes**:
    ```nix
    python = {
      symbol = " ";
      style = "bold yellow";
      pyenv_version_name = true;
      format = "[\${symbol}(\${version})( \\(\$virtualenv\\))]($style) ";
    };
    ```

- [x] **2.2** Add R language support
  - **Description**: Add R language version detection for R projects
  - **Deliverables**:
    - Add `rlang` block to starship settings
    - Update `format` to include `$rlang`
  - **Requirements**: Development Environment Awareness user stories
  - **Code Changes**:
    ```nix
    rlang = {
      symbol = "📊 ";
      style = "bold blue";
      format = "[$symbol($version)]($style) ";
    };
    ```

- [ ] **2.3** Enhance Rust module with toolchain info
  - **Description**: Better Rust toolchain display (version info)
  - **Deliverables**:
    - Update `rust` block with improved format
  - **Requirements**: Development Environment Awareness user stories

### Phase 3: Workflow Enhancements

- [x] **3.1** Add background jobs indicator
  - **Description**: Show count of background jobs when > 0
  - **Deliverables**:
    - Add `jobs` block to starship settings
    - Update `format` to include `$jobs`
  - **Requirements**: Workflow Enhancement Requirements
  - **Code Changes**:
    ```nix
    jobs = {
      symbol = "✦ ";
      style = "bold blue";
      number_threshold = 1;
      format = "[$symbol$number]($style) ";
    };
    ```

- [x] **3.2** Add exit code display
  - **Description**: Show actual exit code when commands fail (not just color)
  - **Deliverables**:
    - Add `status` block to starship settings
    - Update `format` to include `$status`
  - **Requirements**: Workflow Enhancement Requirements
  - **Code Changes**:
    ```nix
    status = {
      disabled = false;
      symbol = "✘ ";
      style = "bold red";
      format = "[$symbol$status]($style) ";
    };
    ```

- [x] **3.3** Add devenv/direnv environment indicator
  - **Description**: Show active devenv environment name using env_var module
  - **Deliverables**:
    - Add `env_var.DEVENV_ROOT` block (or custom variable)
    - Update `format` to include environment indicator
  - **Requirements**: Devenv/Direnv Integration Requirements
  - **Notes**: May need to set custom env var in devenv configs

### Phase 4: Polish & Optional Features

- [x] **4.1** Add Docker context display
  - **Description**: Show Docker context when not default
  - **Deliverables**:
    - Add `docker_context` block to starship settings
    - Update `format` to include `$docker_context`
  - **Requirements**: Future Features (Planned)
  - **Code Changes**:
    ```nix
    docker_context = {
      symbol = " ";
      style = "bold blue";
      only_with_files = true;
      format = "[$symbol$context]($style) ";
    };
    ```

- [ ] **4.2** Add optional time display
  - **Description**: Add module option to enable timestamp in prompt
  - **Deliverables**:
    - Add `time` block to starship settings
    - Add `showTime` option to module
  - **Requirements**: Future Features (Planned)

- [ ] **4.3** Implement transient prompt (optional)
  - **Description**: Configure Fish to use transient prompt for cleaner scrollback
  - **Deliverables**:
    - Research Fish transient prompt integration
    - Add Fish function for transient prompt
    - Add `transientPrompt` option to module
  - **Requirements**: Workflow Enhancement Requirements
  - **Notes**: Requires Fish shell configuration changes

## Quick Implementation Guide

### Immediate Improvements (Copy-Paste Ready)

To quickly enhance the current module, add these blocks to `default.nix`:

```nix
# Inside settings = { ... }

# SSH/User Awareness
username = {
  show_always = false;
  style_user = "bold blue";
  style_root = "bold red";
  format = "[$user]($style)";
};

hostname = {
  ssh_only = true;
  style = "bold yellow";
  format = "@[$hostname]($style) ";
};

# Enhanced Python
python = {
  symbol = " ";
  style = "bold yellow";
  pyenv_version_name = true;
  format = "[\${symbol}(\${version})( \\(\$virtualenv\\))]($style) ";
};

# R Language
rlang = {
  symbol = "📊 ";
  style = "bold blue";
  format = "[$symbol($version)]($style) ";
};

# Background Jobs
jobs = {
  symbol = "✦ ";
  style = "bold blue";
  number_threshold = 1;
  format = "[$symbol$number]($style) ";
};

# Exit Code
status = {
  disabled = false;
  symbol = "✘ ";
  style = "bold red";
  format = "[$symbol$status]($style) ";
};
```

And update the format string:
```nix
format = concatStrings [
  "$username"
  "$hostname"
  "$directory"
  "$git_branch"
  "$git_status"
  "$nix_shell"
  "$python"
  "$nodejs"
  "$rust"
  "$golang"
  "$rlang"
  "$jobs"
  "$status"
  "$cmd_duration"
  "$line_break"
  "$character"
];
```

## Task Completion Criteria

Each task is considered complete when:
- [ ] Configuration is added to `default.nix`
- [ ] System rebuilds successfully (`sudo sys test`)
- [ ] Feature works as expected in terminal
- [ ] No performance degradation observed

## Git Tracking

**Branch**: `feature/202602`

**Related Commits**:
- `b8637e1` - feat(shell): Replace Tide with Starship prompt

---

**Task Status**: In Progress

**Current Phase**: Phase 4

**Overall Progress**: 9/12 tasks completed (75%)

**Last Updated**: 2026-02-01
