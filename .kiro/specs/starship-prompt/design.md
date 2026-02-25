# Starship Prompt Design Document

## Overview

This document describes the technical design for the Starship prompt module in the personal-nixos configuration. The module provides a customizable, fast shell prompt that integrates with Fish shell and displays contextual information about git, development environments, and system state.

## Architecture

### Module Structure

```
modules/home/cli-apps/starship/
└── default.nix          # Main module with all configuration
```

### Integration Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     Home Manager                             │
├─────────────────────────────────────────────────────────────┤
│  sinh-x.cli-apps.starship.enable = true                     │
│           │                                                  │
│           ▼                                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           programs.starship                          │    │
│  │  ┌─────────────────────────────────────────────┐    │    │
│  │  │  settings = { ... }  →  ~/.config/starship.toml │    │
│  │  └─────────────────────────────────────────────┘    │    │
│  │  enableFishIntegration = true  →  Fish init script  │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Prompt Layout Design

### Left Prompt Format

```
[user@host] [ssh] [directory] [git_branch] [git_status] [nix_shell] [devenv] [languages] [duration]
[character]
```

### Proposed Two-Line Layout

```
┌─ Line 1: Context Information ─────────────────────────────────────────┐
│ [user@host?] [ssh?]  ~/path/to/dir   main ?1 !2 +3   nix  py3.11  │
├─ Line 2: Input Line ──────────────────────────────────────────────────┤
│ ❯ _                                                                    │
└───────────────────────────────────────────────────────────────────────┘
```

### Component Visibility Rules

| Component | Always Show | Conditional |
|-----------|-------------|-------------|
| directory | ✓ | - |
| character | ✓ | - |
| username | - | When SSH or non-default user |
| hostname | - | When SSH session |
| ssh_symbol | - | When SSH session |
| git_branch | - | When in git repo |
| git_status | - | When in git repo with changes |
| nix_shell | - | When in Nix shell |
| python | - | When Python files present |
| nodejs | - | When Node files present |
| rust | - | When Rust files present |
| golang | - | When Go files present |
| rlang | - | When R files present |
| cmd_duration | - | When command > 2s |
| jobs | - | When background jobs > 0 |
| status | - | When exit code != 0 |

## Configuration Sections

### 1. Format String

```nix
format = lib.concatStrings [
  "$username"
  "$hostname"
  "$shlvl"
  "$directory"
  "$git_branch"
  "$git_status"
  "$nix_shell"
  "$env_var"        # For devenv name
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

### 2. Username & Hostname (SSH Awareness)

```nix
username = {
  show_always = false;        # Only show when relevant
  style_user = "bold blue";
  style_root = "bold red";
  format = "[$user]($style)";
};

hostname = {
  ssh_only = true;            # Only show on SSH
  style = "bold yellow";
  format = "@[$hostname]($style) ";
};
```

### 3. Directory

```nix
directory = {
  truncation_length = 3;
  truncate_to_repo = true;
  style = "bold cyan";
  read_only = " 󰌾";
  read_only_style = "red";
  home_symbol = "~";
  format = "[$path]($style)[$read_only]($read_only_style) ";
};
```

### 4. Git Integration

#### Dynamic Branch Coloring (Custom Module)

The default `git_branch` module doesn't support dynamic styling. A custom module is used to color the branch based on repository state:

```nix
# Disable default git_branch
git_branch = {
  disabled = true;
};

# Custom module with dynamic colors via ANSI escape codes
custom.git_branch_colored = {
  command = ''
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
      untracked=$(git status --porcelain 2>/dev/null | grep "^??" | head -1)
      modified=$(git status --porcelain 2>/dev/null | grep -v "^??" | head -1)
      if [ -n "$untracked" ]; then
        printf '\033[1;38;2;255;85;85m %s\033[0m' "$branch"    # Red
      elif [ -n "$modified" ]; then
        printf '\033[1;38;2;255;184;108m %s\033[0m' "$branch"  # Orange
      else
        printf '\033[1;38;2;80;250;123m %s\033[0m' "$branch"   # Green
      fi
    fi
  '';
  when = "git rev-parse --git-dir 2>/dev/null";
  format = "$output ";
  shell = ["bash" "--noprofile" "--norc"];
};
```

| State | Color | Hex | Meaning |
|-------|-------|-----|---------|
| Clean | Green | `#50FA7B` | All changes committed |
| Modified | Orange | `#FFB86C` | Only tracked files changed |
| Untracked | Red | `#FF5555` | New untracked files present |

#### Git Status Indicators

```nix

git_status = {
  # Color-coded status indicators for quick visual feedback
  format = "($conflicted$stashed$deleted$renamed$modified$untracked$staged$ahead_behind )";
  conflicted = "[=$count](bold #FF5555)";   # Conflicts - red
  ahead = "[⇡$count](bold #8BE9FD)";        # Ahead - cyan
  behind = "[⇣$count](bold #8BE9FD)";       # Behind - cyan
  diverged = "[⇕⇡$ahead_count⇣$behind_count](bold #8BE9FD)";
  untracked = "[?$count](bold #FF5555)";    # New files - red
  stashed = "[\\$$count](bold #BD93F9)";    # Stashed - purple
  modified = "[!$count](bold #FFB86C)";     # Modified - orange
  staged = "[+$count](bold #50FA7B)";       # Ready to commit - green
  renamed = "[»$count](bold #FFB86C)";      # Renamed - orange
  deleted = "[✘$count](bold #FF5555)";      # Deleted - red
};
```

### 5. Nix Shell

