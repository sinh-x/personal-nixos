# Development Guidance

Ownership: development, formatting, validation, and change conventions.

This document is the sole owner of day-to-day development commands, formatting and validation practice, and repository change conventions. Safety boundaries are defined in `safety.md`; repository structure and output generation are defined in `architecture.md`.

## Change conventions

- Read the relevant implementation and nearby examples before editing.
- Keep changes minimal, atomic, and limited to the assigned scope. Preserve established Nix style and directory conventions.
- Do not modify `flake.lock` or refresh dependencies unless the active task explicitly assigns upgrade work.
- Keep generated files, build outputs, protected data, and host-local state out of commits.
- Stage only intended paths, inspect the staged diff, and use a focused conventional commit message when a commit is authorized.

## Development commands

Use only commands authorized by the active task or validation plan:

- `nix develop` — enter the repository development shell with its Nix tooling and hooks.
- `nixfmt <file>` — apply RFC-style Nix formatting to an assigned file.
- `deadnix --edit <file>` — remove unused Nix code from an assigned file; inspect the resulting edit.
- `statix check` — run Nix static analysis when authorized.
- `nix flake check` — run repository flake checks when authorized.
- `nix build .#<package-name>` — build a package output.
- `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel` — build a host configuration without activation.
- `nix flake show` — inspect flake outputs.

Do not broaden a phase-focused check into a full validation run. A failed required check blocks the commit: report the command and failure rather than bypassing or silently substituting it. Privileged testing is outside agent execution and is owned by `safety.md`.

## Formatting and hooks

The pre-commit check is defined in `checks/pre-commit-hooks/default.nix`. Its active checks cover dead-code cleanup, RFC-style Nix formatting, Statix analysis, Lua linting, and SOPS encryption. The development shell enables the configured hooks.

Format only files in scope. Tools with edit modes, including deadnix, are mutations and require the same path authorization as manual edits.

## Adding repository components

### NixOS or Home Manager module

1. Add `modules/nixos/<category>/<name>/default.nix` or `modules/home/<category>/<name>/default.nix`.
2. Follow the namespace and option patterns described in `architecture.md`.
3. Enable the module in the appropriate system or home configuration.
4. Run only the checks named by the active task.

### Package

1. Add `packages/<name>/default.nix`.
2. Rely on the repository's discovery and package-overlay behavior described in `architecture.md`; do not hand-maintain a separate package registry.
3. Reference the result through `pkgs.<name>` or `pkgs.sinh-x.<name>` as appropriate.
4. Build or validate only the outputs required by the active task.

For non-Nix assets copied by a module, preserve the source tree's existing format and declarative copy pattern rather than editing deployed files directly.
