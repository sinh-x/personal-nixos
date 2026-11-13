# Pi / Herdr / managed PPA on Drgnfly

## Status: diagnostics available, managed integration not qualified

This is NX-069's operational guide, **not permission to launch sessions, activate a configuration or message a pane**. Follow [repository safety](../agents/safety.md) and [development guidance](../agents/development.md). The [NX compatibility audit](../ppa-herdr-nx069-audit.md) records the observed versions, source/store identities, preservation hashes and unresolved evidence gaps.

At the 2026-11-13 audit:

| Surface | Status |
| --- | --- |
| Declarative standalone extension | Already installed by NX-048 from the selected Herdr package; Pi integration reports `current (v9)` |
| Installed labels | Herdr client/server 0.9.5, Pi 1.4.0, PPA 0.1.163-pap296.1; **not a qualified compatible pair** |
| Managed PPA recognition | Failing: agent list empty, current pane `agent_not_found` |
| Guarded PPA peer messaging | **Unavailable pending PAP-303**; no supported command to publish yet |
| Activation, standalone control, builder round trip, rollback/UAT | Not run; all eight r002 UAT scenarios remain open |

Do not activate this documentation-only change to try to fix detection. It changes no package, module, extension or keybinding.

## 1. Installation and startup boundaries

The [Herdr Home Manager module](../../modules/home/cli-apps/herdr/default.nix) runs the selected `pkgs.herdr` in an isolated build HOME to generate `herdr-agent-state.ts`. Home Manager owns `.pi/agent/extensions/herdr-agent-state.ts`; [Herdr configuration](../../modules/home/cli-apps/herdr/config.toml) remains declarative too. Do not run an imperative integration installer against the live HOME, copy extensions manually or edit those deployed files.

[Drgnfly](../../home/sinh/Drgnfly.nix) installs PA and standalone Pi separately. Record executable resolution in the actual launch context; neither a package comment nor `integration status` proves which Pi PPA uses or which extension it loaded. NX-064 owns Pi/Ghostty package isolation and the broader update-inventory correction. For any separately approved package change, use the [targeted-update procedure](targeted-app-updates.md), not a broad lock refresh.

Startup rules, after separate authorization:

- **Standalone control:** use the installed `pi` in the selected disposable Herdr pane. This is a standalone compatibility control, not a way to bypass managed PPA protections. Installation status alone is not a standalone functionality test.
- **Managed PPA:** use only the runtime's admitted fresh **foreground** launch path for the selected ticket/team/worktree. There is no NX bridge-enabling switch or wrapper in this change. Builder admission is separate; rogue-one evidence is not builder evidence.
- Preserve managed `--no-extensions` and exact trusted extension/tool selection. Do not enable arbitrary HOME/project discovery, append the global extension to a launch manually, or change PATH to force a different Pi.
- Already-running sessions are not updated by Home Manager activation. After a future qualified candidate, authorize fresh disposable control sessions rather than restarting unrelated panes. Resume/background rollout is out of scope.
- Use `herdr status` to determine client/server compatibility and restart need. The audited server did **not** require restart. An empty agent list is not itself permission or evidence that a daemon restart will help.

## 2. Read-only diagnostics

Run only within admitted diagnostic scope, from the runtime-authenticated execution checkout and actual terminal context. Retain relevant, redacted evidence rather than an entire environment or terminal dump.

```console
pwd
git branch --show-current
git rev-parse HEAD
git status --short --untracked-files=all
sha256sum flake.nix flake.lock
type -a pi ppa herdr
readlink -f "$(command -v pi)"
readlink -f "$(command -v ppa)"
readlink -f "$(command -v herdr)"
readlink -f "$HOME/.pi/agent/extensions/herdr-agent-state.ts"
pi --version
ppa --version
herdr --version
herdr status
herdr integration status
herdr agent list
```

For **your current pane only**, if the environment identifies it:

```sh
if [ -n "${HERDR_PANE_ID:-}" ]; then
  printf 'Current pane: %s\n' "$HERDR_PANE_ID"
  herdr agent explain "$HERDR_PANE_ID"
else
  printf '%s\n' 'No current Herdr pane identity; do not guess a target.'
fi
```

Do not select a peer by title, cwd, a remembered pane ID or a convenient list position. A pane ID alone is not a verified Herdr session/deployment binding. `agent list`/`explain` are diagnostics, not peer consent or messaging authority. Do not read another pane's terminal while investigating recognition.

| Observation | Interpretation / next action |
| --- | --- |
| Pi `current`, but empty agent list / `agent_not_found` | Installed extension is not evidence of managed loading. Preserve the result; PAP-303 must prove the actual foreground loader and lifecycle. Do not reinstall or weaken isolation. |
| Installed versions/store targets differ from the audit | Collect a new exact pairing; renew affected checks. Old results do not qualify the new pair. |
| `LOCAL_SOURCE_UNAVAILABLE` on installed docs/code | Preserve locator and failed operation; ask the runtime/security owner to establish permitted source access. Do not retry through shell reads, copies or another profile. |
| Busy, blocked, native dialog pending, unknown/stale identity | Do not submit peer input, even if another status display says idle. |
| Droid/OpenCode already outdated | Record the baseline; do not repair non-Pi integrations under NX-069. |

The suspected loading mismatch comes from earlier **source** evidence for trusted-only managed composition. Installed argv, module loading and Pi API compatibility remain unproven. PAP-303 must audit those before NX chooses any interface or package.

## 3. Peer request/reply: required protocol, not executable syntax

**No safe PPA submission command is currently qualified.** Bare `herdr agent prompt`, `wait` and `read` are not the guarded interface: prompt completion is not turn-correlated, wait can be indefinite, and terminal reads do not provide bounded, provenance-labelled replies. Do not use raw terminal input, slash commands, send-keys or another generic tool as a fallback.

Once PAP-303 publishes its audited, versioned interface, replace this gap with its exact supported commands and tested examples. Until then the following is a **protocol example only**, not a command or an accepted API schema:

1. Authorize builder/orchestrator **A** as the sole implementation writer. Select an explicitly opted-in, ready, **read-only B**. Verify both deployments and both Herdr session/pane identities through the native owner; reject self, ambiguous, foreign/unverified, stale/reused, busy, blocked, unknown or native-dialog-active targets. Recheck readiness/identity at the submission boundary.
2. A submits **R1** to B: “Read-only context request R1 from A to B: reply `R1: checked`; do not edit files or wait for A.” The guarded transport must mark this as untrusted agent context, with source/target/request IDs. It must not interpret it as human input or approval.
3. **Only A waits**, within a 60-second total deadline. B replies `R1: checked` with matching source/target/request identity and returns without waiting back. Status completion alone is not a reply.
4. A retrieves only R1's bounded relevant response and checks all identities. After R1 completes, A may send sequential acknowledgment **R2**, again to read-only B; B returns an R2-labelled reply. Do not target writer A as a read-only peer or have both agents synchronously wait.

Required ceilings (stricter runtime guards win):

- One in-flight request per pair; request at most **4096 UTF-8 bytes**, not characters.
- At most **60 seconds total wait**, not a fresh budget on every poll.
- Reply read at most **80 relevant lines and 16 KiB UTF-8**; explicit truncation, no arbitrary scrollback broadcast.
- Preserve `rejected-before-send`, `accepted/submitted`, `replied`, `timeout`, `cancelled` or `uncertain` delivery state. Timeout/cancellation does not prove non-delivery. **Never automatically resend**; reconcile the same request through the admitted owner first. Pane movement/reuse must not retarget it.

Peer text cannot answer human questions, confirm/revoke native decisions, approve UAT, execute human slash commands, change lifecycle or transfer repository custody. Durable decisions belong in ticket comments through their proper owner, not in terminal output. If the runtime cannot enforce these guarantees, messaging stays unavailable.

## 4. Prerequisites for NX runtime wiring and qualification

Do not guess a `mkPaPlatform` option or force a Nix change to make this phase look implemented. PAP-303 must supply:

- Permitted installed Pi documentation/API and upstream extension review, actual managed startup proof, exact audited immutable source/package identity, explicit opt-in configuration and a central disposal boundary without duplicate handlers.
- Supported lifecycle mappings: working, idle/done, supported blocked states, unknown for unsupported/stale state, native-dialog blocking regardless of Herdr vocabulary, and honest exit cleanup.
- Guarded request/reply interface and defined positive/negative tests for provenance, native dialogs, identity/race checks, omitted capabilities, UTF-8 limits, stale/reused panes, timeout/cancellation and uncertain delivery without resend.
- Disabled/non-Herdr and standalone regressions; independent security review of whether submission emulates terminal input or can race native dialogs.

