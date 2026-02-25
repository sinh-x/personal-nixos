# Bug: Workspace Config Generation Fails on Boot Due to Race Condition

## Status
fixed

## Reported
2026-01-20

## Problem
The `generate_workspace_config` script fails to generate `workspaces.conf` correctly on boot because it runs before the Hyprland IPC socket is ready. This requires manually re-running the script after login to get proper workspace configuration.

## Steps to Reproduce
1. Reboot the system or log out and log back in
2. Hyprland starts and executes `generate_workspace_config` via `exec-once`
3. Workspace configuration is missing or incomplete
4. Manually running `~/.config/hypr/scripts/generate_workspace_config` fixes the issue

## Expected Behavior
- `workspaces.conf` should be generated correctly during Hyprland startup
- All workspaces should be properly assigned to monitors
- F-key bindings for workspaces 11-20 should be available (when external monitor connected)

## Actual Behavior
- `hyprctl monitors -j` fails because IPC socket isn't ready
- `MONITORS` variable is empty or incomplete
- Generated `workspaces.conf` is incomplete or uses fallback values
- Workspace assignments may be incorrect or missing

## Root Cause
Race condition in startup sequence:

1. **No socket readiness check** (`generate_workspace_config:8`):
   ```bash
   MONITORS=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null || ...)
   ```
   The script suppresses errors but doesn't wait for the socket to be available.

2. **Immediate execution at startup** (`hyprland.conf:738-739`):
   ```
   exec-once = ~/.config/hypr/scripts/generate_workspace_config eDP-1 right
   exec-once = ~/.config/hypr/scripts/monitor_watcher
   ```
   Both run immediately without waiting for Hyprland to fully initialize.

3. **Double execution** - `monitor_watcher:4` also calls `generate_workspace_config` immediately.

4. **No retry mechanism** - Script fails on first attempt and exits.

## Solution
Implemented the following fixes:

1. **Added socket readiness check** to `generate_workspace_config`:
   - `wait_for_hyprland()` function waits up to 10s (20 attempts × 0.5s) for socket
   - Validates both socket existence AND valid monitor data from `hyprctl`
   - Falls back to existing `workspaces.conf` if timeout occurs

2. **Removed duplicate execution** from `hyprland.conf`:
   - Removed direct `exec-once` call to `generate_workspace_config`
   - `monitor_watcher` handles initial generation on startup

3. **Added logging** to both scripts:
   - Logs to `~/.config/hypr/workspace-gen.log`
   - Tracks socket readiness, monitor detection, and config generation

4. **Updated `monitor_watcher`**:
   - Added socket wait before connecting to event socket
   - Added logging for debugging startup issues

## Files to Change
- `modules/home/wm/hyprland/hypr_config/scripts/generate_workspace_config`
- `modules/home/wm/hyprland/hypr_config/scripts/monitor_watcher`
- `modules/home/wm/hyprland/hypr_config/hyprland.conf`

---

## Tasks

### 1. Add socket readiness check to generate_workspace_config
- [x] **1.1** Add function to wait for Hyprland socket availability
  - Check for `$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock`
  - Implement retry loop with timeout (e.g., 20 attempts, 0.5s delay)
  - Log warnings if socket takes too long
- [x] **1.2** Add function to verify `hyprctl` returns valid monitor data
  - Check that `hyprctl monitors -j` returns non-empty JSON array
  - Validate at least one monitor is detected
- [x] **1.3** Combine socket wait + monitor validation before main logic

### 2. Remove duplicate execution
- [x] **2.1** Remove direct `generate_workspace_config` call from `hyprland.conf:738`
  - The `monitor_watcher` script already calls it on startup (line 4)
  - Having both causes race conditions and duplicate work
- [x] **2.2** Update `monitor_watcher` to handle initial generation with proper waiting

### 3. Add fallback behavior
- [x] **3.1** If socket timeout occurs, use existing `workspaces.conf` if present
- [x] **3.2** Create minimal fallback config if no existing file (single monitor mode)
- [x] **3.3** Add logging to `~/.config/hypr/workspace-gen.log` for debugging

### 4. Improve monitor_watcher startup
- [x] **4.1** Add initial delay or socket wait before first generation call
- [x] **4.2** Ensure socat connection also waits for socket availability

### 5. Testing & Verification
- [ ] **5.1** Test cold boot with external monitor connected
- [ ] **5.2** Test cold boot without external monitor
- [ ] **5.3** Test hotplug scenarios after boot
- [ ] **5.4** Test multiple rapid reboots to catch intermittent failures

---

## Implementation Notes

### Socket Wait Function Example
```bash
wait_for_hyprland() {
  local max_attempts=20
  local attempt=0
  local socket_path="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock"

  while [ $attempt -lt $max_attempts ]; do
    if [ -S "$socket_path" ] && hyprctl monitors -j &>/dev/null; then
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 0.5
  done

  echo "[$(date)] ERROR: Hyprland socket not ready after $max_attempts attempts" >> "$HOME/.config/hypr/workspace-gen.log"
  return 1
}
```

### Monitor Validation Example
```bash
validate_monitors() {
  local monitors
  monitors=$(hyprctl monitors -j 2>/dev/null)

  if [ -z "$monitors" ] || [ "$monitors" = "[]" ]; then
    return 1
  fi

  # Check we can parse at least one monitor name
  if ! echo "$monitors" | jq -e '.[0].name' &>/dev/null; then
    return 1
  fi

  return 0
}
```

---

## Priority
High - Affects every boot/login

## Estimated Complexity
Low-Medium - Primarily adding wait/retry logic to existing scripts
