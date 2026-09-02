# Drgnfly Flake Lock Refresh and Approval-Gated Repair Implementation Tasks

## Task Overview

This document turns the approved external requirements and repository-local design into dependency-ordered work for the full Drgnfly-focused `flake.lock` refresh. Work stops at every approval boundary and fails closed on repository, fingerprint, declaration, warning, repair-size, UAT, or rollback discrepancies.

**Total Estimated Tasks**: 26 tasks organized into 6 phases

**Requirements Reference**: `/home/sinh/Documents/ai-usage/agent-teams/requirements/artifacts/2026-08-31-drgnfly-flake-update-orchestration.md`

**Design Reference**: `.kiro/specs/flake-update-orchestration/design.md`

**Branch**: `feature/NX-042-flake-update-drgnfly`

**Approval order**: approved external requirements → approved design → approved tasks → lock refresh → per-repair approval → Sinh-run UAT → Sinh final merge/application decision.

## Mandatory Execution and Evidence Contract

Every task below inherits these rules:

1. Agents must not run `sudo` or another privileged command, push, merge, activate a live system, change ticket lifecycle state, alter an external-input repository, or alter declared input URLs, branches, tags, refs, follows relationships, or intentional pins.
2. Before **every** phase, revalidate the latest persisted resume fingerprint. A passed result is reusable only if all recorded fields match fresh read-only observations. Reuse zero stale results.
3. For every command, including read-only commands, record the phase/task ID, sequence, working directory, exact command, start/end timestamp, exit code, stdout/stderr or persistent log references, changed files before/after, warnings, warning dispositions, decision, and skip reason when a gated command is not run. Record approval text/identifier, approver, timestamp, artifact hash, and scope at every gate.
4. Persist exactly one consolidated `ResumeFingerprint` after each of the six phases with: phase ID/state; target branch and HEAD; current `flake.lock` SHA-256; all three local-input HEADs; four expected clean/allowlisted worktree states; allowed changed files; SHA-256 values for relevant Kiro/source files; approvals; warning state; and local commit IDs.
5. Fingerprint mismatch handling is deterministic: repository identity/branch, local-input HEAD/clean state, Kiro document hash, or Kiro approval mismatch invalidates Phase 1 onward; warning-baseline or pre-refresh declaration evidence mismatch invalidates Phase 2 onward; refreshed lock/declaration/inventory mismatch invalidates Phase 2 onward; verification command/source fingerprint mismatch invalidates Phase 3 onward; repair diff/approval/commit mismatch invalidates the affected Phase 4 batch and all later evidence; UAT evidence mismatch invalidates Phase 5 onward; audit/rollback/routing-fixture mismatch invalidates Phase 6. Record the mismatched fields, invalidated task IDs, and restart phase before rerunning anything.
6. An unexpected changed file is never cleaned, reset, committed, or accepted automatically. Stop and report its path/status. Any source repair requires a proposal for exactly one root cause, recorded explicit Sinh approval before mutation, and hard limits of at most 5 files and 200 source LoC. Generated `flake.lock` lines and approved Kiro documents are excluded from the source-LoC count.
7. Every new warning relative to the Phase 2 baseline must end as `fixed`, `accepted by Sinh` (with recorded rationale), or `blocking`. Final success permits zero undispositioned new warnings.
8. Local commits may be created only where tasks below explicitly require them and only after applicable Sinh approval and verification. Do not create empty commits. Sinh retains final merge/application authority.

## Recorded Phase 1 Baseline Values

These historical values must remain in the audit and be compared with fresh observations; they must not be silently replaced:

