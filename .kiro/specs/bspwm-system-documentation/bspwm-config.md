# BSPWM Configuration

Detailed documentation of the BSPWM window manager setup.

## Core Configuration

### NixOS Module
**Location:** `modules/nixos/wm/bspwm/default.nix`

```nix
modules.wm.bspwm.enable = true;
```

### Home Module
**Location:** `modules/home/wm/bspwm/default.nix`

```nix
sinh-x.wm.bspwm.enable = true;
```

The home module copies the entire `bspwm_config/` directory to `~/.config/bspwm/`.

---

## Environment Variables

**Location:** `bspwmrc` lines 20-21

| Variable | Value |
|----------|-------|
| `BROWSER` | zen-twilight |
| `EDITOR` | nvim |

---

## Appearance Settings

**Location:** `bspwmrc` lines 26-34

| Setting | Value | Description |
|---------|-------|-------------|
| `BSPWM_FBC` | #81A1C1 | Focused border color |
| `BSPWM_NBC` | #2E3440 | Normal border color |
| `BSPWM_ABC` | #B48EAD | Active border color |
| `BSPWM_PFC` | #A3BE8C | Preselection feedback color |
| `BSPWM_BORDER` | 1 | Border width (pixels) |
| `BSPWM_GAP` | 5 | Window gap (pixels) |
| `BSPWM_SRATIO` | 0.50 | Split ratio |

---

## Monitor & Workspace Configuration

### Per-Host Setup

Each host has its own workspace configuration script in `monitors-workspaces/`:

| Host | File | Primary Monitor |
|------|------|-----------------|
| Elderwood | `Elderwood.fish` | DP-1 |
| Drgnfly | `Drgnfly.fish` | eDP-1 |

### BSPWM Settings

**Location:** `bspwmrc` lines 48-66

| Setting | Value |
|---------|-------|
| `border_width` | $BSPWM_BORDER |
| `window_gap` | $BSPWM_GAP |
| `split_ratio` | $BSPWM_SRATIO |
| `remove_disabled_monitors` | false |
| `remove_unplugged_monitors` | false |
| `borderless_monocle` | true |
| `gapless_monocle` | true |
| `paddingless_monocle` | true |
| `single_monocle` | false |
| `pointer_follows_focus` | true |
| `pointer_follows_monitor` | true |
| `focus_follows_pointer` | true |
| `presel_feedback` | true |

---

## Window Rules

### Floating Windows

**Location:** `bspwmrc` lines 77-103, 147-151

| Application | Class | Additional Settings |
|-------------|-------|---------------------|
| Moneydance | `Moneydance` | floating |
| Blueman | `Blueman-manager` | floating |
| Pavucontrol | `Pavucontrol` | floating, sticky |
| CopyQ | `copyq` | floating |
| Calculator | `gnome-calculator` | floating |
| Bitwarden | `Bitwarden` | floating, locked, sticky |
| Dropdown | `dropdown` | floating, locked, sticky |
| bashtop | `bashtop` | floating, sticky, locked, centered, 1400x1400 |
| pomodoro | `pomodoro` | floating, sticky, locked, centered, 1400x1400 |
| Flameshot | `flameshot` | floating |
| Steam | `Steam` | floating |
| VirtualBox Manager | `VirtualBox Manager` | floating |
| Zoom | `zoom` | floating, sticky |
| Gpick | `Gpick` | floating |
| Yad | `Yad` | floating |
| Alacritty Float | `alacritty-float` | floating |
| Pcmanfm | `Pcmanfm` | floating |
| Viewnior | `Viewnior` | floating |
| feh | `feh` | floating |

### Workspace Assignments

**Location:** `bspwmrc` lines 78-144

| Desktop | Applications |
|---------|--------------|
| 3 | Thunar, Pcmanfm, qBittorrent |
| 4 | VirtualBox Machine, Geany, code-oss |
| 5 | RStudio, Obsidian, Notion |
| 6 | com-install4j-runtime-launcher |
| 7 | LibreOffice apps, Atril, Evince |
| 8 | Thunderbird, Telegram, Hexchat, Viber |
| 9 | Kdenlive, Gimp |
| 10 | Media apps, GParted, system settings |

### External Rules (Dynamic)

**Location:** `scripts/external_rules.fish`

The external rules script handles dynamic window placement based on:
- Current monitor
- Single vs dual monitor setup
- Application class matching

#### Browser Routing

| Browser | Classes |
|---------|---------|
| Chrome | `Google-chrome` |
| Edge | `Microsoft-edge-dev` |
| Firefox | `firefox` |
| Floorp | `floorp` |
| Opera | `Opera` |
| Zen | `zen`, `zen-twilight` |

**Desktops:** 1, 2, 16, 17 (distributed based on monitor)

#### Terminal Routing

| Terminal | Classes |
|----------|---------|
| Alacritty | `Alacritty` |
| Xfce4-terminal | `Xfce4-terminal` |
| Kitty | `kitty` |
| Ghostty | `ghostty` |

**Desktops:** 6, 7, 11, 12 (distributed based on monitor)

