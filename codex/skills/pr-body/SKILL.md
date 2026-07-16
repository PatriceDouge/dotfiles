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

## Refine rather than regenerate

For an existing PR, read the current body first through the connected GitHub app or:

```sh
gh pr view <n> --json body --jq .body
```

Preserve useful human-authored content and make targeted improvements. Draft in chat unless the user explicitly asks to update GitHub. When explicitly updating a PR, use the connected GitHub app when available; otherwise use `gh pr edit` with a body file so shell quoting cannot corrupt Markdown.

If another repository skill owns PR creation mechanics such as title, labels, projects, or risk classification, let it own those mechanics. This skill owns the prose.
