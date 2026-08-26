# AGENTS.md

Cross-tool agent rules (Claude Code, Cursor, etc). This file is the single source of
truth; tool-specific configs import it rather than duplicating it.

## General Guidelines
- No em dashes - use a plain dash "-" instead. This covers every user-visible
  surface, chat replies included, not just committed artifacts.
- Weigh technical decisions on quality, simplicity, robustness, scalability, and
  long-term maintainability over development cost.
- For bug fixes, reproduce the bug in an E2E setting matching the end user's
  experience first, so the fix addresses the real problem. On a stale ticket,
  confirm the bug still reproduces at all before designing a fix - the system may
  have moved on.

## Code Style
- Clean, minimal code. Readability > cleverness.
- No over-engineering: no unnecessary abstractions, error handling, or features
  beyond what's asked.
- Mimic the code style of the surrounding modules.
- Comments carry only what the code cannot: a non-obvious why, a hazard, a
  constraint. No ticket keys, no restating the line below, no narrating a test whose
  name already says what it asserts, no repeating the same rationale at two call
  sites, no justifying alternatives you rejected (that belongs in the PR body).
- After renames/refactors, grep the whole repo for the old name - including docs,
  help text, and inline strings, not just code. Symmetrically, grep for a *new*
  identifier before introducing it: a sibling file in the same package may already
  define that name, and the build failure costs more than the grep.
- Extract shared code on the 3rd duplicated instance of a pattern, not before. Two
  copies are fine; three means extract now.
- Verify platform capabilities before designing around them - try the command or
  read the source, don't rely on `--help` alone. This covers OS and filesystem
  behavior too (temp-dir cleanup policy, file-age thresholds), not just CLI flags:
  check the actual policy rather than answering from memory. Treat announced or
  promised behavior as unshipped until the current system demonstrates it; prefer
  observed behavior over a vendor's future-tense description.
- Guard platform-specific commands (`open`, `pbcopy`, `stat -f`, `date -j`) with
  `command -v` checks in shell scripts. Don't assume the BSD variant on darwin
  either - GNU coreutils often shadows it on PATH, so BSD-only flags (`date -v`)
  fail there too. Prefer portable epoch arithmetic or a language runtime. Two
  darwin traps that fail *silently* rather than erroring: BSD `sed` does not
  support `\b` word boundaries (use `perl -pi -e`), and `stat -f` format
  specifiers can return filesystem info instead of timestamps (use `ls -la` or
  `find -newermt`).
- `fetch` resolves on 4xx/5xx rather than rejecting, so any `fetch` with a
  fallback branch needs an explicit `r.ok` check - otherwise a server error is
  indistinguishable from the server being absent and silently takes the fallback.
- In zsh, quote or brace-wrap anything containing a glob, `:`, or `?` - unquoted
  `--include=*.go` expands, `"$VAR:path"` gets eaten as a `:l`-style parameter
  modifier (use `"${VAR}:path"`), and a bare URL with `?` fails to match.
- Go: default to unexported (lowercase). Only export when cross-package usage is
  confirmed.
- When the goal is just clean output (e.g. a screenshot), filter it (e.g. `grep`)
  rather than modifying code to suppress cosmetic log noise.

## Commit Messages
- No emojis. Before writing one, ask for any additional context or motivation.
- Imperative mood: "Fix bug," not "Fixed bug."
- No scopes in the type prefix: `fix:`, not `fix(odp):`.
- Never put ticket keys in the prefix - they belong in the PR body.
- Never add an agent name as co-author.

## Safety
- Never `rm -rf` outside of build/temp dirs. Always scoped, never `~/` or `/`.
- Never `git push --force` to main/master.
- Never `git reset --hard` or `checkout .` with uncommitted work - stash first.
- Never delete branches without confirming they're merged.

