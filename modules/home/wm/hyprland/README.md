# Hyprland Dynamic Workspace Configuration

This module provides dynamic workspace configuration for Hyprland with automatic monitor detection, hotplug support, and flexible workspace distribution strategies.

## Features

- **Auto-detection**: Automatically detects monitors and resolutions at runtime
- **Hotplug support**: Regenerates workspace configuration when monitors are connected/disconnected
- **Flexible distribution**: Choose how workspaces are distributed across monitors
- **Runtime overrides**: Override settings without rebuilding via config file
- **F-key bindings**: Optional F1-F10 bindings for workspaces 11-20

## Quick Start

Enable the module in your home configuration:

```nix
sinh-x.wm.hyprland.enable = true;
```

That's it! The module will auto-detect your monitors and configure workspaces automatically.

## Configuration Options

### Monitor Settings

#### `monitors.primary`
- **Type**: `string` or `null`
- **Default**: `null` (auto-detect)
- **Description**: Primary monitor name (e.g., `eDP-1`, `DP-1`, `HDMI-A-1`)

```nix
sinh-x.wm.hyprland.monitors.primary = "eDP-1";
```

To find your monitor names, run:
```bash
hyprctl monitors | grep "Monitor"
```

#### `monitors.primaryResolution`
- **Type**: `string` or `null`
- **Default**: `null` (auto-detect)
- **Description**: Primary monitor resolution in `WIDTHxHEIGHT` format

```nix
sinh-x.wm.hyprland.monitors.primaryResolution = "3840x2400";
```

#### `monitors.externalResolution`
- **Type**: `string` or `null`
- **Default**: `null` (auto-detect)
- **Description**: External monitor resolution in `WIDTHxHEIGHT` format

```nix
sinh-x.wm.hyprland.monitors.externalResolution = "2560x1440";
```

#### `monitors.externalPosition`
- **Type**: `enum` - `"left"` | `"right"` | `"above"` | `"below"`
- **Default**: `"right"`
- **Description**: Position of external monitor relative to primary

```nix
sinh-x.wm.hyprland.monitors.externalPosition = "left";
```

#### `monitors.refreshRate`
- **Type**: `enum` - `"preferred"` | `"highrr"` | `"highres"`
- **Default**: `"preferred"`
- **Description**: Refresh rate mode for external monitors

| Value | Description |
|-------|-------------|
| `preferred` | Use monitor's preferred refresh rate |
| `highrr` | Prefer highest refresh rate |
| `highres` | Prefer highest resolution |

```nix
sinh-x.wm.hyprland.monitors.refreshRate = "highrr";
```

### Workspace Settings

#### `workspaces.distribution`
- **Type**: `enum` - `"split"` | `"primary-all"`
- **Default**: `"split"`
- **Description**: How workspaces are distributed across monitors

```nix
sinh-x.wm.hyprland.workspaces.distribution = "split";
```

### Keybinding Settings

#### `keybindings.generateFKeys`
- **Type**: `bool`
- **Default**: `true`
- **Description**: Generate F1-F10 bindings for workspaces 11-20 when external monitor is connected

```nix
sinh-x.wm.hyprland.keybindings.generateFKeys = true;
```

## Workspace Distribution Strategies

### Strategy: `split`

Distributes workspaces based on monitor position (left/right):

| Monitor Position | Workspaces |
|------------------|------------|
| Left monitor | 1-5, 11-15 |
| Right monitor | 6-10, 16-20 |

This is ideal for workflows where you want related workspaces grouped by physical location.

**Single monitor fallback**: All workspaces (1-10) on primary.

### Strategy: `primary-all`

Keeps base workspaces on primary, extended on external:

| Monitor | Workspaces |
|---------|------------|
| Primary | 1-10 |
| External | 11-20 |

This is ideal for workflows where primary monitor is the main focus.

**Single monitor fallback**: All workspaces (1-10) on primary.

## Keybindings

### Default bindings (always active)
| Keys | Action |
|------|--------|
| `SUPER + 1-9, 0` | Switch to workspace 1-10 |
| `SUPER_SHIFT + 1-9, 0` | Move window to workspace 1-10 |

### F-key bindings (when `generateFKeys = true` and external monitor present)
| Keys | Action |
|------|--------|
| `SUPER + F1-F10` | Switch to workspace 11-20 |
| `SUPER_SHIFT + F1-F10` | Move window to workspace 11-20 |

