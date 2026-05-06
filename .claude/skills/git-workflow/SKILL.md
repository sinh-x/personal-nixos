---
name: git-workflow
description: "Local branch strategy override for personal-nixos. Uses develop as the normal feature base and pull-request target. This skill extends /git-ship with project-specific rules. Applied automatically when /git-ship detects this repo."
---

# Git Workflow — personal-nixos Branch Strategy

This skill overrides default `/git-ship` behavior for this repository and uses a **develop-centered workflow**.

## Strategy Overview

```
main (production)
  │
  └── develop (integration branch)
        │
        ├── feat/<short-desc>
        ├── fix/<short-desc>
        └── chore/<short-desc>
```

- Create feature branches from `develop`
- Open PRs targeting `develop`
- Promote `develop` to `main` in separate release PRs

## Branch Naming

### Format

```
<type>/<short-desc>
```

### Examples

| Type | Branch Name |
|------|-------------|
| Feature | `feat/zsh-keybindings` |
| Bug fix | `fix/polybar-crash` |
| Chore | `chore/cleanup-modules` |
| Docs | `docs/update-readme` |
| Refactor | `refactor/simplify-config` |

### Rules

- Branch from `develop`, never from `main`
- Lowercase, hyphens for word separation
- Keep description to 2-4 words

## Creating a Feature Branch

```bash
git fetch origin
git checkout develop
git pull --ff-only origin develop
git checkout -b feat/<description>
```

## Creating a PR

PRs target `develop`:

```bash
gh pr create --base develop --title "feat(zsh): add keybindings"
```

## Workflow Summary

```
1. SYNC          git checkout develop && git pull --ff-only origin develop
2. BRANCH        git checkout -b <type>/<desc>
3. DEVELOP       Make changes
4. TEST          Run relevant non-sudo checks
5. COMMIT        Conventional commit format
6. PUSH          git push -u origin <branch>
7. PR            gh pr create --base develop ...
8. MERGE         Squash merge to develop
9. RELEASE       Separate PR from develop to main
```

## Existing Branches

| Branch | Purpose |
|--------|---------|
| `main` | Production, stable config |
| `develop` | Default base and PR target for feature work |

## Critical Rules

- **NEVER commit directly to `main` or `develop`**
- **Always create a feature branch first** before making changes
- If changes were accidentally made on `develop`, stash them, create a feature branch from `develop`, then pop the stash
- Verify current branch before starting work and switch to a feature branch if on `main` or `develop`

## Compatibility with /git-ship

This skill works with `/git-ship`:
- `/git-ship` handles commit formatting and automation
- This skill overrides base-branch and PR-target decisions
- In this repo, treat `develop` as the default base and PR target