| Repository | Branch | HEAD | Recorded clean state |
|---|---|---|---|
| `/home/sinh/git-repos/sinh-x/personal-nixos` | `feature/NX-042-flake-update-drgnfly` | `8a96151a684d44a8818c068d93b97123a9e57ca2` | clean before approved Kiro documents |
| `/home/sinh/git-repos/andafin/infrastructure/andafin-jira-mcp` | `feature/bitbucket-cloud-integration` | `331314d76885dcd96c241c7cc5a9ecf4dc3c9774` | clean |
| `/home/sinh/git-repos/sinh-x/tools/personal-google-mcp` | `feat/cli-tools` | `3cb65b0bbf5d1df2cf0e4e87788dec656e9dbbac` | clean |
| `/home/sinh/git-repos/sinh-x/tools/pa-platform` | `develop` | `6a746a8aabb1ab4e4f744752ab87f29e69760601` | clean |

Original `flake.lock` SHA-256: `a0344883aa29c65b7dab6b2d8967705618e985fcaf2266e994d8ad03e88d6ab3`.

After approved Kiro document creation, the target repository may match only the explicit phase allowlist and recorded document hashes; the other three repositories must remain clean. Historical clean-baseline evidence remains unchanged.

## Implementation Tasks

### Phase 1: Preflight and Kiro Approval

- [ ] **1.1 [CRITICAL] Revalidate repository ownership and baseline fingerprints**
  - **Description**: Confirm the canonical path, Git top level/common directory, feature branch, canonical mutation-lock metadata, and NX-042 ownership. For all four repositories, record existence, top-level identity, branch, HEAD, and full porcelain status. Recompute the original lock digest and compare every observation with the recorded values above. In the target repository, permit only the approved Kiro-document allowlist and verify hashes; require the three local inputs to remain clean.
  - **Deliverables**: Phase 1 preflight ledger; four-repository manifest; original-lock digest comparison; exact changed-file allowlist.
  - **Verification**: Every read-only command exits 0; identities and recorded fingerprints match; no unexpected changed file exists. This is the earliest verification point for AC-1 and AC-7.
  - **Blocked path**: Stop before further writes on a missing/non-Git/wrong-top-level/dirty repository, wrong branch, wrong lock owner, unexpected file, or fingerprint mismatch. Do not switch branches, reset, clean, or repair state.
  - **Requirements**: FR-1, FR-6, FR-8; NFR-1, NFR-2, NFR-5, NFR-7; AC-1, AC-7, AC-8.
  - **Dependencies**: Approved external requirements and approved design; canonical lock owned by the recorded orchestrator.

- [ ] **1.2 [CRITICAL] Record Kiro approval provenance and obtain tasks approval**
  - **Description**: Record the approved external requirements reference and design approval comment `c-20260831162510483`. Present this `tasks.md` with its SHA-256 to Sinh and wait for an explicit decision tied to this exact artifact. Approval of design or another document does not approve these tasks.
  - **Deliverables**: Requirements/design/tasks hashes; design approval evidence; explicit tasks approval or terminal waiting/declined disposition.
  - **Verification**: The design approval predates `tasks.md`; an explicit tasks approval identifies the reviewed artifact and predates every Phase 2 command.
  - **Blocked path**: Until tasks approval is recorded, run no Nix baseline probe, lock refresh, build, evaluation, test, formatter, source edit, or commit. A declined or missing decision leaves the workflow `awaiting Sinh tasks approval`.
  - **Requirements**: FR-2, FR-8; NFR-1, NFR-2; AC-8.
  - **Dependencies**: Task 1.1.

- [ ] **1.3 Create the approved Kiro checkpoint and Phase 1 resume fingerprint**
  - **Description**: Only after Task 1.2 approval, create one local checkpoint commit containing only the approved `design.md` and `tasks.md`, record its ID/diff, recheck the four repositories, and persist the consolidated Phase 1 fingerprint. Do not push or merge.
  - **Deliverables**: Approved-Kiro local commit; commit diff and ID; one Phase 1 resume fingerprint.
  - **Verification**: Commit contains exactly the two approved Kiro files; original lock digest still matches; three local inputs remain clean; post-commit target status matches its explicit allowlist.
  - **Requirements**: FR-2, FR-6, FR-8; NFR-1, NFR-2, NFR-5, NFR-7; AC-1, AC-7, AC-8.
  - **Dependencies**: Task 1.2 with explicit Sinh tasks approval.

