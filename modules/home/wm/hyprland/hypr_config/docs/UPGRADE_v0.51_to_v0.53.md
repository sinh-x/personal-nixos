# Hyprland Configuration Upgrade Guide: v0.51 to v0.53

**Migration Date:** 2026-01-06
**Previous Version:** 0.51.1
**New Version:** 0.53.0

## Overview

Hyprland v0.53 introduced significant breaking changes to the configuration syntax, particularly around windowrules and deprecated options. This document details all changes applied to migrate the configuration.

---

## 1. Removed Deprecated Options

### 1.1 `general:no_border_on_floating`

**Location:** `general { }` section
**Action:** Removed entirely

```diff
general {
    border_size = $hypr_border_size
-   no_border_on_floating = false
    gaps_in = $hypr_gaps_in
```

**Reason:** Option removed in v0.51+. Use windowrules with `border` for floating windows if needed.

---

### 1.2 `misc:new_window_takes_over_fullscreen` / `misc:new_window_takes_over_fs`

**Location:** `misc { }` section
**Action:** Removed entirely

```diff
misc {
    close_special_on_empty = true
-   new_window_takes_over_fullscreen = 0
    exit_window_retains_fullscreen = false
```

**Note:** This option was renamed to `new_window_takes_over_fs` in v0.52, then removed entirely in v0.53.

---

### 1.3 `misc:disable_hyprland_qtutils_check`

**Location:** `misc { }` section
**Action:** Removed entirely

```diff
misc {
    disable_xdg_env_checks = false
-   disable_hyprland_qtutils_check = false
    lockdead_screen_delay = 1000
```

**Reason:** Option removed in v0.53.

---

### 1.4 `master:inherit_fullscreen`

**Location:** `master { }` section
**Action:** Removed entirely

```diff
master {
    orientation = left
-   inherit_fullscreen = true
    slave_count_for_center_master = 2
```

**Reason:** Option removed in v0.53. Functionality merged into other fullscreen settings.

---

## 2. Windowrule Syntax Changes

### 2.1 Match Syntax Update

**Change:** `class:` and `title:` replaced with `match:class` and `match:title`

```diff
# Old syntax (v0.51 and earlier)
- windowrule = float, class:kitty
- windowrule = float, title:File Operation Progress

# New syntax (v0.53+)
+ windowrule = float on, match:class kitty
+ windowrule = float on, match:title File Operation Progress
```

**Key differences:**
- `class:` becomes `match:class ` (note the space after `class`)
- `title:` becomes `match:title `
- No colon after the match type

---

### 2.2 Boolean Windowrules Require Values

**Change:** Boolean rules like `float`, `pin`, `center` now require explicit values

```diff
# Old syntax
- windowrule = float, match:class kitty
- windowrule = pin, match:class dropdown
- windowrule = center, match:class calculator

# New syntax
+ windowrule = float on, match:class kitty
+ windowrule = pin on, match:class dropdown
+ windowrule = center on, match:class calculator
```

**Valid values:** `on`, `off`, `true`, `false`, `yes`, `no`, `1`, `0`

---

## 3. Summary of All Changed Windowrules

### Float rules updated:
| Original | Updated |
|----------|---------|
| `windowrule = float, class:App` | `windowrule = float on, match:class App` |

### Pin rules updated:
| Original | Updated |
|----------|---------|
| `windowrule = pin, class:App` | `windowrule = pin on, match:class App` |

### Center rules updated:
| Original | Updated |
|----------|---------|
| `windowrule = center, class:App` | `windowrule = center on, match:class App` |

---

## 4. Files Modified

| File | Changes |
|------|---------|
| `hyprland.conf` | All changes listed above |

## 5. Backup Files Created

| File | Description |
|------|-------------|
| `hyprland.conf.old` | Pre-migration config (v0.51 syntax) |
| `hyprland.conf.v051` | Backup with v0.51 compatible syntax |
| `hyprland.conf.v053` | Intermediate v0.53 config (before boolean fix) |

---

## 6. Testing the Configuration

After making changes, test with:

```bash
# Reload configuration
hyprctl reload

# Check for errors
journalctl --user -u hyprland -n 50

# Verify running version
hyprctl version
```

---

## 7. Reverting Changes

To revert to v0.51 compatible config:

```bash
cp ~/.config/hypr/hyprland.conf.old ~/.config/hypr/hyprland.conf
hyprctl reload
```

**Note:** This only works if running Hyprland v0.51.x. Version 0.53+ requires the new syntax.

---

## 8. References

- [Hyprland Wiki - Window Rules](https://wiki.hypr.land/Configuring/Window-Rules/)
- [Hyprland 0.53 Release Notes](https://hypr.land/news/update53/)
- [Hyprland GitHub Releases](https://github.com/hyprwm/Hyprland/releases)
- [Migration Discussion - GitHub](https://github.com/hyprwm/Hyprland/discussions/12607)

---

## 9. Version Compatibility Matrix

| Config Syntax | v0.48 | v0.51 | v0.52 | v0.53+ |
|---------------|-------|-------|-------|--------|
| `class:App` | Yes | Yes | Yes | No |
| `match:class App` | No | No | No | Yes |
| `float,` (no value) | Yes | Yes | Yes | No |
| `float on,` | No | No | No | Yes |
| `no_border_on_floating` | Yes | No | No | No |
| `new_window_takes_over_fullscreen` | Yes | Yes | No | No |
| `new_window_takes_over_fs` | No | No | Yes | No |
| `disable_hyprland_qtutils_check` | Yes | Yes | Yes | No |
| `inherit_fullscreen` | Yes | Yes | Yes | No |
