---
name: pr-body
description: Write or refine a pull request description. Features use Context/Why + How; bugs use Problem + Solution. Use when drafting a PR body, rewriting the description on an open PR, filling in a repo's PR template, or when asked to tighten/clean up a description.
---

# PR body

Two formats. Pick by what the change *is*, not by which repo it's in.

## Feature / enhancement

```
## Context / Why

<The context a reviewer needs, and the why behind the change. Concise and focused.>

## How

<High-level list of the notable changes. Keep it simple — the reviewer can read the
code for specifics.>
```

## Bug fix

```
## Problem

<The bug, concisely. Repro details if they're known.>

## Solution

<The approach to the fix, in a sentence or two. Then a high-level list of the notable
changes.>
```

Infer which format applies from the diff and the branch or commit prefix (`fix(...)` → bug). If the change is genuinely both, or it's unclear, ask in one line rather than guessing.

## The How / Solution list

The list is the part that swells. Hold it to:

- **One sentence per bullet**, stating the change or decision at headline level. A why gets one clause, and only when the bullet is baffling without it.
- **Outcomes, not mechanisms.** Name what is now true, not the options/classes/hooks that make it true.
- **3–7 bullets.** More means it has drifted into a changelog.
- The test for every bullet: cut everything after the first sentence — if the reviewer loses nothing they couldn't get from the diff, ship the cut version.

The register to hit:

```
Too much: - **Subfolders join the existing bulk framework rather than getting a
            bespoke endpoint**, so they inherit the authorization, resumable chunked
            execution, and per-action error reporting every other bulk resource
            already has. The framework needed two small extensions to fit them: …
Right:    - Subfolders become a resource type in the existing bulk framework,
            inheriting its authorization, chunked execution, and per-action results.
```

## Optional request-flow diagrams

Do not add a diagram by default. When the user requests a call stack, request flow, or execution-flow diagram, add a compact fenced `text` diagram under `How` or `Solution`. Introduce it as "The high-level request flow is:" or "The request and service execution flow is:". Call it a call stack only when it shows exact runtime method nesting.

Use this shape:

```text
<Request>
        |
        ├── <existing entry point>
        └── <alternate or future entry point>
        |
        ▼
<Shared service>::<Operation>#call
        ├── <operation-specific checks>
        └── <shared boundary>
                ├── <transaction, authorization, lock, or version check>
                └── <selected operation>
                        ├── <operation A and notable effects>
                        └── <operation B and notable effects>
        |
        ▼
<Commit, result, or externally visible side effect>
```

Keep the flow top-to-bottom, indent according to actual nesting, distinguish current from future entry points, and show only the layers a reviewer needs. Follow it with bullets only when they add decisions or semantics not already visible in the diagram.

## Optional flow diffs

Do not add a flow diff by default. Add one only when the user asks for a before/after flow, flow diff, call-stack diff, or comparable execution-path comparison. Use a flow diff to show how an existing request path changed; use the request-flow diagram above when only the current architecture matters.

Place it under `How` or `Solution`, normally as `## Flow change`, and use a fenced `diff` block. Introduce it with one sentence identifying what stays unchanged and what changes.

```diff
 <Mutation or request>
   -> authorize and resolve input
-  -> write the model directly
+  -> shared error boundary
+     -> DomainService.call(expected_version)
+        -> lock, version-check, validate, and write
   -> return the result
```

Guidelines:

- Prefix unchanged context lines with a space, removed paths with `-`, and new paths with `+`.
- Keep the flow top-to-bottom and include only the layers needed to understand the architectural change.
- Preserve unchanged entry points and results as context when the external contract stays the same.
- For multiple independent entry points, label each operation in one block when it remains compact; use separate blocks only when one block becomes hard to scan.
- Use exact method or class names only when they help reviewers navigate and the nesting has been verified.
- Call it a call-stack diff only when it shows exact runtime method nesting; otherwise label it `Flow change`.
- Do not combine a flow diff with a current-state request-flow diagram unless the user explicitly asks for both.

## Validation

Only when you actually exercised the change and watched what happened. A passing spec suite is not validation — that's a command in the test steps. Nothing run, no section.

It goes in the testing section (a template's "How to Test", or its own heading), above the repro steps, in three parts:

1. **A headline** — where it ran, when, and the score. `**Validated on staging (2026-07-15) — 9/9 PASS**, in a dedicated test folder with an empty decoy folder proving no wrong-parent writes.`
2. **A table, one row per check.** Two shapes:
   - `| Check | Result |` when the expectation is obvious from the check itself (a round trip: toggle off → 404, toggle on → 200).
   - `| # | Behavior verified | Expected | Observed | Result |` when expected-vs-observed is the point, and a reader should be able to count the passes.
   - Describe the behavior in plain language for a reviewer unfamiliar with the implementation. Keep fixture values, status codes, response fields, and version arithmetic in `Expected` and `Observed`.
3. **A caveat** — what the run did *not* prove. "This staging host sits behind CloudFront, which ignores `Surrogate-*`, so the Fastly purge itself isn't observable here." This is often the most valuable line in the section; a run with a blind spot that goes unmentioned reads as a run with no blind spot.

Make `Validation` and the generic test `Steps` sibling headings. When validation has distinct scopes, use concise subsections such as `Endpoint behavior` and `Existing-write compatibility`, each with its own environment, date, and score.

Rows record what you saw, not what you meant to check: "Nothing created; decoy empty" beats "verified nothing was created." Never table a check you didn't run.

## Where the format goes

- **Repo has a PR template** (`.github/PULL_REQUEST_TEMPLATE.md`): the format above is the *content of the Summary of Changes section* — or that repo's nearest equivalent, the first "what changed" section. Read the template and fill its other sections as it asks. Never substitute your own structure for the template's, and remember that passing `--body` to `gh pr create` silently discards it.
- **No template**: the format is the whole body, with the headings at top level.
- Values you don't know (ticket links, etc.) stay as `- TODO` for the human. Don't invent them.

## Rules

Always:

- Lead with plain language. Explain an internal concept the first time it appears. Class and file names are parenthetical navigation aids, never the subject of a sentence.
- Write for a reviewer who is not already deep in this change.

Never:

- **No exhaustive change lists.** "How" and "Solution" are short lists of *notable* changes, not file-by-file changelogs. If the reviewer can get it from the diff, cut it.
- **No naming individuals** — not the reporter, not the author. Say "the collab team", "a customer".
- **No "incident" framing.** Describe what happened neutrally.
- **No padding, hedging, or leftover boilerplate.** A section with nothing real to say gets one line, or gets cut.

## Refining an existing PR

Read the current body first (`gh pr view <n> --json body --jq .body`). You are editing, not regenerating — preserve what the human wrote and change only what's actually wrong. Apply with `gh pr edit <n> --body-file <file>`.

If the repo has its own skill or command that owns PR creation (labels, projects, title conventions, risk assessment), let it own those mechanics. This skill owns the prose.
