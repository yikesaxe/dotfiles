---
name: checkpoint
description: Use when a unit of work is done and ready to ship - runs build/test, cleans up commits, opens a PR, and triggers a retro. Invoke on explicit "checkpoint" requests or when the user signals they're finished with a task.
---

# Checkpoint

Marks "I'm done with this unit of work." Runs in order, does not skip step 8.

1. **Build + test** - run the project's build and relevant tests. Fix failures before
   continuing; do not checkpoint on a red build.
2. **Update README** - if the change affects documented behavior, update the README.
   Skip if nothing user-facing changed.
3. **Ship as one PR** - no stacked-PR splitting (no Graphite in this setup); keep the
   PR focused on this unit of work.
4. **Clean up commit history** - squash WIP commits, reword messages per the Git/Commit
   Messages rules in AGENTS.md. Use `HEAD~N` for squashing, never `git reset --soft main`
   (local `main` drifts from `origin/main` in active repos - see Safety/Git rules).
5. **Show diff and confirm** - summarize what changed and why, get explicit
   confirmation before committing.
6. **Push + open PR** - push the branch, `gh pr create` with a summary and test plan.
7. **Win check** - one or two sentences: does this session's output clearly
   demonstrate value (the kind of thing worth mentioning in a promo packet)? If not,
   note what's missing - don't pad the PR to compensate.
8. **Retro (mandatory)** - invoke the `retro` skill in full mode. Not optional, not
   skippable even if the session felt friction-free (say so explicitly in that case).
