# Hyprland Configuration

Detailed documentation of the Hyprland window manager setup on Emberroot.

## Core Configuration

### NixOS Module
**Location:** `modules/nixos/wm/hyprland/default.nix`

```nix
modules.wm.hyprland = {
  enable = true;
  greetd = {
    enable = true;
    autoLogin = {
      enable = true;
      user = "sinh";
    };
  };
};
```

### Home Module
**Location:** `modules/home/wm/hyprland/default.nix`

```nix
sinh-x.wm.hyprland = {
  enable = true;
  monitors = {
    primary = "eDP-1";
    primaryResolution = "3840x2400";
    externalPosition = "left";
  };
  workspaces.distribution = "split";
};
```

## Display Manager

| Setting | Value |
|---------|-------|
| Manager | greetd |
| Greeter | tuigreet |
| Auto-login | Enabled (user: sinh) |
| VT | tty1 |

## Monitor Configuration

### Primary Display
| Property | Value |
|----------|-------|
| Monitor | eDP-1 |
| Resolution | 3840x2400 |
| Role | Primary |

### Multi-Monitor Setup
| Setting | Value |
|---------|-------|
| External Position | left |
| Detection | Automatic |
| Fallback | Primary only |

## Workspace Distribution

**Mode:** Split distribution

| Monitor | Workspaces |
|---------|------------|
| Primary (eDP-1) | 1-5 |
| External | 6-10 |
| F-keys | 11-20 |

### Workspace Behavior
- Dynamic workspace generation based on monitor detection
- Automatic monitor change detection
- Runtime workspace reconfiguration
- Persistent workspace assignment

## Core Components

### Status Bar
| Component | Package |
|-----------|---------|
| Bar | Waybar |
| Widgets | Eww (Elkowar's Wacky Widgets) |

### Launchers
| Priority | Application | Description |
|----------|-------------|-------------|
| 1 | Wofi | Primary launcher |
| 2 | Rofi | Alternative (Wayland mode) |
| 3 | Fuzzel | Fast fallback |
| 4 | Tofi | Minimal option |

### Notifications
| Component | Package |
|-----------|---------|
| Daemon | Mako |

### Screen Lock
| Component | Package |
|-----------|---------|
| Locker | Hyprlock |

### Wallpaper
| Component | Package | Description |
|-----------|---------|-------------|
| Daemon | swww | Animated wallpaper support |
| Setter | swaybg | Static fallback |
| Manager | sinh-x-wallpaper | Custom wallpaper tool |

## Plugins & Extensions

| Plugin | Description |
|--------|-------------|
| Pyprland | Scratchpad and layout management |
| Hyprcursor | Cursor management |
| Hyprhook | Event hook system |

## Color & Theming

| Component | Theme |
|-----------|-------|
| GTK Theme | TokyoNight |
| Icon Theme | Paper |
| Color Generation | Pywal |
| Color Utilities | Pastel |

## Screenshot & Recording

| Function | Tool |
|----------|------|
| Full screenshot | Hyprshot / Grim |
| Region select | Slurp |
| Screen recording | Wf-recorder |

## Clipboard Management

| Function | Tool |
|----------|------|
| Copy/Paste | wl-clipboard |
| Persistence | wl-clip-persist |
| History | Cliphist |

## Input Configuration

### FCitx5 Integration
| Variable | Value |
|----------|-------|
| `IMSETTINGS_MODULE` | fcitx |
| `INPUT_METHOD` | fcitx |
| `QT_IM_MODULE` | fcitx |
| `XMODIFIERS` | @im=fcitx |
| `GTK_IM_MODULE` | fcitx |

### TrackPoint
| Setting | Value |
|---------|-------|
| Sensitivity | 250 |
| Speed | 120 |
| Drift Time | 25 |

## Environment Variables

### Wayland/Display
```bash
WLR_NO_HARDWARE_CURSORS=1
NIXOS_OZONE_WL=1
XDG_CURRENT_DESKTOP=Hyprland
XDG_SESSION_TYPE=wayland
XDG_SESSION_DESKTOP=Hyprland
```

### GPU (NVIDIA)
```bash
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
LIBVA_DRIVER_NAME=nvidia
```

## XDG Portals

| Portal | Purpose |
|--------|---------|
| xdg-desktop-portal-hyprland | Hyprland integration |
| xdg-desktop-portal-wlr | wlroots fallback |

## Services

| Service | Description |
|---------|-------------|
| Polkit GNOME | Authentication agent |
| Geoclue2 | Location (theme switching) |
| Blueman | Bluetooth applet |

## Brightness Control

| Tool | Method |
|------|--------|
| brightnessctl | Primary |
| acpilight | ACPI backend |
| light | Alternative |

## Audio Integration

| Tool | Function |
|------|----------|
| Pamixer | Volume control |
| Pulsemixer | Mixer CLI |
| Pavucontrol | GUI mixer |
| Playerctl | Media control |

## File Management

| Component | Application |
|-----------|-------------|
| File Manager | Thunar |
| Thumbnails | Tumbler |
| Virtual FS | GVFS |
| Image Viewer | Viewnior, swayimg |

## Monitor Tools

| Tool | Function |
|------|----------|
| wlr-randr | Monitor configuration |
| Hyprpicker | Color picker |

## Compositor Settings

### NVIDIA Specific
| Setting | Value |
|---------|-------|
| PRIME Mode | Sync |
| Offload | Disabled |
| Modesetting | Enabled |
| Power Management | Enabled |
| Full Composition | Forced |

### General
| Setting | Purpose |
|---------|---------|
| picom | X11 compositor fallback |
| Qt5 Wayland | Qt application support |

---

## Window Rules

Window rules control how specific applications behave when launched.

### Floating Windows

Applications that automatically float:

| Application | Class Match |
|-------------|-------------|
| YAD dialogs | `Yad`, `yad` |
| Network Manager | `nm-connection-editor` |
| Volume Control | `pavucontrol` |
| Polkit | `xfce-polkit` |
| Qt Config | `kvantummanager`, `qt5ct` |
| Image Viewers | `feh`, `Viewnior`, `Gpicview`, `Gimp` |
| Media Players | `MPlayer`, `mplayer2` |
| VirtualBox | `VirtualBox Manager`, `VirtualBox` |
| QEMU | `qemu`, `Qemu-system-x86_64` |
| Calculator | `gnome-calculator` |
| Screenshot | `flameshot` |
| Bluetooth | `Blueman-manager` |
| Clipboard | `copyq` |
| Finance | `Moneydance` |
| Steam | `Steam` |
| Zoom | `zoom` |
| Video Editor | `kdenlive`, `Gimp` |

### Workspace Assignments

| Workspace | Applications |
|-----------|--------------|
| 1 | Zen Browser (`zen-twilight`), Floorp |
| 3 | Thunar (file manager) |
| 4 | VirtualBox Machine |
| 5 (silent) | Obsidian, Notion |
| 6 | Kitty terminal, Install4j apps |
| 9 | Kdenlive, GIMP |

### Scratchpads (Special Workspaces)

| Scratchpad | Application | Toggle Key |
|------------|-------------|------------|
| `scratchpad` | Float terminals (`kitty-float`, `alacritty-float`, `foot-float`) | `SUPER + `` ` |
| `bitwarden` | Bitwarden password manager | `CTRL+ALT + B` |
| `viber` | Viber messenger | `CTRL+ALT + V` |

### Pinned Windows (Sticky)

Windows that stay visible across all workspaces:

| Application | Notes |
|-------------|-------|
| Pavucontrol | Volume control |
| dropdown | Dropdown terminals |
| zoom | Video calls |
| bashtop | System monitor |
| pomodoro | Timer |

### Window Sizes

| Application | Size |
|-------------|------|
| YAD dialogs | 60% x 64% |
| Viewnior | 60% x 64% (centered) |
| Float terminals | 785 x 450 |
| bashtop | 1400 x 1400 (centered) |
| pomodoro | 1400 x 1400 (centered) |

### Animations

| Window Type | Animation |
|-------------|-----------|
| `foot-full` | slide down |
| `wlogout` | slide up |

---

## Keybindings

### Legend

| Modifier | Key |
|----------|-----|
| `SUPER` | Windows/Meta key |
| `SHIFT` | Shift key |
| `CTRL` | Control key |
| `ALT` | Alt key |

### Terminal

| Keybinding | Action |
|------------|--------|
| `SUPER + Return` | Open Kitty terminal |
| `SUPER + T` | Open floating Kitty terminal |

### Applications

| Keybinding | Action |
|------------|--------|
| `SUPER + SHIFT + F` | Open Thunar (file manager) |
| `SUPER + SHIFT + E` | Open Geany (editor) |
| `SUPER + SHIFT + W` | Open Zen Browser |

### Rofi Menus

| Keybinding | Menu |
|------------|------|
| `SUPER + D` | Application launcher |
| `ALT + F1` | Application launcher |
| `ALT + F2` | Command runner |
| `SUPER + R` | Run as root |
| `SUPER + M` | Music player |
| `SUPER + N` | Network manager |
| `SUPER + B` | Bluetooth |
| `SUPER + X` | Power menu |
| `SUPER + A` | Screenshot menu |
| `SUPER + K` | Keybindings help |

### Window Management

| Keybinding | Action |
|------------|--------|
| `SUPER + C` | Close active window |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + S` | Toggle pseudo-tiling |
| `SUPER + Space` | Toggle floating + center |
| `SUPER + Tab` | Cycle windows |
| `SUPER + Z` | Swap with master |
| `SUPER + SHIFT + P` | Pin window (sticky) |
| `SUPER + SHIFT + S` | Swap with next window |

### Focus Navigation

| Keybinding | Action |
|------------|--------|
| `SUPER + Left` | Focus left |
| `SUPER + Right` | Focus right |
| `SUPER + Up` | Focus up |
| `SUPER + Down` | Focus down |

### Move Windows

| Keybinding | Action |
|------------|--------|
| `SUPER + SHIFT + Left` | Move window left |
| `SUPER + SHIFT + Right` | Move window right |
| `SUPER + SHIFT + Up` | Move window up |
| `SUPER + SHIFT + Down` | Move window down |

### Resize Windows

| Keybinding | Action |
|------------|--------|
| `SUPER + CTRL + Left` | Shrink width (-20) |
| `SUPER + CTRL + Right` | Expand width (+20) |
| `SUPER + CTRL + Up` | Shrink height (-20) |
| `SUPER + CTRL + Down` | Expand height (+20) |

### Move Floating Windows

| Keybinding | Action |
|------------|--------|
| `SUPER + ALT + Left` | Move left (-20) |
| `SUPER + ALT + Right` | Move right (+20) |
| `SUPER + ALT + Up` | Move up (-20) |
| `SUPER + ALT + Down` | Move down (+20) |

### Workspaces (1-10)

| Keybinding | Action |
|------------|--------|
| `SUPER + 1-0` | Switch to workspace 1-10 |
| `SUPER + SHIFT + 1-0` | Move window to workspace 1-10 |
| `CTRL + ALT + Left` | Previous workspace |
| `CTRL + ALT + Right` | Next workspace |
| `CTRL + ALT + SHIFT + Left` | Move window to previous workspace |
| `CTRL + ALT + SHIFT + Right` | Move window to next workspace |

### Workspaces (11-20) - F-Keys

| Keybinding | Action |
|------------|--------|
| `SUPER + F1-F10` | Switch to workspace 11-20 |
| `SUPER + SHIFT + F1-F10` | Move window to workspace 11-20 |

### Groups

| Keybinding | Action |
|------------|--------|
| `SUPER + G` | Toggle group mode |
| `SUPER + H` | Previous window in group |
| `SUPER + L` | Next window in group / cycle layout |
| `SUPER + SHIFT + L` | Toggle group lock |

### Workspace Modes

| Keybinding | Action |
|------------|--------|
| `SUPER + CTRL + F` | Toggle all-float mode |
| `SUPER + CTRL + S` | Toggle all-pseudo mode |

### Special Workspaces (Scratchpads)

| Keybinding | Action |
|------------|--------|
| `SUPER + `` ` | Toggle scratchpad |
| `CTRL + ALT + B` | Toggle Bitwarden scratchpad |
| `CTRL + ALT + V` | Toggle Viber scratchpad |

### Monitor Management

| Keybinding | Action |
|------------|--------|
| `SUPER + SHIFT + =` | Move window to next monitor |

### Screenshots

| Keybinding | Action |
|------------|--------|
| `Print` | Screenshot area (select) |
| `SUPER + Print` | Screenshot area (select) |
| `ALT + Print` | Screenshot in 5 seconds |
| `SHIFT + Print` | Screenshot in 10 seconds |
| `CTRL + Print` | Screenshot active window |

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

### Miscellaneous

| Keybinding | Action |
|------------|--------|
| `SUPER + P` | Color picker |
| `CTRL + ALT + L` | Lock screen (hyprlock) |
| `CTRL + `` ` | Clipboard history (rofi + cliphist) |
| `CTRL + ALT + Delete` | Exit Hyprland |
| `Lid Switch` | Lock screen |

### Mouse Bindings

| Binding | Action |
|---------|--------|
| `SUPER + Left Click` | Move window |
| `SUPER + Right Click` | Resize window |

---

## Startup Applications

Applications launched automatically when Hyprland starts:

| Application | Purpose |
|-------------|---------|
| `~/.config/hypr/scripts/startup` | Main startup script |
| `monitor_watcher` | Dynamic workspace configuration |
| `viber` | Messenger (to scratchpad) |
| `fcitx5` | Input method |
| `aw-server` | ActivityWatch server |
| `clipman store` | Clipboard manager |
| `bitwarden` | Password manager (to scratchpad) |
| `wl-paste --type text` | Text clipboard history |
| `wl-paste --type image` | Image clipboard history |
| `low_battery` | Battery monitor script |
| `thunderbird` | Email client |

---

## Layout Configuration

### Dwindle Layout (Default)

| Setting | Value |
|---------|-------|
| Pseudotile | false |
| Force split | 0 |
| Preserve split | false |
| Smart split | false |
| Smart resizing | true |
| Special scale factor | 0.8 |
| Split width multiplier | 1.0 |
| Use active for splits | true |
| Default split ratio | 1.0 |

### Master Layout (Alternative)

| Setting | Value |
|---------|-------|
| Master factor | 0.55 |
| New status | slave |
| New on top | false |
| Orientation | left |
| Special scale factor | 0.8 |
| Smart resizing | true |
| Drop at cursor | true |

---

## Animation Settings

| Animation | Duration | Curve | Style |
|-----------|----------|-------|-------|
| windowsIn | 5 | default | popin 0% |
| windowsOut | 5 | default | popin |
| windowsMove | 5 | default | slide |
| layersIn | 4 | default | slide |
| layersOut | 4 | default | slide |
| fadeIn | 8 | default | - |
| fadeOut | 8 | default | - |
| border | 20 | default | - |
| borderangle | 20 | default | once |
| workspacesIn | 5 | default | slide |
| workspacesOut | 5 | default | slide |
| specialWorkspaceIn | 5 | default | fade |
| specialWorkspaceOut | 5 | default | fade |
