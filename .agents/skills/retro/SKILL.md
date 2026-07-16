---
name: retro
description: Capture friction, mistakes, and corrections from the current session into INBOX.md. Use in full mode at checkpoint step 8 or explicit session end; use in abbreviated mode proactively before context-loss events (exiting plan mode, switching repos/tasks, long pauses).
---

# Retro

Feeds the learning loop: `retro` writes to `~/.agents/INBOX.md` (local scratchpad,
never committed/synced). `triage` later reads it and promotes real patterns into
`~/.agents/AGENTS.md`.

Create `~/.agents/INBOX.md` with a `# Inbox` header if it doesn't exist yet.

## Full retro

Triggered by checkpoint step 8, or an explicit session-end request.

1. Review the session: where did the agent loop, make a mistake the user corrected,
   hang on a prompt, or take an unsafe action?
2. For each distinct piece of friction, append one entry to `~/.agents/INBOX.md`:
   ```
   - [date] <what happened, in one or two sentences - concrete enough that triage
     can judge if it's general/actionable without re-reading the session>
   ```
3. If nothing notable happened, say so explicitly rather than skipping the step
   silently - e.g. "no friction this session, nothing added to INBOX.md."
4. If `~/.agents/INBOX.md` now has more than ~10 unresolved entries (excluding
   `## Refined` / `## Resolved` sections), tell the user it's time to run `triage`.

## Abbreviated retro

Triggered proactively before a context-loss event (exiting plan mode, switching
repos/tasks, a long pause) - not just at checkpoint.

- Quick one-line capture per observation, same format and target as full retro, but
  skip the full session review - just log what's fresh before it's lost.
