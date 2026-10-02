# NixOS Flake Upgrade Workflow

Ownership: NixOS flake upgrade orchestration and PPA checkout handoff.

This document is the sole owner of the reusable full-lock-refresh procedure. It governs admission, evidence, repair approvals, Drgnfly verification, pause and resume, rollback, and final handoff. Repository safety remains owned by `docs/agents/safety.md`; ordinary development conventions remain owned by `docs/agents/development.md`.

## Plan-first PPA handoff

PAP-215 separates read-only requirements analysis from mutation-authorized builder execution.

Requirements records only:

- the registry-bound repository key and canonical repository root;
- the exact ticket;
- the approved full base SHA;
- the exact linked feature branch;
- Linked Branch State: `planned`; and
- Branch Action: `create`.

Requirements does not require or obtain a builder worktree, checkout, checkout path, lease, holder, ticket slot, repository permit, or operator-prepared checkout. It performs no checkout lifecycle operation or branch action. The canonical root is the requirements analysis identity, not proof of builder execution authority.

After approval, the trusted PPA builder/orchestrator launcher reserves capacity, acquires or reuses and authenticates the distinct ticket checkout, and reconciles the complete canonical identity, ticket, base, branch, state, and action binding. At launch, `PA_REPO`, the current directory, Git top level, deployment context, and protected registry evidence must all equal the authenticated ticket checkout. The launcher supplies that location as the runtime-supplied checkout path; documentation and handoffs must not hard-code it.

Admission permits one active builder lineage per repository/ticket and at most four active ticket checkouts per canonical repository. A parent and its authenticated direct implementation child count as one lineage. A duplicate lineage or fifth checkout is rejected before project-file or branch mutation and before child/runtime spawn.

Only the authenticated builder orchestrator may use ordinary Git to create the exact planned branch from the approved base. For a later materialized run it may select only the exact runtime-authenticated linked branch. Before implementation starts, persist the checkout and lease binding, capacity permit, lineage and correlation identifiers, branch result, full HEAD, and complete launch status. Objective text, an arbitrary checkout, and an Orca-created worktree are not authentication evidence.

Missing, stale, duplicate, replayed, self-asserted, or conflicting evidence fails closed. Every workflow stop diagnostic must be at most 2,000 JavaScript characters and use all five labels:

```text
Condition: <what stopped>
Source: <protected evidence that disagrees>
Reason: <specific mismatch or missing field>
Correction: <evidence or operator action needed>
Resume Action: <fresh validation required before relaunch>
```

Do not repair, replace, clean, or relocate a checkout in response to an admission failure.

## Reusable gates and evidence

### Entry gate

Before Phase 1, require approved requirements, the exact plan-first fields above, authenticated builder admission, an already-current exact branch, and a complete clean or explicitly allowlisted status. Record the target repository and each required local input repository by runtime-resolved path, Git top level, branch, full HEAD, and complete status. Unexpected state blocks the workflow; it is never reset, stashed, cleaned, or silently accepted.

Agents execute zero privileged commands throughout this workflow. Builds, evaluations, source edits, and commits must be non-privileged and separately authorized by the active plan.

### Command and decision ledger

For every phase command, record the phase and sequence, working directory, exact command, timestamps, exit status, output or durable log reference, before/after changed paths, warnings, warning dispositions, approval or decision evidence, and the reason for every gated skip. Record approvals with approver, timestamp, exact scope, and artifact or proposal hash. Silence and elapsed time are never approval.

### Pause and resume gate

At each phase boundary persist one resume fingerprint containing:

- phase identifier and state;
- target branch and full HEAD;
- `flake.lock` SHA-256;
- required local-input full HEADs and expected status;
- allowed changed paths and relevant file hashes;
- current approvals, warning state, and local checkpoint commits;
- for Phases 5 and 6, the current, target, active, next-boot, and currently booted generation identities; the network recovery plan; the exact Phase 5 test command and reported result; the Phase 6 presentation hash, fresh approval, exact rebuild command and reported result; critical-service observations; and any failure, recovery, and exact rollback-command evidence; and
- command-log and decision references.

