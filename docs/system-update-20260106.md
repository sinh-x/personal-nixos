# System Update - 2026-01-06

## Summary
Fixed deprecation warnings and build issues in NixOS configuration after flake update.

## Changes Made

### 1. Wireless Configuration Fix
**Issue**: Obsolete option warning for `networking.wireless.userControlled.enable`

**Fixed in**:
- `systems/x86_64-linux/Drgnfly/wifi-networks.nix:6`
- `systems/x86_64-linux/Emberroot/wifi-networks.nix:6`
- `systems/x86_64-linux/Elderwood/default.nix:135`

**Change**:
```diff
- userControlled.enable = true;
+ userControlled = true;
```

### 2. System Variable Deprecation Fix
**Issue**: `system` has been renamed to `stdenv.hostPlatform.system`

**Fixed in**:
- `systems/x86_64-linux/Elderwood/default.nix:149-152`
- `systems/x86_64-linux/Emberroot/default.nix:195-198`
- `modules/nixos/antigravity/default.nix:18`

**Change**:
```diff
- inputs.zen-browser.packages."${system}".default
+ inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
```

### 3. XFCE Package Restructuring
**Issue**: `xfce.thunar` and `xfce.tumbler` moved to top-level packages

**Fixed in**:
- `modules/nixos/wm/bspwm/default.nix:56`
- `modules/nixos/wm/hyprland/default.nix:126-127`

**Change**:
```diff
- xfce.thunar
- xfce.tumbler
+ thunar
+ tumbler
```

### 4. Temporarily Disabled Packages (Build Failures)

#### anytype (Emberroot only)
**Location**: `modules/home/office/default.nix:26`

**Reason**: Build failure with gcc 15.2.0 - missing `#include <cstdint>` in upstream `protoc-gen-js-3.21.4`

**Error**:
```
external/com_google_absl/absl/container/internal/container_memory.h:66:27:
error: 'uintptr_t' does not name a type
```

**Status**: Temporarily commented out until upstream fix or nixpkgs update

#### R Setup (All systems)
**Location**: `systems/x86_64-linux/Emberroot/default.nix:20`

**Reason**: R package `V8-8.0.1` build failure

**Status**: Temporarily disabled (`r_setup.enable = false`)

### 5. Migrated WiFi Secrets to sops-nix (Emberroot)

**Issue**: After flake update, `wpa_supplicant` could not access wifi passwords stored in `/home/sinh/wireless.env` due to:
- Permissions/ownership issues (file owned by user `sinh`, not accessible during early boot)
- Service timing issues (`wpa_supplicant` starts before `/home` is mounted)

**Solution**: Migrated wifi passwords to sops-nix encrypted secrets

**Changes**:
- `systems/x86_64-linux/Emberroot/wifi-networks.nix:5` - Changed `secretsFile` to use sops secret path
  ```diff
  - secretsFile = "/home/sinh/wireless.env";
  + secretsFile = config.sops.secrets."wifi/credentials".path;
  ```

- `modules/nixos/system/security/sops/default.nix:32-35` - Added wifi credentials secret with proper permissions
  ```nix
  secrets."wifi/credentials" = {
    owner = "wpa_supplicant";
    mode = "0600";
  };
  ```

**Implementation**:
1. Wifi passwords stored in `secrets/secrets.yaml` under `wifi.credentials` key in `key=value` format
2. Sops-nix decrypts to `/run/secrets/wifi/credentials` at boot time
3. File owned by `wpa_supplicant` user with mode `0600`
4. Networks still use `pskRaw = "ext:keyname"` to reference passwords from the secrets file

**Benefits**:
- Passwords encrypted at rest using age
- Proper permissions and ownership for `wpa_supplicant` access
- Available during early boot (before `/home` is mounted)
- Centralized secret management with other system secrets

### 6. Added Flatpak Support (Emberroot)

**Location**: `systems/x86_64-linux/Emberroot/default.nix:224`

**Change**:
```nix
services.flatpak.enable = true;
```

**Reason**: Workaround for broken nixpkgs packages (anytype) - allows installation via Flatpak

## Testing Notes

### sys test behavior with network changes
When running `sudo sys test` with wireless configuration changes:
- NixOS immediately activates the new configuration
- This includes restarting `wpa_supplicant` service
- May cause temporary network interruption
- Changes are ephemeral (not added to boot entries)
- Rebooting returns to previous working configuration

**Recommendation**: For network-related changes, use `sudo sys rebuild` directly or be prepared for temporary connectivity loss with `sys test`.

### WiFi Secrets with sops-nix
To add/update wifi passwords:
1. Edit encrypted secrets: `sops secrets/secrets.yaml`
2. Update the `wifi.credentials` key with passwords in `key=value` format
3. Rebuild: `sudo sys rebuild`
4. Secrets are automatically decrypted and permissions set correctly at boot

## Verification
All deprecation warnings resolved. System builds successfully with temporary package exclusions. WiFi passwords now managed securely via sops-nix.

## Next Steps
- Monitor nixpkgs for anytype/protoc-gen-js fix (gcc 15.2.0 compatibility)
- Monitor for R V8 package fix
- Re-enable packages once upstream issues resolved
- Consider installing anytype via Flatpak: `flatpak install flathub io.anytype.Anytype`