### Phase 2: Baseline and Full Lock Refresh

- [ ] **2.1 [CRITICAL] Validate Phase 1 fingerprint and capture no-write baseline**
  - **Description**: Match the complete Phase 1 fingerprint, then capture pre-refresh warnings and no-write evaluation evidence. Every Nix probe must use `--no-write-lock-file`; include the repository flake check and toplevel evaluation for Drgnfly, Elderwood, FireFly, and Lily. Fingerprint `flake.nix`, its declared inputs/follows data, relevant source files, and the pre-refresh lock.
  - **Deliverables**: Fingerprint-validation result; baseline command logs/exit codes; warning inventory; host-evaluation baseline; pre-refresh declaration manifest.
  - **Verification**: No baseline probe changes `flake.lock` or another file; command and warning evidence is complete even when a probe fails.
  - **Blocked path**: A fingerprint mismatch routes to the mapped earliest phase. A baseline failure is classified and recorded; it is not repaired in this task.
  - **Requirements**: FR-3, FR-6, FR-8; NFR-2, NFR-5, NFR-6; AC-2, AC-3, AC-7, AC-8.
  - **Dependencies**: Task 1.3.

- [ ] **2.2 [CRITICAL] Perform the single full lock-graph refresh and guard declarations**
  - **Description**: Run the explicit full `nix flake update` once, non-privileged and only after all preceding gates pass. Capture pre/post lock hashes, command output, exit code, changed-file lists, and complete diff. Compare the pre/post `flake.nix` hash and normalized declaration manifest to prove URLs, branches, tags, refs, follows relationships, and intentional pins are unchanged.
  - **Deliverables**: Refreshed `flake.lock`; refresh ledger/log; pre/post lock hashes; declaration-preservation comparison.
  - **Verification**: Only `flake.lock` changes in this task and declared inputs are byte/semantically unchanged. This is the earliest verification point for AC-2.
  - **Blocked path**: If a declaration change is present or required, stop as out of scope and route to requirements review. Do not edit `flake.nix` or rerun a narrower/alternative update to mask the result.
  - **Requirements**: FR-3, FR-8; NFR-1, NFR-2; AC-2, AC-8.
  - **Dependencies**: Task 2.1 completed with a matching fingerprint.

- [ ] **2.3 Inventory changed roots and disposition warning deltas**
  - **Description**: For every changed root input, report old/new revision and content/NAR hash (or explicitly record why a field is not applicable), and distinguish root from transitive churn. Compare update output/warnings with Task 2.1 baseline and assign each new warning `fixed`, explicit-Sinh-accepted with rationale, or `blocking`.
  - **Deliverables**: Complete changed-root-input inventory; transitive-change summary; warning delta and dispositions.
  - **Verification**: Inventory coverage reconciles to the lock diff; no new warning lacks a disposition. This is the earliest verification point for AC-3.
  - **Blocked path**: An undispositioned warning blocks the phase. Warning acceptance requires Sinh's explicit decision; an agent may not infer acceptance.
  - **Requirements**: FR-3, FR-8; NFR-2, NFR-6; AC-3, AC-8.
  - **Dependencies**: Task 2.2.

- [ ] **2.4 Commit the lock refresh and persist the Phase 2 resume fingerprint**
  - **Description**: Commit only the generated, verified `flake.lock` refresh, record the commit ID/diff, recheck all four repositories, and persist one consolidated Phase 2 fingerprint including baseline logs, declaration manifest, warning inventory, and changed-input inventory hashes.
  - **Deliverables**: Local lock-refresh commit; commit evidence; one Phase 2 resume fingerprint.
  - **Verification**: Commit contains only `flake.lock`; declared-input guard remains equal; target status and local-input clean states match expectations.
  - **Requirements**: FR-3, FR-6, FR-8; NFR-2, NFR-5, NFR-6; AC-2, AC-3, AC-7, AC-8.
  - **Dependencies**: Task 2.3 with zero undispositioned warnings.

