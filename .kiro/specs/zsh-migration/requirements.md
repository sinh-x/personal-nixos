# ZSH Migration Requirements

## Overview
Migrate from Fish shell to ZSH for better POSIX compliance and consistency with remote servers.

Related: [GitHub Issue #7](https://github.com/sinh-x/personal-nixos/issues/7)

## User Stories

### US-1: Shell Consistency
**As a** developer
**I want** the same shell syntax locally and on remote servers
**So that** I can use the same commands without mental translation

### US-2: Script Portability
**As a** developer
**I want** shell snippets from documentation to work without modification
**So that** I can quickly copy-paste commands from Stack Overflow/docs

### US-3: Feature Parity
**As a** Fish user
**I want** equivalent features in ZSH
**So that** I don't lose productivity after migration

## Feature Comparison

| Feature | Fish | ZSH | Status |
|---------|------|-----|--------|
| BAT_THEME env var | ✅ | ✅ | Complete |
| sinh-x-scripts in PATH | ✅ | ✅ | Complete |
| Vi keybindings | ✅ | ✅ | Complete |
| Git aliases/abbreviations | ✅ | ✅ | Complete |
| ls aliases | ✅ | ✅ | Complete |
| cat → bat alias | ✅ | ✅ | Complete |
| vim, ssha, sshconfig, anytype aliases | ✅ | ✅ | Complete |
| Autosuggestions | ✅ | ✅ | Complete |
| Syntax highlighting | ✅ | ✅ | Complete |
| Starship prompt | ✅ | ✅ | Complete |
| Fuzzy completion | ✅ (native) | ✅ (fzf-tab) | Complete |
| History search | ✅ | ✅ (Atuin) | Complete (enhanced) |
| Per-directory history | ❌ | ✅ | ZSH has extra |

## Missing Features (To Implement)

### MF-1: Clipboard Paste Binding
- **Fish**: `bind \cp fish_clipboard_paste`
- **ZSH**: Need to add `Ctrl+P` paste binding
- **Priority**: Low (can use terminal paste)

### MF-2: sinh_git_folders Variable
- **Fish**: `set sinh_git_folders (/usr/bin/env cat ~/.config/sinh-x-scripts/sinh_git_folders.txt | read -z)`
- **ZSH**: Need to load this variable
- **Priority**: Medium (used by sinh-x plugin)

### MF-3: Auto Conda Activation
- **Fish**: `auto_conda` function triggers on `$PWD` change
- **ZSH**: Need `chpwd` hook to auto-activate conda environments
- **Priority**: Low (not actively using conda)

### MF-4: sinh-x.fish Plugin
- **Source**: https://github.com/sinh-x/sinh-x.fish
- **Features**: Custom git shortcuts, directory navigation
- **ZSH**: Need equivalent or port functionality
- **Priority**: Medium

### MF-5: ggl.fish Plugin
- **Source**: https://github.com/sinh-x/ggl.fish
- **Features**: Google search from terminal
- **ZSH**: Need equivalent or port functionality
- **Priority**: Low

### MF-6: global_sessions_vars.zsh File
- **Fish**: Sources `~/.config/sinh-x-scripts/global_sessions_vars.fish`
- **ZSH**: Config references `.zsh` version which may not exist
- **Priority**: High (will error if file missing)

## Acceptance Criteria

- [x] ZSH module created with vi-mode, autosuggestions, syntax highlighting
- [x] Starship integrates with ZSH
- [x] Default shell changed to ZSH
- [x] All git/ls aliases ported
- [x] Fuzzy completion working (fzf-tab)
- [x] History sync with Atuin
- [x] Per-directory history available
- [ ] Create `global_sessions_vars.zsh` or update config to handle missing file
- [ ] Document sinh-x.fish plugin features for future porting
- [ ] Document ggl.fish plugin features for future porting

## Decision

**Status**: In Progress

Migrating to ZSH with the following approach:
1. Keep Fish installed alongside ZSH during transition
2. Set ZSH as default shell
3. Port missing features incrementally based on usage
4. Remove Fish after 2-4 weeks of successful ZSH usage
