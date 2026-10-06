---
name: devbox-verify
description: Verify a branch's changes on a wt-devbox cloud devbox before pushing or opening a PR — run checks (tests, lint, typecheck) remotely, prove the app boots, drive the UI in a remote headless browser, and report an evidence table. Use when asked to verify, test, prove, or sanity-check a change "on a devbox"/"for real", when about to push or open a PR on a change that affects runtime behavior, or instead of waiting on a branch deploy.
---

# Devbox verify

Prove a change works on a real running app before it leaves the laptop. A branch deploy
needs a PR and CI; a devbox needs neither. This skill is the happy path. For any
`ok: false` envelope, unfamiliar `error.code`, or teardown edge case, load the `wtdb` skill
(official, ships with wt-devbox; `$wtdb`) and follow its recovery for that code — do not improvise.

## When to run it

- The user asks to verify, test, or prove something, or to "check it on a devbox".
- Before proposing a push or PR for a change that affects runtime behavior: controllers,
  GraphQL, frontend, migrations, workers, cable, agent tools, MCP tools.
- Skip it for docs, comments, spec-only changes, and changes whose local spec run is
  already conclusive. Say you skipped and why.

## Rules

- Always pass the branch explicitly and run `wtdb` from the worktree where the edits live,
  so wtdb maps that worktree instead of creating a new one under `~/.wt-devbox/worktrees`.
  If `worktree.should_switch` is ever true, stop: the edits and the box have diverged.
- Never target `main`.
- Always pass `--json`. Read `ok` first, then `ready` and `health.status`. Exit code 0 does
  not mean the dev server is up.
- `ensure`/`sync` push the branch to origin if it is missing there. That is cheap here
  (CI and branch deploys trigger on `pull_request`, not push) but it is still a publish:
  tell the user the first time in a session.
- Sync before every check or verification: `wtdb sync <branch> --json`. The on-save watcher
  is not a guarantee that the box has the latest edit.
- `wtdb stop`, never `wtdb delete`, unless the user asks. Never `--remove-branch`.
- A fresh box takes ~15 min (provision, full `bundle`/`yarn`/GraphQL compile, migrations,
  boot); a pooled box ~30s; a running one seconds. Redirect stdout/stderr to files under
  `/tmp`, run `ensure` in the background (`… > out.json 2> progress.ndjson &`), and poll the
  progress file, relaying each `.message` rather than going silent.
- `wtdb`, `devbox`, and `agent-browser --cdp` need network access, `~/.wt-devbox`, and
  `git push`, so they fail inside the sandbox. Request escalated permissions for them up
  front instead of retrying sandboxed.

## Loop

### 1. Preflight (once per session)

```bash
wtdb version --check          # upgrade with `wtdb upgrade --json` if behind
devbox auth status            # "Authenticated as ..." — else ask the user to run `devbox auth login`
wtdb config auto-update-main --json  # must be "off"; if not, tell the user (it merges origin/main into the branch)
wtdb status --json            # what's already running; reuse an existing mapping
```

### 2. Bring the box up

```bash
wtdb ensure <branch> --json
```

- `ok: false` → load the `wtdb` skill and follow the recovery for `error.code`.
- `health.status: "starting" | "unknown"` → `wtdb wait <branch> --json`; `ready: false`
  after a wait is a timeout, not success.
- `health.status: "devbox_run_failed"` → the server didn't boot; report `health.message`,
  read `wtdb logs --type runtime <branch> -n 200 --json`.
- Record `devbox`, `url`, and `worktree_path` for the report.

### 3. After each batch of edits

```bash
wtdb sync <branch> --json
```

Deps and migrations re-run automatically when their trigger files changed
(`Gemfile.lock`, `yarn.lock`, `app/graphql/`, `*.gql.ts`, `db/migrate/`, `db/data/`).

### 4. Checks

Configured in the repo's `.wt-devbox.toml`. In wistia/wistia: `backend-tests`,
`frontend-tests`, `typecheck`, `lint`, `oxfmt`, `stylelint`.