## Agent
- Hang detection: run potentially-slow commands in background, poll output. No new
  output for 15s (with verbose/debug flags) or 30s (without) means assume hung - kill,
  retry with a timeout, or fall back. Unbuffer first (`python3 -u`, `stdbuf -oL`,
  `grep --line-buffered`) and don't pipe through `tail`/`head`, or block buffering
  will masquerade as a hang.
- Scope every search. Never `find /` or an unscoped repo-wide `grep -rn` in a
  monorepo - start from the known repo root or domain dir. For "where is this branch
  / worktree", `git worktree list` and `git log` answer directly without searching.
  The ban alone has failed three times, so use a positive first move instead:
  **name the likely location and `ls` it.** Skills and agent config live in
  `~/.claude`, `~/.agents`, `~/dotfiles`; repos in `~/go/src`; the vault in
  `~/Documents`. If those miss, `find "$HOME" -maxdepth 3` - never `/`.
- Exit loops if there's no progress toward a verifiable goal. Never retry the same
  failure 3+ times - stop, note the pattern, ask. Two opaque or unreadable responses
  from one source are enough: switch format, surface, or source instead of probing
  the same failure through adjacent commands.
- Ask before guessing paths or values - don't assume from a directory listing. When
  in learning/exploratory mode, read the primary sources (the actual diff, the
  actual thread) before presenting scope/decision questions - don't ask before
  investigating.
- After disruptions (tool rejection, context restore, mode switch, concurrent edits
  from another tool), verify actual state (`git status`, `git diff`, `ls`) before
  retrying anything.
- Never auto-merge PRs or enable auto-merge. Stop at push/PR creation unless
  explicitly asked to merge.
- Never auto-post GitHub PR comments/reviews (`gh pr comment`, `gh pr review`)
  unless explicitly asked in the current session.
- At the end of an autonomous session, summarize completed work and remaining
  items clearly.
- Check relevant recalled memories before acting on env/dep/tooling issues, and
  apply them at the moment of the action they govern - not just at read time and
  not only after thrashing first. **This applies to the rules in this file too.**
  The recurring failure is not a missing rule but a rule that was in context and
  wasn't consulted while composing the command - so before running anything with a
  known trap (shell globs, pipes into `tail`, interactive auth, platform-specific
  flags), re-check the governing rule against the exact command you are about to
  run.
- Distinguish "broke because I skipped a step" from "fundamentally infeasible"
  before declaring something a blocker - verify by trying the missing step, not by
  asserting. Same for "untestable": check for existing test/eval infrastructure
  first. Before rejecting a review suggestion as infeasible, reread its exact wording
  and enumerate the implementation seams where it could apply.
- Before agreeing to perform an action, confirm it's inside your tool surface.
  Built-in CLI commands (`/plugin`, `/model`, `/clear`) can only be typed by the
  user - say so upfront rather than accepting and walking it back.
- Verify a ticket's own claims against the code before designing around them. Don't
  call a listed item out-of-scope without checking git history for whether it already
  shipped, and don't trust an enumeration of "the affected components" without
  confirming it's complete.
- Never write the interpretation before seeing the output - no `echo "(empty = clean)"`
  next to a command whose result you haven't read. Likewise, compute derived numbers
  (file counts, diff stats, totals) from the source of truth at render time instead of
  hardcoding them, so they can't go stale when the underlying work changes. Read the
  actual payload before diagnosing a tool failure; never invent a plausible transport
  or formatting explanation for output you have not verified.
- Don't silently deviate from a saved template or format. If it seems to lack a slot
  for something, check whether an existing section already covers it; if the deviation
  is genuine, call it out explicitly. Same when an instruction file contradicts
  *itself* - a numbered step that conflicts with the same file's notes - surface the
  conflict instead of quietly following whichever appears first.
- When the user references an image you can't natively see (an external URL), offer to
  fetch and read it locally rather than only reporting that you can't see it.
- When a tooling/build command fails unexpectedly and 1-2 quick checks don't
  explain it - or the same error recurs - search team docs/Slack/web before
  continuing to guess at fixes.
