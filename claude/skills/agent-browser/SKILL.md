---
name: agent-browser
description: Drive a real browser from the CLI with agent-browser — navigate, click, fill forms, snapshot, screenshot, validate UI changes, scrape pages. This is the default browser driver in every repo, in preference to playwright-cli, Chrome DevTools MCP, and Playwright MCP. Use for any browser automation task.
---

# agent-browser

`agent-browser` is the browser driver. Reach for it for **every** browser task, in every repo — in preference to `playwright-cli`, Chrome DevTools MCP, and Playwright MCP.

## Load its bundled skill first — every time

The CLI ships skills that are version-matched to the installed binary. Read them before running commands. Do not reconstruct the flag surface from memory; your memory of it will be wrong, and the bundled skills move with the binary.

```sh
agent-browser skills get core --full   # do this before the first command
agent-browser skills list              # core, dogfood, electron, slack, agentcore, vercel-sandbox
agent-browser skills get dogfood       # systematic exploratory testing of a web app
agent-browser skills get electron      # VS Code, Slack, Discord, Figma desktop apps
```

This skill deliberately does not duplicate the command reference. `skills get core --full` is the reference.

## What this skill owns, and what the repo still owns

agent-browser does the **driving**. It does not replace repo-specific knowledge:

- **wistia/wistia** — the `agent-login` skill still owns authentication (`bin/agent-login-url`, session refresh) and the discipline of driving the UI like a real user instead of shortcutting through curl, GraphQL mutations, or DB writes. Take the auth flow and those norms from `agent-login`; do the actual clicking with agent-browser rather than the browser MCPs it names.
- **Any repo with its own browser skill** — take its URLs, fixtures, and setup steps. Still drive with agent-browser.

If a repo skill and this one disagree about *how to click something*, this one wins. If they disagree about *what URL, what account, what setup* — the repo wins.

## Working rules

- **Snapshot to decide, screenshot to show.** The accessibility snapshot is what you act on — it gives you refs and semantic structure. Screenshots are for showing a human, or when layout itself is the thing in question. Don't burn turns eyeballing pixels to find a button.
- **Prefer semantic locators** (role, label, text, testid) over brittle CSS selectors.
- **Never claim an outcome you didn't observe.** If a click failed, a page didn't load, or an element wasn't found, say so plainly. A fabricated "it works" is worse than a failed step.
- **Close the session when done** so the next task doesn't inherit a stale page.

## When it misbehaves

- Commands failing because there's no browser → `agent-browser install`.
- Behavior that doesn't match the docs → check `agent-browser --version`. It's installed globally via npm (`npm ls -g agent-browser`), so `npm i -g agent-browser@latest` upgrades both the binary and its bundled skills.
