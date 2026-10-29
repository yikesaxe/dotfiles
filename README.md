# dotfiles

Personal config for this machine. Run `install.sh` to symlink everything into place
(safe to re-run - backs up any pre-existing real files first).

## Layout

- `.agents/AGENTS.md` - cross-tool agent rules (Claude Code, Cursor, etc.), the
  single source of truth for agent behavior.
- `.agents/skills/` - reusable workflows, including PR descriptions, teammate
  reviews, and the checkpoint/retro/triage learning loop.
- `.claude/` - Claude-Code-specific config that imports/wraps the above.
- `config/` - Catppuccin Mocha theming and app config for ghostty, starship,
  lazygit, k9s, and tmux.
- `shell/` - a universal zsh layer (prompt, tool init, aliases) sourced from
  `~/.zshrc` after its ansible-managed block.

`~/.agents/INBOX.md` is a local scratchpad written by `retro` and consumed by
`triage` - it is intentionally not part of this repo.

## Install on a new machine or Workspace

Clone the repository into the user's home directory, inspect the installer, and
then run it:

```shell
git clone https://github.com/yikesaxe/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
sed -n '1,240p' install.sh
./install.sh
```

The installer is safe to re-run. Before replacing a real file, it moves that file
to a timestamped directory under `~/.claude/backups/`. It then installs shared
agent guidance for both tools:

- Codex reads `~/.codex/AGENTS.md`.
- Claude Code reads `~/.claude/CLAUDE.md`.
- Shared rules and skills live under `~/.agents/`.

After installation, start a new agent session so the tool reloads its guidance and
skills. An agent setting up a Workspace should not copy individual files or invent
its own symlinks: clone this repository, review `install.sh`, run it with the user's
approval, and report any files that were backed up.

Verify the important links with:

```shell
readlink "$HOME/.agents/AGENTS.md"
readlink "$HOME/.codex/AGENTS.md"
readlink "$HOME/.claude/CLAUDE.md"
readlink "$HOME/.claude/settings.json"
```

## PR descriptions

Use `$pr-description` in Codex or `/pr-description` in Claude Code. The shared
rules also select it when you ask to draft or revise your own PR description.
It adapts Paul Saulue-Laborde's audience-tiered writing workflow: a short
overview, conceptual changes, useful examples or diagrams, real design
tradeoffs, and verified testing evidence. Detail scales with the change.

The draft is a local Markdown file for review. Approval is required before
creating or updating the hosted PR description. It does not change Git safety
rules, publish reviews, or merge anything. `checkpoint` uses the same workflow.

## Pstack skills

The selected pstack skills are saved under `.agents/skills/`: `bro`, `teach`,
`how`, `why`, and `unslop`. The last three support `teach`. Their references
are included, so they do not depend on a plugin cache. The existing installer
links this directory for Codex and Claude Code; restart the agent session
after installing or updating it.

These are standalone skills: use `$bro` or `$teach` in Codex, or `/bro` or
`/teach` in Claude Code. A separately installed pstack plugin also exposes its
own `pstack:` entries. The standalone copies do not require that plugin.

The existing `review-teammate-pr` skill is also included for reviewing other
people's PRs. Use `$review-teammate-pr` in Codex or `/review-teammate-pr` in
Claude Code. Use `pr-description` for writing up your own changes.

Source: [painhardcore/pstack](https://github.com/painhardcore/pstack/tree/04830a98367e41c79d1565e0c4903cc6ddedce1b),
version `1.1.0`, commit `04830a98367e41c79d1565e0c4903cc6ddedce1b`.
The selected skill files match that snapshot. The original
[MIT license](.agents/skills/PSTACK-LICENSE) is included. Updates are manual;
updating the separately installed plugin does not update these copies.

## Updating existing Workspaces

This repository is `yikesaxe/dotfiles`, separate from Datadog's shared
`ddoghq/workspaces-dotfiles` repository. Only committed and pushed changes are
available to a Workspace pulling from GitHub; local edits do not propagate.

On a Workspace already installed from this repository, inspect its checkout:

```shell
cd "$HOME/dotfiles"
git remote -v
git status --short
git branch --show-current
```

If the remote is your intended `yikesaxe/dotfiles` repository, the checkout is
clean, and its branch tracks the intended remote branch, update it with:

```shell
git pull --ff-only
```

Existing symlinks pick up changed rules and skills immediately on disk. Start a
new Codex or Claude session to reload them. If the symlinks are missing or the
installer changed, review `install.sh`, then run `./install.sh`. It reapplies
all managed config, not just agent skills, and backs up existing real files.
Do not overwrite remote edits or resolve divergence by resetting the checkout.

If you instead registered your setup in Datadog's shared dotfiles repository,
publish changes there through its normal review flow, then run on your Mac:

```shell
workspaces dotfiles sync WORKSPACE_NAME
```

Replace `WORKSPACE_NAME` with the exact target. Omitting it syncs all active
Workspaces. This command uses the shared repository, not this personal repo.
Do not migrate or change your configured dotfiles source merely to update a skill.
