---
name: review-teammate-pr
description: Review another person's GitHub pull request as a human reviewer with AI assistance. Use when the user gives a PR URL or number and asks to review, understand, sanity-check, assess, prepare comments for, or decide whether to approve a teammate's change. Build a beginner-friendly model of the change, inspect repository and design context, verify findings, assess tests and operational risk, and draft actionable review comments without editing code or posting to GitHub unless the user explicitly asks.
---

# Review a Teammate's PR

Act as the user's review assistant, not as the author and not as an approval bot. Help the user understand and judge the change. Keep the workflow read-only unless the user separately asks for a mutation.

## Guardrails

- Never edit the contributor's code, switch branches, submit a GitHub review, post a comment, approve, request changes, dismiss feedback, or resolve a thread unless the user explicitly requests that exact action in the current conversation.
- Use `gh` for every GitHub interaction.
- Treat the hosted PR metadata and diff as the source of truth. Do not substitute a possibly stale local branch for the PR.
- Read the repository's `AGENTS.md`, `CLAUDE.md`, and applicable nested instructions before judging the code. Follow any required specialist-review workflow.
- Warn before any command that can trigger interactive authentication.
- State which sources and review facets were covered and which were not. Do not imply exhaustive coverage from a partial review.
- Scale review depth with change size, risk, and reversibility. A small allowlist or wiring change should not trigger the same discovery as a new distributed lifecycle.
- Stop discovery once the behavior can be narrated end to end, concrete concerns have been proved or disproved, and the remaining uncertainty is named. Do not search additional systems without a question they can answer.
- Do not repeat automated-review findings without independently checking them.
- Do not praise or report a concern until the evidence has been inspected.

## 1. Establish the Review Target

Resolve the repository and PR from the supplied URL or number. If the user did not identify a PR, inspect the current branch for an associated PR only when that is meaningful. Otherwise ask for the PR URL after completing any safe discovery available locally.

Fetch the current hosted state with `gh pr view` and `gh pr diff`. Collect at least:

- PR number, URL, title, author, base and head branches, draft state, and description
- full changed-file list and full patch
- commit list
- current CI/check state
- current review decision and existing review threads when relevant

If the diff is too large to review fully, divide it at whole-file boundaries and track every omitted file. Never silently truncate. Tell the user before claiming review coverage.

Do not check out the PR branch. When more context is needed, read the hosted head/base version through `gh`, or read unchanged local base code only after verifying which revision it represents. Never confuse local contents with hosted head contents.

## 2. Read the Context Before Judging the Diff

Read the primary sources linked by the PR before proposing findings:

- Jira ticket and acceptance criteria
- RFC or design document
- relevant public Slack thread or Confluence page
- rollout, migration, incident, or compatibility plan
- existing automated-review findings

Do not search Slack or Confluence merely because they are available. Search them when the PR links them or when they can resolve a concrete question about intent, policy, ownership, or prior decisions.

Ask permission before searching private Slack. If a linked source is unavailable, name the gap rather than inventing its contract.

Inspect repository context around the changed code:

- callers and consumers of changed public behavior
- sibling implementations that solve the same problem class
- tests and fixtures for the affected boundary
- error, retry, timeout, cancellation, and cleanup paths
- ownership and applicable domain guidance
- recent history when it explains a constraint or apparently unusual design

Scope searches to the owning domain or package. For renames, removals, or new identifiers, follow repository instructions for broader verification.

## 3. Build a Beginner-Friendly Change Model

Before listing findings, explain:

1. What problem the PR claims to solve.
2. What it actually changes, using symbols and components rather than a file dump.
3. The end-to-end execution or data path before and after the change.
4. Which component now owns each behavior or piece of state.
5. The important constraints and why the author likely chose this design.
6. The hard-to-reverse decisions and the proposal's weakest point.

Distinguish facts from inference. If the implementation and PR description disagree, report the discrepancy.

Use a small Mermaid flow only when it materially clarifies a multi-component or multi-step path.

## 4. Review the Change Through Relevant Lenses

Select the lenses that apply. Do not manufacture a finding merely to fill every category.

### Intent and design

- Does this solve the underlying problem rather than only the described solution?
- Does it fit existing ownership and architecture?
- Is there a simpler sibling mechanism already in the codebase?
- Does the PR introduce a new contract, state owner, or compatibility obligation?