## Example Configurations

### Single Monitor (Laptop)

Minimal config - let everything auto-detect:

```nix
sinh-x.wm.hyprland = {
  enable = true;
  # Everything auto-detected
};
```

### Dual Monitor (Laptop + External on Right)

```nix
sinh-x.wm.hyprland = {
  enable = true;
  monitors = {
    primary = "eDP-1";
    primaryResolution = "1920x1080";
    externalPosition = "right";
  };
  workspaces.distribution = "split";
};
```

### Dual Monitor (Desktop with External on Left)

```nix
sinh-x.wm.hyprland = {
  enable = true;
  monitors = {
    primary = "DP-1";
    primaryResolution = "2560x1440";
    externalPosition = "left";
    refreshRate = "highrr";
  };
  workspaces.distribution = "split";
};
```

### Dual Monitor (Primary-focused workflow)

```nix
sinh-x.wm.hyprland = {
  enable = true;
  monitors = {
    primary = "eDP-1";
    externalPosition = "right";
  };
  workspaces.distribution = "primary-all";
  keybindings.generateFKeys = true;
};
```

### High-resolution Setup (4K + 1440p)

```nix
sinh-x.wm.hyprland = {
  enable = true;
  monitors = {
    primary = "eDP-1";
    primaryResolution = "3840x2400";
    externalResolution = "2560x1440";
    externalPosition = "left";
  };
  workspaces.distribution = "split";
};
```

## Runtime Configuration (monitor-vars.conf)

You can override settings at runtime without rebuilding NixOS by editing `~/.config/hypr/monitor-vars.conf`.

### Priority System

The configuration uses a three-tier priority system:

1. **User config file** (`monitor-vars.conf`) - Highest priority
2. **Nix config** (home-manager options) - Second priority
3. **Auto-detect** - Fallback when nothing is configured

This allows you to:
- Set defaults in Nix config (persistent across rebuilds)
- Override temporarily via user config file (no rebuild needed)
- Let the system auto-detect when you don't care

### Available Variables

Edit `~/.config/hypr/monitor-vars.conf` with any of these variables:

```bash
# Monitor settings
VAR_PRIMARY_MONITOR="eDP-1"        # Primary monitor name
VAR_PRIMARY_RESOLUTION="3840x2400" # Primary resolution (WIDTHxHEIGHT)
VAR_EXTERNAL_RESOLUTION="2560x1440" # External monitor resolution

# Position and display settings
VAR_EXTERNAL_POSITION="right"      # left, right, above, below
VAR_REFRESH_RATE="preferred"       # preferred, highrr, highres

# Workspace settings
VAR_DISTRIBUTION="split"           # split, primary-all
VAR_GENERATE_FKEYS="true"          # true, false
```

### Example: Temporary Monitor Override

Your Nix config has external monitor on the right, but today you want it on the left:

```bash
# ~/.config/hypr/monitor-vars.conf
VAR_EXTERNAL_POSITION="left"
```

Then regenerate:
```bash
~/.config/hypr/scripts/generate_workspace_config
```

### Example: Testing Different Distribution

Try `primary-all` distribution without rebuilding:

```bash
# ~/.config/hypr/monitor-vars.conf
VAR_DISTRIBUTION="primary-all"
```

Regenerate and test:
```bash
~/.config/hypr/scripts/generate_workspace_config
```

### When to Use Runtime Config vs Nix Config

| Use Case | Recommendation |
|----------|----------------|
| Permanent setup | Nix config |
| Testing changes | Runtime config |
| Temporary override | Runtime config |
| Different location (office vs home) | Runtime config |
| Sharing config across machines | Nix config |

### Resetting to Nix Defaults

To reset runtime overrides, comment out or remove variables from `monitor-vars.conf`:

```bash
# ~/.config/hypr/monitor-vars.conf
# VAR_EXTERNAL_POSITION="left"  # commented out - will use Nix config
```

Or delete the file entirely to use only Nix config + auto-detect.

## File Locations

| File | Purpose |
|------|---------|
| `~/.config/hypr/workspaces.conf` | Generated workspace configuration |
| `~/.config/hypr/monitor-vars.conf` | User runtime overrides |
| `~/.config/hypr/workspace-gen.log` | Generation log for debugging |
| `~/.config/hypr/scripts/generate_workspace_config` | Workspace generation script |
| `~/.config/hypr/scripts/monitor_watcher` | Monitor hotplug watcher |

