## File deletion

Do not use `rm`, `rm -r`, `rm -rf`, `rmdir`, or `unlink`. For requested
deletions, first resolve and validate the exact targets, then use a recoverable
Trash operation. Prefer `trash` when it is installed; on macOS, use
`mv -i -- <target> ~/.Trash/`. Ask the user before permanently deleting data.

## Machine-local guidance

If `~/.codex/AGENTS.local.md` exists, read it before starting work. It contains
machine-specific guidance that is intentionally excluded from dotfiles.
