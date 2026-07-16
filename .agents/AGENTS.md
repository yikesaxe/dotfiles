# AGENTS.md

Cross-tool agent rules (Claude Code, Cursor, etc). This file is the single source of
truth; tool-specific configs import it rather than duplicating it.

## General Guidelines
- No em dashes - use a plain dash "-" instead.
- Weigh technical decisions on quality, simplicity, robustness, scalability, and
  long-term maintainability over development cost.
- For bug fixes, reproduce the bug in an E2E setting matching the end user's
  experience first, so the fix addresses the real problem.

## Code Style
- Clean, minimal code. Readability > cleverness.
- No over-engineering: no unnecessary abstractions, error handling, or features
  beyond what's asked.
- Mimic the code style of the surrounding modules.
- After renames/refactors, grep the whole repo for the old name - including docs,
  help text, and inline strings, not just code.
- Extract shared code on the 3rd duplicated instance of a pattern, not before. Two
  copies are fine; three means extract now.
- Verify platform capabilities before designing around them - try the command or
  read the source, don't rely on `--help` alone.
- Guard platform-specific commands (`open`, `pbcopy`, `stat -f`, `date -j`) with
  `command -v` checks in shell scripts.
- Go: default to unexported (lowercase). Only export when cross-package usage is
  confirmed.

## Commit Messages
- No emojis. Before writing one, ask for any additional context or motivation.
- Imperative mood: "Fix bug," not "Fixed bug."
- Never add an agent name as co-author.

## Safety
- Never `rm -rf` outside of build/temp dirs. Always scoped, never `~/` or `/`.
- Never `git push --force` to main/master.
- Never `git reset --hard` or `checkout .` with uncommitted work - stash first.
- Never delete branches without confirming they're merged.

## Agent
- Hang detection: run potentially-slow commands in background, poll output. No new
  output for 15s (with verbose/debug flags) or 30s (without) means assume hung - kill,
  retry with a timeout, or fall back.
- Exit loops if there's no progress toward a verifiable goal. Never retry the same
  failure 3+ times - stop, note the pattern, ask.
- Ask before guessing paths or values - don't assume from a directory listing.
- After disruptions (tool rejection, context restore, mode switch, concurrent edits
  from another tool), verify actual state (`git status`, `git diff`, `ls`) before
  retrying anything.
- Never auto-merge PRs or enable auto-merge. Stop at push/PR creation unless
  explicitly asked to merge.
- Never auto-post GitHub PR comments/reviews (`gh pr comment`, `gh pr review`)
  unless explicitly asked in the current session.
- At the end of an autonomous session, summarize completed work and remaining
  items clearly.

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

## Testing
- TDD for core logic - write tests first, use them as guardrails for autonomous
  work.
- Table-driven tests for Go.
- No heavy mocks. If something needs mocks to test, reconsider the boundary.
- When a test fails, fix the code, not the test - only change the test if the
  requirement itself was wrong.
