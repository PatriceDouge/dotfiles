# dotfiles

Personal and work configuration profiles, symlinked into place from this repo.

## Structure

```
dotfiles/
├── install.sh        # symlinks configs into place (idempotent, backs up existing files)
├── bin/
│   ├── ghostty-sessions  # snapshot/restore claude+codex CLI sessions across restarts
│   └── rh                # "resume here": restore the saved session for a pane's cwd
├── launchd/
│   └── com.patricedouge.ghostty-sessions.plist  # auto-snapshot sessions every 10 min
├── ghostty/
│   └── config        # Ghostty terminal config
├── personal/
│   ├── claude/
│   │   └── skills/     # personal Claude Code skills
│   └── codex/
│       ├── AGENTS.md   # personal Codex guidance
│       └── skills/     # personal Codex skills and UI metadata
└── work/
    ├── claude/
    │   └── skills/     # work Claude Code skills
    └── codex/
        ├── AGENTS.md   # work Codex guidance
        └── skills/     # work Codex skills and UI metadata
```

The two profiles initially contain the same Claude Code and Codex configuration,
so they can evolve independently. Skills in the selected profile apply in every repo.
Repo-specific conventions (PR templates, labels, CI, team workflows) stay in that
repo's own agent configuration, and these skills defer to them.

## Setup on a new machine

```sh
git clone git@github.com:PatriceDouge/dotfiles.git /Volumes/CaseSensitive/dotfiles
cd /Volumes/CaseSensitive/dotfiles
./install.sh personal
```

On a work machine, select the work profile instead:

```sh
./install.sh work
```

Running `./install.sh` without an argument defaults to `personal`.

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
| Scripts | `bin/<name>`          | `~/.local/bin/<name>`                                           |
| launchd | `launchd/<label>.plist` | copied (not symlinked — launchd wants real files) to `~/Library/LaunchAgents/` and loaded via `launchctl bootstrap` |
| Claude  | `<profile>/claude/skills/<name>` | `~/.claude/skills/<name>` (each skill linked individually, so plugin-installed skills are left alone) |
| Codex   | `<profile>/codex/skills/<name>`  | `~/.codex/skills/<name>` (each skill linked individually, so built-in and plugin skills are left alone) |
|         | safety defaults        | merged into `~/.codex/config.toml` without tracking credentials or machine-specific state |
|         | `<profile>/codex/AGENTS.md`      | `~/.codex/AGENTS.md`                              |

The portable Codex defaults keep the sandbox in `workspace-write`, retain
interactive approval boundaries, and send eligible approval requests through
Auto-review. Global guidance tells Codex to use a recoverable Trash operation
instead of permanent deletion commands. Machine-specific guidance belongs in
the untracked `~/.codex/AGENTS.local.md` file.

## Editing

Edit files under the selected profile (or via the symlinked path — same file), then commit.
The repo is the source of truth.
