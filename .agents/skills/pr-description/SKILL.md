---
name: pr-description
description: Draft or revise a GitHub PR description from the actual change, with a reviewer-focused summary, design rationale, and verified testing evidence. Use when writing up your own changes or preparing a PR; not for reviewing someone else's PR.
---

# PR Description

Adapted from Paul Saulue-Laborde's `amazing-pr-description` workflow in
`ddoghq/workspaces-dotfiles/users/paul.laborde/.claude/skills/`.

## Gather evidence

Read [the audience guide](references/audience.md) and [the template](template.md).
Follow the repository's PR template and contribution rules first; adapt this
structure to them rather than silently replacing required sections.

- Confirm the repository, branch, worktree, and intended base. Read the actual
  diff and commit history; for a hosted PR use `gh pr view` and `gh pr diff`.
- Include motivation, constraints, and decisions the user supplied that the diff
  cannot explain. Do not invent alternatives or rationale to fill a section.
- For a stack, describe this layer against its own base, not the final stack tip.
  Explain dependencies and scope left to other layers where relevant.
- Report tests as observed: command, result, and what behavior was exercised.
  Separate tests not run, failed checks, and limitations from verified results.
  A passing CI check is not evidence of a manual or live E2E test.

## Draft and review

Write the description to a temporary Markdown file outside the repository using
the permitted file-editing tool. Give the user a clickable absolute path or
artifact preview. The file, not a chat-only paraphrase, is the review artifact.

Use the template proportionally: a small fix can be a short overview, a few
change bullets, and testing. Add a diagram or usage example only if it materially
clarifies the change. Collapse longer explanations, decisions, and test output;
do not wrap every short bullet in an empty disclosure block.

Reconcile the complete draft with the current diff after revisions. Revise the
same file until the user approves the description. Existing approval of code or
a request to draft a description does not approve publishing it.

Do not spawn an agent merely because this skill was invoked. If delegation is
otherwise authorized, pass the drafter the relevant diff, user rationale, these
references, and ownership of the draft file. Keep publishing with the agent that
witnessed the user's approval.

## Publish only the approved artifact

Show the final file and wait for explicit approval to create the PR or update its
description. If the user already approved exact text for publication, preserve
that approval's scope and use it as-is. Use `gh pr create --draft --body-file`
or `gh pr edit --body-file` as appropriate, following existing Git rules.

Description approval alone does not authorize commits, pushes, reviews, merges,
or changes to the implementation. Do not add author attribution to the PR body.
After an authorized publish, read the hosted description back and compare it to
the approved file before reporting success.
