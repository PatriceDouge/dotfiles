---
name: pr-title
description: Create or revise pull request titles using the author's Conventional Commit-style format. Use whenever creating a PR, drafting its title, or correcting an existing PR title; pair with pr-body when the description is also needed.
---

# PR title

Write pull request titles as:

```text
<type>(<scope>): <concise description>
```

Use this convention unless the repository has a more specific title requirement.

## Choose the type

Use the type that best describes the primary intent of the change:

- `feat` for a new capability or meaningful product behavior.
- `fix` for a defect correction or restored expected behavior.
- `chore` for general maintenance or cleanup not covered by a more specific type.
- `docs` for documentation-only changes.
- `refactor` for restructuring code without changing its behavior.
- `test` for adding or correcting tests without changing production behavior.
- `style` for formatting or other non-functional style changes.
- `perf` for a performance improvement.
- `ci` for continuous-integration configuration or workflows.
- `build` for build systems, packaging, or dependency changes.

These follow Conventional Commits: `feat` and `fix` carry the specification's
defined semantics, while the additional common types classify other work. Use
another type only when the repository or user explicitly establishes it.

## Choose the scope

Name the narrow, stable product or engineering surface affected by the change. Prefer scope vocabulary already used by the author's recent PRs in the repository. Use lowercase kebab-case for multiword scopes.

Examples include `speakers`, `api`, `mcp`, `transcripts`, `agent`, and `media-agent`.

## Write the description

- Start with a lowercase imperative verb such as `add`, `expose`, `preserve`, `support`, `correct`, or `update`.
- Describe the outcome, not the implementation details.
- Keep it concise and omit the trailing period.
- Append a ticket reference only when it is known or supplied; never invent one.

For an explicitly breaking change, use `!` after the surface area:
`<type>(<surface-area>)!: <concise description>`.

Examples:

```text
feat(speakers): expose speaker read tools to MCP
fix(transcripts): preserve speaker data on speakerless caption uploads
chore(agent): update transcript editing guidance
docs(api): clarify transcript response formats
refactor(speakers): centralize speaker assignment writes
test(mcp): cover speaker tool discovery
style(frontend): format customization imports
perf(search): reduce speaker filter queries
ci(rspec): correct database cache detection
build(frontend): update Vite configuration
```

Before creating a PR, derive the title from the actual diff and intended outcome rather than copying the branch name. If the scope is unclear and recent merged PR titles are available, inspect a small recent sample from the same author and repository.
