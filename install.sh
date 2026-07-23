#!/usr/bin/env bash
# Symlink dotfiles into place. Idempotent; backs up any existing real files.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    rm "$dest"                         # replace an existing symlink
  elif [ -e "$dest" ]; then
    echo "Backing up existing $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  fi
  ln -s "$src" "$dest"
  echo "Linked $dest -> $src"
}

set_codex_root_setting() {
  local config="$1" key="$2" value="$3" temp
  mkdir -p "$(dirname "$config")"
  touch "$config"
  temp="$(mktemp "${config}.tmp.XXXXXX")"

  awk -v key="$key" -v value="$value" '
    BEGIN { in_root = 1; written = 0 }
    in_root && $0 ~ "^[[:space:]]*\\[" {
      if (!written) {
        print key " = " value
        print ""
        written = 1
      }
      in_root = 0
    }
    in_root && $0 ~ "^[[:space:]]*" key "[[:space:]]*=" {
      if (!written) {
        print key " = " value
        written = 1
      }
      next
    }
    { print }
    END {
      if (!written) print key " = " value
    }
  ' "$config" > "$temp"

  mv "$temp" "$config"
}

# --- Ghostty ---------------------------------------------------------------
# macOS reads the app-support path; Linux/other uses the XDG path.
case "$(uname -s)" in
  Darwin) GHOSTTY_DEST="$HOME/Library/Application Support/com.mitchellh.ghostty/config" ;;
  *)      GHOSTTY_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config" ;;
esac
link "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_DEST"

# --- Claude Code -----------------------------------------------------------
# Link skills one at a time rather than linking ~/.claude/skills wholesale, so
# plugin-installed skills already living there are left in place.
for skill in "$DOTFILES_DIR"/claude/skills/*/; do
  link "${skill%/}" "$HOME/.claude/skills/$(basename "$skill")"
done

# --- Codex ----------------------------------------------------------------
# Keep machine-specific state and credentials in the local config while
# applying portable safety defaults from this installer.
CODEX_CONFIG="$HOME/.codex/config.toml"
set_codex_root_setting "$CODEX_CONFIG" "approval_policy" '"on-request"'
set_codex_root_setting "$CODEX_CONFIG" "approvals_reviewer" '"auto_review"'
set_codex_root_setting "$CODEX_CONFIG" "sandbox_mode" '"workspace-write"'

# Link personal skills one at a time so built-in .system and plugin-installed
# skills already living under ~/.codex/skills are left in place.
for skill in "$DOTFILES_DIR"/codex/skills/*/; do
  link "${skill%/}" "$HOME/.codex/skills/$(basename "$skill")"
done

link "$DOTFILES_DIR/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"

echo "Done."
