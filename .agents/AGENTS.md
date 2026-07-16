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

## Commit Messages
- No emojis. Before writing one, ask for any additional context or motivation.
- Imperative mood: "Fix bug," not "Fixed bug."
- Never add an agent name as co-author.

## Safety
- Never `rm -rf` outside of build/temp dirs. Always scoped, never `~/` or `/`.
- Never `git push --force` to main/master.
- Never `git reset --hard` or `checkout .` with uncommitted work - stash first.
- Never delete branches without confirming they're merged.

## Git
- Conventional commits: feat:, fix:, chore:, refactor:, docs:, test:.
- Always run relevant tests before committing.
- Use the `gh` CLI for all GitHub interactions.
- Always rebase, never merge - clean linear history.
- Branch from `origin/main`, not local `main` (local main drifts in active repos).
