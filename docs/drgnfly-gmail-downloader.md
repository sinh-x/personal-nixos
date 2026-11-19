# Read-only Gmail downloads on Drgnfly

Home Manager declares one `gmail-downloader.service` and one
`gmail-downloader.timer` for `sinh`, enabled only in `home/sinh/Drgnfly.nix`.
Nothing is installed or started by evaluating/building this configuration.
Activation and real-mailbox acceptance are separate operator actions.

## Schedule and behavior

- Nominal runs: **08:00, 12:00 and 18:00 Asia/Ho_Chi_Minh** (UTC+7), regardless
  of the host timezone. `AccuracySec=1s`, with no randomized delay, is not a
  hard real-time start or completion guarantee.
- Each oneshot runs `personal`, then `andafin`, sequentially. Both use the
  existing root `/home/sinh/.local/share/gmail-downloader` without filters or
  `--all`: all accessible mail, including Spam and Trash. Future profiles are
  not automatically enrolled.
- An ordinary failure in either profile still permits the other attempt and
  makes the service fail overall. Termination stops the run rather than starting
  the next profile. There is no automatic service restart or short scan deadline.
- systemd coalesces starts of the same active oneshot; timer/manual starts do not
  create another service instance. Existing downloader per-profile writer locks
  remain authoritative for direct CLI/authorization contention. Never delete a
  `writer.lock` file to break a lock; an idle persistent lock file is normal.
- `Persistent=true` permits one eligible catch-up when the timer resumes after
  missed slots, not one download per missed slot. Initial enable has no earlier
  trigger history to replay. Slots occurring during a long active run do not form
  a backlog. There is no polling, wake-from-power-off or connectivity guarantee.
- This is a **user** timer attached to `timers.target`. NX does not enable
  lingering. Login-only means the normal user-manager lifetime, including logind
  shutdown grace and any other active sessions. Screen locking is not logout;
  the timer cannot run after the non-lingering manager stops.

## Executable and private storage

The reusable option `sinh-x.cli-apps.gmail-downloader.enable` defaults to false.
Its `executable` option is an absolute **string**, defaulting to:

```text
/home/sinh/git-repos/sinh-x/tools/learning-management/scripts/gmail-downloader/gmail-download
```

NX builds an immutable Bash scheduling wrapper with store-referenced tooling.
It does **not** package, copy or build the downloader, import its checkout into
Nix, or read the archive during evaluation. A missing/non-executable binary fails
before either download; there is no fetch, compile or authorization fallback.

The local binary is mutable, operator-managed and not reproducibly pinned by NX.
Keep that checkout available and reconcile its executable with reviewed upstream
source before rollout/update. Learning-management owns source changes, dependency
setup and builds. Its `scripts/gmail-downloader/README.md` documents Linux/POSIX
storage, Go **1.26.8**, pinned `go.mod`/`go.sum`, and its own offline/race tests.
With that toolchain and cached dependencies, its owner can separately authorize:

```sh
cd /home/sinh/git-repos/sinh-x/tools/learning-management/scripts/gmail-downloader
CGO_ENABLED=0 GOTOOLCHAIN=local GOPROXY=off GOSUMDB=off \
  go build -o gmail-download ./cmd/gmail-download
```

Do not build/update this external checkout as an NX activation side effect.
Moving/removing it requires an explicit NX executable-option change or restoring
it through its owner, not silently selecting a different executable from `PATH`.

The external archive contains plaintext private data, credentials, manifests and
run reports. None belong in Git, Nix inputs, the store, tickets or shared logs.
The service and wrapper use umask `0077`; the downloader preserves its existing
0700 directories/0600 files, ownership checks, profile isolation, incremental
resume, raw retention and hash verification. Unsafe existing storage fails rather
than being recursively repaired. Keep encrypted backups and sufficient disk space.
No sending, mark-read, labeling, deletion, attachment execution or AI processing
is added. Routine journal output contains public aliases/status/aggregate counts
only. Do not attach private run reports or OAuth diagnostics to shared evidence.

## Inspect and run — after approved activation

These are `sinh`'s user-manager commands, not system-wide units:

```sh
systemctl --user status gmail-downloader.timer gmail-downloader.service
systemctl --user list-timers --all gmail-downloader.timer
systemctl --user show gmail-downloader.timer -p NextElapseUSecRealtime -p LastTriggerUSec
journalctl --user -u gmail-downloader.service --since today
loginctl show-user sinh -p Linger
```

