# Shared WiFi Configuration Requirements

## 1. Introduction

This document specifies the requirements for consolidating WiFi network configurations across all NixOS hosts (Emberroot, Elderwood, Drgnfly) into a single shared module.

**Architecture Overview**: Create a NixOS module that centralizes WiFi network definitions using SOPS-encrypted secrets, eliminating duplication while allowing per-host customization via additional networks.

## 2. Current State Analysis

| Host | Networks | Secrets Method | Config Location |
|------|----------|----------------|-----------------|
| Emberroot | 59+ | SOPS encrypted | `systems/.../Emberroot/wifi-networks.nix` |
| Drgnfly | 48 | File `/home/sinh/wireless.env` | `systems/.../Drgnfly/wifi-networks.nix` |
| Elderwood | 1 | File `/home/sinh/.config/wireless.env` | Inline in `default.nix` |

**Issues**:
- ~48 networks duplicated between Emberroot and Drgnfly
- Emberroot has 11+ networks not in Drgnfly (drift)
- Inconsistent secrets management (SOPS vs file-based)
- 2 networks have hardcoded passwords instead of external refs

**Target State**: All hosts use SOPS-encrypted secrets from `secrets/secrets.yaml`

## 3. User Stories

### System Administrator
- **As a sysadmin**, I want to add a new WiFi network once, so that all my machines can connect to it
- **As a sysadmin**, I want to update a WiFi password in one place, so that I don't have to update multiple files
- **As a sysadmin**, I want each host to use its preferred secrets mechanism, so that I maintain flexibility

### Developer
- **As a developer**, I want a clear module interface, so that I can easily understand and modify WiFi settings
- **As a developer**, I want per-host overrides, so that I can add host-specific networks when needed

## 4. Acceptance Criteria

### Module Structure Requirements
- **WHEN** a new NixOS module `modules.wifi` is created, **THEN** it **SHALL** be auto-discovered by Snowfall Lib
- **WHEN** the module is enabled, **THEN** it **SHALL** configure `networking.wireless` with all shared networks
- **WHEN** the module is enabled, **THEN** it **SHALL** automatically use SOPS-managed secrets file

### Network Configuration Requirements
- **WHEN** all networks are merged, **THEN** the system **SHALL** include all 59+ unique networks from current configs
- **WHEN** a network uses `pskRaw = "ext:keyname"`, **THEN** the key name **SHALL** be consistent across all hosts
- **IF** a network has no password (open network), **THEN** it **SHALL** be defined with empty braces `{}`

### Per-Host Customization Requirements
- **WHEN** a host needs additional networks, **THEN** it **SHALL** be able to merge extra networks via module options

### Security Requirements
- **WHEN** the module is enabled, **THEN** it **SHALL** use `config.sops.secrets."wifi/credentials".path` for secrets
- **WHEN** the module is enabled, **THEN** `modules.sops.enable` **SHALL** also be enabled (dependency)
- **WHEN** hardcoded passwords exist, **THEN** they **SHALL** be migrated to external secret references
- **WHEN** the module is used, **THEN** no plain-text passwords **SHALL** appear in the Nix store
- **WHEN** migrating from file-based secrets, **THEN** all credentials **SHALL** be added to `secrets/secrets.yaml`

## 5. Feature Specifications

### Core Features
1. **Shared Network List**: Single source of truth for all WiFi networks
2. **SOPS Integration**: All hosts use SOPS-encrypted secrets (no file-based secrets)
3. **Network Merging**: Ability to add host-specific networks via `extraNetworks`
4. **User Control**: Enable `userControlled` for wpa_cli access

### Module Options
1. **`modules.wifi.enable`**: Boolean to enable the module (requires `modules.sops.enable = true`)
2. **`modules.wifi.extraNetworks`**: Attribute set of additional per-host networks
3. **`modules.wifi.userControlled`**: Boolean for user-controlled WiFi (default: true)

Note: `secretsFile` is automatically set to `config.sops.secrets."wifi/credentials".path`

## 6. Success Criteria

### Functionality
- **WHEN** `sudo sys rebuild` runs on any host, **THEN** the system **SHALL** build successfully
- **WHEN** WiFi is configured, **THEN** all networks **SHALL** be available via `wpa_cli list_networks`

### Maintainability
- **WHEN** a new network is added, **THEN** only one file **SHALL** need modification
- **WHEN** reviewing WiFi config, **THEN** all networks **SHALL** be visible in one location

## 7. Migration Plan

1. Create shared module at `modules/nixos/wifi/default.nix`
2. Merge all unique networks from Emberroot and Drgnfly into the module
3. Migrate hardcoded passwords to `ext:keyname` format
4. Ensure all WiFi credentials exist in `secrets/secrets.yaml` (SOPS)
5. Ensure `modules.sops.enable = true` on all hosts (Elderwood already has it)
6. Update Emberroot to use new module (remove wifi-networks.nix import)
7. Update Drgnfly to use new module (remove wifi-networks.nix import, remove file-based secrets)
8. Update Elderwood to use new module (remove inline wifi config)
9. Delete old `wifi-networks.nix` files
10. Test all three hosts with `sudo sys test`

## 8. Out of Scope

- Automatic network discovery or scanning
- GUI for managing networks
- Support for non-SOPS secrets (all hosts will use SOPS)

---

**Document Status**: Approved

**Last Updated**: 2026-01-13

**Implementation**: Completed - see `tasks.md`
