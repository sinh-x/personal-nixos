# NX-069: Pi / Herdr / PPA compatibility audit

## Result and scope

**The detection failure is reproduced; the runtime fix and end-to-end acceptance remain blocked.** This is the NX-owned portion of P1, not completion of PAP-303's compatibility/security contract.

Read-only observations below were collected on 2026-11-13, through 16:24:46 UTC, in deployment `d-4d61a3` (rogue-one, not builder). After seeing the blockers, Sinh selected **Commit NX audit and guide**: two documentation commits, without dependency changes, cross-repository edits, activation, pane creation or messaging. No product UAT was run.

Basis: NX-069's published `nx069-ppa-herdr/r002` requirements and UAT, referenced by the ticket under `agent-teams/requirements/artifacts/packages/NX-069/nx069-ppa-herdr/r002/`. This audit does not change those artifacts, replay their publish-only decision, or complete either ticket.

## Checkout and ownership

Authenticated execution checkout: `/home/sinh/.treehouse/personal-nixos-570358/9/personal-nixos`, branch `feature/NX-069-ppa-herdr-integration`, initially clean at `861a9f15ecd7928f95e734f63c7d9242ccf344d0`. The canonical repository is identity evidence, not a substitute execution checkout. No branch, lease, worktree return or merge operation is part of this change.

| Surface | Current owner and conclusion |
| --- | --- |
| [Herdr module](../modules/home/cli-apps/herdr/default.nix) | NX-048 already generates `herdr-agent-state.ts` by running the selected `pkgs.herdr` in an isolated build HOME, then installs it declaratively at `.pi/agent/extensions/herdr-agent-state.ts`. Preserve this; a second manual copy is not a fix. |
| [Overlay](../overlays/sinh-x/default.nix) | Selects Herdr from `inputs.herdr` and PA through `inputs.pa-platform.lib.mkPaPlatform`, with existing Vim/AXI feature choices. Do not invent a Herdr option or change those choices. |
| [Drgnfly home](../home/sinh/Drgnfly.nix) | Enables Herdr and installs both `pa-platform` and `pi-coding-agent`. Executable resolution must be checked independently of comments describing a bundled Pi. |
| [Flake input](../flake.nix) | PA is a local **path** input. A lock refresh can capture different local bytes; a Git HEAD is not an immutable identity for a dirty path input. |
| PAP-303 | Owns trusted extension composition, lifecycle mapping, provenance/dialog-safe bounded peer messaging and the exact package/configuration interface. Fresh ticket read: `idea`, no implementation or qualification evidence. NX has no authority to implement it in another repository. |
| NX-064 | Owns Drgnfly Pi/Ghostty package isolation and correction of the broader app-update inventory. Fresh ticket read: `pending-approval`. No Pi repin, removal, PATH change or broad runbook rewrite here. |

The PA source path declared by **this checkout** is `/home/sinh/git-repos/sinh-x/tools/pa-platform`. Read-only Git inspection found branch `develop`, HEAD `7f208de75fad52c003d151d9338934c6caa06d19`, modified `docs/README.md` and untracked `docs/PAP-282-session-external-read-design.md`. Their contents were not inspected or changed. This does not adopt that local source, establish its correspondence to installed PA, or reconcile the separate operator-selected PA worktree mentioned in r002.

## Selected source identities (not installed qualification)

These identities came directly from this checkout's `flake.lock`, not from evaluating or building a candidate package. No fetch or lock update was performed.

| Root input | Locked identity |
| --- | --- |
| `nixpkgs` | GitHub revision `0bb2eedc20e4739f29e8045034f2828ad7054f8f`; NAR `sha256-fiPJ88izTVucjeo2EQ3jk4aWmLg03I1D4vxnX2QjEgE=` |
| `herdr` | GitHub revision `ee5bfb5041bb3e4a49d591c72308aae3c81ecdde`; NAR `sha256-0B58jR/v1vxbK7cwoq++SnOCsED0sHDkgqVMvsrjezE=`; follows root nixpkgs |
| `pa-platform` | Local path above; NAR `sha256-1BwiCEXmqTZnUQeMHHj2tpRchkH//7Ev8BOjJGq3jJA=`; follows root nixpkgs; no locked Git revision |