### Phase 3: Non-Privileged Verification and Diagnosis

- [ ] **3.1 [CRITICAL] Validate the Phase 2 resume fingerprint**
  - **Description**: Freshly compare every Phase 2 fingerprint field before reusing baseline/update evidence or starting expensive checks.
  - **Deliverables**: Field-by-field match report or invalidation record naming the earliest restart phase.
  - **Verification**: Reused evidence has a complete match; mismatched evidence is marked invalid and not cited as passing.
  - **Requirements**: FR-6, FR-8; NFR-2, NFR-5; AC-7, AC-8.
  - **Dependencies**: Task 2.4, or the latest approved Phase 4 loop checkpoint.

- [ ] **3.2 Run aggregate flake checks**
  - **Description**: Run `nix flake check --no-write-lock-file`, record full logs and exit code, and prove it does not mutate the lock/worktree.
  - **Deliverables**: Flake-check log; changed-file before/after evidence; warning delta.
  - **Verification**: Exit code is 0 for a passing path; all warnings are dispositioned. This begins AC-4 verification.
  - **Requirements**: FR-4, FR-8; NFR-2, NFR-6; AC-3, AC-4, AC-8.
  - **Dependencies**: Task 3.1.

- [ ] **3.3 Evaluate all four NixOS toplevels**
  - **Description**: Evaluate Drgnfly, Elderwood, FireFly, and Lily toplevel derivations separately with `--no-write-lock-file`, retaining one command/exit/log record per host. Make no physical/runtime claim for Elderwood, FireFly, or Lily.
  - **Deliverables**: Four host-evaluation records and warning deltas.
  - **Verification**: All four evaluations exit 0 and leave the worktree unchanged.
  - **Requirements**: FR-4, FR-8; NFR-2, NFR-6; AC-3, AC-4, AC-8.
  - **Dependencies**: Task 3.2.

- [ ] **3.4 Build the Drgnfly toplevel without a result symlink**
  - **Description**: Run `nix build --no-link --no-write-lock-file .#nixosConfigurations.Drgnfly.config.system.build.toplevel --max-jobs 4 --cores 2`. Record any resource override request and rationale before use; an override must be operator-approved and logged.
  - **Deliverables**: Drgnfly build log/exit code; no-link proof; resource settings and warning delta.
  - **Verification**: Build exits 0, creates no `result` symlink, changes no repository file, and all Task 3.2–3.4 commands pass. This completes the automated verification for AC-4.
  - **Requirements**: FR-4, FR-8; NFR-2, NFR-4, NFR-6; AC-3, AC-4, AC-8.
  - **Dependencies**: Task 3.3.

- [ ] **3.5 Diagnose failures without editing source and select the next route**
  - **Description**: If Tasks 3.2–3.4 fail, preserve evidence and classify each failure as environmental/dependency or source/configuration. For a source failure, identify one root cause and prepare proposal inputs only; make no edit. Environmental failures may be retried only after the named dependency recovers. If all checks pass, route directly to Phase 5.
  - **Deliverables**: Root-cause diagnosis; retry evidence or Phase 4 proposal input; deterministic route (`Phase 4` or `Phase 5`).
  - **Verification**: Diagnosis cites the failing command/log and rules out speculative unrelated cleanup. No source mutation occurred.
  - **Blocked path**: A declared-input/upstream/external-repository fix routes to requirements. An unresolved environment dependency stays blocked. A source repair routes to Task 4.1 only.
  - **Requirements**: FR-5, FR-8; NFR-1, NFR-2; AC-5, AC-8.
  - **Dependencies**: Tasks 3.2–3.4 attempted and fully recorded.

