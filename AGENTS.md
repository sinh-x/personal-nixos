# Agent Instructions

This file is the cross-agent entry point for this repository. Keep it concise: the linked topic owners contain the detailed guidance.

## Non-negotiable summary

- Never execute privileged commands. Present required privileged operations for Sinh to run manually.
- Work only in the runtime-authenticated repository or worktree, on the approved branch, and within the assigned scope.
- Preserve unrelated changes, secrets, and operator-owned state; use only approved lifecycle and retirement tooling.
- Run only the checks authorized for the current phase, and report failures without bypassing safety gates.
- Keep changes atomic, traceable, and consistent with the repository's established module and formatting conventions.

## Guidance index

- Repository safety and privileged-command boundaries: [Safety](docs/agents/safety.md)
- Repository structure and configuration flow: [Architecture](docs/agents/architecture.md)
- Development commands and change conventions: [Development](docs/agents/development.md)
- NixOS dependency-upgrade orchestration: [NixOS upgrade workflow](docs/workflows/nixos-upgrade.md)

## Ownership

Each linked document owns its topic's detailed rules. This root file summarizes non-negotiable behavior and routes agents to the single topic owner; it does not duplicate those documents.
