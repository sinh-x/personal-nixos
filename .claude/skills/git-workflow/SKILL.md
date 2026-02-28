---
name: git-workflow
description: "Local branch strategy override for personal-nixos. Uses monthly integration branches (integrate/YYYYMM) instead of merging directly to main. This skill extends /git-ship with project-specific rules. Applied automatically when /git-ship detects this repo."
---

# Git Workflow — personal-nixos Branch Strategy

This skill overrides the default `/git-ship` behavior for this repository, implementing a **monthly integration branch** strategy.

## Strategy Overview

```
main (production)
  │
  └── integrate/202602 (February integration)
        │
        ├── feat/202602-zsh-switch
        ├── fix/202602-polybar-crash
        └── chore/202602-cleanup
```

- **Feature branches** merge into **monthly integration branches** (e.g., `integrate/202602`)
- **Monthly integration branches** merge into `main` when stable
- This allows batching related changes and testing them together before production

## Current Integration Branch

Determine the current integration branch:
```bash
INTEGRATION_BRANCH=$(date +"integrate/%Y%m")  # e.g., integrate/202602
```

Check if it exists:
```bash
git show-ref --verify --quiet "refs/heads/$INTEGRATION_BRANCH" || \
git show-ref --verify --quiet "refs/remotes/origin/$INTEGRATION_BRANCH"
```

If it doesn't exist, create from `main`:
```bash
git checkout -b "$INTEGRATION_BRANCH" main
git push -u origin "$INTEGRATION_BRANCH"
```

## Branch Naming

### Format

```
<type>/<YYYYMM>-<short-desc>
```

### Examples

| Type | Branch Name |
|------|-------------|
| Feature | `feat/202602-zsh-keybindings` |
| Bug fix | `fix/202602-polybar-crash` |
| Chore | `chore/202602-cleanup-modules` |
| Docs | `docs/202602-update-readme` |
| Refactor | `refactor/202602-simplify-config` |

### Rules

- Always prefix with the current month (`YYYYMM`)
- Branch from the current integration branch, NOT `main`
- Lowercase, hyphens for word separation
- Keep description to 2-4 words

## Creating a Feature Branch

```bash
# Get current integration branch
INTEGRATION=$(date +"integrate/%Y%m")

# Create feature branch from integration
git checkout -b feat/$INTEGRATION-<description> $INTEGRATION
```

Example:
```bash
git checkout -b feat/202602-zsh-keybindings integrate/202602
```

## Creating a PR

PRs target the **integration branch**, not `main`:

```bash
gh pr create --base "integrate/202602" --title "feat(zsh): add keybindings" --body "$(cat <<'EOF'
## Summary
- Added directory stack navigation keybindings
- Matches fish shell behavior

## Test plan
- [x] `sudo sys test` passes
- [x] Keybindings work in new shell

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

## Merging Integration to Main

When a month's work is stable and tested:

```bash
gh pr create --base "main" --head "integrate/202602" \
  --title "release: February 2026 integration" \
  --body "$(cat <<'EOF'
## Summary
Monthly integration of February 2026 changes.

## Changes included
- feat(zsh): directory stack navigation
- fix(polybar): crash on reload
- chore: cleanup unused modules

## Test plan
- [x] All features tested individually
- [x] Full system rebuild successful

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

## Workflow Summary

```
1. INTEGRATION   Ensure integrate/YYYYMM exists (create from main if not)
2. BRANCH        git checkout -b <type>/YYYYMM-<desc> integrate/YYYYMM
3. DEVELOP       Make changes
4. TEST          sudo sys test
5. COMMIT        Conventional commit format
6. PUSH          git push -u origin <branch>
7. PR            gh pr create --base "integrate/YYYYMM" ...
8. MERGE         Squash merge to integration
9. RELEASE       When stable, PR integration → main
```

## Existing Branches

| Branch | Purpose |
|--------|---------|
| `main` | Production, stable config |
| `develop` | Development branch |
| `integrate/YYYYMM` | Monthly integration (created as needed) |

## Critical Rules

- **NEVER commit or make changes directly on the integration branch** (`integrate/YYYYMM`) or `main`
- **Always create a feature branch first** before making any code changes
- If changes were accidentally made on the integration branch, stash them, create a feature branch, then pop the stash
- The agent must check the current branch before starting work and create a feature branch if on integration or main

## Compatibility with /git-ship

This skill works with `/git-ship`:
- `/git-ship` handles commits, conventional format, co-author
- This skill overrides **base branch** and **PR target** decisions
- When in this repo, always use integration branch as base/target
- `/git-ship` and `/dev-workflow` must respect this branch strategy — feature branch first, then PR to integration
