# Fish Prompt Git Split Implementation Tasks

## Task Overview

This document breaks down the implementation of custom Tide prompt items for separating git branch and status display.

**Total Tasks**: 6 tasks organized into 3 phases

**Requirements Reference**: `requirements.md`

**Design Reference**: `design.md`

## Implementation Tasks

### Phase 1: Create Custom Tide Item Functions

- [ ] **1.1** Create `_tide_item_gitbranch.fish` function
  - **Description**: Create a fish function that displays only the git branch name with truncation support
  - **Deliverables**:
    - `modules/home/cli-apps/fish/tide-items/_tide_item_gitbranch.fish`
  - **Requirements**: Git Branch Display Requirements
  - **Dependencies**: None
  - **Implementation Details**:
    - Detect if in git repository
    - Get current branch name (or short SHA if detached)
    - Apply truncation with ellipsis if exceeds max length
    - Use `_tide_print_item` to output segment
    - Handle edge cases: detached HEAD, new repo with no commits

- [ ] **1.2** Create `_tide_item_gitstatus.fish` function
  - **Description**: Create a fish function that displays only git status indicators
  - **Deliverables**:
    - `modules/home/cli-apps/fish/tide-items/_tide_item_gitstatus.fish`
  - **Requirements**: Git Status Display Requirements
  - **Dependencies**: None
  - **Implementation Details**:
    - Count staged files (`+N`)
    - Count unstaged/modified files (`!N`)
    - Count untracked files (`?N`)
    - Check for stash entries
    - Check ahead/behind upstream
    - Only display segment if there are changes
    - Set appropriate background color based on state

### Phase 2: Integrate with home-manager

- [ ] **2.1** Add tide item files to fish module
  - **Description**: Configure home-manager to install custom tide functions
  - **Deliverables**:
    - Update `modules/home/cli-apps/fish/default.nix`
  - **Requirements**: Integration Requirements
  - **Dependencies**: 1.1, 1.2
  - **Implementation Details**:
    - Use `home.file` to install functions to `~/.config/fish/functions/`
    - Consider using `source` attribute or inline `text`
    - Ensure proper file permissions

- [ ] **2.2** Configure tide variables and prompt items
  - **Description**: Set tide configuration variables and update prompt item order
  - **Deliverables**:
    - Update `modules/home/cli-apps/fish/default.nix`
  - **Requirements**: Visual Requirements, Integration Requirements
  - **Dependencies**: 2.1
  - **Implementation Details**:
    - Add tide variable configuration to `interactiveShellInit`
    - Set colors: `tide_gitbranch_bg_color`, `tide_gitstatus_bg_color`, etc.
    - Set truncation length: `tide_gitbranch_truncation_length`
    - Update `tide_left_prompt_items` to replace `git` with `gitbranch gitstatus`

### Phase 3: Testing and Refinement

- [ ] **3.1** Test and verify functionality
  - **Description**: Rebuild system and test all git states
  - **Deliverables**:
    - Working prompt with separate git segments
  - **Requirements**: All acceptance criteria
  - **Dependencies**: 2.2
  - **Test Cases**:
    - [ ] Clean repository - only branch shows
    - [ ] Untracked files - shows `?N`
    - [ ] Staged changes - shows `+N`
    - [ ] Unstaged changes - shows `!N` with yellow bg
    - [ ] Mixed state - shows all indicators
    - [ ] Long branch name (30+ chars) - truncates with ellipsis
    - [ ] Non-git directory - no git segments
    - [ ] Detached HEAD - shows short SHA

- [ ] **3.2** Adjust colors and visual polish
  - **Description**: Fine-tune colors and segment appearance based on testing
  - **Deliverables**:
    - Final color configuration
  - **Requirements**: Visual Requirements
  - **Dependencies**: 3.1
  - **Adjustments**:
    - Verify powerline separators connect properly
    - Adjust colors if needed for visibility
    - Ensure icon renders correctly

## Task Completion Criteria

Each task is considered complete when:
- [ ] Deliverables are implemented and functional
- [ ] Code follows NixOS/home-manager patterns
- [ ] Changes integrate with existing fish configuration
- [ ] System rebuilds successfully with `sudo sys test`

## File Structure

```
modules/home/cli-apps/fish/
├── default.nix                          # Main fish module (modified)
└── tide-items/                          # New directory
    ├── _tide_item_gitbranch.fish       # Branch display function
    └── _tide_item_gitstatus.fish       # Status display function
```

## Git Tracking

**Branch**: `feature/202601`

**Related Commits**: TBD after implementation

---

**Task Status**: Not Started

**Current Phase**: Phase 1

**Overall Progress**: 0/6 tasks completed (0%)

**Last Updated**: 2026-01-30
