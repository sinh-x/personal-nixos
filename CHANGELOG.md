# Changelog

## [Unreleased]

### Changed — 2026-11-28
- Refresh flake inputs for Home Manager, nixos-hardware, Hyprland, SOPS,
  Zen Browser, Avodah, antigravity-nix and pre-commit hooks, including six
  Hyprland-related transitive dependencies.
- Refresh the local PA Platform source snapshot. Jira MCP's snapshot timestamp
  changes without a content-hash change.
- Keep all nixpkgs pins, Umbriel and Noctalia unchanged; this refresh does not
  replace the desktop shell or change the default login session.

## [202603] - 2026-03

### 202603+3
- FireFly: fix SOPS secret key case (tailscale/Firefly)

### 202603+2
- FireFly: lock SSH to Tailscale only — remove public port 22 exposure

### 202603+1
- Add Tailscale exit node support; enable on Drgnfly (laptop)
