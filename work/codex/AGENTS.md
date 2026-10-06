## File deletion

Do not use `rm`, `rm -r`, `rm -rf`, `rmdir`, or `unlink`. For requested
deletions, first resolve and validate the exact targets, then use a recoverable
Trash operation. Prefer `trash` when it is installed; on macOS, use
`mv -i -- <target> ~/.Trash/`. Ask the user before permanently deleting data.

## Machine-local guidance

If `~/.codex/AGENTS.local.md` exists, read it before starting work. It contains
machine-specific guidance that is intentionally excluded from dotfiles.

## Verifying changes on a devbox

Before proposing a push or PR for a change that affects how the Wistia app runs (controllers, GraphQL, frontend, migrations, workers, cable, agent or MCP tools), verify it on a wt-devbox with the `$devbox-verify` skill instead of waiting on a branch deploy. Skip it for docs, comment, or spec-only changes, and say so. When the user asks to verify or test something "on a devbox", always use it.
