# dotfiles

Personal configuration files, symlinked into place from this repo.

## Structure

```
dotfiles/
├── install.sh        # symlinks configs into place (idempotent, backs up existing files)
└── ghostty/
    └── config        # Ghostty terminal config
```

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

| Config  | Repo path        | Symlinked to                                                     |
| ------- | ---------------- | --------------------------------------------------------------- |
| Ghostty | `ghostty/config` | macOS: `~/Library/Application Support/com.mitchellh.ghostty/config` |
|         |                  | Linux: `~/.config/ghostty/config`                               |

## Editing

Edit files in this repo (or via the symlinked path — same file), then commit.
The repo is the source of truth.
