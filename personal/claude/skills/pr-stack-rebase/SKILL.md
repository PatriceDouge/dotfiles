---
name: pr-stack-rebase
description: Safely inspect, rebase, verify, push, and synchronize a GitHub stacked pull request chain when trunk advances or a lower layer changes. Use for GitHub's gh stack workflow, stack divergence warnings, and cascading rebases; do not use for unrelated independent pull requests.
---

# Rebase a pull request stack

Preserve each pull request's intended patch while restoring a linear branch chain. Rebasing a stack does not authorize merging, retargeting, marking PRs ready, applying migrations, or changing PR content.

## Safety checks

Before rewriting branches:

1. Read the repository guidance and confirm `gh stack` is installed and authenticated.
2. Inspect every PR's state, draft status, head, base, and current head SHA. Stop if any layer is merged, queued, closed, or unexpectedly retargeted.
3. Confirm the intended order with `gh stack checkout <PR>` and `gh stack view`.
4. Check all relevant worktrees. Do not proceed over uncommitted or unpushed changes.
5. Prefer a clean isolated clone when the main checkout is dirty or stack branches are checked out across multiple worktrees.
6. Record the original branch heads as local backup refs. Do not push those refs.

Tell the user that the rebase rewrites commit SHAs and retriggers CI. Obtain authorization immediately before pushing if the request did not already authorize remote updates.

## Preferred workflow

Run the cascading rebase locally:

```sh
gh stack rebase
```

If it reports a conflict, resolve only understood conflicts, stage the resolution, and run `gh stack rebase --continue`. Use `gh stack rebase --abort` when the resolution is uncertain. Confirm the original heads were restored after an automatic abort.

Do not push immediately. First verify:

- `git status` is clean;
- trunk is an ancestor of the bottom branch;
- every lower branch is an ancestor of the branch immediately above it;
- `git range-diff` shows that each layer retains its intended commits;
- layer-by-layer `git diff --stat` and changed-file lists match the original PR scope.

Inspect every `!` entry in `git range-diff`. Changes caused only by new trunk context, such as a schema-version header, can be expected; unexplained semantic differences require investigation.

Before publishing, compare the remote heads with the SHAs recorded before the rebase. Then push with:

```sh
gh stack push
```

`gh stack push` uses per-branch force-with-lease checks but is not atomic. If one branch is rejected, inspect every remote head before retrying; do not assume none were updated.

## Already-diverged fallback

`gh stack rebase` may restore the stack and stop when a child was already based on an older parent tip. Only use a manual cascade after identifying every exact boundary:

1. Rebase the bottom branch onto the latest trunk.
2. Record its new head.
3. For each child from bottom to top, identify the child's actual old parent tip with the PR metadata, merge base, and commit graph.
4. Replay only that child's commits with `git rebase --onto <new-parent> <old-parent> <child>`.
5. Record the new child head and repeat for the next layer.

Never guess an `old-parent` SHA. Keep local pre-rebase refs until all remote verification is complete, and run the full verification checklist before pushing.

## Post-push verification

Fetch the remote branches and confirm the remote ancestry chain. Re-read every PR and verify that:

- it remains open and retains its prior draft/ready state;
- its head and base branch names are unchanged;
- no PR was merged or removed from the stack;
- the stack UI no longer reports divergent branches;
- CI restarted on the rewritten heads.

The checkout used for the rebase is synchronized. Other clones and worktrees still holding the old commits are stale. Update them only after confirming they are clean; use `gh stack sync` when that checkout already tracks the stack, and let the remote be the source of truth when the only divergence is the completed rebase. Never use a hard reset over uncommitted work.
