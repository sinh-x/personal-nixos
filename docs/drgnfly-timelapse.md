# Drgnfly timelapse input (NX-067)

The native server is selected from
`inputs.timestamp-timelapse.packages.${pkgs.stdenv.hostPlatform.system}.timelapse-server`.
The adjacent local service module remains the **only** service-module import.
Copied sources under `systems/x86_64-linux/Drgnfly/timelapse/` are retained but
are no longer the selected package source; retirement is separate work.

## Source and update ownership

Initial source: `git+file:///home/sinh/git-repos/sinh-x/timestamp-timelapse?ref=develop&rev=693feed0ff0961616b63326f57455fd3dcfdf95a`.
This exact committed revision includes TTL-014's browser-login fix
(`Referrer-Policy: same-origin`), without accepting null/foreign Origin or
weakening CSRF, TLS, CSP, or cookies. Unlike the earlier draft raw-path input,
it does not capture dirty/untracked/ignored worktree files or depend on a
Treehouse lease. Retain the local Git repository and commit; this local-only
URL is not portable to other builders. A published exact revision is a separate
reviewed source change. Advancing local `develop` alone does not move this pin.

The input owns its locked nixpkgs/Go toolchain. Do not add a host-nixpkgs
`follows`, change root nixpkgs, or refresh unrelated inputs to update this server.
For the initial pin the expected package is:

```text
/nix/store/llrknbgwp8j0x8cly332c84p1lj8jdi5-timelapse-server-0.1.0
```

Follow [targeted updates](workflows/targeted-app-updates.md), including fresh
scope approval, canonical checkout identity, source/status review, file hashes,
and baseline checks. For a future update, review the new exact source commit,
change only the URL's `rev` (and `ref` if needed), then run as an ordinary user:

```sh
nix flake update --offline timestamp-timelapse
```

Stop if required inputs are unavailable offline. Never run an unnamed
`nix flake update` or `sys update timestamp-timelapse` (the wrapper refreshes
all inputs). Compare the lock against the pre-update working-tree baseline:
only this input and its dependency identities may change. Node renumbering is
not an update; compare resolved locked identities, including follows edges.
Never replace a dirty lock wholesale or stash/reset operator changes.

## Non-privileged validation

From the runtime-authenticated canonical checkout, on the approved branch:

```sh
nix eval --offline --no-update-lock-file --no-write-lock-file --raw \
  .#nixosConfigurations.Drgnfly.config.services.timestamp-timelapse.package.outPath
nix eval --offline --no-update-lock-file --no-write-lock-file --impure --json --expr '
  let f = builtins.getFlake (builtins.getEnv "PWD"); in
  import ./systems/x86_64-linux/Drgnfly/timelapse/fixture.nix {
    nixpkgs = f.inputs.nixpkgs;
    timelapse = f.inputs.timestamp-timelapse;
  }'
nix build --offline --no-update-lock-file --no-write-lock-file --no-link \
  --max-jobs 4 --cores 2 \
  .#nixosConfigurations.Drgnfly.config.services.timestamp-timelapse.package
nix build --offline --no-update-lock-file --no-write-lock-file --no-link \
  --max-jobs 4 --cores 2 --print-out-paths \
  .#nixosConfigurations.Drgnfly.config.system.build.toplevel
```

Before activation, compare the exact full candidate closure and generated units
with the recorded running system; disclose unrelated changes and new warnings.
Package/fixture tests are not full-host acceptance or live browser UAT.

## Lifecycle and operator acceptance