- [ ] **3.6 Persist the Phase 3 resume fingerprint**
  - **Description**: Persist one consolidated Phase 3 fingerprint containing all check/evaluation/build logs, source hashes, warning dispositions, diagnosis, and selected route.
  - **Deliverables**: One Phase 3 resume fingerprint; phase pass/fail/block disposition.
  - **Verification**: Fingerprint references every Phase 3 command and zero undispositioned new warnings on the passing route.
  - **Requirements**: FR-6, FR-8; NFR-2, NFR-5, NFR-6; AC-3, AC-4, AC-7, AC-8.
  - **Dependencies**: Task 3.5.

### Phase 4: Sinh-Approved Repairs

- [ ] **4.1 [CRITICAL] Prepare one bounded repair proposal and wait for Sinh**
  - **Description**: Validate the Phase 3 fingerprint. Prepare a proposal for exactly one diagnosed root cause naming affected files, proposed diff, source-LoC count, targeted checks, aggregate Phase 3 rechecks, risks, and rollback. Prove the proposal touches at most 5 files and 200 source LoC, excludes external-input repositories/unrelated cleanup/protected machine state, and preserves declared refs. Obtain explicit Sinh approval tied to this exact proposal/hash.
  - **Deliverables**: Repair proposal; file/LoC calculation; proposed diff; explicit approval or terminal declined/blocked record.
  - **Verification**: Approval predates any mutation and covers the exact diff/scope. This is the earliest verification point for AC-5.
  - **Blocked path**: Missing approval means zero source edits. More than 5 files or 200 source LoC blocks for revised Kiro plan and approval. Declared-ref, upstream, external-input, protected-state, or live-network/storage changes route to requirements and are never applied here.
  - **Requirements**: FR-5, FR-6, FR-8; NFR-1, NFR-2, NFR-3, NFR-5; AC-5, AC-7, AC-8.
  - **Dependencies**: Task 3.6 selected the Phase 4 route.

- [ ] **4.2 Apply only the approved repair diff and format only changed Nix files**
  - **Description**: After approval, revalidate proposal/source hashes, apply only the approved diff, recount files and source LoC from the actual diff, and run `nixfmt` only on Nix files changed by that batch. Record formatter-induced diff separately and stop if it expands beyond approved scope.
  - **Deliverables**: Actual approved source diff; before/after file lists; actual file/LoC count; formatting ledger.
  - **Verification**: Actual mutation remains within the approved proposal, 5-file limit, and 200-source-LoC limit; declarations and external inputs remain unchanged.
  - **Blocked path**: Scope drift, formatter spillover, or limit breach stops before commit and requires a revised proposal/approval; do not normalize unrelated files.
  - **Requirements**: FR-5, FR-8; NFR-1, NFR-2, NFR-3; AC-5, AC-8.
  - **Dependencies**: Task 4.1 with explicit Sinh approval.

- [ ] **4.3 Run targeted checks and the full aggregate verification sequence**
  - **Description**: Run the proposal's targeted checks, then repeat Tasks 3.2–3.4 in full with the same no-write/no-link/resource constraints. Recompute warning deltas and dispositions.
  - **Deliverables**: Targeted-check logs; complete aggregate recheck logs; warning dispositions; changed-file proof.
  - **Verification**: Targeted checks and all Phase 3 blocking checks exit 0; no unapproved worktree change or undispositioned warning remains.
  - **Blocked path**: A failed recheck returns to non-editing diagnosis in Task 3.5. A new root cause requires a new Task 4.1 proposal and approval; existing approval cannot be reused.
  - **Requirements**: FR-4, FR-5, FR-8; NFR-1, NFR-2, NFR-3, NFR-6; AC-3, AC-4, AC-5, AC-8.
  - **Dependencies**: Task 4.2.

