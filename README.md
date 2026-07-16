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