---

## Keybindings

**Location:** `sxhkdrc`

### Legend

| Modifier | Key |
|----------|-----|
| `super` | Windows/Meta key |
| `shift` | Shift key |
| `ctrl` | Control key |
| `alt` | Alt key |

### Terminal

| Keybinding | Action |
|------------|--------|
| `super + Return` | Open Ghostty terminal |
| `super + shift + Return` | Open floating terminal |
| `super + alt + Return` | Open fullscreen terminal |

### Applications

| Keybinding | Action |
|------------|--------|
| `super + shift + F` | Open Thunar (file manager) |
| `super + shift + W` | Open Zen Browser |
| `super + P` | Color picker |
| `ctrl + alt + M` | Music manager |
| `ctrl + alt + B` | Toggle Bitwarden |
| `ctrl + alt + O` | Open Obsidian |
| `ctrl + shift + Escape` | Toggle bashtop |
| `ctrl + shift + F12` | Toggle dropdown terminal |
| `super + ctrl + F5` | Calendar (gsimplecal) |
| `super + ctrl + F12` | Display key |
| `XF86Calculator` | GNOME Calculator |

### Rofi Menus

| Keybinding | Menu |
|------------|------|
| `alt + F1` | Application launcher |
| `alt + F2` | Command runner |
| `super + B` | Bluetooth |
| `super + M` | Music |
| `super + N` | Network manager |
| `super + R` | Run as root |
| `super + S` | Screenshot |
| `super + T` | Themes |
| `super + W` | Window switcher |
| `super + X` | Power menu |

### Window Management

| Keybinding | Action |
|------------|--------|
| `super + C` | Close window |
| `super + shift + C` | Kill window |
| `super + F` | Toggle fullscreen |
| `super + Space` | Toggle floating/tiled |
| `super + shift + Space` | Toggle pseudo-tiled |
| `super + L` | Toggle layout (tiled/monocle) |
| `super + Z` | Swap with biggest window |
| `super + shift + V` | Rotate parent 90 degrees |

### Focus Navigation

| Keybinding | Action |
|------------|--------|
| `super + Left` | Focus west |
| `super + Right` | Focus east |
| `super + Up` | Focus north |
| `super + Down` | Focus south |
| `alt + Tab` | Cycle next window |
| `alt + shift + Tab` | Cycle previous window |

### Move Windows

| Keybinding | Action |
|------------|--------|
| `alt + shift + Left` | Swap west |
| `alt + shift + Right` | Swap east |
| `alt + shift + Up` | Swap north |
| `alt + shift + Down` | Swap south |

### Resize Windows

| Keybinding | Action |
|------------|--------|
| `super + ctrl + Left` | Expand left (-20) |
| `super + ctrl + Right` | Expand right (+20) |
| `super + ctrl + Up` | Expand up (-20) |
| `super + ctrl + Down` | Expand down (+20) |
| `super + alt + Left` | Shrink from left (+20) |
| `super + alt + Right` | Shrink from right (-20) |
| `super + alt + Up` | Shrink from top (+20) |
| `super + alt + Down` | Shrink from bottom (-20) |

### Move Floating Windows

| Keybinding | Action |
|------------|--------|
| `super + alt + shift + Left` | Move left (-20) |
| `super + alt + shift + Right` | Move right (+20) |
| `super + alt + shift + Up` | Move up (-20) |
| `super + alt + shift + Down` | Move down (+20) |

### Workspaces (1-10)

| Keybinding | Action |
|------------|--------|
| `super + 1-0` | Switch to desktop 1-10 |
| `super + shift + 1-0` | Move window to desktop 1-10 |
| `ctrl + alt + Left` | Previous desktop |
| `ctrl + alt + Right` | Next desktop |
| `ctrl + alt + shift + Left` | Move window to previous desktop |
| `ctrl + alt + shift + Right` | Move window to next desktop |

### Workspaces (11-20) - F-Keys

| Keybinding | Action |
|------------|--------|
| `super + F1-F10` | Switch to desktop 11-20 |
| `super + shift + F1-F10` | Move window to desktop 11-20 |

### Monitor Management

| Keybinding | Action |
|------------|--------|
| `super + shift + =` | Move window to next monitor |
| `super + shift + -` | Move window to previous monitor |
| `super + shift + Arrow` | Move window to monitor in direction |

### Preselection

| Keybinding | Action |
|------------|--------|
| `super + H` | Preselect east (horizontal split) |
| `super + V` | Preselect south (vertical split) |
| `super + Q` | Cancel preselection |
| `super + ctrl + 1-9` | Set preselection ratio (0.1-0.9) |

### Node Flags

| Keybinding | Action |
|------------|--------|
| `super + ctrl + M` | Toggle marked |
| `super + ctrl + X` | Toggle locked |
| `super + ctrl + Y` | Toggle sticky |
| `super + ctrl + Z` | Toggle private |

### Screenshots

| Keybinding | Action |
|------------|--------|
| `Print` | Flameshot GUI |
| `alt + Print` | Full screenshot |
| `ctrl + Print` | Window screenshot |