- [ ] **4.4 Commit the repair batch and persist the Phase 4 fingerprint**
  - **Description**: Create one local commit containing only the approved, verified batch. Record commit ID/diff/approval linkage and persist one consolidated Phase 4 fingerprint. Return through Task 3.1 so aggregate results are reused only after matching the new checkpoint; repeat Phase 4 once per separately approved root cause.
  - **Deliverables**: One local repair commit; approval-to-diff-to-commit evidence; one Phase 4 fingerprint per completed loop.
  - **Verification**: Commit scope equals approved scope; file/LoC limits hold; repository status and all three local-input states match expectations.
  - **Requirements**: FR-5, FR-6, FR-8; NFR-1, NFR-2, NFR-3, NFR-5; AC-5, AC-7, AC-8.
  - **Dependencies**: Task 4.3 passes.

### Phase 5: Sinh-Run Drgnfly UAT

- [ ] **5.1 [CRITICAL] Validate the latest automated-pass fingerprint and UAT readiness**
  - **Description**: Match the latest Phase 3/4 fingerprint and prove flake check, four evaluations, Drgnfly no-link build, and warning dispositions are current. Verify activity evidence contains zero agent-run privileged commands.
  - **Deliverables**: UAT-readiness checklist and fingerprint match report.
  - **Verification**: All non-privileged blockers pass and zero new warnings are undispositioned.
  - **Blocked path**: Any mismatch returns to the earliest invalidated phase; any missing automated pass blocks UAT handoff.
  - **Requirements**: FR-6, FR-7, FR-8; NFR-1, NFR-2, NFR-5, NFR-6; AC-6, AC-7, AC-8.
  - **Dependencies**: Passing Task 3.6 after any Phase 4 loops.

- [ ] **5.2 Give Sinh exact privileged test and rollback instructions**
  - **Description**: Prepare copyable commands for Sinh, including `cd /home/sinh/git-repos/sinh-x/personal-nixos && sudo sys test`, plus exact verified system and repository rollback commands tied to the recorded baseline/phase commits. Explain what each command does, identify critical services to observe, and clearly label every privileged command as Sinh-run only. Agents must not execute these commands.
  - **Deliverables**: Operator handoff with exact test/rollback commands, expected observations, commit IDs, and original lock digest.
  - **Verification**: Commands target Drgnfly/current approved checkout, rollback identifiers exist, and activity still proves zero agent-run privileged commands.
  - **Requirements**: FR-7, FR-8; NFR-1, NFR-2; AC-6, AC-8.
  - **Dependencies**: Task 5.1.

- [ ] **5.3 Wait for and record Sinh's Drgnfly UAT result**
  - **Description**: Record Sinh's exact command, exit code/result, timestamp, and observations for connectivity, display/session, boot-critical services, and any other identified critical service. Do not infer success from silence. A failure returns to Task 3.5 diagnosis and, if source edits are required, a new Task 4.1 approval gate.
  - **Deliverables**: Sinh-reported UAT evidence; pass/fail/block disposition; rollback outcome if used.
  - **Verification**: Final-success routing is allowed only after Sinh reports `sudo sys test` passed on Drgnfly without a critical service regression. This is the earliest and completing verification point for AC-6.
  - **Blocked path**: Missing report remains blocked; failed UAT prevents success and routes through diagnosis; agents never run the retry or rollback command.
  - **Requirements**: FR-7, FR-8; NFR-1, NFR-2; AC-6, AC-8.
  - **Dependencies**: Task 5.2.

- [ ] **5.4 Persist the Phase 5 resume fingerprint**
  - **Description**: Persist one consolidated Phase 5 fingerprint with readiness hashes, exact handoff, Sinh's report, critical-service observations, privileged-command ownership proof, and phase disposition.
  - **Deliverables**: One Phase 5 resume fingerprint.
  - **Verification**: Fingerprint links to current commits/lock/source hashes and explicit UAT evidence; failure/block state cannot be represented as success.
  - **Requirements**: FR-6, FR-7, FR-8; NFR-1, NFR-2, NFR-5; AC-6, AC-7, AC-8.
  - **Dependencies**: Task 5.3.