```bash
wtdb run checks <branch> --json                                   # checks matching files changed vs main
wtdb run checks backend-tests <branch> --json -- spec/path_spec.rb # one check, narrowed
```

One check name per call. The envelope reports `ran`, `failed`, and `all_passed`; on failure
it adds `failed_step` and `stderr_tail`. The test runner's own summary (e.g. rspec's
`N examples, 0 failures`) is only in the log at `log_path` — grep it for the report.
Expect ~45s of Rails boot on top of the specs themselves.

### 5. Runtime verification — pick by what changed

**UI / GraphQL / anything a user sees**

```bash
wtdb browser start <branch> --json           # signs in the agent test user (owner/wadmin)
wtdb browser verify <branch> --json          # the gate: real public route loads
```

`cdp_url` is a local tunnel (`http://127.0.0.1:<port>`). Drive the page with
`agent-browser --cdp <port> …` (load the `agent-browser` skill first) — it attaches to the
already-logged-in remote Chromium. Drive it like a user; don't shortcut through GraphQL or
the DB. The signed-in account is the subdomain `devbox-agent-sandbox-<box host>`.
- Different role: `wtdb browser login <branch> --role viewer|limited|standard|manager --json`
  signs the browser in as `agent-<role>+<devbox identifier>@wistia.com` in the same account
  (provisioned on first use). `wtdb browser login <branch> --json` returns to the owner.
- Impersonation: provision the role member first, sign back in as owner (a wadmin), then use
  the footer's Impersonate button and pick that member.
- Evidence clip: `wtdb browser record start <branch> --out /tmp/x.mp4 --json` …
  `wtdb browser record stop <branch> --json`.
- Fallback without agent-browser: `wtdb browser screenshot <branch> [url] --output <file> --json`.

**Backend / data / jobs**

Pipe Ruby over stdin — nested shell/Ruby quoting through `devbox ssh` breaks easily:

```bash
cat <<'RUBY' | devbox ssh <devbox> -- "cd ~/code/wistia && REQUIRE_RAILS_MASTER_KEY=false bin/rails runner -"
p User.count
RUBY
```

The box has seeded dev data, not the user's. For their data: `bin/dev-db` snapshot +
an uncommitted `dev/.dev-db-snapshot` marker, then sync.

**API**

The public API routes at `https://api-<box host>` (swap the `app` label of `url`); an
unauthenticated call returns the API's own `401` JSON. A token for the sandbox account
still has to be minted on the box — not yet worked out; say so rather than improvising.

**Always — runtime logs**

All Procfile processes (rails, sidekiq, anycable, ws, vite) log to one stream, prefixed with
the process name and ANSI-colored. Strip color and filter by process:

```bash
wtdb logs --type runtime <branch> -n 5000 | sed 's/\x1b\[[0-9;]*m//g' \
  | grep -E '^(rails|sidekiq|anycable|ws) ' | grep -v log_query_source | grep -iE 'error|reject|unauthor'
```

AnyCable logs `connection_identifiers` as a base64 GlobalID — decode it
(`base64 -d`) to see which user a websocket is authenticated as.

**Give async work time.** The first agent/LLM run or job on a cold box can take 30s+.
Before calling something stuck, check the logs and look again.

### 6. Report

```markdown
Verified on `<devbox>` (<url>) at <short sha>

| # | Behavior verified | How | Result |
|---|---|---|---|
| 1 | <capability, one clause> | checks / browser / runner | PASS / FAIL — <observed> |
```

Write "Behavior verified" for a reviewer who hasn't read the code. Put this table in the
PR's How to Test section when a PR follows.

### 7. Wrap up

Leave the box running while iterating. When the task is done:

```bash
wtdb browser stop <branch> --json
wtdb stop <branch> --force --json            # returns the box to the pool, keeps the worktree
```

Merged-PR boxes are cleaned up automatically (`cleanup_merged` is on).