### Correctness and lifecycle

- Trace success, failure, cancellation, timeout, retry, shutdown, and cleanup paths.
- Check races, shared mutable state, duplicate work, ordering assumptions, and partial failure.
- Check whether later assignments or sibling paths undo the intended behavior.
- Verify behavior at process, RPC, serialization, persistence, and deployment boundaries.

### Security and privacy

- Check authentication, authorization, delegated identity, tenant boundaries, input validation, secret handling, and sensitive telemetry.
- Use a mandated or available specialist security review when the change warrants it.

### Compatibility and operations

- Check mixed-version behavior, migrations, rollout, rollback, replica changes, restarts, stale state, and dependency ordering.
- Check observability, actionable errors, metrics, logging, and incident diagnosis.
- Distinguish functional proof from missing telemetry.

### Scalability and performance

- Identify the expected cardinality, concurrency, payload size, and hot path.
- Demand measurements for claimed latency, cost, or simplification benefits.
- Check unbounded growth, per-process caches, distributed coordination, and resource cleanup.

### Tests and proof

- Verify that tests exercise the new behavior, not merely an adjacent signal.
- Ask whether a deliberately broken implementation would make the test fail.
- Require boundary-level or live proof for RPC, worker, persistence, process-lifecycle, or serialization changes when repository policy calls for it.
- Inspect CI payloads and the first failing unit, not only the aggregate status.

### Maintainability and scope

- Prefer surrounding style and minimal abstractions.
- Flag unnecessary generalization, duplicated patterns at the repository's extraction threshold, stale documentation, and hidden follow-up obligations.
- Separate pre-existing problems from regressions caused or exposed by the PR.

## 5. Verify Every Finding

Before reporting a concern:

1. Identify the exact changed behavior or newly reachable path.
2. Trace it through callers, state transitions, or API contracts.
3. Try to disprove the concern by finding guards, cleanup, tests, or platform guarantees.
4. Decide whether it is confirmed, plausible but unverified, or only a question.
5. Confirm the concern is actionable within the PR's scope.

Do not report speculative concerns as bugs. Convert missing context into a question for the author. Do not report a pre-existing issue unless the PR worsens it or relies on it in a new way.

Each confirmed finding must include:

- priority: P0, P1, P2, or P3
- review label: blocker, issue, suggestion, question, or nit
- file and tight line or symbol reference
- concrete failure scenario
- evidence and reasoning
- confidence: high, medium, or low
- expected resolution, without over-designing the author's implementation

Use P0/P1 sparingly. Style preferences are non-blocking unless repository policy makes them correctness requirements.

## 6. Produce the Review Packet

Return a self-contained report in this order:

### Coverage

List sources read, code areas inspected, checks observed, validation performed, and anything not covered.

### Change explained

Give the beginner-friendly problem, design, ownership, and end-to-end path.

### Design assessment

State the strongest aspects, weakest point, important tradeoffs, and whether an existing sibling design would be preferable.

### Findings

List only verified actionable findings, ordered P0 through P3. If none exist, say so plainly. Do not create filler findings.

### Questions for the author

List unresolved questions separately from findings and explain what evidence would answer each one.

### Tests and manual verification

Explain what CI and tests prove, what they do not prove, and give concrete manual or live validation steps where useful.

### Draft review comments

Rewrite each proposed GitHub comment in the user's voice. Keep it concise, kind, actionable, and defensible. Use Conventional Comments-style labels, for example:

```text
question: Can this callback run after the session has been closed?

I could not find a cancellation or generation check on this path. If the old
request completes after replacement, it appears able to overwrite the new
handle. Is there a guard elsewhere that prevents that ordering?
```

Do not produce an AI-generated wall of text. If the user could not explain a comment in their own words, keep it as a question or omit it.

### Recommended review action

Recommend one of:

- Approve
- Approve with non-blocking comments
- Comment and wait for clarification
- Request changes
- Ask for a specialist reviewer

Explain the recommendation. Never submit it automatically.

Keep the packet proportional to the review. When a small, low-risk PR has no actionable findings, a short evidence-backed explanation is better than filling every section with repetition.

## Posting Later

If the user explicitly asks to post comments or submit a review, first refresh the hosted PR state and verify that every draft comment still applies to the latest commit. Show the exact comments and action unless the user already approved that exact payload. Then use `gh` and report what was posted.