Preservation baseline, SHA-256 of repository file bytes:

| Path | SHA-256 |
| --- | --- |
| `flake.nix` | `adf02976b0666b4aec416a7847e238e45f754eba7b7e01d93633daff5b08765a` |
| `flake.lock` | `6576c951c3741690025c0ccc9fbb95880e9d2ef79265718ece6f03cf8f01514a` |
| `modules/home/cli-apps/herdr/default.nix` | `11c1a6e58983c70c3c2a39b0ab04ad53800b39a71a208cc6170f805bea38a3c5` |
| `modules/home/cli-apps/herdr/config.toml` | `3c9ba526c7470c52f977916beb6bd9d32325d1c8000658f00ef55f0a92462b1f` |
| `overlays/sinh-x/default.nix` | `2caa98b3a78ed40584ef6e89c08971031dfa5bfc4f1d993fb0505273c4373113` |

These are the feature checkout's baseline, **not** the canonical checkout's historical dirty-file hashes from r002. No canonical source mutation or transfer of operator changes was performed.

## Installed observations

The resolved executable/store targets below identify the observed installation, not an audited compatible pair or hashes of installed source bytes.

| Probe | Observed result |
| --- | --- |
| `herdr --version` | `herdr 0.9.5` |
| `herdr status` | Client/server 0.9.5, private protocol 22 compatible, endpoint compatible, restart not needed, server binary not stale |
| `pi --version` | `1.4.0` |
| `ppa --version` | `ppa 0.1.163-pap296.1` |
| `herdr integration status` | Pi `current (v9)` at `~/.pi/agent/extensions/herdr-agent-state.ts` |
| `herdr agent list` | `{"id":"cli:agent:list","result":{"agents":[],"type":"agent_list"}}` |
| Current pane metadata | `HERDR_PANE_ID=w1:pY`, `HERDR_WORKSPACE_ID=w1`; `HERDR_SESSION_ID` and `HERDR_TERMINAL_ID` unset. This is not verified session/deployment binding for messaging. |
| `herdr agent explain w1:pY` | `agent_not_found`: `agent target w1:pY not found` |
| Non-Pi status baseline | Droid `outdated (v3 < v4)`, OpenCode `outdated (v10 < v13)`; all other listed integrations not installed. Not repaired or counted as new failures. |

Resolved targets:

```text
PPA: /nix/store/vlpnb0wh0v39rfcz36jdb1jhq7faq4p3-pa-platform-0.1.163-pap296.1/bin/ppa
Pi: /nix/store/isaxx2q4ka0ra8fs0fdq337431slzd37-pi-coding-agent-1.4.0/bin/pi
Herdr: /nix/store/1a6fy989j3d68aqicm3gs83y21kkzri1-herdr-0.9.5/bin/herdr
Standalone extension: /nix/store/x78xy43yn8lhlc64mh8d98agni3v8cla-herdr-agent-state.ts
```

### Installed-source access remains unavailable

Native `read` returned `LOCAL_SOURCE_UNAVAILABLE` for each attempted locator:

- `README.md` and `docs/extensions.md` under `/nix/store/isaxx2q4ka0ra8fs0fdq337431slzd37-pi-coding-agent-1.4.0/lib/node_modules/pi-monorepo/`;
- `/nix/store/x78xy43yn8lhlc64mh8d98agni3v8cla-herdr-agent-state.ts`;
- attempted adapter locator `/nix/store/vlpnb0wh0v39rfcz36jdb1jhq7faq4p3-pa-platform-0.1.163-pap296.1/lib/node_modules/pa-platform/packages/pi-pa/src/adapter.ts` (installed source layout itself unverified).

