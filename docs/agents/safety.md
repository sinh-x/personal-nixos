# Agent Safety

Ownership: agent safety and privileged-command boundaries.

This document is the sole owner of repository safety rules. Architecture belongs in `architecture.md`; development and validation conventions belong in `development.md`; dependency-upgrade orchestration belongs in the upgrade workflow.

## Privileged boundary

Agents must execute zero privileged commands. Never run `sudo`, activate a system configuration, or perform another operation that requires elevated privileges.

When privileged validation or activation is required, explain its purpose and present the exact command for Sinh to run manually. Typical operator-only commands are:

- `sudo sys test` — build and activate the configuration temporarily.
- `sudo sys rebuild` — build and switch to the configuration persistently.

Do not claim that an operator-only check passed until Sinh provides its result.

## Repository and scope safety

- Work only in the runtime-authenticated repository or worktree, on the approved branch, and within the assigned path and action scope.
- Treat the canonical repository path as identity unless runtime evidence also authenticates it as the execution path. Do not substitute another checkout.
- Preserve unrelated staged, unstaged, and untracked changes. Do not stash, reset, clean, restore, overwrite, or otherwise dispose of operator-owned state.
- Do not create, select, merge, rebase, delete, push, or return branches or checkouts unless the active task explicitly authorizes that exact action.
- Use only the lifecycle, retirement, and deletion mechanism approved by the active task. Never bypass its audit trail with an equivalent destructive command.

If identity, branch, ownership, or scope evidence conflicts, stop before mutation and report the observed evidence and the correction needed to resume.

## Protected data

Repository-protected data uses sops-nix and age; `.sops.yaml` defines repository policy and encrypted values live under `secrets/`.

- Never print, copy into documentation, commit, or otherwise expose decrypted protected data or host-local state.
- Do not decrypt or modify protected data unless the assigned scope explicitly requires it.
- Preserve encryption when an authorized protected-data change is made, and allow the repository's SOPS check to verify the result.
- Redact sensitive runtime and lease values from reports when they are not required as evidence.
