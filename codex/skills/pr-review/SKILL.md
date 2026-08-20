---
name: pr-review
description: Review a pull request or local branch in depth by first understanding the change end-to-end, then identifying what could be better or simpler, what was missed, unintended consequences, and departures from general or repository-specific patterns. Use when asked to review a PR, review a branch before pushing, assess someone else's changes, or identify correctness, security, testing, migration, backfill, architecture, or maintainability risks.
---

# PR review

## 1. Pick the target

For the user's own work—when no PR is given, or when the named PR is theirs and its branch is checked out—review the local branch and worktree. Local is the source of truth and may be ahead of what is pushed.

```sh
git diff $(git merge-base HEAD origin/main)...HEAD
git status --short
git diff
git log --oneline $(git merge-base HEAD origin/main)..HEAD
```

For someone else's work, require a PR number or URL. Read it through Codex's connected GitHub app when available; use `gh` for unavailable data or CI details. Read the description and existing discussion before the diff. Do not check out another author's branch merely to review it.

If asked to review someone else's work without a PR reference, ask for one.

When a GitHub plugin skill is available, follow it for access mechanics. This skill owns review depth and output.

## 2. Understand before critiquing

This phase is not output. It is what makes the critique reliable.

1. Read the description. Establish what the change is trying to do. For an open PR, also read existing comments and relevant CI state; do not repeat feedback already given.
2. Understand the change end-to-end, not just the hunks. Identify where behavior enters, what calls it, what it touches, and what is now true that was not before. Read every changed file in context and trace callers, downstream consumers, persistence boundaries, side effects, and failure paths.
3. Learn the local patterns. Read applicable `AGENTS.md` files and the nearest existing implementation of the same kind of behavior. Judge pattern alignment against the actual repository, not an abstract ideal.
4. Verify uncertain behavior with focused read-only experiments or targeted tests when practical.

If intent still cannot be established from the PR, repository, or linked context, ask. A partial review is better than a guessed one.

## 3. Run the depth pass

Run every lens; they surface different problems.

- **What could be better?** Check correctness, naming, validation, authorization, security, error behavior, and test coverage.
- **What could be simpler?** Look for indirection that earns nothing, cases that collapse, and hand-rolled behavior where a repository utility or established abstraction exists.
- **What did we miss?** Check edge cases, failure modes, regression tests, documentation, migrations and backfills, old data, partial rollout, feature-flag paths, and rollback.
- **What are the unintended consequences?** Trace blast radius across callers and consumers. Check scale, concurrency, retries, idempotency, external side effects, and behavior for other use cases.
- **What departs from general best practice?** Raise it only where it creates a concrete risk or cost, not as theory.
- **What departs from this codebase's patterns?** Check architecture, layering, conventions, and existing abstractions. Prefer consistency with surrounding code unless the existing pattern itself causes the problem; if so, say that explicitly.

Prefer concrete execution flows over hypothetical concerns. State whether an issue will occur, can occur under identified conditions, or remains uncertain.

## 4. Report ranked findings only

Do not include a walkthrough, change summary, section per lens, or praise. Return only actionable findings, most serious first:

1. Correctness, data loss, and security
2. Unintended consequences and blast radius
3. Missed cases and missing tests
4. Simplification and pattern alignment
5. Nits, batched at the end and unranked

For each finding, state what is wrong, the concrete scenario that triggers it, why it matters, the smallest reasonable fix direction, and an exact `file.rb:42` reference. Add a concise severity label when it helps the author prioritize.

Close with a short **What I couldn't review confidently** list. Include only meaningful verification gaps or residual risks. If there are no findings, say so and provide only that list.

## Rules

- Scale output to the diff while keeping scrutiny proportional to risk. A one-line authentication or shared-framework change may need more investigation than a large isolated change.
- Distinguish what will be a problem from what might be. Do not report speculative micro-optimizations or suggest extraction for its own sake.
- Say what is uncertain. Flagging something that could not be assessed confidently is more useful than a confident guess.
- Every finding costs the author work. If it is not actionable and worth their time, cut it.
- Treat the author as a trusted, capable colleague. Criticism is expected; sycophancy and excessive hedging are not useful.
- Never mutate GitHub state unless the user explicitly asks. When asked to draft feedback, provide comment-ready text and the exact file and line. When explicitly posting review comments, follow the repository's emoji conventions.