## How It Works

1. **Startup**: `monitor_watcher` starts and runs `generate_workspace_config`
2. **Generation**: Script reads config priority: user file > Nix config > auto-detect
3. **Output**: Creates `workspaces.conf` with monitor and workspace assignments
4. **Hotplug**: `monitor_watcher` listens for monitor events and regenerates config
5. **Reload**: Hyprland config is automatically reloaded after generation

## Troubleshooting

### Checking the Log

The generation script logs all actions to `~/.config/hypr/workspace-gen.log`:

```bash
tail -20 ~/.config/hypr/workspace-gen.log
```

Example healthy output:
```
[2026-01-14 15:06:26] INFO: Loaded user config from /home/user/.config/hypr/monitor-vars.conf
[2026-01-14 15:06:26] INFO: Using user config external position: right
[2026-01-14 15:06:26] INFO: Using user config primary monitor: eDP-1
[2026-01-14 15:06:26] INFO: Primary: eDP-1 (3840x2400), External: none (n/a)
[2026-01-14 15:06:26] INFO: Workspace configuration generated
```

### Manually Regenerating Workspaces

If workspaces aren't configured correctly, regenerate manually:

```bash
~/.config/hypr/scripts/generate_workspace_config
```

### Verifying Monitor Detection

Check what monitors Hyprland sees:

```bash
hyprctl monitors
```

Or for JSON output:
```bash
hyprctl monitors -j | jq '.[].name'
```

### Checking Generated Configuration

View the current workspace configuration:

```bash
cat ~/.config/hypr/workspaces.conf
```

### Common Issues

#### Monitor Not Detected

**Symptoms**: External monitor connected but not in workspace config

**Solutions**:
1. Check if Hyprland sees it: `hyprctl monitors`
2. Regenerate config: `~/.config/hypr/scripts/generate_workspace_config`
3. Check log for errors: `tail ~/.config/hypr/workspace-gen.log`

#### Workspaces Not Switching Correctly

**Symptoms**: Keybindings don't switch to expected workspace

**Solutions**:
1. Verify workspaces.conf is sourced in your hyprland.conf
2. Check for conflicting keybindings
3. Regenerate and reload:
   ```bash
   ~/.config/hypr/scripts/generate_workspace_config
   hyprctl reload
   ```

#### F-Keys Not Working for Workspaces 11-20

**Symptoms**: SUPER+F1-F10 doesn't switch to workspaces 11-20

**Possible causes**:
1. No external monitor connected (F-key bindings only generated with dual monitors)
2. `generateFKeys` is set to `false`
3. Another application capturing F-keys

**Solutions**:
1. Check if external monitor is detected: `hyprctl monitors`
2. Verify setting: check your Nix config or `monitor-vars.conf`
3. Check workspaces.conf for F-key bindings:
   ```bash
   grep "F1" ~/.config/hypr/workspaces.conf
   ```

#### Hotplug Not Triggering Regeneration

**Symptoms**: Connecting/disconnecting monitor doesn't update workspaces

**Solutions**:
1. Check if monitor_watcher is running:
   ```bash
   pgrep -f monitor_watcher
   ```
2. Check Hyprland socket exists:
   ```bash
   ls $XDG_RUNTIME_DIR/hypr/*/
   ```
3. Restart monitor_watcher (or restart Hyprland)

#### Wrong Monitor Positions

**Symptoms**: Workspaces appear on wrong monitor

**Solutions**:
1. Check `externalPosition` setting matches physical layout
2. For `split` distribution, "left" monitor gets 1-5, "right" gets 6-10
3. Override temporarily:
   ```bash
   echo 'VAR_EXTERNAL_POSITION="left"' >> ~/.config/hypr/monitor-vars.conf
   ~/.config/hypr/scripts/generate_workspace_config
   ```

### Resetting to Defaults

To completely reset workspace configuration:

```bash
# Remove user overrides
rm ~/.config/hypr/monitor-vars.conf

# Remove generated config
rm ~/.config/hypr/workspaces.conf

# Regenerate fresh
~/.config/hypr/scripts/generate_workspace_config
```

### Debug Mode

For detailed debugging, run the script with bash tracing:

```bash
bash -x ~/.config/hypr/scripts/generate_workspace_config 2>&1 | less
```

This shows every command executed and variable value.
