# Development Environment

Complete development setup on the Emberroot system.

## Editor Stack

### Primary: Neovim (sinh-x-nixvim / Neve)

**Source:** `sinh-x.cli-apps.editor.neovim`

A fully-featured Neovim distribution with extensive language support.

#### LSP Support
| Language | LSP Server |
|----------|------------|
| Rust | rust-analyzer |
| TypeScript/JavaScript | typescript-language-server |
| Go | gopls |
| Python | pyright, ruff-lsp |
| Lua | lua-language-server |
| Julia | julia-lsp |
| Kotlin | kotlin-language-server |
| Nix | nil, nixd |
| HTML/CSS | vscode-langservers |
| JSON | vscode-langservers |
| YAML | yaml-language-server |
| Bash | bash-language-server |
| Docker | dockerfile-language-server |

#### Formatters
| Language | Formatter |
|----------|-----------|
| JavaScript/TypeScript | Prettier, eslint_d |
| Python | Black |
| Lua | Stylua |
| Rust | Rustfmt |
| Nix | nixfmt (RFC-style) |
| Go | gofmt |

#### Linters
| Scope | Tool |
|-------|------|
| JavaScript | eslint_d |
| Lua | Selene |
| Nix | Statix |
| General | Tree-sitter |

### Secondary: VS Code

**Source:** `sinh-x.coding.editor.vscode`

| Extension | Purpose |
|-----------|---------|
| Rust Analyzer | Rust development |
| GitHub Copilot | AI assistance |

### AI Assistant: Claude Code

**Source:** `sinh-x.coding.claudecode`

Anthropic's official CLI for AI-assisted coding.

## Programming Languages

### Rust
| Component | Source |
|-----------|--------|
| Toolchain | System |
| cargo-binstall | Pre-built binary installer |
| rust-analyzer | LSP |

### Node.js
| Version | 22 |
| Package Manager | npm |

### Python
| Component | Source |
|-----------|--------|
| Runtime | `modules.python` |
| LSP | pyright |
| Linter | ruff |
| Formatter | Black |

### Go
| Component | Details |
|-----------|---------|
| Runtime | Latest stable |
| LSP | gopls |

### Zig
| Runtime | Latest |

### Julia
| Runtime | Latest |
| LSP | julia-lsp |

### Lua
| Runtime | Latest |
| LSP | lua-language-server |
| Linter | Selene |
| Formatter | Stylua |

## Container & Virtualization

### Docker
**Source:** `modules.docker`, `sinh-x.coding.docker`

| Feature | Status |
|---------|--------|
| Docker daemon | Enabled |
| User access | sinh |
| Rootless | Configured |

### Genymotion
**Source:** `modules.genymotion`

Android emulator for mobile development.

### VirtualBox
| Component | Status |
|-----------|--------|
| Guest Additions | Installed |
| Kernel modules | Loaded |

## Cloud & Infrastructure

### AWS
| Tool | Description |
|------|-------------|
| AWS CLI v2 | Full AWS management |

### Google Cloud
**Source:** `modules.gcloud`

| Tool | Description |
|------|-------------|
| gcloud | GCP CLI |
| gsutil | Storage management |

### Rclone
Cloud storage synchronization for multiple providers.

## Version Control

### Git
| Tool | Description |
|------|-------------|
| git | Core VCS |
| gitflow | Branching workflow |
| lazygit | TUI interface |

### GitHub
| Tool | Description |
|------|-------------|
| gh | GitHub CLI |

## Terminal & Shell

### Fish Shell
**Source:** `sinh-x.cli-apps.shell.fish`

| Feature | Configuration |
|---------|---------------|
| Plugins | sinh-x.fish, ggl.fish |
| FZF integration | Custom theme |
| Atuin | History sync |
| Zoxide | Smart cd |

### Zellij
**Source:** `sinh-x.cli-apps.multiplexers.zellij`

| Theme | Catppuccin |
| Status bar | zjstatus |

### Terminals
| Terminal | Purpose |
|----------|---------|
| Kitty | Primary (GPU-accelerated) |
| Warp | Secondary (AI features) |

## Nix Development

### Tools
| Tool | Purpose |
|------|---------|
| direnv | Automatic environment loading |
| devenv | Development environments |
| nix-tree | Store browser |
| nh | Nix helper |
| deadnix | Find unused code |
| statix | Static analysis |
| nixfmt | Code formatting |

### Pre-commit Hooks
Defined in `checks/pre-commit-hooks/default.nix`:

| Hook | Action |
|------|--------|
| deadnix | Auto-remove unused code |
| nixfmt | RFC-style formatting |
| statix | Static analysis |
| luacheck | Lua linting |
| pre-commit-hook-ensure-sops | SOPS verification |

## Search & Navigation

| Tool | Purpose |
|------|---------|
| ripgrep | Fast text search |
| fd | Fast file finder |
| fzf | Fuzzy finding |
| yazi | File browser TUI |

## JSON/YAML Processing

| Tool | Format |
|------|--------|
| jq | JSON |
| yq | YAML |
| gojq | JSON (Go implementation) |

## Task & Time Management

### Super Productivity
**Source:** `sinh-x.coding.super-productivity`

Task tracking, time management, and todo lists.

### ActivityWatch
**Source:** `sinh-x.apps.utilities`

Automated time tracking with Wayland window watcher.

## Keyboard

### QMK
| Component | Status |
|-----------|--------|
| qmk | Installed |
| udev rules | Configured |

Custom keyboard firmware support.

## Common Workflows

### Starting Development
```bash
# Enter project with devenv
cd /path/to/project
direnv allow  # Auto-activates on entry

# Or manually
nix develop
```

### Rebuilding System
```bash
# Test changes (ephemeral)
sudo sys test

# Apply permanently
sudo sys rebuild
```

### Code Formatting
```bash
# Nix files
nixfmt <file>

# Or use pre-commit
git commit  # Hooks run automatically
```

### Backup
Rustic runs automatically daily between 19:00-23:59.

```bash
# Manual backup
rustic backup
```
