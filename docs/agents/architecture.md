# Repository Architecture

Ownership: repository architecture and configuration flow.

This document is the sole owner of repository structure, flake-output construction, module namespaces, and configuration flow.

## Flake orchestration

The repository owns its flake orchestration rather than using a framework generator:

1. `flake.nix` passes `inputs` and the repository source to `lib/flake-support/default.nix`.
2. `lib/flake-support/default.nix` recursively discovers `default.nix` files in the repository's systems, modules, packages, overlays, checks, and shells.
3. The orchestration layer exposes `nixosConfigurations`, `nixosModules`, `homeModules`, `overlays`, `packages`, `checks`, `devShells`, `lib`, and `pkgs`.
4. Package files also produce `package/<name>` overlays, exposing packages as both `pkgs.<name>` and `pkgs.sinh-x.<name>`.

Because discovery is path-based, a component's directory and `default.nix` location determine its generated output name.

## Configuration flow

- `systems/x86_64-linux/<hostname>/default.nix` is the host-level NixOS entry point. It imports hardware and shared configuration and enables system options.
- `home/sinh/<hostname>.nix` is the per-host Home Manager entry point and composes shared configuration from `home/sinh/global/`.
- `modules/nixos/` contains reusable NixOS modules under the `modules.*` option namespace.
- `modules/home/` contains reusable Home Manager modules under the injected `sinh-x.*` namespace.
- `overlays/` adapts repository packages and external flake inputs into package sets.
- `packages/`, `checks/`, and `shells/` provide custom derivations, flake checks, and development shells respectively.

The four deployed host configurations are Drgnfly, Elderwood, FireFly, and Lily.

## Repository libraries

`lib/flake-support/default.nix` extends nixpkgs and Home Manager libraries with helpers from `lib/` and makes them available to modules through `specialArgs`.

`lib/module/default.nix` supplies:

- `mkOpt` and `mkOpt'` for options with or without descriptions;
- `mkBoolOpt` and `mkBoolOpt'` for Boolean options;
- `enabled` and `disabled` option-set shortcuts;
- `capitalize`, `boolToNum`, `default-attrs`, and `nested-default-attrs` utilities.

`lib/theme/default.nix` supplies `compileSCSS` for theme stylesheet compilation.

## Important configuration surfaces

- Window-manager system configuration lives under `modules/nixos/wm/`; matching user configuration lives under `modules/home/wm/`. A host should enable corresponding system and home options.
- BSPWM's declarative files live below `modules/home/wm/bspwm/bspwm_config/` and are copied recursively into the user's configuration.
- Fish configuration, plugins, abbreviations, and shell environment are defined in `modules/home/cli-apps/fish/default.nix`.
- sops-nix policy is defined by `.sops.yaml`, with encrypted repository data under `secrets/`. Handling rules are owned by `safety.md`.
