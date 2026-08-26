#!/bin/bash
# Symlink setup for ~/dotfiles. Safe to re-run.
set -eu

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.claude/backups/pre-dotfiles-$(date +%Y%m%d%H%M%S 2>/dev/null || echo manual)"

link() {
  local target="$1" link_path="$2"
  if [[ -L "$link_path" ]]; then
    rm "$link_path"
  elif [[ -e "$link_path" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$link_path" "$BACKUP_DIR/$(basename "$link_path")"
    echo "backed up existing $link_path -> $BACKUP_DIR/"
  fi
  mkdir -p "$(dirname "$link_path")"
  ln -s "$target" "$link_path"
  echo "linked $link_path -> $target"
}

link "$DOTFILES/.agents/AGENTS.md" "$HOME/.agents/AGENTS.md"
link "$DOTFILES/.agents/skills" "$HOME/.agents/skills"
link "$DOTFILES/.agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
link "$HOME/.agents/skills" "$HOME/.claude/skills"
link "$DOTFILES/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link "$DOTFILES/.claude/settings.json" "$HOME/.claude/settings.json"

link "$DOTFILES/config/ghostty/config" "$HOME/.config/ghostty/config"
link "$DOTFILES/config/starship/starship.toml" "$HOME/.config/starship.toml"
link "$DOTFILES/config/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
link "$DOTFILES/config/k9s" "$HOME/.config/k9s"
link "$DOTFILES/config/tmux.conf" "$HOME/.tmux.conf"

touch -a "$HOME/.agents/INBOX.md"
if [[ ! -s "$HOME/.agents/INBOX.md" ]]; then
  echo "# Inbox" > "$HOME/.agents/INBOX.md"
fi

echo "done."