The tool did not establish whether these were absent, changed or unsupported by source classification. Preserve the failed coordinates; the runtime/security owner must establish permitted source access before retry. No shell reads, copies, alternate-profile reads or other bypasses were used. Installed Pi API/extension privilege review and executable launch-path proof are therefore still missing.

## Root-cause and transport limits

r002 records earlier PA **source** evidence that managed launches use `--no-extensions` plus an explicitly trusted extension, whose inspected composition lacked Herdr. Together with today's empty list, this supports the extension-loading mismatch hypothesis. It does **not** prove the actual installed launch arguments, loaded modules or fresh foreground behavior. No standalone control or new managed session was launched here.

Read-only Herdr 0.9.5 CLI help establishes only these limits:

- `agent prompt --wait` is explicitly **not turn-correlated**; completion of an already-working turn can match. Existing blocked state is rejected, but this is not proof of native-dialog race safety, provenance protection or a safe submission mechanism.
- `agent wait` without `--timeout` waits indefinitely.
- `agent read` exposes terminal output with a line limit but no documented byte limit or request correlation. It is not a bounded peer-reply protocol.

Consequently bare Herdr prompt/wait/read is **not** the admitted PPA messaging interface. No prompt, wait, terminal read, send-keys, focus, restart or pane/session operation was performed. Re-enabling extension discovery, adding a wrapper, or reinstalling the global extension would not close these safety gaps.

## Phase disposition and required handoff

| Phase | Current disposition | Required next evidence |
| --- | --- | --- |
| P1 | NX ownership/symptom audit recorded; PAP compatibility contract **blocked** | Admitted installed Pi/API/upstream-extension audit; fresh standalone/managed startup proof; exact source/installed pair; finite configuration interface and lifecycle/security contract |
| P2 | **Blocked on PAP-303**, no NX substitute | Runtime implementation, defined positive/negative source tests, dialog/provenance/race review, exact compatible package/interface |
| P3 | NX operational documentation can proceed; runtime wiring/selection **blocked** | Reconcile operator-owned PA input and NX-064; select only the separately qualified package. No guessed option, forced Nix edit or unapproved lock refresh. |
| P4 | **Not run** | Independent review, applicable hosted CI, installed qualification, genuine foreground builder/read-only-peer evidence, Sinh activation/rollback/UAT |

All eight r002 UAT scenarios remain **Not run**. Rogue-one diagnostics are not builder-mode validation. Communication is context only, never human approval, native workflow authority or write ownership.

Documentation-only validation is limited to whitespace/local-link checks, TOML parsing, preservation hashes and the normal repository commit hooks. Candidate package/Home Manager evaluation/builds, keybinding derivation execution, source runtime/security tests, activation and UAT are separate gates, not implied passes. With only documentation changes, package/module selection for all four hosts is unchanged; this is a source-preservation conclusion, not four-host evaluation or runtime testing.

### Commit tooling setup

The first normal commit attempt failed because this worktree lacked `.pre-commit-config.yaml`. No bypass flag was used. Sinh separately authorized scoped offline Nix evaluation/builds to obtain the repository-declared hook configuration and an ignored worktree symlink, without changing the shared Git hook.

The attempted `checks.x86_64-linux.pre-commit-hooks.configFile` attribute was absent. Read-only attribute discovery found `config.configFile`; `nix build --offline --no-link --no-write-lock-file --print-out-paths .#checks.x86_64-linux.pre-commit-hooks.config.configFile` returned `/nix/store/d5k100vrfapyvfy08dhcdm5rkd82kfp8-pre-commit-config.json`. A native read of that generated file also returned `LOCAL_SOURCE_UNAVAILABLE`; no alternate content read was attempted. This tooling setup is not a package qualification build or a fix for installed-source access.
