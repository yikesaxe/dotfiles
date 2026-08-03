---
name: ai-news
description: Write today's AI industry news digest into the Obsidian vault. Use when the user runs /ai-news, or asks for a daily AI news update/digest.
---

# AI News

Produces one dated AI-news digest note per day in the vault, at
`04 learning/ai-news/<YYYY-MM-DD>.md` (vault root is `~/Documents/Axel's Vault`),
using `00 templates/ai-news.md`. Forked from the internal Datadog skill
`github.com/DataDog/experimental/.../users/stephanie.wei/skills/ai-newsletter/SKILL.md`
(which posts to `#daily-ai-newsletter`) - same source curation and anti-hallucination
rules, but writes a personal vault note instead of posting to Slack.

## Idempotency

Before doing anything, check whether `04 learning/ai-news/<today>.md` already exists.
If it does, tell the user it's already been run today and show the existing note
instead of re-running - don't overwrite a day's digest silently.

## Lookback window

- Default: since yesterday.
- If today is Monday: since Friday (weekend-aware, so nothing gets skipped).

## Sources

Run these in parallel:

1. **Web** - 2-3 `WebSearch` queries covering:
   - Lab blogs directly: Anthropic, OpenAI, Google Research/DeepMind.
   - `arxiv.org` cs.AI listings or Papers with Code trending, for research signal without PR spin.
   - Hacker News (Algolia API or search) as a community-vetted noise filter - if a story
     isn't there, it's usually just a press release.
   - General press only when it's reporting something not already covered by the above
     (avoid rehashing the same announcement three ways).
2. **Slack** - `mcp__slack__slack_search_public_and_private` over `#dd-ai-watercooler` and
   `#ai-devx-announcements`, filtered to AI-relevant messages from the lookback window.

## Quality rules (carried over from the internal skill - don't skip these)

- **Never fabricate a URL.** If you can't find the real link for a finding, drop the
  finding rather than guess.
- **Verify dates yourself.** Check the article/thread date in the page or message, don't
  trust a search engine's date filter blindly.
- **Dedup across sources.** If a story shows up in both Slack and web search, write one
  bullet with both links, not two bullets.
- **"So what" bar.** Every bullet should make it obvious in one sentence why it matters -
  no bare headline drops.
- Max ~5 bullets per section - curate, don't dump everything found.

## Output

Fill `00 templates/ai-news.md` and write it to `04 learning/ai-news/<YYYY-MM-DD>.md`:

- `## TL;DR` - 2-3 sentences summarizing the day, written last.
- `## Claude & AI News` - lab/model/research news.
- `## Datadog AI Chatter` - relevant finds from the two Slack channels.
- `## Interesting Reads` - anything notable that didn't fit above (demos, repos, essays).
- `## Sources` - flat list of every link used, for traceability.

Leave a section's bullet empty (just `-`) rather than deleting the heading if nothing
relevant turned up that day.
