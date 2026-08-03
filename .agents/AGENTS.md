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
  help text, and inline strings, not just code.
- Extract shared code on the 3rd duplicated instance of a pattern, not before. Two
  copies are fine; three means extract now.
- Verify platform capabilities before designing around them - try the command or
  read the source, don't rely on `--help` alone.
- Guard platform-specific commands (`open`, `pbcopy`, `stat -f`, `date -j`) with
  `command -v` checks in shell scripts. Don't assume the BSD variant on darwin
  either - GNU coreutils often shadows it on PATH, so BSD-only flags (`date -v`)
  fail there too. Prefer portable epoch arithmetic or a language runtime.
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
- Exit loops if there's no progress toward a verifiable goal. Never retry the same
  failure 3+ times - stop, note the pattern, ask.
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
  not only after thrashing first.
- Distinguish "broke because I skipped a step" from "fundamentally infeasible"
  before declaring something a blocker - verify by trying the missing step, not by
  asserting. Same for "untestable": check for existing test/eval infrastructure
  first.
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
  hardcoding them, so they can't go stale when the underlying work changes.
- Don't silently deviate from a saved template or format. If it seems to lack a slot
  for something, check whether an existing section already covers it; if the deviation
  is genuine, call it out explicitly.
- When the user references an image you can't natively see (an external URL), offer to
  fetch and read it locally rather than only reporting that you can't see it.
- When a tooling/build command fails unexpectedly and 1-2 quick checks don't
  explain it - or the same error recurs - search team docs/Slack/web before
  continuing to guess at fixes.
- When polling for a result (build status, branch existence, API state), gate
  success on the command's exit code, not on whether stdout is non-empty. Use the
  platform's own status command as the readiness signal, never an HTTP probe -
  wildcard DNS and auth layers answer 401/404 whether or not the thing exists.
- Warn the user or let them run it directly before running commands that can
  trigger interactive auth (SSO/OIDC browser popups) - don't launch them in the
  background unannounced. Warn per command, not once per session; having cleared one
  command says nothing about the next.
- State upfront which sources were and weren't covered when a task implies
  exhaustive coverage (e.g. "cross-check docs against code") - don't let the user
  discover the gap.

## Git
- Conventional commits: feat:, fix:, chore:, refactor:, docs:, test:.
- Always run relevant tests before committing.
- Use the `gh` CLI for all GitHub interactions.
- Always rebase, never merge - clean linear history.
- Branch from `origin/main`, not local `main` (local main drifts in active repos).
- Squash-merge PRs - one commit per PR on main.
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
  changes if the failure reproduces after retrying.

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
