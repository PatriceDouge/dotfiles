---
name: pr-review
description: Review a pull request or local branch in depth by understanding the change end-to-end, tracing callers and data flow, checking repository conventions, and returning ranked actionable findings. Use when asked to review a PR, review a branch before pushing, assess someone else's changes, or identify correctness, security, testing, migration, backfill, or maintainability risks.
---

# Pull request review

## Select the source of truth

For the user's own checked-out work, review the local branch and worktree because they may be ahead of the pushed PR:

```sh
git diff $(git merge-base HEAD origin/main)...HEAD
git status --short
git diff
git log --oneline $(git merge-base HEAD origin/main)..HEAD
```

For someone else's PR, require a PR number or URL. Prefer Codex's connected GitHub app for metadata, the patch, changed filenames, and existing comments. Use `gh` only for gaps such as Actions checks or unavailable connector data. Do not check out another author's branch merely to review it.

When a GitHub plugin skill is available, follow it for access mechanics; this skill owns review depth and output.

## Understand before critiquing

1. Read the PR description, status, existing review comments, and relevant CI state. Do not repeat feedback already present.
2. Read every changed file in surrounding context. Trace entry points, callers, downstream consumers, persistence boundaries, and failure paths.
3. Read the applicable `AGENTS.md` files and nearby implementations of the same kind of behavior.
4. Distinguish the intended contract from the current implementation. Verify uncertain behavior with focused, read-only experiments or targeted tests when practical.
5. Ask only when intent cannot be established from the PR, repository, or linked context.

## Run the depth pass

Check every relevant lens:

- Correctness, authorization, security, validation, and error behavior
- Data loss, migrations, backfills, old data, partial rollout, and rollback
- Concurrency, scale, retries, idempotency, and external side effects
- Callers and consumers outside the changed hunks
- Edge cases and missing regression coverage
- Unnecessary indirection or hand-rolled behavior where a repository utility exists
- Alignment with the codebase's established architecture and conventions

Prefer concrete execution flows over hypothetical concerns. State whether an issue will occur, can occur under identified conditions, or remains uncertain.

## Report findings

Return findings first, most serious first:

1. Correctness, data loss, and security
2. Unintended consequences and blast radius
3. Missed cases and missing tests
4. Simplification and pattern alignment
5. Batched nits, only when worth the author's time

For each finding, include:

- A concise severity label
- What is wrong
- The concrete scenario that triggers it
- Why it matters
- The smallest reasonable direction for a fix
- A file and line reference

Do not pad the review with a walkthrough or praise. If there are no findings, say so and list only meaningful residual risks or verification gaps. Explicitly identify anything that could not be reviewed confidently.

## GitHub write boundary

Never post, approve, request changes, resolve threads, or otherwise mutate GitHub state unless the user explicitly asks. When asked to draft feedback, provide comment-ready text and the exact file/line where it belongs. When explicitly posting review comments, follow the repository's emoji conventions.
