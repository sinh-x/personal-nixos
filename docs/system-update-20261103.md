# System Update - 2026-11-03

**Branch**: `develop`

**Host for application-version comparison**: Drgnfly

## Summary

Refreshed flake inputs while preserving declared URLs, refs, pins and follows relationships, including the existing operator-selected local PA Platform input. Replaced OnlyOffice with LibreOffice to resolve evaluation failures caused by GTK2 being marked broken in the updated nixpkgs.

The application versions below were verified with `nix store diff-closures`, comparing the previous saved Drgnfly system with the configuration used in Sinh's temporary activation test. They are actual closure-version differences, not versions inferred from flake input commit hashes.

**Attribution caveat**: this comparison includes all differences since that saved system, including any earlier repository changes. It does not prove that every listed application changed solely because of this lock refresh. Most remote lock updates were already uncommitted when this session began and were preserved; the session's full refresh additionally updated local-input metadata/snapshots.

## Application Version Changes

Notable application changes, excluding most libraries, build dependencies and generated shell-completion packages:

| Application | Previous saved system | Tested configuration |
|---|---|---|
| Zen Browser (Twilight) | 1.24t | 1.25t |
| Google Chrome | 155.0.8059.39 | 156.0.8078.79 |
| Chromium | 155.0.8059.39 | 156.0.8078.79 |
| Microsoft Edge | 154.0.4258.62 | 156.0.4314.50 |
| Vivaldi | 8.2.4133.83 | 8.2.4133.96 |
| Discord | 1.0.160 | 1.0.168 |
| Signal Desktop | 8.29.0 | 8.32.0 |
| Signal CLI | 0.14.8 | 0.14.9 |
| Telegram Desktop | 7.2.8 | 7.3.2 |
| Obsidian | 1.13.7 | 1.14.5 |
| Ghostty | 1.3.1 | 1.4.0 |
| Warp Terminal | 0.2026.09.16.08.27.stable_02 | 0.2026.10.14.08.27.stable_01 |
| Herdr | 0.9.3 | 0.9.5 |
| Neovim | 0.12.5 | 0.12.6 |
| Kdenlive | 26.08.1 | 26.08.2 |
| OpenCode | 1.18.35 | 2.2.1 |
| Pi Coding Agent | 1.0.4 | 1.4.0 |
| PA Platform | 0.1.154 | 0.1.154-pap273.2 |
| Tailscale | 1.102.5 | 1.104.4 |

PA Platform uses a local development snapshot; `0.1.154-pap273.2` is not presented as a general upstream release.

### Office Application Replacement

| Removed | Added |
|---|---|
| OnlyOffice Desktop Editors 9.1.0 | LibreOffice 26.8.0.3 (`libreoffice-stable`) |

The previous saved system contained OnlyOffice 9.1.0. The updated nixpkgs evaluated OnlyOffice 9.4.0, whose GTK2 dependency caused the build evaluation failure; it was replaced rather than enabling broken packages.

The approved package substitutions are in:

- `modules/home/office/default.nix`
- `home/vy/default.nix`
- `home/doangia/default.nix`

Document rendering and workflow compatibility with LibreOffice still require human verification.

## System and Multimedia Components

| Component | Previous saved system | Tested configuration |
|---|---|---|
| systemd | 261.3 | 262 |
| Linux firmware | 20260916 | 20261019 |
| FFmpeg full | 9.0.1 | 9.0.2 |
| FFmpeg / FFmpeg headless | 8.1.2 | 8.1.3 and 9.0.2 in the closure |

The nixpkgs root input advanced from `e7439b6b14ad3cc35d05608ebca9bce01a25f5f8` to `0bb2eedc20e4739f29e8045034f2828ad7054f8f`. Other changed input revisions include Antigravity, Herdr, Zen Browser, Home Manager, NixOS hardware definitions, Disko, Impermanence, SOPS, pre-commit hooks and Hyprland components. An input revision change alone is not proof of an installed application-version change; for example, Drgnfly does not enable Hyprland.

## Verification and Outstanding Issues

| Check | Result |
|---|---|
| Formatting of the three changed Nix source files | Passed |
| `nix flake check --no-write-lock-file` | Passed for the native system |
| Separate Drgnfly, Elderwood, FireFly and Lily toplevel evaluations | Passed |
| Agent-run non-privileged Drgnfly build | Incomplete after a 15-minute command timeout |
| Drgnfly build in Sinh's subsequent `sudo sys test .` | Succeeded |
| Temporary activation in that operator-run test | Failed, exit status 4 |

Activation reported two separate problems:

1. `timestamp-timelapse-prepare.service` failed when Tailscale certificate preparation returned `500 Internal Server Error: no netmap available`. Read-only diagnosis found that the unit orders itself after `tailscaled.service`, but daemon startup does not guarantee tailnet readiness. The journal showed earlier instances of the same failure. Tailscale was running and online at the later diagnostic check, but preparation remained failed and the timelapse service was inactive.
2. `systemd-machined.socket` could not start because `systemd-machined.service` was already active. The journal explicitly reported the socket/service startup conflict; at diagnosis the service was active and the socket inactive.

No repair for either activation issue is included in these changes. Existing stdenv deprecation warnings remain. A successful build or evaluation does not imply a successful activation, reboot test or human acceptance test. Elderwood, FireFly and Lily were evaluated only, not physically tested.

At the time of this report, the update remained uncommitted and unpushed. The failed activation blocks an "all good" recommendation; resolve the service failures and obtain a passing operator test before treating the upgrade as complete. Follow the [full upgrade workflow](workflows/nixos-upgrade.md) and [privileged-command boundary](agents/safety.md).

## Comparison Provenance

The exact read-only comparison used for the tables was:

```console
nix store diff-closures \
  /nix/store/nnby57q9p1dlzalsncclwcynrc6yvpzz-nixos-system-Drgnfly-26.11.20261008.e7439b6 \
  /nix/store/n6hwl8fyzp43acyw0cpx30zbdl64r3i2-nixos-system-Drgnfly-26.11.20261101.0bb2eed
```

At capture, those paths were resolved from `/nix/var/nix/profiles/system` and `/run/current-system`, respectively. Those references may point elsewhere after later rebuilds, and the exact store paths may eventually be garbage-collected. This records the comparison, not a claim that the temporary activation passed.