On resume, compare every field with fresh read-only observations before reusing prior work. A mismatch invalidates evidence from the earliest affected phase: admission or repository identity restarts Phase 1; baseline or declaration evidence restarts Phase 2; lock, source, verification, repair, or UAT drift restarts the phase that produced it. Preserve the mismatch and invalidated evidence; do not normalize the checkout. Expensive checks may be reused only after a complete fingerprint match.

### Warning-disposition gate

Compare warnings against the Phase 2 baseline. Every new warning must be `fixed`, `accepted by Sinh` with a recorded rationale, or `blocking`. Final success requires zero undispositioned new warnings. Warning suppression or agent-inferred acceptance is not a disposition.

## Phase 1 — Preflight and plan validation

1. Validate the authenticated checkout, exact ticket branch, base ancestry, full HEAD, and complete worktree status against protected launch evidence.
2. Confirm every plan-required local input exists at its recorded Git top level and has the expected full HEAD and status. Treat local inputs as read-only dependencies unless a separate approved scope says otherwise.
3. Capture the original lock digest, `flake.nix` digest, declared input URLs/refs/pins/follows relationships, and all repository fingerprints.
4. Confirm the plan names Drgnfly as the blocking build and UAT host, with Elderwood, FireFly, and Lily as blocking evaluation surfaces.
5. Record all required approvals and persist the Phase 1 resume fingerprint. Pause before baseline probes or lock mutation if any gate is incomplete.

## Phase 2 — Baseline and full lock refresh

1. Validate the complete Phase 1 fingerprint.
2. Capture no-write baseline evidence: flake checks and separate toplevel evaluations for Drgnfly, Elderwood, FireFly, and Lily use `--no-write-lock-file`. Preserve failures as baseline evidence rather than repairing them here.
3. Record the baseline warning inventory and pre-refresh declaration manifest.
4. Run one explicit full `nix flake update`. Capture its command output, exit status, pre/post lock hashes, changed paths, and complete lock diff.
5. Prove `flake.nix` and its declared URLs, branches, tags, refs, pins, and follows relationships did not change. A required declaration change is out of scope and returns to requirements review.
6. Inventory every changed root input with its old/new revision and content hash where applicable; distinguish root changes from transitive churn and disposition every new warning.
7. Verify that this phase changed only `flake.lock`, create the authorized local checkpoint, and persist the Phase 2 fingerprint.

## Phase 3 — Non-privileged verification and diagnosis

1. Validate the latest Phase 2 or approved-repair fingerprint.
2. Run `nix flake check --no-write-lock-file` and prove it does not change the lock or worktree.
3. Evaluate the toplevel derivation for all four hosts separately: Drgnfly, Elderwood, FireFly, and Lily. All four evaluations are blocking; do not claim physical testing of the three evaluation-only hosts.
4. Build Drgnfly with no result symlink and no lock write, using `--max-jobs 4 --cores 2` unless Sinh approves and the ledger records a resource override.
5. Reconcile warning deltas. If every check passes, persist the automated-pass fingerprint and proceed to Phase 5.
6. If a command fails, preserve its exact log and classify the cause as environmental/dependency or source/configuration. Retry environmental failures only after the named dependency recovers. Diagnose source failures without editing and prepare one repair proposal for Phase 4. Declared-input, upstream, external-repository, protected-state, live-network, or storage changes return to requirements review.

## Phase 4 — Sinh-approved repairs

1. Validate the failing Phase 3 fingerprint and prepare a proposal for exactly one diagnosed root cause. Include the proposed diff, risks, rollback, targeted checks, full Phase 3 rechecks, file count, and source-LoC count.
2. Each batch is limited to 5 files and 200 source LoC. Generated lock lines and workflow evidence do not expand this source allowance. An over-limit or broadened proposal returns for a revised plan and fresh Sinh approval.
3. Wait for explicit Sinh approval tied to the exact proposal or hash. Missing or declined approval means no source mutation.
4. Immediately before editing, revalidate source hashes and scope. Apply only the approved diff, then recount the actual files and source LoC. Format only changed Nix files, and stop if formatting spills outside approved scope.
5. Run the approved targeted checks, then repeat the complete Phase 3 flake check, four-host evaluation, Drgnfly build, status, and warning sequence.
6. If all checks pass, create one authorized repair checkpoint and persist its approval-to-diff-to-commit fingerprint. Return through Phase 3 validation. A different root cause requires a new proposal and approval.

