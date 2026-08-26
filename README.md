# dotfiles

Personal config for this machine. Run `install.sh` to symlink everything into place
(safe to re-run - backs up any pre-existing real files first).

## Layout

- `.agents/AGENTS.md` - cross-tool agent rules (Claude Code, Cursor, etc.), the
  single source of truth for agent behavior.
- `.agents/skills/` - the checkpoint/retro/triage learning loop.
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