- When polling for a result (build status, branch existence, API state), gate
  success on the command's exit code, not on whether stdout is non-empty. Use the
  platform's own status command as the readiness signal, never an HTTP probe -
  wildcard DNS and auth layers answer 401/404 whether or not the thing exists.
  Exit codes can lie too: a harness task notification has reported `exit code 0`
  while its own payload said `FAILED` with 8 broken tests. Read the payload. For
  aggregated checks, success requires both zero pending and zero failures. Before
  waiting on a named check, confirm it is required and can settle independently;
  never wait on the merge action itself as a prerequisite to merging.
- **Verify the specific mechanism that was broken, not an adjacent signal that is
  easier to check.** Repeatedly the cheap signal was green while the feature was
  dead: an open port is a socket, not proof a particular service owns it (confirm
  with `ps -p <pid> -o args=`); a `200` on a page says nothing about the endpoint
  that page calls (curl the endpoint); a filtered test run reports `PASSED` when the
  filter matched nothing (confirm the expected test names appear in the log). Before
  saying something works, name what was actually exercised. For routed or
  multi-backend systems, assert the returned route/mode/strategy before accepting the
  result, then prove continuity at the resource boundary rather than from a shared
  conversation ID alone.
- Warn the user or let them run it directly before running commands that can
  trigger interactive auth (SSO/OIDC browser popups) - don't launch them in the
  background unannounced. Warn per command, not once per session; having cleared one
  command says nothing about the next.
- State upfront which sources were and weren't covered when a task implies
  exhaustive coverage (e.g. "cross-check docs against code") - don't let the user
  discover the gap. For a multi-facet topic ("styling", "performance", "security"),
  enumerate the facets before claiming coverage: researching layout and calling
  "styling" done, having skipped typography and color, is the same failure.
- Don't put a claim into a durable artifact - Jira ticket, PR comment, design doc -
  before verifying it. Asserted test coverage that didn't exist, and consumer
  behavior characterized from a partial read, both had to be corrected publicly.
  Prefer symbol names over `file:line` in anything durable when the base may be
  stale, and re-verify citations after switching branches. State unverified premises
  as assumptions instead of letting them silently justify a design, and after several
  edit rounds reread the entire artifact for stale prose rather than updating only
  headline counts.
- Try to break your own recommendation before writing it down, and state its weakest
  point alongside its strengths - a tally of a proposal's wins with the flaw omitted
  is advocacy dressed as analysis. Measure claimed benefits rather than asserting
  them: compute a refactor's net diff before calling it a simplification, and check
  that a "something might depend on this" consumer actually exists before paying
  complexity to preserve it.
- Before proposing a new mechanism, check how the codebase already solved the same
  problem class for a sibling feature - the existing answer is often a design option
  you would not otherwise surface, and diverging from it needs a reason.
- When a doc names an endpoint, API, or config key without giving its contract, read
  the implementation rather than inventing the shape. A guessed field name fails at
  runtime, and often silently.
- Don't poll a harness-tracked background task by re-reading its output file - the
  completion notification is the signal. Poll only external state the harness cannot
  observe.
- If a Read returns stale or placeholder content, print the real bytes (`awk`, `sed
  -n`) before editing. Do not attempt a second exact-match edit against text
  reconstructed from memory.
- When starting a persistent background process (server, relay, watcher), state up
  front how it terminates and how to kill it, and prefer a self-limiting default over
  relying on the user to remember. Do not assume one started earlier is still alive.
- Output-formatting rules for chat replies do not govern how much substance a
  generated artifact contains. Brevity constraints on a reply must not thin out a
  file, doc, or page - especially content behind a collapsed section the reader
  already chose to open.
- Confirm scope in one line before an expensive spend (multi-agent fan-out, long
  research, a large generated artifact). Cheap insurance there, not worth asking for
  a quick lookup.
- Read explicit labels and ordering in user-pasted text literally - a job marked
  `(latest)` is the latest. Don't infer recency from list position or from which
  status seems like it ought to be newer.