## Phase 5 — Sinh-run Drgnfly UAT

1. Validate the latest automated-pass fingerprint and prove that flake check, all four evaluations, the Drgnfly no-link build, warning dispositions, and zero agent-run privileged commands remain current.
2. Generate a copyable command using the runtime-supplied checkout path, for example:

   ```console
   cd '<runtime-supplied checkout path>' && sudo sys test
   ```

   Label it Sinh-run only. Also provide exact, fingerprint-bound repository and system rollback commands and explain their effects. Agents must not execute the test, activation, or privileged rollback commands.
3. Wait for Sinh's exact command result and observations for connectivity, display/session, boot-critical services, and other plan-identified critical services. Silence is not success.
4. A failed UAT returns to non-editing diagnosis and, when a source change is needed, a fresh Phase 4 approval. Only a Sinh-reported passing Drgnfly test without critical regression permits a passing Phase 5 fingerprint.

## Phase 6 — Sinh-approved persistent switch

1. Admit this phase only after fresh read-only observations prove that the automated-pass fingerprint and passing Phase 5 fingerprint both remain current, match each other in full, and identify the same reviewed feature candidate. Reconcile canonical and authenticated repository identity, ticket, branch, full HEAD, lock digest, local-input HEADs and statuses, allowed paths and hashes, warning dispositions, repair approvals and checkpoints, Phase 5 command and observations, generation evidence, and command-log references. Zero mismatches are permitted. Drift invalidates evidence from the earliest affected phase and blocks approval and execution.
2. Before requesting approval, record network recovery readiness: the pre-switch connectivity baseline, a tested independent local or console access path, the responsible operator, the prior active and boot generation identities, and the concrete system rollback command below. A missing recovery path blocks the switch.
3. Present one immutable approval record containing the canonical repository key and root; runtime-authenticated checkout path and Git top level; ticket; exact branch and full HEAD; `flake.lock` SHA-256; current generation number and store path; target generation number and candidate toplevel store path; the Phase 5 and automated-pass fingerprint references; network recovery evidence; and this exact checkout-bound command with the runtime value substituted:

   ```console
   cd '<runtime-authenticated checkout path>' && sudo sys rebuild
   ```

   Hash the complete presentation and record it in the decision ledger. The displayed target must be the already-reviewed Drgnfly build output; rebuilding a different HEAD, lock, or local-input state is forbidden.
4. Obtain fresh explicit approval from Sinh, durably tied to that presentation hash and exact command. This is distinct from Phase 5: test approval does not approve persistent switch. Silence, elapsed time, a prior repair approval, or a passing test is not approval. Immediately before execution, re-read every admission field and the command; any change cancels the approval and returns to the earliest affected phase.
5. Agents maintain zero agent-run privileged commands. Only Sinh may run the exact displayed command from the authenticated checkout. Sinh must report the exact command run, start and end timestamps, exit status, output or durable log reference, and whether execution was interrupted; an agent must not infer a result or retry the command.
6. After the command, capture the active generation, the boot generation selected as the default for the next boot, and the currently booted generation, each by generation number and resolved store path. Require exit status 0 and require both the active generation and next-boot generation to equal the approved target. The currently booted generation may remain the recorded prior generation because there is no mandatory reboot. Repeat and record connectivity, display/session, boot-critical service, and every plan-named critical-service observation. All must pass with no critical regression.
7. A nonzero or missing exit status, fingerprint or command drift, active or boot generation mismatch, connectivity loss, display/session failure, or boot-critical or plan-named service regression blocks success. Preserve the command output, observations, generation links, failure time, and unchanged authenticated checkout. Present the following concrete actions with every placeholder substituted from the ledger; only Sinh may run the privileged action:

   ```console
   sudo nixos-rebuild switch --rollback
   git clone --no-local '<canonical repository root>' '<new disposable rollback clone>' && git -C '<new disposable rollback clone>' switch --detach '<baseline full HEAD>' && test "$(sha256sum '<new disposable rollback clone>/flake.lock' | cut -d ' ' -f1)" = '<original lock SHA-256>'
   ```

   Use the recorded local or console path if networking failed. After system rollback, Sinh reports its exit status and the active, next-boot, and booted generation identities plus the same critical observations; they must match the recorded baseline before recovery is accepted. The non-privileged repository command reconstructs and verifies the baseline only in a new disposable clone; it must not alter the authenticated ticket checkout. Diagnose without edits, then route source changes through a fresh bounded Phase 4 proposal and repeat every invalidated phase.
