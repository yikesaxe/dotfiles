---
name: ticket
description: File a new Jira ticket into the Obsidian vault, or update an active ticket's session file at the end of a work session. Use when given a Jira link/key to add to the vault, or when finishing/pausing work on a ticket that has a vault note.
---

# Ticket

Manages the vault's ticket notes end-to-end: filing new tickets and keeping session
files current. The vault's own `CLAUDE.md` (at the vault root, in "Ticket naming" and
"Ticket session workflow") is the source of truth for structure and rules - read it
each run rather than assuming these notes; if it and this skill disagree, the vault's
CLAUDE.md wins and this skill should be corrected to match.

## Mode: file a new ticket

Triggered by a Jira link or key with no existing vault note.

1. Fetch the issue via the Atlassian MCP tools (summary, description, status,
   priority, assignee, reporter, acceptance criteria if present).
2. Create `03 ai-platform/tickets/notes/<KEY>.md` and
   `03 ai-platform/tickets/sessions/<KEY>-session.md` from `00 templates/ticket.md`
   and `00 templates/ticket-session.md`. Filename is the Jira key, never the title
   (see vault CLAUDE.md "Ticket naming"). Notes and sessions live in separate
   sibling folders, not together.
3. Fill the ticket note's Problem/Context from the issue description; leave
   Plan/Implementation/Questions for the user.
4. Add the new ticket under `index.md`'s "Tickets" and "Active Work" sections.

## Mode: update session (end of session)

Triggered explicitly, or proactively offer this at the end of any session that
touched an active ticket.

1. Read the ticket note and its session file first to avoid contradicting existing
   status.
2. Update the session file's live status block (status, branch, PR, owner, last
   updated date).
3. Update Blockers and Next Actions to reflect current reality - remove
   resolved blockers, don't just append.
4. Append one dated entry to the Session Log describing what happened this
   session (started/investigated/found/next steps) - keep it terse, this is a log
   not a narrative.
5. Suggest any learning note (`04 learning/`) that should be captured from this
   session, per the vault's ticket session workflow - don't create it unasked.

Do not duplicate this skill's job with `retro`/`triage` - those manage the
cross-session agent-behavior INBOX in `~/.agents/`, a separate system from the
vault's own ticket/session notes. A ticket session update is never an INBOX entry.
