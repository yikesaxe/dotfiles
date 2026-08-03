---
name: aip-learn
description: Write today's "one new thing about AI Platform" note into the Obsidian vault. Use when the user runs /aip-learn, or asks to learn something new about AIP team initiatives, services, or other teams' work.
---

# AIP Learn

Produces one dated note per day in the vault at
`03 ai-platform/aip-learn/<YYYY-MM-DD>.md` (vault root is `~/Documents/Axel's Vault`),
using `00 templates/aip-learn.md`. Each note explains exactly one concrete thing about
AI Platform (or an adjacent team's work) that the user didn't already have documented -
this is a rotation of small, real learnings, not a status roundup.

## Idempotency

Before doing anything, check whether `03 ai-platform/aip-learn/<today>.md` already
exists. If it does, tell the user it's already been run today and show the existing
note instead of re-running.

## Avoiding repeats

Before picking a topic, list the files in `03 ai-platform/aip-learn/` from the last
~14 days and skim their `## What I learned today` headings so the same topic isn't
picked twice in a row.

## Sources

Pick ONE topic from real, current material - don't invent one:

- **Confluence** (`mcp__atlassian__search` / `searchConfluenceUsingCql`): AI Platform
  space overview, "AI Platform: How we work" (RFC process), Weekly Adoption Digest -
  AI Platform Agentic Workflows, Golden Paths for Agent Architectures, Datadog AI
  Product Catalog, AIPAW Share & Learns, Demos log, AIPAW intern project briefs.
- **Slack** (`mcp__slack__slack_search_public_and_private`): `#ai-platform-dev`,
  `#ai-platform-backroom`, and per-team channels if a specific team's work looks
  promising that day (e.g. `#ray`, `#docstore-announcements`,
  `#ai-platform-agentic-workflows-backroom`).

Prefer something concrete and current (a recent RFC, a shipped feature in the
adoption digest, a demo, an intern project) over a generic overview restatement.

## Output

Fill `00 templates/aip-learn.md` and write it to `03 ai-platform/aip-learn/<YYYY-MM-DD>.md`:

- `## What I learned today` - the topic, explained simply, as if for someone who
  hasn't seen the source doc.
- `## Why it matters` - why this is relevant to AIP or to the user's own work.
- `## Source(s)` - the actual Confluence/Slack link(s) used. Never fabricate a link.
- `## Related` - wikilinks to related vault notes if any exist (tickets, learning
  notes, services) - leave empty if none apply, don't force a link.
