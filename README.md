# dotfiles

Personal configuration files, symlinked into place from this repo.

## Structure

```
dotfiles/
├── install.sh        # symlinks configs into place (idempotent, backs up existing files)
├── ghostty/
│   └── config        # Ghostty terminal config
├── claude/
│   └── skills/           # personal Claude Code skills
│       ├── agent-browser/ # default browser driver; defers to the CLI's own skills
│       ├── pr-body/       # PR description format (features + bugs)
│       └── pr-review/     # PR / branch review: understand e2e, then ranked findings
└── codex/
    ├── AGENTS.md        # personal Codex guidance
    └── skills/         # personal Codex skills and UI metadata
        ├── agent-browser/ # browser driving and UI verification
        ├── pr-body/       # template-aware PR descriptions
        └── pr-review/     # connector-first, end-to-end PR review
```

Claude Code and Codex skills here are personal and portable — they apply in every repo.
Repo-specific conventions (PR templates, labels, CI, team workflows) stay in that
repo's own agent configuration, and these skills defer to them.

## Setup on a new machine

```sh
git clone git@github.com:PatriceDouge/dotfiles.git /Volumes/CaseSensitive/dotfiles
cd /Volumes/CaseSensitive/dotfiles
./install.sh
```

Clone anywhere you like — `install.sh` derives its own location, so the target
directory doesn't matter. If you clone onto an external volume (as above), that
volume must stay mounted for the symlinks to resolve.

`install.sh` symlinks each config to where the app expects it. If a real file
already exists at the destination, it's moved aside to `<file>.bak` first.

## What lives where

| Config  | Repo path             | Symlinked to                                                     |
| ------- | --------------------- | --------------------------------------------------------------- |
| Ghostty | `ghostty/config`      | macOS: `~/Library/Application Support/com.mitchellh.ghostty/config` |
|         |                       | Linux: `~/.config/ghostty/config`                               |
| Claude  | `claude/skills/<name>` | `~/.claude/skills/<name>` (each skill linked individually, so plugin-installed skills are left alone) |
| Codex   | `codex/skills/<name>`  | `~/.codex/skills/<name>` (each skill linked individually, so built-in and plugin skills are left alone) |
|         | safety defaults        | merged into `~/.codex/config.toml` without tracking credentials or machine-specific state |
|         | `codex/AGENTS.md`      | `~/.codex/AGENTS.md`                                            |

The portable Codex defaults keep the sandbox in `workspace-write`, retain
interactive approval boundaries, and send eligible approval requests through
Auto-review. Global guidance tells Codex to use a recoverable Trash operation
instead of permanent deletion commands. Machine-specific guidance belongs in
the untracked `~/.codex/AGENTS.local.md` file.

## Editing

Edit files in this repo (or via the symlinked path — same file), then commit.
The repo is the source of truth.
