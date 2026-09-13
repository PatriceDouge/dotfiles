---
name: agent-browser
description: Drive a real browser from the CLI with agent-browser to navigate, click, fill forms, inspect accessibility snapshots, capture screenshots, validate UI changes, scrape pages, and test Electron apps. Use for browser automation or hands-on UI verification, in preference to playwright-cli, Chrome DevTools MCP, and Playwright MCP unless the user or repository explicitly requires another driver.
---

# Agent browser

Use `agent-browser` as the default browser driver.

## Load the bundled reference first

Before the first browser command in each task, read the version-matched core skill. Do not reconstruct the command surface from memory.

```sh
agent-browser skills get core --full
```

List and load a specialized bundled skill when the task needs one:

```sh
agent-browser skills list
agent-browser skills get dogfood
agent-browser skills get electron
```

Use `dogfood` for systematic exploratory testing and `electron` for desktop apps such as VS Code, Slack, Discord, or Figma.

## Combine with repository instructions

Let repository `AGENTS.md` files and repo-local skills own URLs, accounts, fixtures, login flows, and environment setup. Let this skill own browser-driving mechanics.

For `wistia/wistia`, follow the repo's `agent-login` skill for authentication and security boundaries. Drive the resulting flow with `agent-browser`; do not replace user-visible UI verification with direct API, GraphQL, or database mutations.

## Working rules

- Snapshot to decide; screenshot to show. Use accessibility snapshots for refs and semantic structure. Use screenshots for layout inspection or human evidence.
- Prefer semantic locators such as role, label, text, and test ID over brittle CSS selectors.
- Observe the result of each meaningful action before claiming success.
- Exercise the flow as a user would unless the user asks for a lower-level diagnostic.
- Close the browser session when finished so later tasks do not inherit stale state.
- Do not install or upgrade browser tooling without user approval when that would download software or mutate the global environment.

## Troubleshooting

- If no browser is installed, use `agent-browser install` after obtaining any required approval.
- If behavior differs from the bundled reference, inspect `agent-browser --version` and reload `agent-browser skills get core --full`.
- If a repository-specific prerequisite fails, report that prerequisite rather than claiming the UI flow failed.