8. Every Phase 6 stop records the bounded five-label diagnostic (`Condition`, `Source`, `Reason`, `Correction`, and `Resume Action`) in at most 2,000 JavaScript characters. Persist a passing Phase 6 fingerprint only when all admission, approval, execution, generation, service, warning, failure-readiness, and rollback-command evidence agrees.
9. Switch this exact reviewed feature candidate before any merge decision. Switch approval authorizes only the displayed rebuild command: merge remains a separate later decision, as do branch removal, checkout alteration, checkout return, and any reboot.

## Phase 7 — Audit, rollback, and handoff

1. Validate the current Phase 6 fingerprint and require all seven current phase fingerprints to match. Reconcile the ledger across all seven phases, including every command and exit status, skip reason, baseline, lock/input inventory, warning disposition, approval, diff, checkpoint, invalidation, and UAT result. The final audit must also capture the Phase 6 presentation hash and fresh approval, exact command reported by Sinh and its result, approved target plus active, next-boot, and currently booted generation identities, every required service observation, all failure and recovery evidence (or an explicit record that none occurred), and proof that the switch preceded any merge decision.
2. Validate non-privileged repository rollback only in a new disposable clone or equivalent isolated validation location, using the exact ledger-substituted Phase 6 repository command; never destructively change the authenticated ticket checkout. Prove that sequence returns to the recorded baseline lineage and original lock digest. Keep system rollback separate: only Sinh may run the exact ledger-substituted privileged rollback command, using the recorded local or console path after network loss, and must report its result and restored generation and service evidence.
3. Confirm all authorized changes are committed, the authenticated checkout is clean, all four host evaluations and the Drgnfly build are current, Phase 5 UAT passed, the approved Phase 6 switch and generation/service proof passed, and zero new warnings are undispositioned. Any missing or mismatched evidence blocks success and produces the bounded five-label diagnostic plus the exact fingerprint-bound rollback or recovery actions; never report partial success.
4. Publish the final branch, full HEAD, changed-path list, audit artifact, Phase 5 evidence, Phase 6 approval/command/result/generation/service/failure-recovery evidence, rollback evidence, switch-before-merge evidence, and recommendation. Keep merge authority separate: neither a passing switch nor this handoff approves merge, reboot, branch removal, checkout alteration, or checkout return.
5. Leave one committed, clean candidate at an exact Feature SHA ready for a separately authorized independent review. The reviewer, not the implementation agent, runs the ticket-approved Full Validation Matrix; acceptance requires 9 of 9 commands in order with exit status 0, Critical 0, Major 0, and rationale for every accepted or deferred Minor finding.
6. Perform matching, idempotent PA authority finalization. Finalization may clear only matching transient authority evidence; it must not merge, remove a branch, alter checkout contents, or return the checkout.
7. Preserve the checkout by default. Missing approval means retain, and only Sinh/operator may return the checkout after fresh explicit approval and the required identity, ownership, cleanliness, and durable-comment checks.

## Completion gate

The workflow is complete only when all seven current phase fingerprints match; the full refresh preserves declared inputs; flake check, four-host evaluation, and the Drgnfly build pass; every repair has exact prior approval and remains within the 5-file and 200-source-LoC bounds; Sinh reports passing Drgnfly UAT; the distinct Phase 6 presentation and fresh approval, exact reported command/result, target and active/next-boot/currently booted generation identities, critical-service observations, and any failure/recovery evidence all reconcile; repository and system rollback instructions retain their separate execution boundaries and the command audit is complete; zero new warnings are undispositioned; and the reviewed feature candidate was switched before any separate merge decision. Any failure or mismatch blocks completion and publishes the bounded five-label diagnostic with exact ledger-substituted rollback or recovery actions. Final handoff and matching PA finalization preserve separate Sinh authority for privileged execution, merge, reboot, branch removal, checkout alteration, and checkout return; absent fresh return approval, retain the checkout.
