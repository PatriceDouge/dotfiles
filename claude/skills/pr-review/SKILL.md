---
name: pr-review
description: Review a pull request or a branch in depth — understand it end-to-end first, then critique for what could be better, simpler, missed, unintended, or off-pattern. Use when asked to review a PR, review a branch before pushing, or give feedback on someone's changes.
---

# PR review

## 1. Pick the target

**Reviewing your own work** — no PR number given, or the PR named is Patrice's own and its branch is checked out. Review the **local branch or worktree**, not the PR: local is the source of truth and may be ahead of what's pushed.

```sh
git diff $(git merge-base HEAD origin/main)...HEAD   # committed work on this branch
git status --short && git diff                        # plus anything uncommitted
git log --oneline $(git merge-base HEAD origin/main)..HEAD
```

**Reviewing someone else's work** — requires a PR number or URL. Read it through `gh`; don't check their branch out.

```sh
gh pr view <n>            # description, comments, CI state — read this FIRST
gh pr diff <n>
```

If you're asked to review someone else's work without a PR reference, ask for one.

## 2. Understand before you critique

This phase is not output. It's the thing that makes the critique worth reading.

1. **Read the description.** What is this change *trying* to do? On an open PR, also read the existing comments — never hand back feedback someone already gave.
2. **Understand the change end-to-end.** Not the hunks — the change. Where does it enter, what calls it, what does it touch, what is now true that wasn't? Open the files around the diff and the callers of what changed. A diff read in isolation produces confident, wrong review.
3. **Learn the local patterns.** Read the repo's `CLAUDE.md`/conventions and the nearest existing implementation of the same kind of thing. "Off-pattern" is only meaningful relative to the actual pattern.

If, after this, you don't understand the intent, ask. A partial review is fine; a guessed one isn't.

## 3. The depth pass

Run every lens. They surface different things:

- **What could be better?** Correctness, naming, error paths, test coverage, security.
- **What could be simpler?** Indirection that earns nothing, hand-rolled code where a utility exists, cases that collapse.
- **What did we miss?** Edge cases, failure modes, tests, docs, migrations and backfills, feature-flag paths, rollback.
- **Unintended consequences?** Blast radius. Who else calls this? What breaks at scale, under concurrency, on old data, for other callers?
- **Off general best practice?** Only where it actually bites — not theory.
- **Off *this codebase's* patterns?** Architecture, layering, existing abstractions. Consistency with surrounding code usually beats theoretical purity — but if the existing pattern *is* the problem, say so.

## 4. Output: ranked findings only

No walkthrough, no summary of the change, no section per lens, no praise. Just findings, **most serious first**:

1. Correctness, data loss, security
2. Unintended consequences and blast radius
3. Missed cases, missing tests
4. Simplification and pattern alignment
5. Nits — batched at the end, unranked

Each finding: what's wrong, why it matters, what to do instead, and `file.rb:42`. Close with a short **what I couldn't review confidently** list.

## Rules

- **Scale to the diff.** Same scrutiny, proportional output. A one-line change to auth or `ApplicationController` is not a one-line change to some model.
- **Distinguish *will* be a problem from *might* be.** No speculative micro-optimizations; no "consider extracting" for its own sake.
- **Say what you're unsure of.** Flagging a file you couldn't confidently assess is more useful than a confident guess about it.
- **Every finding costs the author work.** If it isn't actionable and worth their time, cut it.
- The author is a trusted, capable colleague. Criticism is expected; sycophancy and hedging aren't.
- **Never post to GitHub.** Report in chat. Only post comments if Patrice explicitly asks, and then use the repo's emoji codes (👍❓❌🔧🙃💭🤡).