Expected lingering remains `no`. A successful build says nothing about the active
units. Confirm the timer is active and its next trigger matches Vietnam time.
A failed run can coexist with a healthy waiting timer; inspect service status and
aggregate logs, then investigate privately. Only after explicit consent for a full,
unfiltered read-only download of **both** profiles at the unchanged external root:

```sh
systemctl --user start gmail-downloader.service
```

This may take a long time and waits for completion. The next ordinary timer run
can retry incomplete work, or the owner can approve a manual rerun. No special
cleanup, lock deletion or forced raw replacement is needed for normal resume.

## Scan cost and OAuth failures

Every run re-enumerates all matching message IDs and hash-verifies archived
artifacts, even when little new mail arrives. Large initial **and recurring** scans
can take substantial time, bandwidth, local I/O and API quota. Long scans can span
later slots. Scans are moving snapshots, not point-in-time backups; inaccessible
or permanently deleted remote messages cannot be recovered. Remote deletion and
selection changes do not prune local originals.

Network, quota and auth failures remain visible; the existing downloader owns
bounded per-request retries. Expired/revoked grants require manual browser
reauthorization under learning-management's documented procedure, independently
for the affected profile. External Google OAuth apps in Testing commonly have
seven-day refresh-token expiry for Gmail scopes; security/admin changes can also
revoke access. Do not add silent authorization, broaden readonly scopes or put
account addresses, client JSON, consent URLs or tokens into service configuration.
Stop the timer/service before owner-led authorization to avoid lock contention.

## Validate, activate and accept

From the authenticated NX ticket checkout, without updating locks or activating:

```sh
nix build --offline --no-update-lock-file --no-write-lock-file --no-link .#checks.x86_64-linux.gmail-downloader
nix eval --offline --no-update-lock-file --no-write-lock-file --json .#nixosConfigurations.Drgnfly.config.home-manager.users.sinh.systemd.user.services.gmail-downloader
nix eval --offline --no-update-lock-file --no-write-lock-file --json .#nixosConfigurations.Drgnfly.config.home-manager.users.sinh.systemd.user.timers.gmail-downloader
nix build --offline --no-update-lock-file --no-write-lock-file --no-link .#nixosConfigurations.Drgnfly.config.system.build.toplevel
```

The scoped check tests synthetic argv, account failure isolation, missing binary,
nonblocking synthetic locks, private umask, foreground ordering, termination,
opt-out, unit properties and exact calendar occurrences under two host timezones.
It never executes the real binary or accesses private storage. It does not prove
runtime systemd overlap/catch-up/logout behavior or real-account acceptance.

Before rollout, review the exact candidate, generated units/wrapper and all other
activation deltas; record a verified known-good system generation and backup
readiness. **Enabling the timer may cause a download as soon as activation starts
it**, so rollout consent must cover that possibility, not just a later manual run.
Only Sinh runs privileged commands, manually, from this reviewed ticket checkout:

```sh
sudo sys test
# Only after temporary verification and separate persistent-activation approval:
sudo sys rebuild
```

Observe the active user timer, unchanged `Linger=no`, repeated starts during a
slow run without duplicate service processes, and cancellation without launching
the second profile. A disposable manager should additionally verify one catch-up
after multiple missed slots, no-miss restart, and a scan exceeding the normal
oneshot timeout. Do not alter the real clock/stamps for tests. An independent
observer is needed to test final logout without keeping `sinh` logged in.

After explicit both-profile/full-scan consent, verify one complete read-only run.
Privately inspect each profile's `state/PROFILE/runs/` report for the effective
unfiltered selection, Spam/Trash inclusion, completion/failures and pending work;
check archive permissions/integrity/retention and remote read/label state without
opening messages in a UI that marks them read. Record only aggregate results and
candidate identity. Unknown/failed evidence is not a pass; fixtures/builds alone
are not final human acceptance.

## Stop, disable and rollback

For an immediate **temporary** stop (preserves all archives and credentials):

```sh
systemctl --user stop gmail-downloader.timer gmail-downloader.service
```

A later Home Manager activation/login can restore the timer. For durable disable,
set `sinh-x.cli-apps.gmail-downloader.enable = false;` in Drgnfly's admitted source
change, validate it, and have Sinh apply the reviewed configuration. Do not manage
competing ad-hoc units or enable lingering. After disabling, confirm neither unit
is active and no downloader child remains.

For system rollback, Sinh selects the recorded verified known-good generation via
his approved system-generation procedure. Use an immediately previous generation
only if it is that known-good one; do not guess. Alternatively apply the narrow
reviewed module-disable change. Rollback does not undo downloaded data or OAuth
changes. Never reset Git, overwrite unrelated edits or delete the private root as
an activation rollback.
