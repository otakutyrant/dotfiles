# Security audit ledger

This ledger preserves audit progress and evidence across version changes and
workspace cleanup. Inventory maintenance is allowed without an audit request;
auditing an entity requires an explicit user request. No new audit was started
on 2026-10-31. The ordered queue is [inventory.md](inventory.md), with exact
identities and declaration details in [inventory.json](inventory.json).

## Status and evidence rules

- Pending: inventoried, with no coverage of the current identity.
- In progress: explicitly authorized audit running in `codex-sandbox` under
  `~/tmp`, with a bounded independent `kimi-sandbox` audit when quota is
  available. Workers may run concurrently on the same entity in separate
  workspaces; record authorization scope and each worker command.
- Completed: manual review and an appropriate external scanner finished, with no
  critical issue identified within the documented scope.
- Partial: reusable evidence exists, but scope, version, or required scanning
  coverage is incomplete. This does not establish current-version coverage.
- Blocked: a required audit step cannot proceed; record why and the next step.
- Critical found: malicious behavior, a critical vulnerability, or a critical
  least-privilege violation; report immediately and pause the queue.
- Retired: declaration removed; archive in place, record the removal date, and
  exclude it from the active queue. Preserve its inventory identity, ledger
  entries, audit results, reports, evidence, and links.

Each audit entry records its stable entity ID, current and audited versions or
revisions, source/artifact identity, start and finish dates, authorization,
scope, worker workspace and launcher, progress, scanner evidence, result,
limitations, next step, and cleanup. Preserve completed entries when a new
version is declared. Non-critical findings are skipped; use an aggregate note
rather than a finding backlog. Scanner execution failures or unsupported input
cannot count as clean.

Record Kimi quota availability evidence, its independent scope and result, or
the reason it was skipped. Give Kimi a fresh session and matching source inputs
without disclosing the Codex audit or exposing its prompts, progress, findings,
reports, or scanner outputs. Preserve each worker's evidence separately and
reconcile conclusions after both independent reviews finish. Report critical
findings immediately. Missing Kimi quota alone does not make a Codex audit
incomplete.

## Fresh audit baseline

On 2026-10-31, the user explicitly requested removal of the inherited result and
a full restart from scratch. No prior audit results are retained in this ledger
or credited toward coverage. All inventory entities are pending. This reset does
not authorize an entity audit; wait for an explicit audit request.

## Template for the next authorized audit

Copy this template only when an entity audit is explicitly requested. It is not
a completed or in-progress audit record.

- Entity ID and declaration:
- User authorization and requested scope:
- Priority and exposure rationale:
- Current version/revision and artifact/source hashes:
- Audited version/revision and artifact/source hashes:
- Start date/time and finish date/time (with timezone):
- Dedicated `~/tmp` workspace and trusted launcher command:
- Kimi quota evidence, independent launcher/scope/result, or skip reason:
- Separate workspace paths, matching input identities, and Kimi session
  isolation:
- Reconciliation of Codex and Kimi conclusions, when both ran:
- Manual review scope and progress:
- Scanner name/version, command, database timestamp, exit status, coverage:
- Sanitized evidence and report links:
- Critical result and immediate notification, if applicable:
- Aggregate non-critical findings skipped:
- Status, limitations, and next step:
- Workspace cleanup outcome/date, or retention reason:
