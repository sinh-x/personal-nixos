# Targeted application updates

A human/agent runbook for updating selected everyday applications through this Nix configuration, without accidentally refreshing the entire system's dependencies.

This document describes a procedure; it does not authorize an update, change dependencies, or introduce independent package pins. Follow [repository safety](../agents/safety.md) and [development guidance](../agents/development.md). Use the [full-lock upgrade workflow](nixos-upgrade.md) for a full refresh instead. PPA execution still requires its current runtime admission and approved scope; this runbook is not checkout or branch authority.

## 1. Choose the apps, not just the installed packages

The initial inventory comes from [Drgnfly's home configuration](../../home/sinh/Drgnfly.nix), its enabled modules, MIME defaults, and declarative shortcuts. These identify **daily-use candidates, not measured usage frequency**. Zen is the default browser, Neovim is `$EDITOR`, and Ghostty and Herdr have explicit shortcuts/integration. Confirm the actual priority list with Sinh before updating anything.

Do not read shell/browser histories, messages, application databases, decrypted secrets, or other private host state to infer frequency. Ask Sinh to name or rank the applications instead. Re-check enablement on the requested host; the other hosts differ from Drgnfly.

### App-to-source map

Re-read the linked files before every update; source ownership can change. Names in the input column are root names in `flake.nix`, not executable names.

| Drgnfly candidate | Current update authority | Route / source evidence |
| --- | --- | --- |
| Zen Twilight | `zen-browser` input | A; [Zen module](../../modules/home/apps/web/zen-browser/default.nix) imports the Twilight Home Manager module and disables self-updates. Updating this input may affect other Zen variants on Elderwood too. |
| Neovim (`nvim`) | `sinh-x-nixvim` input, exporting `nvim` as `pkgs.nixvim` | A; [Neovim module](../../modules/home/cli-apps/neovim/default.nix), [overlay](../../overlays/sinh-x/default.nix). The overlay also applies a package fix; review it. Language servers/tools installed alongside Neovim mostly come from root `nixpkgs` and do not automatically update with this input. |
| OpenCode | `opencode` input, Sinh's `sinh-x-dev` branch | A; [module](../../modules/home/coding/opencode/default.nix), [overlay](../../overlays/sinh-x/default.nix). Do not substitute the nixpkgs package or upstream's default branch. |
| Herdr | `herdr` input | A; [module](../../modules/home/cli-apps/herdr/default.nix), [overlay](../../overlays/sinh-x/default.nix). Also generates a Pi integration extension and supplies Fish completions. |
| PA / bundled Pi | Local `pa-platform` input plus `mkPaPlatform` options | D; [overlay](../../overlays/sinh-x/default.nix), [input declaration](../../flake.nix). A refresh can change multiple bundled tools/extensions, not just Pi. |
| Standalone `pi-coding-agent` | Root `nixpkgs` | C; [home package list](../../home/sinh/Drgnfly.nix). It is also installed alongside PA; updating it is not the same as updating PA's bundled Pi. |
| Droid | Repository derivation with version and npm artifact hash | B; [package](../../packages/droid/default.nix). The wrapper disables the upstream auto-updater. |
| Orca IDE | Repository derivation with source revision and dependency hashes | B; [package](../../packages/orca-ide/default.nix), [Orca update notes](../orca-drgnfly.md#updating). Review pnpm, Electron and native-runtime compatibility too. |
| Chrome, Edge, Vivaldi | Root `nixpkgs`: `google-chrome`, `microsoft-edge`, `vivaldi` | C; [browser module](../../modules/home/apps/web/browser/default.nix), [Vivaldi module](../../modules/home/apps/web/vivaldi/default.nix). |
| Ghostty, Kitty, Warp, Fish | Root `nixpkgs`: `ghostty`, `kitty`, `warp-terminal`, `fish` | C; [Ghostty](../../modules/home/cli-apps/ghostty/default.nix), [Kitty](../../modules/home/cli-apps/kitty/default.nix), [Warp](../../modules/home/cli-apps/warp/default.nix), [Fish](../../modules/home/cli-apps/fish/default.nix) modules. Fish plugin revisions/hashes are separate source pins in its module. |
| Obsidian, Logseq | Root `nixpkgs`: `obsidian`, `logseq` | C; [home package list](../../home/sinh/Drgnfly.nix). |
| Discord, Telegram, Signal, Element, Zoom | Root `nixpkgs`: `discord`, `telegram-desktop`, `signal-desktop` / `signal-cli`, `element-desktop`, `zoom-us` | C; [social module](../../modules/home/social-app/default.nix). |
| Viber | Root `nixpkgs` plus repository installation fix | C; [social module](../../modules/home/social-app/default.nix), [Viber overlay](../../overlays/viber/default.nix). Preserve the library/launcher fix. |
| Bitwarden desktop | Root `nixpkgs`: `bitwarden-desktop` | C; [module](../../modules/home/security/bitwarden/default.nix). |
| Avodah (`avo`), ZCA listener | `sinh-x-avodah`, `sinh-x-zca-js` inputs respectively | A; [personal apps module](../../modules/home/apps/sinh-x/default.nix), [social module](../../modules/home/social-app/default.nix), [overlay](../../overlays/sinh-x/default.nix). ZCA is a user service; activation can restart it. |
| Jira / personal Google MCP tools | Local `andafin-jira-mcp` / `personal-google-mcp` inputs | D; [input declarations](../../flake.nix), [overlay](../../overlays/sinh-x/default.nix). |

VS Code, Claude Code, Codex, Slack, and ZeroClaw are disabled in the current Drgnfly home configuration; do not treat their presence elsewhere in the repository as proof of use. A request for one needs a fresh installation/source trace.

## 2. Preflight and agree on one update unit

All command examples assume the **runtime-authenticated repository root**, not an arbitrary checkout. Do not create or select a branch merely to follow this document.

1. Confirm repository/worktree identity, approved branch, full HEAD, current scope, and any applicable runtime admission. Capture:

   ```console
   pwd
   git rev-parse --show-toplevel
   git branch --show-current
   git rev-parse HEAD
   git status --short --untracked-files=all
   git diff --stat
   git diff --cached --stat
   sha256sum flake.nix flake.lock
   ```

2. Record existing staged/unstaged changes and hashes of every file in scope. A dirty file is not permission to overwrite it. If the update would overlap operator changes, stop for an explicit ownership/allowlist decision; never stash, reset, clean, or restore them.
3. Trace the selected app from host enablement → module/package → overlay → input or fixed-output source. Inspect `flake.nix` and `flake.lock` directly before evaluation. Identify missing or changed local inputs, `follows` relationships, fixed refs, and affected hosts.
4. Agree on the target app, host, upstream channel/revision or release, route below, allowed changed files, anticipated transitive changes, validation commands, and rollback plan. Source/declaration changes require explicit approval, not just permission to refresh a lock.
5. Capture approved no-write baseline evaluations/builds and warning inventory before mutation. A failing baseline is evidence to report, not permission to repair unrelated problems. Get the plan approved before updates or expensive checks.

Prefer one app/source per change. Multiple apps sharing an input are one update unit; disclose the shared blast radius rather than promise application-only isolation.

## 3. Apply the matching route

### A — An existing dedicated flake input

Use Nix directly, as an ordinary user. **Do not use `sys update <input>`:** the current [implementation](../../packages/sys/default.nix) ignores its argument and runs a full `nix flake update`, despite its help text. `sudo` is neither needed nor allowed for an agent's lock refresh.

After approval, run **one** matching example, not this entire list:

```console
nix flake update zen-browser
nix flake update opencode
nix flake update herdr
nix flake update sinh-x-nixvim
```

Modern Nix accepts root input names as positional arguments. `nix flake update` **without names updates everything**. If the installed Nix does not support this syntax, stop and agree on the equivalent supported command; do not fall back to a full refresh.

Then inspect:

```console
git diff -- flake.lock
git diff -- flake.nix
git status --short --untracked-files=all
sha256sum flake.nix flake.lock
```

Compare against the captured working-tree baseline, not just `HEAD` if pre-existing edits exist. Record old/new revisions and hashes for the selected input and its transitive changes. Require unrelated root input identities and `flake.nix` bytes to remain unchanged. Shared lock nodes can be renamed/deduplicated; compare resolved input identities rather than assuming a textual node rename is a new dependency. Unexpected unrelated updates block continuation.

An input may carry its own nixpkgs (currently Zen and OpenCode do); expect its dependency closure to change. A `follows = "nixpkgs"` input uses the existing root nixpkgs instead. Neither relationship justifies updating root `nixpkgs` as an unapproved repair.

A tag/fixed revision such as `fcitx5-lotus`'s `snapshot-20260330` will not move to a newer release merely by refreshing its lock. Changing the declaration is a separately approved source change. No lock change may simply mean the tracked ref has no newer revision; report that rather than changing channels silently.

### B — A repository-owned derivation or plugin pin

For Droid, update only the approved version and matching artifact hash in `packages/droid/default.nix`. For Orca, follow its [package-specific update notes](../orca-drgnfly.md#updating): source revision/hash, pnpm dependency hash, executable pin and Electron assumptions may all need coordinated review. Fish plugins use their own revision/hash pairs in the module, not `flake.lock`.

1. Verify the requested upstream release and exact source/artifact location. Do not execute an upstream installer or self-updater.
2. Propose the precise file/attribute changes and compatibility risks, then obtain approval before editing.
3. Calculate hashes for the exact fetcher: `fetchurl` hashes file bytes; `fetchFromGitHub` hashes the unpacked source tree. They are not interchangeable. Dependency fetchers such as `fetchPnpmDeps` have additional hashes.
4. If an approved hash-discovery build uses a temporary placeholder, keep it confined to the approved derivation. A mismatch is expected diagnostic evidence only; replace it with the independently verified hash and require a successful final build. Never disable hash verification, sandboxing or tests, or commit a placeholder.
5. Format only the changed Nix files and review the diff. Leave `flake.lock` unchanged unless a separate input update is explicitly included in the plan.

### C — A package from the shared root nixpkgs

There is currently **no independent app-update input** for these packages. For example, `nix flake update discord` is invalid: `discord` is a package attribute, not a root input. `nix flake update nixpkgs` moves the shared package set used by the whole OS and other apps; it is not a Discord-only update. Building just Discord does not make that lock change isolated.

Ask Sinh to choose before mutation:

- Defer to the next separately approved system/package-set upgrade. Use the full-lock workflow only if a full refresh is actually approved; a root-nixpkgs-only update still needs an explicit system-wide validation plan.
- Propose an isolated package source/override for the named app. This is a configuration design change, **not something this runbook has already installed**. The proposal must name the new input/pin, exact selected attributes, overlay/module wiring, unfree settings, compatible dependencies, affected hosts and checks. Do not globally replace `pkgs` or add a second floating package source without approval. Desktop/compositor/driver-related packages need particular ABI/integration review.
- Propose a narrowly scoped version/source override if appropriate, including hashes, dependencies, patches and update ownership. Do not assume bumping `version` alone updates a nixpkgs package correctly.

Never work around the shared pin with `nix profile install`, `npm install -g`, a curl-to-shell installer, an AppImage, or an in-app updater. Those can shadow or bypass the declarative installation rather than update it.

### D — A local input or a bundled tool

Resolve the exact current URL/path from `flake.nix`; do not substitute another checkout. Record each required local repository's Git top level, branch, full HEAD and complete status using read-only Git commands. Missing/unexpected local state blocks the refresh; do not pull, switch, clean, build-edit or otherwise modify the external repository without its own approved scope.

- `pa-platform` and `andafin-jira-mcp` currently use local path inputs. A targeted refresh captures local source contents; a clean Git HEAD alone is insufficient evidence for a dirty path source. Record the intended content and resulting NAR hash without publishing protected data.
- `personal-google-mcp` currently uses `git+file`. Record its locked revision/ref and verify the intended source state before refreshing. Git-tracked/dirty-file handling and explicit ref selection differ from a raw path input; do not assume uncommitted files are either all included or all ignored. For a commit-bound refresh, require the source to be clean at the approved commit; otherwise stop for exact content review.
- Updating PA's bundle may update Pi, adapters and extensions together. Updating root `pi-coding-agent` separately may leave the effective `pi` unchanged because both are installed. Check executable resolution in the actual terminal/Orca/PA launch context after activation; do not change `PATH` or remove either installation without approval.

Once local state and intended bundle changes are approved, use the same named-input form (for example, `nix flake update pa-platform`), then apply Route A's lock-diff checks. Preserve existing `mkPaPlatform` feature choices. This does not authorize edits to the PA repository or to live agent state.

## 4. Validate without activation

Agree on the exact checks before running them; the following is a suggested plan, **not standing authorization**. Capture command, working directory, timestamps, exit status and logs, source/lock hashes, changed paths, and warnings. Re-check fingerprints on resume; drift invalidates affected evidence. New warnings must be fixed, explicitly accepted by Sinh with rationale, or blocking.

1. Evaluate the configured package/version to establish before/after evidence. Packages in the overlaid package set are exposed under `pkgs`, not necessarily under flake `packages`:

   ```console
   nix eval --raw --no-write-lock-file .#pkgs.x86_64-linux.nixpkgs.opencode.version
   ```

   Substitute the traced package attribute, not a guessed executable name. If `version` is absent, record derivation/store identity instead. This is the candidate configuration, not proof of what is currently running.

2. Build the selected package where addressable. Examples (choose the approved target):

   ```console
   nix build --no-link --no-write-lock-file --max-jobs 4 --cores 2 .#droid
   nix build --no-link --no-write-lock-file --max-jobs 4 --cores 2 .#orca-ide
   nix build --no-link --no-write-lock-file --max-jobs 4 --cores 2 .#pkgs.x86_64-linux.nixpkgs.opencode
   ```

   `.#droid` and `.#orca-ide` exist because they are repository packages. Do not assume `.#discord` or `.#opencode` exists. For module-selected packages such as Zen, inspect the module's actual package option or validate the user's integrated home closure:

   ```console
   nix build --no-link --no-write-lock-file --max-jobs 4 --cores 2 .#nixosConfigurations.Drgnfly.config.home-manager.users.sinh.home.path
   ```

3. Evaluate every affected host. Shared modules/overlays and globally imported external modules can affect hosts where the app is disabled. Default to all four unless the approved plan demonstrates narrower impact. Run separately, stopping and retaining the log on failure:

   ```console
   nix eval --raw --no-write-lock-file .#nixosConfigurations.Drgnfly.config.system.build.toplevel.drvPath
   nix eval --raw --no-write-lock-file .#nixosConfigurations.Elderwood.config.system.build.toplevel.drvPath
   nix eval --raw --no-write-lock-file .#nixosConfigurations.FireFly.config.system.build.toplevel.drvPath
   nix eval --raw --no-write-lock-file .#nixosConfigurations.Lily.config.system.build.toplevel.drvPath
   ```

4. Include the repository checks and Drgnfly integration build in the proposed plan when Drgnfly is the target. Other target hosts need their own approved integration build:

   ```console
   nix flake check --no-write-lock-file
   nix build --no-link --no-write-lock-file --max-jobs 4 --cores 2 .#nixosConfigurations.Drgnfly.config.system.build.toplevel
   ```

5. Compare status and file hashes again. These checks must not refresh the lock or alter tracked source. A failure does not authorize channel changes, dependency refreshes, safety-gate bypasses or unrelated fixes; diagnose read-only and seek approval for any repair.

## 5. Sinh-only activation and smoke test

This repository integrates Home Manager into NixOS. A package build does not update the active desktop or an already-running process. Do not substitute a standalone Home Manager switch or a user-profile installation.

Only after the approved non-privileged checks pass, provide commands using the authenticated checkout path. **Sinh runs these manually on the target host; agents never run privileged commands.** For Drgnfly, from that checkout:

```console
sudo sys test
# Only after a passing smoke test and Sinh's approval:
sudo sys rebuild
```

`test` temporarily activates the candidate without making it the boot default. It is not a sandbox: user-service restarts, app database migrations and other mutable effects may persist after a reboot or rollback. Before activation, Sinh should back up important application data using their existing backup process; agents must not inspect or copy private profiles.

Close and reopen the selected app, then ask Sinh to verify:

- Correct executable/store identity and version (`command -v` / `type -a` for CLI apps; About/version UI for desktop apps). For Pi/PA, verify from the launch context actually used.
- Normal launch, existing profile/workspace, keybindings and authentication; no unexpected re-login or migration problems.
- App-specific basics: browser links/video, terminal shell and sessions, editor plugins/LSP, chat sending/notifications, or agent provider/extension startup. Test messages, network actions and paid agent runs require separate consent.
- Connectivity, graphical session and affected user services remain healthy.

No response is not a pass. Record Sinh's exact outcome; do not claim testing of other physical hosts from evaluation results alone.

## 6. Rollback and handoff

Before activation, record the current system generation/store target and a known-good application-data recovery plan. Read-only system identity can be captured with `readlink -f /run/current-system` and `readlink -f /nix/var/nix/profiles/system`.

- **Uncommitted candidate:** leave it intact if it fails. Report the exact proposed reverse patch for Sinh's approval; do not use blanket `git restore`, `reset`, or a saved whole-lock overwrite on a dirty checkout.
- **Focused committed update:** propose `git revert <exact-update-commit>` only with authorization, on the approved branch and after reviewing current changes/conflicts. Rebuild and validate the reverted configuration before operator activation. Do not rewrite shared history.
- **Failed temporary activation:** Sinh can reboot into the previously verified boot generation; do not assume the currently selected boot entry is correct. Rebooting does not reverse application-data migrations.
- **After a persistent switch:** if the immediately preceding system generation is the recorded known-good generation, offer `sudo nixos-rebuild switch --rollback` for Sinh to run manually. Otherwise stop and have Sinh select the recorded known-good boot generation; do not blindly roll back to an unknown generation. System rollback does not revert Git, user data, or an independent profile install.

Handoff must list selected apps/source unit, original and candidate revisions/versions/hashes, affected hosts, precise changed files, checks and warning dispositions, operator smoke-test result or pending status, and the fingerprint-bound rollback plan. Commit only if authorized, staging only intended paths and inspecting the staged diff. Do not claim completion while required checks or operator tests are pending.

### Copyable request template

```text
Target host(s):
Frequently used app(s), confirmed by Sinh:
Requested release/channel/revision:
Source route and exact input/package:
Approved repository/worktree + branch + baseline HEAD/hashes:
Existing changes and ownership decision:
Allowed files/actions; expected shared/transitive effects:
Local-input identities/status (if any):
Approved baseline and post-update checks:
Approval evidence:
Commands/logs, warning decisions, and resume fingerprint:
Sinh-only activation + app smoke-test checklist:
Known-good system generation + app-data recovery + repository rollback:
Result: proposed / blocked / checks passed, awaiting Sinh / verified
```