### Media & Hardware Keys

| Key | Action |
|-----|--------|
| `XF86MonBrightnessUp` | Increase brightness |
| `XF86MonBrightnessDown` | Decrease brightness |
| `XF86AudioRaiseVolume` | Increase volume |
| `XF86AudioLowerVolume` | Decrease volume |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle microphone mute |
| `XF86AudioNext` | Next track (mpc) |
| `XF86AudioPrev` | Previous track (mpc) |
| `XF86AudioPlay` | Play/pause (mpc) |
| `XF86AudioStop` | Stop (mpc) |
| `XF86Launch5` | Decrease brightness |
| `XF86Launch6` | Increase brightness |

### System

| Keybinding | Action |
|------------|--------|
| `ctrl + shift + Q` | Quit BSPWM |
| `ctrl + shift + R` | Restart BSPWM |
| `super + shift + R` | Restart Polybar |
| `super + Escape` | Reload sxhkd config |
| `ctrl + alt + Escape` | xkill |
| `ctrl + alt + W` | Refresh wallpaper |

---

## Autostart Applications

**Location:** `bspwmrc` lines 158-219

| Application | Purpose |
|-------------|---------|
| xsettingsd | X settings daemon |
| xfce-polkit | Polkit authentication agent |
| sxhkd | Hotkey daemon |
| bspbar | Polybar launcher |
| bspcomp | Picom compositor |
| bspdunst | Dunst notification daemon |
| copyq | Clipboard manager |
| fcitx5 | Input method |
| flameshot | Screenshot tool |
| viber | Messenger |
| input-leap | KVM software |
| sinh-x-wallpaper | Wallpaper manager |
| aw-qt | ActivityWatch |
| pomodoro | Pomodoro timer |
| displaykey.fish | Display key indicator |

---

## Core Components

### Status Bar
| Component | Package |
|-----------|---------|
| Bar | Polybar |

### Launchers
| Application | Description |
|-------------|-------------|
| Rofi | Primary launcher and menu system |

### Notifications
| Component | Package |
|-----------|---------|
| Daemon | Dunst |

### Compositor
| Component | Package |
|-----------|---------|
| Compositor | Picom |

### Wallpaper
| Component | Package |
|-----------|---------|
| Setter | feh |
| Manager | sinh-x-wallpaper |

---

## Scripts

**Location:** `bspwm_config/scripts/`

| Script | Purpose |
|--------|---------|
| `bspbar` | Launch Polybar |
| `bspcomp` | Launch Picom compositor |
| `bspdunst` | Launch Dunst notifications |
| `bspterm` | Terminal launcher with options |
| `bspvolume` | Volume control |
| `bspbrightness` | Brightness control |
| `bspcolorpicker` | Color picker |
| `bspmusic` | Music player control |
| `bspwm-toggle-visibility.sh` | Toggle window visibility |
| `external_rules.fish` | Dynamic window rules |
| `rofi_*` | Various Rofi menus |
| `displaykey.fish` | Display key indicator |
| `win_screenshot` | Window screenshot |

---

## System Packages

**Location:** `modules/nixos/wm/bspwm/default.nix`

### Window Manager
- bspwm
- sxhkd
- polybarFull
- picom

### Launchers
- rofi
- dmenu

### Utilities
- dunst
- feh
- flameshot
- xdotool
- xdo
- copyq

### File Management
- thunar
- gvfs
- lxappearance

### Audio
- pamixer
- pulsemixer

### Screen Lock
- betterlockscreen

### Theming
- pastel
- xcolor

### Input
- screenkey

---

## Comparison with Hyprland

| Feature | BSPWM | Hyprland |
|---------|-------|----------|
| Display Server | X11 | Wayland |
| Terminal | Ghostty | Ghostty |
| Browser | Zen Browser | Zen Browser |
| File Manager | Thunar | Thunar |
| Status Bar | Polybar | Waybar |
| Launcher | Rofi | Rofi (Wayland) |
| Compositor | Picom | Built-in |
| Notifications | Dunst | Mako |
| Screenshot | Flameshot | Grim + Slurp |
| Clipboard | CopyQ | wl-clipboard + cliphist |
| Screen Lock | betterlockscreen | Hyprlock |

### Synced Settings

The following settings are kept in sync between BSPWM and Hyprland:

1. **Default Applications**
   - Terminal: Ghostty
   - Browser: Zen Browser (zen-twilight)
   - File Manager: Thunar

2. **Workspace Assignments**
   - Desktop 3: File managers
   - Desktop 4: Code editors, VirtualBox
   - Desktop 5: Obsidian, Notion
   - Desktop 9: Kdenlive, GIMP

3. **Similar Keybindings**
   - `super + Return`: Terminal
   - `super + shift + F`: File manager
   - `super + shift + W`: Browser
   - `super + C`: Close window
   - `super + F`: Fullscreen
   - `super + Space`: Toggle floating
   - `super + 1-0`: Workspaces 1-10
   - `ctrl + alt + B`: Bitwarden toggle
