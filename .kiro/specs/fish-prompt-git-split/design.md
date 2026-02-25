# Fish Prompt Git Split Design Document

## Overview

This feature splits Tide's default `git` prompt item into two separate custom items: `gitbranch` and `gitstatus`. This allows independent truncation of the branch name while keeping status indicators always visible.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Fish Shell Prompt                        │
├─────────────────────────────────────────────────────────────┤
│  Tide Framework                                              │
│  ┌─────────┐ ┌─────────┐ ┌───────────┐ ┌──────────┐        │
│  │   os    │ │   pwd   │ │ gitbranch │ │ gitstatus│  ...   │
│  └─────────┘ └─────────┘ └───────────┘ └──────────┘        │
│       │           │            │             │               │
│       └───────────┴────────────┴─────────────┘               │
│                         │                                    │
│              tide_left_prompt_items                          │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  home-manager (NixOS)                        │
│  modules/home/cli-apps/fish/default.nix                      │
│  - Defines custom tide item functions                        │
│  - Configures tide_left_prompt_items                         │
└─────────────────────────────────────────────────────────────┘
```

### Tide Item System

Tide items are fish functions named `_tide_item_<name>`. They output prompt segments using tide helper functions:
- `_tide_print_item <name> <icon> <text>` - Outputs a prompt segment
- Tide variables control colors: `tide_<item>_bg_color`, `tide_<item>_color`, etc.

### Current vs Proposed Structure

**Current** (single `git` item):
```
[os] [pwd] [git: branch +1 !3] [newline] [character]
              └─── truncates together ───┘
```

**Proposed** (split items):
```
[os] [pwd] [gitbranch: branch] [gitstatus: +1 !3] [newline] [character]
              └── truncates ──┘  └── never truncates ──┘
```

## Components and Interfaces

### 1. _tide_item_gitbranch Function

```fish
# ~/.config/fish/functions/_tide_item_gitbranch.fish
function _tide_item_gitbranch
    # Only run in git repos
    if not command git rev-parse --is-inside-work-tree 2>/dev/null | string match -q true
        return
    end

    # Get branch name
    set -l branch (command git branch --show-current 2>/dev/null)
    if test -z "$branch"
        set branch (command git rev-parse --short HEAD 2>/dev/null)
    end

    # Truncate if needed
    set -l max_length $tide_gitbranch_truncation_length
    if test (string length "$branch") -gt $max_length
        set branch (string sub -l $max_length "$branch")"…"
    end

    # Determine background color based on repo state
    set -l bg_color $tide_gitbranch_bg_color
    # Could check for conflicts/dirty state to change color

    _tide_print_item gitbranch $tide_gitbranch_icon $branch
end
```

### 2. _tide_item_gitstatus Function

```fish
# ~/.config/fish/functions/_tide_item_gitstatus.fish
function _tide_item_gitstatus
    # Only run in git repos
    if not command git rev-parse --is-inside-work-tree 2>/dev/null | string match -q true
        return
    end

    set -l staged (command git diff --cached --numstat 2>/dev/null | wc -l | string trim)
    set -l unstaged (command git diff --numstat 2>/dev/null | wc -l | string trim)
    set -l untracked (command git ls-files --others --exclude-standard 2>/dev/null | wc -l | string trim)

    set -l status_text ""

    if test "$staged" -gt 0
        set status_text "$status_text+$staged "
    end
    if test "$unstaged" -gt 0
        set status_text "$status_text!$unstaged "
    end
    if test "$untracked" -gt 0
        set status_text "$status_text?$untracked"
    end

    # Only display if there's something to show
    if test -n (string trim "$status_text")
        # Determine bg color based on state
        set -l bg_color $tide_gitstatus_bg_color
        if test "$unstaged" -gt 0
            set bg_color $tide_gitstatus_bg_color_unstable
        end

        _tide_print_item gitstatus '' (string trim "$status_text")
    end
end
```

### 3. Tide Configuration Variables

```fish
# gitbranch configuration
set -U tide_gitbranch_bg_color 4E9A06          # Green (clean)
set -U tide_gitbranch_color 000000              # Black text
set -U tide_gitbranch_icon \uf1d3               # Git icon
set -U tide_gitbranch_truncation_length 24

# gitstatus configuration
set -U tide_gitstatus_bg_color 4E9A06           # Green (clean/staged only)
set -U tide_gitstatus_bg_color_unstable C4A000  # Yellow (unstaged)
set -U tide_gitstatus_bg_color_urgent CC0000    # Red (conflicts)
set -U tide_gitstatus_color 000000              # Black text

# Update prompt items
set -U tide_left_prompt_items os pwd gitbranch gitstatus newline character
```

## NixOS/home-manager Integration

### Module Structure

```nix
# modules/home/cli-apps/fish/default.nix
{
  programs.fish = {
    # ... existing config ...

    interactiveShellInit = ''
      # ... existing init ...

      # Configure custom tide git items
      set -g tide_gitbranch_bg_color 4E9A06
      set -g tide_gitbranch_color 000000
      set -g tide_gitbranch_icon \uf1d3
      set -g tide_gitbranch_truncation_length 24

      set -g tide_gitstatus_bg_color 4E9A06
      set -g tide_gitstatus_bg_color_unstable C4A000
      set -g tide_gitstatus_bg_color_urgent CC0000
      set -g tide_gitstatus_color 000000
    '';
  };

  # Install custom tide item functions
  home.file.".config/fish/functions/_tide_item_gitbranch.fish".text = ''
    # gitbranch function content
  '';

  home.file.".config/fish/functions/_tide_item_gitstatus.fish".text = ''
    # gitstatus function content
  '';
}
```

## Color Scheme Mapping

| State | gitbranch bg | gitstatus bg | Notes |
|-------|--------------|--------------|-------|
| Clean | `4E9A06` (green) | N/A (hidden) | No status shown when clean |
| Staged only | `4E9A06` (green) | `4E9A06` (green) | Both green |
| Unstaged | `4E9A06` (green) | `C4A000` (yellow) | Status turns yellow |
| Conflicts | `CC0000` (red) | `CC0000` (red) | Both red |

## Testing Strategy

### Manual Testing
1. Navigate to git repo with clean state - verify only gitbranch shows
2. Create untracked file - verify gitstatus shows `?1`
3. Stage a file - verify gitstatus shows `+1`
4. Modify staged file - verify gitstatus shows `+1 !1`
5. Create branch with 30+ char name - verify truncation works
6. Switch to non-git directory - verify both items disappear

### Visual Testing
1. Verify powerline separators connect properly between segments
2. Verify colors match existing tide theme
3. Verify icons render correctly (requires Nerd Font)

## Performance Considerations

- Git commands are run for each prompt render
- Consider caching mechanism if performance is an issue
- Tide already has internal caching; leverage where possible

## Migration Path

1. Add custom functions via home-manager
2. Update `tide_left_prompt_items` to replace `git` with `gitbranch gitstatus`
3. Set configuration variables
4. Rebuild system with `sudo sys rebuild`

---

**Requirements Traceability**: This design addresses all requirements from `requirements.md`

**Review Status**: Draft

**Last Updated**: 2026-01-30
