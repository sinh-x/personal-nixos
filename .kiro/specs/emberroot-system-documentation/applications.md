# Emberroot Applications

Complete list of applications installed on the Emberroot system, organized by category.

## Table of Contents
- [Window Manager & Display](#window-manager--display)
- [Terminal Emulators](#terminal-emulators)
- [Shell & CLI](#shell--cli)
- [Text Editors & IDEs](#text-editors--ides)
- [Development Tools](#development-tools)
- [Web Browsers](#web-browsers)
- [Communication & Social](#communication--social)
- [Multimedia](#multimedia)
- [Office & Productivity](#office--productivity)
- [File Management](#file-management)
- [Security & Privacy](#security--privacy)
- [System Utilities](#system-utilities)
- [Custom sinh-x Tools](#custom-sinh-x-tools)

---

## Window Manager & Display

### Core WM Stack
| Application | Description | Source |
|-------------|-------------|--------|
| Hyprland | Wayland compositor | `modules.wm.hyprland` |
| greetd + tuigreet | Display manager | `modules.wm.hyprland.greetd` |
| Hyprlock | Screen locker | `sinh-x.wm.hyprland` |
| XDG Desktop Portal | Application integration | System |

### Wayland Utilities
| Application | Description |
|-------------|-------------|
| swaybg | Background setter |
| swww | Animated wallpaper daemon |
| Waybar | Status bar |
| Mako | Notification daemon |
| Wofi | Application launcher |
| Wofi-pass | Password integration |
| Rofi (Wayland) | Alternative launcher |
| Fuzzel | Fast launcher |
| Tofi | Minimal launcher |
| Eww | Widget framework |

### Screenshot & Recording
| Application | Description |
|-------------|-------------|
| Hyprshot | Hyprland screenshot |
| Grim | Wayland screenshot |
| Slurp | Region selection |
| Wf-recorder | Screen recording |

### Clipboard
| Application | Description |
|-------------|-------------|
| wl-clipboard | Clipboard utilities |
| wl-clip-persist | Persistent clipboard |
| Cliphist | Clipboard history |

---

## Terminal Emulators

| Application | Theme | Status | Source |
|-------------|-------|--------|--------|
| Kitty | Tokyo Night | Primary | `sinh-x.cli-apps.terminal.kitty` |
| Warp | Default | Secondary | `sinh-x.cli-apps.terminal.warp` |
| Alacritty | - | Alternative | System |

---

## Shell & CLI

### Shell
| Application | Description | Source |
|-------------|-------------|--------|
| Fish | Primary shell | `sinh-x.cli-apps.shell.fish` |
| Fish plugins | sinh-x.fish, ggl.fish | Config |

### Terminal Multiplexer
| Application | Theme | Source |
|-------------|-------|--------|
| Zellij | Catppuccin | `sinh-x.cli-apps.multiplexers.zellij` |
| zjstatus | Zellij status bar | Overlay |

### CLI Utilities
| Application | Description |
|-------------|-------------|
| atuin | Shell history sync |
| bat | Syntax-highlighted cat |
| btop | System monitor |
| dua | Disk usage analyzer |
| fd | Fast file finder |
| fzf | Fuzzy finder |
| gh | GitHub CLI |
| htop | Process monitor |
| jq | JSON processor |
| lazygit | Git TUI |
| lsd | Modern ls |
| ncdu | Disk usage TUI |
| neofetch | System info |
| ripgrep | Fast grep |
| tldr | Command examples |
| tree | Directory tree |
| yazi | File manager TUI |
| zoxide | Smart cd |

### Archive Tools
| Application | Formats |
|-------------|---------|
| p7zip | 7z, zip, rar, etc. |
| unar | Universal extractor |
| unzip | ZIP files |
| zip | ZIP creation |

---

## Text Editors & IDEs

### Neovim (Primary)
| Component | Details |
|-----------|---------|
| Package | sinh-x-nixvim (Neve) |
| Theme | Custom |
| Source | `sinh-x.cli-apps.editor.neovim` |

**LSP Support:**
- Rust (rust-analyzer)
- TypeScript/JavaScript
- Go
- Python
- Lua
- Julia
- Kotlin
- And more...

**Tools Included:**
- Tree-sitter (syntax highlighting)
- Formatters: Prettier, Black, Stylua, Rustfmt
- Linters: eslint_d, Selene, Statix

### VS Code
| Setting | Value |
|---------|-------|
| Source | `sinh-x.coding.editor.vscode` |
| Extensions | Rust Analyzer, GitHub Copilot |

### Claude Code
| Source | `sinh-x.coding.claudecode` |

---

## Development Tools

### Languages & Runtimes
| Language | Version/Package |
|----------|-----------------|
| Rust | System + cargo-binstall |
| Node.js | 22 |
| Python | Custom module |
| Go | Latest |
| Zig | Latest |
| Julia | Latest |
| Lua | Latest |

### Containers & VMs
| Tool | Description | Source |
|------|-------------|--------|
| Docker | Container runtime | `modules.docker` |
| Genymotion | Android emulator | `modules.genymotion` |
| VirtualBox | VM (guest additions) | System |

### Cloud & Infrastructure
| Tool | Description |
|------|-------------|
| AWS CLI v2 | AWS management |
| gcloud | Google Cloud SDK |
| rclone | Cloud storage sync |

### Version Control
| Tool | Description |
|------|-------------|
| git | Version control |
| gitflow | Git workflow |
| gh | GitHub CLI |

### Nix Tools
| Tool | Description |
|------|-------------|
| direnv | Environment switcher |
| devenv | Development environments |
| nix-tree | Store browser |
| nh | Nix helper |
| deadnix | Unused code finder |
| statix | Static analysis |

---

## Web Browsers

| Browser | Type | Status | Source |
|---------|------|--------|--------|
| Zen Browser (twilight) | Firefox fork | Primary | `sinh-x.apps.web.zen-browser` |
| Google Chrome | Chromium | Secondary | `sinh-x.apps.web.browser.chrome` |
| Brave | Chromium | Alternative | `sinh-x.apps.web.browser.brave` |

---

## Communication & Social

| Application | Protocol | Source |
|-------------|----------|--------|
| Discord | Discord | `sinh-x.social-apps.discord` |
| Element | Matrix | `sinh-x.social-apps.element` |
| Telegram Desktop | Telegram | `sinh-x.social-apps.telegram` |
| Signal Desktop | Signal | `sinh-x.social-apps.signal` |
| Slack | Slack | `sinh-x.social-apps.slack` |
| Viber | Viber | `sinh-x.social-apps.viber` |
| Zoom | Video call | `sinh-x.social-apps.zoom` |
| Thunderbird | Email | System |

---

## Multimedia

### Audio
| Application | Description | Source |
|-------------|-------------|--------|
| MPD | Music daemon | `sinh-x.multimedia.mpd` |
| ncmpcpp | MPD client | `sinh-x.multimedia.mpd` |
| mpc | MPD CLI | `sinh-x.multimedia.mpd` |
| PipeWire | Audio server | System |
| Pavucontrol | Volume GUI | System |
| Pamixer | Volume CLI | System |
| Playerctl | Media control | System |

### Video
| Application | Description |
|-------------|-------------|
| mpv | Video player |
| yt-dlp | Video downloader |
| Kdenlive | Video editor |
| Wf-recorder | Screen recorder |
| FFmpeg 7 (full) | Multimedia framework |

### Image
| Application | Description |
|-------------|-------------|
| GIMP | Image editor |
| Viewnior | Image viewer |
| swayimg | Wayland image viewer |
| ImageMagick | CLI image processing |
| Hyprpicker | Color picker |

---

## Office & Productivity

| Application | Description | Source |
|-------------|-------------|--------|
| OnlyOffice | Office suite | `sinh-x.office` |
| Obsidian | Note-taking | `sinh-x.office` |
| Evince | PDF viewer | `sinh-x.office` |
| Okular | Document viewer | System |
| Inkscape | Vector graphics | `sinh-x.office` |
| Super Productivity | Task/time tracking | `sinh-x.coding.super-productivity` |
| ActivityWatch | Time tracking | `sinh-x.apps.utilities` |

---

## File Management

| Application | Type | Description |
|-------------|------|-------------|
| Thunar | GUI | File manager with plugins |
| Yazi | TUI | Terminal file manager |
| GVFS | Service | Virtual filesystem |
| Tumbler | Service | Thumbnails |

---

## Security & Privacy

| Application | Description | Source |
|-------------|-------------|--------|
| Bitwarden | Password manager | `sinh-x.security.bitwarden` |
| sops-nix | Secrets management | `sinh-x.security.sops` |
| age | Encryption | sops backend |

---

## System Utilities

### Hardware Monitoring
| Tool | Description |
|------|-------------|
| btop | System resources |
| nvtop | GPU monitoring |
| nvidia-system-monitor-qt | NVIDIA GUI monitor |
| lm_sensors | Hardware sensors |
| below | System profiler |

### Display & Input
| Tool | Description |
|------|-------------|
| brightnessctl | Brightness control |
| acpilight | ACPI brightness |
| light | Backlight control |
| sct | Color temperature |

### Networking
| Tool | Description |
|------|-------------|
| stubby | DNS-over-TLS |
| OpenSSH | SSH server |

### Printing
| Tool | Description |
|------|-------------|
| CUPS | Print daemon |
| CUPS-PDF | PDF printer |
| brlaser | Brother laser driver |

### Filesystem
| Tool | Description |
|------|-------------|
| ntfs3g | NTFS support |

---

## Custom sinh-x Tools

| Package | Description | Source |
|---------|-------------|--------|
| sinh-x-pomodoro | Pomodoro timer CLI | Overlay |
| sinh-x-wallpaper | Wallpaper manager | Overlay |
| sinh-x-ip_updater | Dynamic IP service | Overlay |
| sinh-x-nixvim (Neve) | Neovim distribution | Overlay |
| sinh-x-gitstatus | Git status utility | Overlay |

---

## Backup & Sync

| Tool | Description | Schedule |
|------|-------------|----------|
| rustic | Backup solution | Daily 19:00-23:59 |
| rclone | Cloud sync | Manual |
| syncthing | File sync | Continuous |

---

## Gaming

| Application | Description |
|-------------|-------------|
| Steam | Gaming platform |

---

## Fonts

### Nerd Fonts
- JetBrainsMono (default monospace)
- Fira Code
- Hack
- Iosevka
- Iosevka Term
- Meslo LGS

### Other Fonts
- Noto Fonts (Unicode)
- Noto Color Emoji
- Font Awesome
- Material Icons
- Ubuntu Classic
- Dancing Script
- Powerline fonts
- WPS missing fonts
- Archcraft icon fonts
