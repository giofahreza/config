---
name: manual-test
description: Manually test an implementation against its requirements by really running it: Playwright MCP for frontend, curl for backend APIs, and the real command or trigger for CLIs, jobs and migrations. Called by doit after implementing and by review-pr; can also be run directly.
---

Run the changed behavior for real and report evidence. Arguments in $ARGUMENTS: optional extra instructions (for example a URL, an environment, "FE only").

Never report Passed without evidence you actually observed. If something cannot be run, report Not tested with the reason. Never fake a result.

## 1. Targets
Test targets, in this order of preference:
- The in-scope requirements, acceptance criteria and the ticket's test cases (QA-TC rows: title, steps, expected) from `get-ticket-context`. Run test cases as written.
- For `doit --review`: the behavior each fixed finding concerns.
- For `review-pr`: the requirements the PR claims, plus the behavior the diff changes.
If none of these are in the conversation, derive targets from the diff and say you did.

## 2. Choose the method per area changed
- **Frontend (pages, components, forms)**: Playwright MCP.
- **Backend HTTP endpoints**: curl.
- **CLI**: run the real command with realistic arguments; check output and exit code.
- **Jobs, consumers, cron**: trigger once locally and observe logs and read-only data effects.
- **Migrations**: apply on a local database, check the schema, roll back if a down migration exists.
- **Library or pure code**: targeted unit tests or a REPL call.
- **Config or docs only**: load or validate the config; say if there is nothing runnable.
A change that spans areas gets each method (for example an FE form that calls a new endpoint: curl the endpoint, then drive the form).

## 3. Environment and safety (hard rules)
- Test against a local or dev instance only. Never send write requests (POST, PUT, PATCH, DELETE) or create accounts or data on shared QA, staging or production. Read-only requests against a shared environment only if the user says to.
- Find how to run the project: use the `run` skill if available, otherwise README, Makefile, `package.json` scripts, docker-compose and CLAUDE.md. Start servers in the background and stop every process you started when done.
- Do not guess credentials, and do not print or save secrets or personal data. Read tokens from env vars or files without echoing them. If login or an account is needed and none is available, ask the user instead of creating real data.
- Do not edit project files to make the app run. If it cannot start (missing dependencies, database, env), report Not tested with the exact blocker.
- Do not branch-switch, stash or commit. Save evidence (screenshots, response bodies) in the session scratchpad directory or a temp folder outside the repo, never in the repo.

## 4. Scenarios
For each target run at least one happy path and one negative or edge path taken from the acceptance criteria (validation message, error state, empty state, permission, 4xx response). If the requirement is about i18n, check each locale touched. If the FE uses dummy data, test the states with it and say so.

## 5. Frontend with Playwright MCP
Load the tools first with ToolSearch (`select:mcp__playwright__browser_navigate,mcp__playwright__browser_snapshot,mcp__playwright__browser_click,mcp__playwright__browser_type,mcp__playwright__browser_fill_form,mcp__playwright__browser_select_option,mcp__playwright__browser_press_key,mcp__playwright__browser_wait_for,mcp__playwright__browser_take_screenshot,mcp__playwright__browser_console_messages,mcp__playwright__browser_network_requests,mcp__playwright__browser_resize,mcp__playwright__browser_close`).
- Navigate to the page, then use `browser_snapshot` to assert text, labels, field states and disabled/enabled buttons. Prefer the snapshot over screenshots for assertions.
- Drive the flow: fill, select, click, submit. Check validation and error states, not just the happy path.
- After each flow, read `browser_console_messages` for new errors or warnings caused by the change, and `browser_network_requests` for the expected calls (URL, method, status, payload) and no unexpected ones.
- Take a screenshot of each key state into the scratchpad folder. Resize only if a requirement concerns responsive behavior.
- Close the browser when done.

## 6. Backend with curl
- Use `curl -sS -i --max-time 20 -X <METHOD> <url> -H ... -d ...` against the local base URL.
- Check the status code, the body shape against the contract (fields, types, required values), and the error body and status for each negative case (400, 401, 403, 404, 409, 422 as the requirement implies).
- Verify side effects with read-only calls (GET or a read-only query through the project's existing tooling), not by editing data by hand.
- Keep tokens out of the output (read from env, redact in what you report).

## 7. Report
Return a table with one row per scenario: Target (requirement and source) | Scenario | Method (Playwright, curl, command) | Expected | Actual | Result (Passed, Failed, Not tested) | Evidence (screenshot path, curl status and a short redacted body, log line).
- For every Failed row, give the exact steps to reproduce.
- For every Not tested row, give the reason and what is needed to run it.
- Keep evidence short and redact secrets and personal data.

## 8. Clean up
Stop servers and processes you started, close the browser, and remove any local test data you created if that can be done safely. Check `git status` shows no test artifacts left in the repo.
