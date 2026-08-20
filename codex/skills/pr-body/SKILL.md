---
name: pr-body
description: Write or refine a pull request description using a concise feature or bug-fix format while preserving the repository's PR template and the human author's rationale. Use when drafting a PR body, rewriting an open PR description, filling a pull request template, tightening prose, or preparing a description before publishing changes.
---

# Pull request body

Choose the content format from the nature of the change.

## Feature or enhancement

```markdown
## Context / Why

<Concise context and motivation a reviewer needs.>

## How

- <Notable outcome or decision.>
```

## Bug fix

```markdown
## Problem

<Concise description of the bug and reproduction context when known.>

## Solution

- <Notable outcome or decision.>
```

Infer the format from the diff, commits, branch, issue, and conversation. Ask one concise question only when the classification materially changes the description and cannot be inferred.

## Respect the repository template

Read `.github/PULL_REQUEST_TEMPLATE.md` before composing a body when it exists. Use the feature or bug format inside the template's summary section or nearest equivalent. Fill every required template section; do not replace the template with a custom top-level structure.

Follow applicable `AGENTS.md` instructions. In `wistia/wistia` specifically:

- Leave unknown fields such as a Shortcut link as `- TODO`.
- Ground Human Rationale in what the user actually said, decided, or verified. Do not invent motivation.
- Mention a relevant feature flag in Summary of Changes or AI Usage with context.

## Keep the change list useful

- Use 3–7 bullets when a list is needed.
- Keep each bullet to one sentence.
- State outcomes and decisions, not file-by-file mechanisms.
- Include a why clause only when the change would otherwise be confusing.
- Cut details a reviewer can obtain directly from the diff.

Write in plain language for a reviewer who is not already immersed in the change. Explain an internal concept on first use. Use class and file names only as secondary navigation.

Do not name individuals, invent rationale, use incident framing, reproduce an exhaustive changelog, or preserve empty boilerplate.

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

## Report validation that was performed

Include a validation table only when the change was actually exercised and its behavior observed. A passing automated suite is not validation; list those as commands in the test steps. Omit the section entirely when nothing was run.

Place it in the testing section — the template's "How to Test" or nearest equivalent — above the reproduction steps, in three parts:

1. A headline giving where it ran, when, and the outcome, such as `**Validated on staging (2026-07-15) — 9/9 PASS**`, with a clause on the setup when that setup is what makes the result trustworthy.
2. A table with one row per check. Use `| Check | Result |` when the expectation follows from the check itself, or `| # | Behavior verified | Expected | Observed | Result |` when expected against observed is the point and the reader should be able to count passes. Describe the behavior in plain language for a reviewer unfamiliar with the implementation; keep fixture values, status codes, response fields, and version arithmetic in `Expected` and `Observed`.
3. A caveat naming what the run did not prove — an environment that could not exercise the real code path, a check deferred, a result confirmed only indirectly.

Make `Validation` and the generic test `Steps` sibling headings. When validation has distinct scopes, use concise subsections such as `Endpoint behavior` and `Existing-write compatibility`, each with its own environment, date, and score.

Record observations rather than intentions. Never present an unrun check as passing.

## Refine rather than regenerate

For an existing PR, read the current body first through the connected GitHub app or:

```sh
gh pr view <n> --json body --jq .body
```

Preserve useful human-authored content and make targeted improvements. Draft in chat unless the user explicitly asks to update GitHub. When explicitly updating a PR, use the connected GitHub app when available; otherwise use `gh pr edit` with a body file so shell quoting cannot corrupt Markdown.

If another repository skill owns PR creation mechanics such as title, labels, projects, or risk classification, let it own those mechanics. This skill owns the prose.