```nix
nix_shell = {
  symbol = " ";
  style = "bold blue";
  impure_msg = "impure";
  pure_msg = "pure";
  unknown_msg = "";
  format = "via [$symbol$state( \($name\))]($style) ";
};
```

### 6. Development Environment (Custom)

```nix
# Using env_var module for devenv detection
env_var.DEVENV_ROOT = {
  symbol = "📦 ";
  style = "bold green";
  format = "[$symbol$env_value]($style) ";
  # Will show the devenv project directory name
};
```

### 7. Language Modules

```nix
python = {
  symbol = " ";
  style = "bold yellow";
  pyenv_version_name = false;  # Use python --version instead of pyenv
  format = "[$symbol($version)( \\($virtualenv\\))]($style) ";
};

rust = {
  symbol = " ";
  style = "bold #f74c00";  # Rust orange
  format = "[$symbol($version)]($style) ";
};

golang = {
  symbol = " ";
  style = "bold cyan";
  format = "[$symbol($version)]($style) ";
};

nodejs = {
  symbol = " ";
  style = "bold green";
  format = "[$symbol($version)]($style) ";
};

rlang = {
  symbol = "📊 ";
  style = "bold blue";
  format = "[$symbol($version)]($style) ";
};
```

### 8. Status & Jobs

```nix
status = {
  disabled = false;
  symbol = "✘ ";
  style = "bold red";
  format = "[$symbol$status]($style) ";
};

jobs = {
  symbol = "✦ ";
  style = "bold blue";
  number_threshold = 1;
  format = "[$symbol$number]($style) ";
};
```

### 9. Command Duration

```nix
cmd_duration = {
  min_time = 2000;  # 2 seconds
  style = "bold yellow";
  format = "took [$duration]($style) ";
  show_milliseconds = false;
};
```

### 10. Character (Vi Mode)

```nix
character = {
  success_symbol = "[❯](bold green)";
  error_symbol = "[❯](bold red)";
  vimcmd_symbol = "[❮](bold green)";
  vimcmd_replace_one_symbol = "[❮](bold purple)";
  vimcmd_replace_symbol = "[❮](bold purple)";
  vimcmd_visual_symbol = "[❮](bold yellow)";
};
```

## Color Scheme

Based on terminal theme compatibility (Tokyo Night style):

| Element | Color | Hex |
|---------|-------|-----|
| Directory | Cyan | `#7dcfff` |
| Git Branch | Purple | `#bb9af7` |
| Git Staged | Green | `#50FA7B` |
| Git Modified | Orange | `#FFB86C` |
| Git Untracked | Red | `#FF5555` |
| Git Deleted | Red | `#FF5555` |
| Git Stashed | Purple | `#BD93F9` |
| Git Ahead/Behind | Cyan | `#8BE9FD` |
| Nix Shell | Blue | `#7aa2f7` |
| Python | Yellow | `#e0af68` |
| Rust | Orange | `#f74c00` |
| Go | Cyan | `#73daca` |
| Node | Green | `#9ece6a` |
| Error | Red | `#f7768e` |
| Success | Green | `#9ece6a` |
| Username | Blue | `#7aa2f7` |
| Hostname (SSH) | Yellow | `#e0af68` |

## Module Options Design

### Current (Simple)

```nix
options.${namespace}.cli-apps.starship = {
  enable = mkEnableOption "Starship prompt";
};
```

### Future (Extended Options)

```nix
options.${namespace}.cli-apps.starship = {
  enable = mkEnableOption "Starship prompt";

  theme = mkOption {
    type = types.enum [ "default" "tokyo-night" "catppuccin" "minimal" ];
    default = "default";
    description = "Color theme for the prompt";
  };

  showTime = mkOption {
    type = types.bool;
    default = false;
    description = "Show timestamp in prompt";
  };

  transientPrompt = mkOption {
    type = types.bool;
    default = false;
    description = "Use transient prompt (collapse previous prompts)";
  };

  rightPrompt = mkOption {
    type = types.bool;
    default = false;
    description = "Use right-side prompt for secondary info";
  };
};
```

## Testing Strategy

### Manual Testing Checklist

1. **Basic Prompt**
   - [ ] Prompt renders on shell start
   - [ ] Character changes color on command failure
   - [ ] Vi mode symbols switch correctly

2. **Git Integration**
   - [ ] Branch shows in git repos
   - [ ] Status indicators update on changes
   - [ ] Clean repos show no status

3. **SSH Session**
   - [ ] Hostname shows on SSH
   - [ ] Username shows on SSH
   - [ ] Local sessions hide user/host

4. **Development Environments**
   - [ ] Python version shows in Python projects
   - [ ] Virtualenv name shows when active
   - [ ] Rust version shows in Rust projects
   - [ ] Nix shell indicator appears in nix-shell

5. **Performance**
   - [ ] Prompt renders in < 50ms
   - [ ] No visible lag when typing

## Migration Notes

### From Tide to Starship

- Tide used Fish-native configuration
- Starship uses TOML config (generated by Nix)
- Key differences:
  - Tide: Right prompt default | Starship: Left prompt (configurable)
  - Tide: Fish-only | Starship: Cross-shell
  - Tide: Git status via custom functions | Starship: Built-in git module

### Compatibility

- Fish vi mode: Fully supported via `vimcmd_symbol`
- Kitty terminal: Full Unicode/emoji support
- Warp terminal: Full support (Starship detected automatically)

---

**Requirements Traceability**: This design addresses all requirements from `requirements.md`

**Review Status**: Draft

**Last Updated**: 2026-02-02

**Related Files**:
- `modules/home/cli-apps/starship/default.nix` - Implementation
- `requirements.md` - Requirements specification
- `tasks.md` - Implementation tasks