- For process, policy, or compliance questions, read the governing policy document.
  Tooling not enforcing a rule is not the same as policy permitting it, so never
  answer from mechanical config (a GitHub ruleset flag, a branch protection setting)
  alone. Before calling a finding merge-blocking, confirm the relevant gate is
  currently enabled; a conditional config comment is not evidence that it is.
- Skip WebFetch for SSO-gated internal web UIs - it returns an empty page shell.
  Go straight to the CLI or API (`gh pr checks`, `gh api`) or to Confluence/Slack
  search. Known offenders: `gitlab.ddbuild.io`, `mosaic.us1.ddbuild.io`.
- Before installing or recommending a new tool, check whether a built-in primitive
  already performs the scoped operation.
- Treat a surprising empty result from a filtered or hand-built query as
  unverified. Retry once with a simpler or unfiltered query before concluding that
  the object or content is absent.
- For Confluence MCP, if markdown/HTML is an opaque placeholder, retry once as ADF;
  if that is still unusable, use targeted search/CQL snippets rather than trying to
  reverse-engineer the placeholder.
- When describing that logic or data "moved into" a service, distinguish a server
  change from a client-side adapter using an existing generic capability. Name the
  newly owned schema or behavior so readers do not infer it already existed.
- When fixing one instance of a bug class, inspect the whole function and sibling
  paths for the same pattern, including later assignments that can undo the fix.
- Rendered tool output can be lossy. Before exact-match editing or judging prose,
  reread the real bytes with markers or from a file, and reread immediately before
  editing when formatters or concurrent tools may have changed the target.

## Git
- Conventional commits: feat:, fix:, chore:, refactor:, docs:, test:.
- Always run relevant tests before committing.
- Use the `gh` CLI for all GitHub interactions.
- For cross-repository dependency stacks, temporary branch-tip pseudo-versions
  are development-only. Merge the upstream PR first, then repin the downstream
  PR to the upstream release tag or reachable merge commit, regenerate all
  dependency metadata, and verify a clean dependency resolution before merging
  downstream. With squash merges, never leave the downstream PR pinned to a
  pre-squash commit: deleting the upstream branch can make that revision
  unreachable. Required order: upstream merge -> tag/reachable merge commit ->
  downstream repin and verification -> downstream merge.
- Always rebase, never merge - clean linear history.
- On a published PR branch, add CI and review fixes as new commits. Do not amend
  commits that have already been pushed for review; preserve the review history.
- Do not continually rebase a published PR branch just to keep it current. Rebase
  only to resolve an actual conflict or immediately before merge.
- Branch from `origin/main`, not local `main` (local main drifts in active repos).
- With several worktrees of one repo checked out, re-derive the target worktree for
  every write - don't infer it from the last `cd`. An absolute path composed from the
  wrong root lands edits on an unrelated branch. `git -C <path> branch --show-current`
  confirms before writing.
- When a branch is far behind and the next work is a redesign rather than an
  increment, check whether a fresh branch off `origin/main` removes the rebase from
  the critical path before planning around the rebase. The old branch can stay as a
  fallback, and its rebase cost is only owed if you fall back to it.
- Squash-merge PRs - one commit per PR on main. This does not require a
  single-commit PR branch; keep review-fix commits and let the merge squash them.
- `gh pr create` defaults to `--draft` unless told otherwise for that repo.
- New repos get a `.gitignore` with `.DS_Store` immediately.
- Before committing, verify staged files match intent: `git diff --cached --stat`.
- Never stage a `settings.json` `model` field - it's session-local, toggled via
  `/model`, not something to commit.
- Check the git remote and `gh auth status` identity before concluding a PR or
  branch is missing or inaccessible - don't assume an org/account mismatch away.
