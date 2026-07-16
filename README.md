# dotfiles

Personal agent config: `.agents/AGENTS.md` is the cross-tool rules file (Claude Code,
Cursor, etc.), `.agents/skills/` holds the checkpoint/retro/triage learning loop, and
`.claude/` holds Claude-Code-specific config that imports/wraps the above. Run
`install.sh` to symlink everything into place.

`~/.agents/INBOX.md` is a local scratchpad written by `retro` and consumed by
`triage` - it is intentionally not part of this repo.
