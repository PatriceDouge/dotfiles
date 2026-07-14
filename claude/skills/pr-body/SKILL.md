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