### Phase 6: Audit, Rollback, and Reusable Handoff

- [ ] **6.1 [CRITICAL] Validate Phase 5 and complete the persistent audit**
  - **Description**: Match the Phase 5 fingerprint and reconcile the ledger against all six phases. The persistent implementation audit must include 100% of commands/exit codes, before/after changed files, skipped gated commands/reasons, four-repository baseline, original lock digest, changed-input inventory, warning baseline/deltas/dispositions, diffs, approvals, local commit IDs, fingerprints/invalidation events, UAT evidence, rollback instructions, and final disposition.
  - **Deliverables**: Persistent audit artifact and 100%-complete reconciliation checklist.
  - **Verification**: No ledger gap, undispositioned warning, unexplained diff, missing approval, or missing terminal blocked path remains. This begins final AC-8 verification.
  - **Blocked path**: Any missing evidence blocks completion; do not reconstruct or invent command results, approvals, exit codes, or timestamps.
  - **Requirements**: FR-8; NFR-2, NFR-5, NFR-6, NFR-7; AC-8.
  - **Dependencies**: Passing Task 5.4.

- [ ] **6.2 Validate repository rollback in a disposable clone**
  - **Description**: Create a disposable clone outside the canonical checkout, check out the final local checkpoint, execute the documented non-privileged repository rollback sequence there, and verify the resulting tree/commit lineage and `flake.lock` SHA-256 return to the recorded baseline. Do not test rollback by mutating the canonical checkout. Record clone creation, commands, exit codes, before/after diffs, and cleanup disposition.
  - **Deliverables**: Disposable-clone rollback log; verified rollback instructions; original-lock digest proof.
  - **Verification**: Rollback succeeds in the clone and produces lock digest `a0344883aa29c65b7dab6b2d8967705618e985fcaf2266e994d8ad03e88d6ab3`; canonical checkout is unchanged. This completes rollback verification for AC-8.
  - **Blocked path**: A rollback mismatch blocks final recommendation and requires corrected instructions/reverification. Agents run no privileged system rollback.
  - **Requirements**: FR-8; NFR-1, NFR-2, NFR-7; AC-8.
  - **Dependencies**: Task 6.1.

- [ ] **6.3 Exercise routine-update eligibility offline with conforming and exception fixtures**
  - **Description**: Without creating or changing a live ticket, evaluate two written fixtures against the §16 eligibility rule in the approved requirements. The conforming fixture must include the ISO run date, repository/baseline branch, ticket-based target branch, full-refresh/ref-preservation policy, Drgnfly blocking role, three evaluation-only hosts, all three clean local-input paths, Sinh approval/test roles, AC-1–AC-9, all six phases, baseline requirements doc-ref, route/class, and `Exceptions: none`. The exception fixture must omit one required field or declare an exception.
  - **Deliverables**: Two offline fixture bodies; field-by-field decision table; expected route for each; proof that no live ticket was created.
  - **Verification**: Conforming fixture deterministically routes to `builder/implement` without new requirements analysis; exception fixture routes to requirements review. This is the earliest and completing verification point for AC-9.
  - **Requirements**: FR-9; NFR-2; AC-9.
  - **Dependencies**: Task 6.2.

- [ ] **6.4 Record the final checkpoint and persist the Phase 6 fingerprint**
  - **Description**: Ensure every authorized repository change is already in a verified local commit. If authorized verified changes remain, create one final local checkpoint commit containing only those changes; otherwise designate the latest verified phase commit as the final checkpoint rather than creating an empty commit. Persist one consolidated Phase 6 fingerprint including audit, rollback, and offline-routing evidence.
  - **Deliverables**: Final local checkpoint ID/diff; one Phase 6 resume fingerprint; clean/allowlisted state report for all four repositories.
  - **Verification**: Final checkpoint contains no unauthorized change; all six phase fingerprints exist; no stale result is cited; audit and rollback references resolve.
  - **Requirements**: FR-6, FR-8, FR-9; NFR-2, NFR-5; AC-7, AC-8, AC-9.
  - **Dependencies**: Task 6.3.