Preserve account `timestamp-timelapse`, endpoint `100.83.89.101:8443`, hostname
`drgnfly.tail10c2c6.ts.net`, trusted HTTPS/application authorization, preparation
and renewal helpers/timer, hardening (including Go's `AF_NETLINK` requirement),
archive and credential persistence, and bakery/gateway coexistence.

The preparation unit references the new admin binary, so changing packages is
a real lifecycle event. The existing helper preserves initialized auth; do not
run it manually, replay initialization, reset passwords/tokens, delete state,
change permissions/networking, or migrate archives. No phone APK update or
re-enrollment is required for this server integration.

**Agents execute zero privileged commands.** After non-privileged checks and
closure/unit review pass, Sinh separately approves and runs temporary activation
from the authenticated checkout (`sudo sys test`). First record
`readlink -f /run/current-system` and
`readlink -f /nix/var/nix/profiles/system`, and use the existing backup process
for archive/credentials without exposing their contents. Then Sinh verifies:

- Freshly load `/login`; the old page retains its old referrer policy. Log in
  using the existing owner account; trusted TLS and authorization still work.
- Existing saved work/video browsing, playback, and downloads remain available.
- Phone sync continues using existing enrollment, without archive/token resets.
- Bakery/gateway remain healthy; preparation, renewal, and timer are healthy.

Only after reported results and separate explicit approval should Sinh perform
persistent activation (`sudo sys rebuild`). TTL-014's broader two-phone/product
acceptance remains separate. A build or synthetic browser test does not satisfy
these human checks.

## Reviewed rollback procedure

Initial source baseline: NixOS `e0e283e4d11f6309ed87f4c84fceb4fcb94f485d`.
Before this implementation both the running and persistent system targets were
`/nix/store/wzwnmhd27dmdh7av75c0ys1g8l4rxqwn-nixos-system-Drgnfly-26.11.20261008.e7439b6`.
Reauthenticate these identities immediately before any operator activation.

For an uncommitted candidate, leave failed changes intact. Request approval for
a narrow reverse diff of the integration's source/fixture/lock changes, checked
against current file hashes. Remove only this input's lock edge/now-unused nodes;
undo node renumbering only after reviewing other input identities. Do not copy an
old whole lock over operator edits. For an authorized focused commit, propose an
exact `git revert <integration-commit>` and review conflicts, never reset/rebase.
Rebuild/revalidate the reverted candidate before any operator activation.

After a failed temporary activation, Sinh may boot the recorded known-good
generation. After persistent activation, offer
`sudo nixos-rebuild switch --rollback` **only** when the immediately previous
generation is the verified known-good target; otherwise Sinh selects the recorded
boot generation. System rollback does not restore mutable application data and
must not reset or replace credentials/archive. Preserve both when rolling back.

## Implementation evidence — d-aaf4d9

Implemented in the canonical checkout on
`feature/NX-067-timelapse-flake-input`, based on clean
`e0e283e4d11f6309ed87f4c84fceb4fcb94f485d`. Sinh approved the exact source and
non-privileged check plan in the foreground. The source repository was clean at
`204d28e0514facb199a40027c9e7274d8be28d68`; its later HEAD did not change the
selected `693feed` commit, and the external repository was not modified.

- Named offline lock update passed. All existing root inputs' recursively
  resolved locked/original identities were unchanged (including renamed nodes).
  New input NAR: `sha256-KGKMQ1dYLbQcOoNogY+m9cWxFMMijPn0XryQylGpLLg=`.
  Its own nixpkgs remains `e7439b6b14ad3cc35d05608ebca9bce01a25f5f8`.
- Baseline and candidate host fixtures passed, including negative host,
  Tailscale, firewall-readiness, and persistence gates. The local optional-module
  fixture also passed, including disabled-service, port, store-secret, and
  `AF_NETLINK` assertions.
- Before/after full-host configuration snapshots preserved lifecycle settings,
  hardening, account, firewall, persistence, tmpfiles, and renewal/timer settings.
  Only server references and the generated preparation-script reference changed;
  that script's contents differ only in the native binary path.
- Nixfmt 1.5.0 check, Statix checks on the three changed Nix files, and
  `git diff --check` passed. Native package realization passed from cache at the
  expected fixed package path; this deployment did not rerun upstream Go tests
  or synthetic Chromium tests.
- Offline full Drgnfly build passed. Exact candidate:
  `/nix/store/v879xlzsvdx51allpj63wyzk1inwzavj-nixos-system-Drgnfly-26.11.20261008.e7439b6`.
- Running-to-candidate exact closure comparison: 16 removed / 17 added paths,
  limited to server, generated preparation/unit/system/environment outputs,
  registry, and source snapshots. No unrelated application package changed.
  System unit contents differ only for the timelapse server and preparation
  binary references (including the wanted-by symlink), plus nix-daemon's
  `X-Restart-Triggers`. The entire system-wide user-unit directory is unchanged.
  Nix registry/NIX_PATH gain the new input; the `self` entry changes to the
  dirty candidate snapshot. Generated environment differences are limited to
  those registrations and transitive store references. A nix-daemon restart
  trigger is therefore an expected additional activation effect.
- Baseline and candidate full-host evaluation both emitted the existing
  `stdenv.isLinux` / `stdenv.isDarwin` deprecation warnings; no new evaluation
  warnings were observed. Dirty-tree warnings are expected for this uncommitted
  candidate. Initial source copying also emitted Nix store hard-link-limit
  notices; the baseline fixture nevertheless exited successfully.

Diagnostic history is not hidden: an initial snapshot serializer forced the
removed impermanence `method` option; selecting only directory/user/group/mode
fixed the diagnostic. Initial comparison assertions omitted generated script
references, wanted-by symlink content, NIX_PATH registration, and dirty `self`
metadata. Those diagnostics failed, were investigated, and passed only after
explicitly accounting for these observed derived changes. No module safety gate
was removed or bypassed. Command/log evidence remains in the deployment activity
and temporary `/tmp/nx067.gl3JQd/` files (the latter are not durable storage).

Resume fingerprints (SHA-256):

| File | Candidate |
| --- | --- |
| `flake.nix` | `e2b2f81f8d6d0c46c287f9b8f408f9e36ed78571041c458819f8ec254e8780f2` |
| `flake.lock` | `35ac24465ff5904b36d7c2b071069e1e1ef1790e20e790f0fa23398d16c6cb53` |
| `drgnfly-timelapse.nix` | `f2f7265d85f7ad6bb5a25b4a55dec41478b63f770aa17d030cba7e2dc54255e7` |
| `fixture.nix` | `af7b9f60fcce0b2f3862bb5b6db31b64770128e96ec9669136d2d068f3a31549` |

This is **implementation/build evidence, not activation or acceptance**. No
privileged commands, service lifecycle commands, credential/archive access,
commit, or push were performed. Live browser login, existing archive/video,
phone sync, and bakery/gateway health remain operator checks; closure invariance
is not a live health check. Ticket acceptance remains pending those results.
Rebuild/review if tracked source or lock changes; committing or later including
this documentation can itself change the flake's source-snapshot store identity.
