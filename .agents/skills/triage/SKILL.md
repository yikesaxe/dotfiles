---
name: triage
description: Evaluate accumulated INBOX.md entries and route each into AGENTS.md as a promoted rule, a strengthened existing rule, a task, or a discard. Use when INBOX.md has grown past ~10 unresolved entries, or on explicit "triage" request.
---

# Triage

Turns raw friction in `~/.agents/INBOX.md` into durable rules in
`~/dotfiles/.agents/AGENTS.md` (edit the real file, not through the symlink target
directly - they're the same file, just be aware which repo you're committing in).

For each unresolved entry in INBOX.md, run three filters in order:

1. **Is it general?** Repo-specific quirks (wrong import path in one package, a
   one-off flaky test) don't belong in a personal cross-tool AGENTS.md - discard with
   a note that it belongs in that project's own CLAUDE.md if it recurs.
2. **Is it already covered?** If an existing AGENTS.md rule already implies this,
   strengthen that rule instead of adding a near-duplicate.
3. **Is it actionable as a rule, or does it need actual implementation?** A one-line
   behavioral fix ("use HEAD~N, not reset --soft main") is a rule. Something needing
   new tooling or a multi-step process ("detect hangs on slow builds") is a task, not
   a rule.

Route each entry to exactly one outcome:

- **Promote** - append a new bullet under the relevant AGENTS.md section (or add a
  new section if none fits). Remove the entry from INBOX.md.
- **Strengthen** - amend the existing rule's wording in place to cover the new
  nuance. Remove the entry from INBOX.md.
- **Task** - move the entry to a `## Refined` section in INBOX.md with a priority
  (P1/P2/P3) and a one-line approach.
- **Discard** - move the entry to a `## Resolved` section in INBOX.md with a
  one-line reason (e.g. "one-off", "too vague - no repeatable pattern").

After triage, show the user a short summary: how many promoted, strengthened,
tasked, discarded - and the actual AGENTS.md diff for anything promoted or
strengthened, since that file governs future sessions.