- [ ] **6.5 Issue the bounded final recommendation and stop for Sinh's decision**
  - **Description**: Report success, blockage, or rollback recommendation based only on recorded evidence. A success recommendation requires passing non-privileged checks, Sinh-reported passing UAT, verified rollback, complete audit, and zero undispositioned new warnings. Provide exact changed-file and commit evidence, then wait for Sinh's final merge/application decision.
  - **Deliverables**: Final disposition/recommendation; exact changed-file/commit summary; explicit final decision gate.
  - **Verification**: AC-1–AC-9 traceability is complete and AC-8 audit completeness is 100%. No agent push, merge, privileged application, or ticket-lifecycle transition occurs.
  - **Blocked path**: Any failed criterion results in a blocked/rollback recommendation, never partial success. Only Sinh may authorize merge or application.
  - **Requirements**: FR-1–FR-9; NFR-1–NFR-7; AC-1–AC-9.
  - **Dependencies**: Task 6.4.

## Acceptance-Criteria Traceability and Earliest Verification

| Acceptance criterion | Implementing/verifying tasks | Earliest verification point | Completion point |
|---|---|---|---|
| AC-1 | 1.1, 1.3 | 1.1 repository/baseline gate | 1.3 Phase 1 checkpoint |
| AC-2 | 2.1, 2.2, 2.4 | 2.2 post-refresh declaration guard | 2.4 lock checkpoint |
| AC-3 | 2.1, 2.3, 3.2–3.4, 3.6, 4.3 | 2.3 root-input/warning reconciliation | 6.1 final audit reconciliation |
| AC-4 | 3.2–3.4, 4.3 | 3.2 aggregate flake check | 3.4, repeated by 4.3 after repairs |
| AC-5 | 3.5, 4.1–4.4 | 4.1 proposal/approval/limit gate | 4.4 approved repair checkpoint |
| AC-6 | 5.1–5.4 | 5.3 explicit Sinh UAT result | 5.4 Phase 5 fingerprint |
| AC-7 | 1.1, 1.3, 2.1, 2.4, 3.1, 3.6, 4.1, 4.4, 5.1, 5.4, 6.4 | 1.1 mismatch invalidation gate | 6.4 six-fingerprint audit |
| AC-8 | Every task; 6.1–6.2, 6.4–6.5 | 1.1 command ledger begins | 6.2 rollback proof and 6.5 final audit disposition |
| AC-9 | 6.3–6.5 | 6.3 offline fixtures | 6.5 final handoff |

## Definition of Done

The workflow is done only when:

1. All six phases have one persisted, matching resume fingerprint and all invalidations/reruns are recorded.
2. The complete lock refresh preserves every declared input URL/ref/pin and every changed root input is inventoried.
3. Flake check, all four host evaluations, and the no-link Drgnfly build pass on the final fingerprint.
4. Every repair was separately approved before mutation and stayed within 5 files/200 source LoC.
5. Sinh reports passing Drgnfly UAT without critical regression; agents ran zero privileged commands.
6. Zero new warnings are undispositioned.
7. Audit completeness and disposable-clone rollback verification pass, and the two offline routine-ticket fixtures route correctly.
8. All authorized changes have local checkpoint evidence; agents have not pushed, merged, or applied the system.
9. The final handoff is waiting for Sinh's merge/application decision.

---

**Task Status**: Awaiting Approval

**Current Phase**: Phase 1 — explicit Sinh tasks approval gate

**Overall Progress**: 0/26 implementation tasks completed

**Last Updated**: 2026-08-31

**Assigned Developer**: PA builder under NX-042 orchestration