- After an aborted rebase across a large base gap, clean up orphaned untracked
  files with `git stash -u` (recoverable) - verify they match the new base before
  the irreversible `git stash drop`. If the index also looks wrong (thousands of
  files falsely staged), confirm with `git write-tree` vs `git rev-parse HEAD^{tree}`
  and fix with a plain index-only `git reset`, not `--hard`.
- Rewriting commit messages must preserve the base. `git reset --hard origin/main`
  plus cherry-pick silently rebases the branch and invalidates any test runs done on
  the old base - use `git rebase -i --no-autosquash` style in-place editing, or flag
  the base change before running it.
- Don't disable commit signing or change signing config to work around a transient
  signing-agent hiccup - retry `git rebase --continue` first; only pursue config
  changes if the failure reproduces after retrying. Stop after two identical signing
  failures and diagnose the agent instead of continuing to retry.
- Resolve conflicts by reading the semantic boundaries of both sides; never apply a
  textual "keep both" when markers cross function or block boundaries.
- A verification command must gate the mutation that follows: use separate checked
  calls or `&&`, never `;` before `git add`, commit, push, or another state change.
- After a push or automated review trigger, inspect issue comments, review bodies,
  and inline review threads before reporting that no feedback arrived.
- Rebase can move backup branches through `--update-refs`. Park safety refs where
  update-refs cannot follow them or verify their target immediately afterward.
- After rebasing across a large base gap, build every touched package as well as
  running tests; replayed import and build-graph assumptions may fail compilation
  without failing the selected tests.
- Before stack cleanup or retargeting, query each PR's current state. Each
  intermediate PR must also expose a coherent API and testable design - correctness
  only at the final stack tip is insufficient.
- For aggregate CI failures, inspect the bridge/child pipeline graph and identify
  the first failing unit before proposing a source change or retrying only the
  aggregate status.

## Skills
- Whenever a skill is added, removed, or has its behavior meaningfully changed,
  update the "Claude Skills" note in the Obsidian vault
  (`04 learning/Tips n Tricks/Claude Skills.md`) to match - keep that note as the
  single up-to-date index of what each skill does.
- Before creating a new note or doc, grep the target vault/repo for an existing one
  on the same topic and extend/merge it rather than adding a parallel duplicate.

## Experiments and evaluation
- State where a success criterion came from before measuring against it, and whether
  anything but you validated it. Never invent the "correct answer", ship it into the
  thing under test, and then grade against it.
- Don't change what a metric covers mid-run. Widening or narrowing scoring after
  results start landing invalidates the comparison - re-check that each metric still
  measures the thing under test after any scoring change.

## Testing
- TDD for core logic - write tests first, use them as guardrails for autonomous
  work.
- Unit tests are not sufficient proof for a change at a process or serialization
  boundary (Temporal activities, RPC, workers). Run it live against the real thing,
  and put the logs or screenshots in a "Proof of working" section of the PR - do this
  proactively, not after a reviewer asks.
- Table-driven tests for Go.
- No heavy mocks. If something needs mocks to test, reconsider the boundary.
- When a test fails, fix the code, not the test - only change the test if the
  requirement itself was wrong.
- A passing test after deliberately breaking the implementation is evidence to
  inspect the test, not proof the fix was unnecessary. Check whether the break was
  complete and whether the test can observe the intended mechanism.
- Missing logs or traces are a telemetry-coverage result, not automatically a
  functional failure. Reconcile them with direct behavioral evidence and preserve
  both signals instead of discarding a successful live proof.
- For policy-constrained agents, E2E prompts must be legitimate product tasks rather
  than bare shell/file instructions. Put the desired side effect inside that task and
  verify the exact effect independently across turns.
- When testing timeout, idle, or expiry behavior, check that the mechanism used to
  observe it isn't the thing resetting it. A 1s polling loop counts as activity and
  makes a working idle-shutdown look broken.
- When authoring a prompt that says "ground your answer in the provided context",
  test the case where the context legitimately doesn't cover the question before
  calling it done - half that rule produces refusals on plain general knowledge.