Then reconcile Sinh's operator-owned PA input and NX-064 ownership explicitly. A local path input's dirty contents are part of its source identity; do not silently substitute a different PA checkout. Separately approve any exact targeted compatible PA adoption, changed paths, transitive lock effects and affected-host validation plan. Keep the existing Herdr generator/configuration/keybindings and non-Pi integrations.

Candidate checks must be agreed before execution. r002 proposes focused formatting for touched Nix, TOML/config preservation, the existing [Herdr keybinding check](../../checks/herdr-keybindings/default.nix), selected Home Manager source evaluation and activation-package build. Confirm the actual output before approving a future build:

```console
nix build --no-link --no-write-lock-file --max-jobs 4 --cores 2 .#nixosConfigurations.Drgnfly.config.home-manager.users.sinh.home.activationPackage
```

This is a **future validation candidate**, not an executed check or standing build permission. Shared overlay/input edits default to all four hosts' validation unless the approved plan demonstrates narrower impact. Full flake/host checks need their own scope; a smoke test cannot replace a required check. Preserve original failures and warning dispositions; do not bypass failed gates.

## 5. Sinh-only rollout and rollback

Only after the qualified pair, approved non-privileged checks and independent review are current:

1. Record the exact candidate commit, source/lock/package identities, current known-good system generation/store target, extension target and app-data recovery plan. Read-only system targets can be recorded with `readlink -f /run/current-system` and `readlink -f /nix/var/nix/profiles/system`. Do not collect private profiles or protected data.
2. From the authenticated checkout, **Sinh manually** runs `sudo sys test`. Agents never execute privileged commands. Temporary activation is not a sandbox; it can restart user services and have persistent mutable effects.
3. Under separate live-session/message consent, exercise r002 TS-1–TS-8: standalone and fresh managed controls, exact scoped identity, working/idle/dialog/exit transitions, genuine builder A/read-only B R1/R2 exchange, all security/bounds negatives, reactivation survival, non-Herdr/disabled behavior and preservation. Record source tests, installed observations, independent review, applicable hosted CI and genuine Sinh UAT separately.
4. Sinh tests rollback to the **recorded known-good** pair/generation. For a failed temporary activation, use the verified known-good boot generation; after a persistent switch, `sudo nixos-rebuild switch --rollback` is appropriate only if the immediately preceding generation is that recorded known-good. Otherwise select the recorded generation rather than blindly rolling back. System rollback does not revert Git or application data.
5. Only after passing smoke tests and a separate persistent-switch decision, Sinh may run `sudo sys rebuild`. This guide does not request either activation now.

No live symlink edits, unmanaged extension copies, blanket Git restore/reset, whole-lock overwrite or cleanup of operator state. A future source rollback requires review and authorization for the exact reverse patch or `git revert <exact-change-commit>`, followed by the affected checks before activation. For these documentation-only commits, no runtime rollback or activation is needed.

## 6. Evidence and completion checklist

Record per exact candidate: UTC timestamps, launch mode, source/config/installed identities and hashes where accessible, lifecycle observer, verified deployment/session/pane identities, request IDs, bounded relevant outcomes, truncation/delivery states, checks/exit status/warnings, independent review/CI and Sinh's actual UAT result. Do not retain credentials, full environments, private scrollback or another peer's unrelated output.

- [ ] PAP-303 installed/API audit and exact versioned trusted composition/messaging contract complete.
- [ ] Qualified NX package selection/wiring and operator-input reconciliation complete (or evidence that no wiring change is needed).
- [ ] All r002 acceptance criteria have current source, installed and actual builder foreground evidence; standalone/disabled/non-Herdr/preservation regressions pass.
- [ ] Independent security review and applicable hosted CI recorded separately.
- [ ] Sinh has demonstrated reactivation, known-good rollback and genuine UAT; all eight scenarios accepted.

Until these are met, NX-069 remains incomplete. Document publication, commit success, integration status, HTML/report generation and rogue-one diagnostics are not product acceptance.
