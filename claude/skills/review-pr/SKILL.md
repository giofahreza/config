---
name: review-pr
description: Brutally review a GitHub pull request given its link. Fetches the PR, gets ticket context, checks the PR covers the requirements, and checks it follows repo rules (CLAUDE.md) and code style. Use when asked to review a PR or given a PR URL to review.
---

Review the PR in $ARGUMENTS (URL or number). Add `--local` to also review uncommitted and unpushed local work, or use `--local` alone to review local work before any PR exists (see step 1b).

## Stance
Review brutally. Assume the PR is wrong until the evidence shows otherwise. Be direct and blunt about every problem, without softening, praise padding or "consider maybe" phrasing. Attack the design, not the author. Do not approve to be polite: if a requirement is missing, a rule is broken, or a risk is unproven, say so and request changes. Every claim must cite file:line or a requirement. Do not invent problems; brutal means rigorous, not noisy.

## 1. Read the PR
If no PR was given (`--local` alone), skip this step and go to step 1b.

Always use `gh-nikel` for repos owned by `impact-credit-solutions`; use plain `gh` for any other owner. `gh-nikel` is a zsh function in `~/.zshrc`, so it is not available in the Bash tool directly. Run it through an interactive zsh:
- `zsh -ic 'gh-nikel pr view <pr> --json title,body,headRefName,baseRefName,files,commits'`
- `zsh -ic 'gh-nikel pr diff <pr>'`

It passes all arguments to `gh` with `GH_CONFIG_DIR=$HOME/.config/gh-nikel`. Note it also runs `git config user.email` in the current directory, so run it from inside a relevant repo checkout, not from an unrelated repo.

If the PR is in another repo than the working directory, use `--repo <owner>/<repo>`, and read repo rules from a local checkout only if one exists; otherwise fetch CLAUDE.md via `gh-nikel api` (or `gh api` for other owners).

## 1b. Local changes (only with `--local`)
Use this when $ARGUMENTS contains `--local` or the user says to include local changes. Without it, ignore the working tree completely.

**With a PR (`<PR> --local`): review the PR plus what is on top of it locally.**
- Work inside the PR's repo checkout. Do not switch branches, stash, reset or commit.
- Check the checkout matches the PR: `git branch --show-current` against `headRefName`, and that the PR head (`headRefOid`) is HEAD or an ancestor of HEAD (`git fetch origin pull/<n>/head`, then `git merge-base --is-ancestor <headRefOid> HEAD`). If it is not, stop and tell the user the local changes are not on top of this PR (different branch or diverged); offer to review the PR only or the local changes only.
- Collect the local delta: commits ahead of the PR head (`git log --oneline <headRefOid>..HEAD`, `git diff <headRefOid>..HEAD`), staged changes (`git diff --cached`), unstaged changes (`git diff`), and untracked files from `git status --porcelain` (read them with the Read tool). Skip lock files, build output, binaries and files over about 1000 lines unless they matter; say what you skipped.

**Without a PR (`--local` alone): review local work before it is pushed.**
- Base is `git merge-base HEAD origin/<default branch>` (default branch from `git symbolic-ref refs/remotes/origin/HEAD`). The diff is `git diff <base>` (commits ahead, staged and unstaged) plus untracked files.
- The ticket key comes from the branch name or local commit messages. No `gh` call is needed. There is no PR title to check: in step 6 check the local commit messages and suggest a PR title instead.

Then review the combined change (PR diff plus local delta, or the local diff alone) through steps 2 to 7. Tag every finding `[PR]` or `[Local]`, and in the coverage table mark evidence that exists only locally with `(local)`.

## 2. Get ticket context
Invoke the `get-ticket-context` skill, passing the ticket key and any links found in the PR title, branch name, and description. If no ticket is found, say so and skip step 3.

## 3. Requirement coverage
For each requirement and acceptance criterion from the context, mark it:
- Implemented (cite file:line)
- Partially implemented (what is missing)
- Not implemented
Rules:
- If any requirement source (PRD, ticket, artifact, design, test case) asks for more than the code does, that is **missing implementation**. Report it as a finding; a requirement marked "Not implemented" or "Partially implemented" is P0 or P1 (P0 if it is a core requirement or acceptance criterion). Do not excuse it as out of scope, to-be-done-later, or implemented by another ticket unless a source explicitly says so.
- If requirement sources conflict with each other (use the "Source conflicts" section from `get-ticket-context`), do not decide which one is right and do not count the PR as implemented or missing against a disputed requirement. List it separately under **Needs validation**, with both statements, their sources, and the owner of each, and say who must be asked. Judge the PR against only the requirements that are not disputed.
Also flag changes in the PR that no requirement asks for. Check that test cases listed in the ticket have corresponding tests.

## 4. Repo rules and style
- Read CLAUDE.md files that apply to the changed paths (root and subdirectories).
- Read configured style tooling that exists in the repo (e.g. `.editorconfig`, eslint/prettier/ruff/golangci config, lint scripts) and check the diff against it. Run the linter on changed files if it is cheap.
- Report violations with the rule they break.

## 5. Correctness
Scrutinize the diff line by line for bugs, unhandled errors, race conditions, edge cases, security issues, data-loss risks, backward-compatibility breaks, performance problems, dead code, and unnecessary complexity or scope creep. Challenge every new abstraction and dependency. Flag tests that only mirror the implementation or would not fail if the code were wrong. Skip only nitpicks that a configured linter already catches.

## 5b. Security (frontend and backend)
Review every changed line for security issues, in addition to step 5. Trace untrusted input from where it enters (request, URL, form, storage, third-party response) to where it is used (query, command, file path, HTML, redirect, log, response). Cover only the areas the diff touches; read the surrounding code (auth middleware, validators, shared helpers) before calling something missing, because the protection may already exist upstream. Do not report a generic risk with no path through this code.

**Backend**
- Authentication and authorization on every new or changed endpoint, handler, job or consumer: missing auth, missing role or permission check, and object-level access (IDOR: an id from the request used without checking it belongs to the caller or tenant).
- Injection: SQL/NoSQL built from strings, shell or process commands, template injection, path traversal in file paths or uploads, SSRF in server-side fetches of user-supplied URLs, unsafe deserialization, XML external entities.
- Input validation at the boundary: missing or weak validation of type, length, range and format; mass assignment (binding a whole request body to a model or update).
- Secrets and data exposure: hardcoded secrets or keys, tokens or personal data in logs, error messages or stack traces returned to clients, response bodies that return more fields than the contract or the caller may see.
- Sessions and tokens: weak or missing expiry, tokens in URLs, missing CSRF protection on cookie-authenticated state changes, unsafe CORS (wildcard origin with credentials), missing rate limiting or lockout on login, OTP, reset and other abuse-prone endpoints.
- Crypto and data handling: homemade crypto, weak hashing for passwords, predictable ids or tokens, `Math.random` or similar for security values, disabled TLS verification, sensitive data stored or sent in clear text.
- Dependencies and config: new or upgraded dependencies with known vulnerabilities (check the lock file diff; run the repo's audit command only if it is cheap), debug or permissive settings enabled in non-local config.
- Data changes: migrations or queries that expose, delete or widen access to data.

**Frontend**
- XSS: `dangerouslySetInnerHTML`, `innerHTML`, `v-html`, unsanitized HTML or markdown rendering, user input in `href`/`src` (`javascript:` URLs), dynamic script or style injection.
- Open redirects: navigation or `window.location` from a query parameter or response value without an allowlist.
- Sensitive data on the client: tokens, passwords, OTPs, personal data or API keys in `localStorage`/`sessionStorage`, URLs, query strings, console logs, analytics events, source maps, or committed env files; secrets in `NEXT_PUBLIC_*`, `VITE_*` or similar public env vars.
- Trusting the client: authorization or business rules enforced only in the UI (hidden or disabled buttons, route guards) with no matching server check; client-side price, role or status values sent to the server as truth.
- Requests: credentials or tokens sent to third-party origins, missing CSRF handling for cookie auth, unsafe `postMessage` handlers (no origin check), insecure iframes or `target="_blank"` without `rel="noopener"`, user-controlled data in `eval`, `new Function` or dynamic imports.
- Input handling: file upload type and size checks only on the client, validation messages or error handling that leak whether an account or record exists (user enumeration).

**Priority**
- **P0**: a reachable exploit through the changed code: auth bypass, IDOR, injection, secret or personal data exposure, stored or reflected XSS.
- **P1**: a security weakness that needs a condition to exploit (missing rate limit on an OTP or login endpoint, weak validation, sensitive data in logs or storage, a client-only authorization check on a sensitive action).
- **P2**: a hardening gap with limited impact (missing security header, verbose error, overly broad CORS on a non-sensitive endpoint).
Each security finding gives `file:line`, the attack path in one or two sentences (who sends what and what they get), and the fix. Tag the category (for example `Security: IDOR`) in the finding. If a security-relevant requirement is in the ticket (permissions, validation, masking), it is also checked in step 3.

## 6. PR naming and commit standard (commitizen / Conventional Commits)
Check the PR title first, then the commit messages (`commits` from step 1). If the repo defines its own convention (a commitizen config such as `.cz.toml`/`pyproject.toml`, commitlint config, or a rule in CLAUDE.md or a PR template), that overrides the defaults below.

PR title format: `<type>(<scope>): <description>`; the scope is optional.
- **type** is one of: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`. It must match what the PR actually does (e.g. a bug fix titled `feat` is wrong; a new capability titled `fix` is wrong).
- **scope** is a short noun for the area changed (module, service, page), lowercase, no spaces.
- **description** is imperative, present tense ("add", not "added" or "adds"), lowercase first letter, no trailing period, concise (about 72 characters or less, not counting the trailing ticket key), and says what the change does, not how or why.
- A breaking change is marked with `!` before the colon (`feat(api)!: ...`) and/or a `BREAKING CHANGE:` footer in the body. Flag a PR that breaks behavior, an API or a contract but is not marked.
- The title must describe the whole PR. Flag vague titles ("update", "fix bug", "changes", "wip") and titles that name only one part of a multi-part change.
- Flag a PR that mixes unrelated types (for example `feat` and `refactor` of unrelated code) and should be split.
- The ticket key goes at the end of the title in parentheses, e.g. `feat(registration): route borrower registration to onboarding service (LC-2075)`. Flag a missing key, or a key at the start of the title, inside the scope, or in another format (including square brackets). Some older titles in the repo history use `[KEY]`, but parentheses are the standard to apply here. A repo-specific convention found in step 6 (commitlint, CLAUDE.md, PR template) still overrides this.

Commit messages follow the same format. Body and footers are optional but a footer such as `BREAKING CHANGE:` or `Refs: <ticket>` must be well-formed when present. Flag `fixup!`, `wip`, `merge` or `update` commits that would end up in the history if the repo does not squash. If the repo squash-merges, the PR title is what lands in history, so weigh the title more than the individual commits.

For every naming problem, give the corrected title or message. Priority: every naming finding in this step is P1, regardless of how minor.

## 7. Manual test (always)
Run the `manual-test` skill on the requirements the PR claims and the behavior the diff changes: Playwright MCP for FE, curl for BE endpoints, the real command or trigger for anything else. Follow its safety rules (local or dev environment only, no writes to shared environments).
- Also try the security suspicions from step 5b that can be checked safely on the local or dev instance: for example call a changed endpoint without a token or with another user's id, send an over-long or malformed value, or enter `<script>`-style text in a changed field and see whether it renders. Keep probes minimal and non-destructive; never run scanners, brute force or load against any environment. A suspicion that cannot be tested stays a code-reading finding and is marked "not exploited, from code".
- The code has to be what is running. Test only when the checkout is at the PR head, or with `--local`. Do not switch branches or create worktrees on your own; if the checkout is elsewhere, report Not tested with that reason and ask the user whether to test another way.
- A Failed scenario is a finding with the reproduction steps from `manual-test`: P0 if it breaks an acceptance criterion or core behavior, otherwise P1. Source: manual test.
- Not tested is not a pass. Say why, and say it in the verdict reason.

## Output
- **Verdict**: approve / request changes / reject, with a one-line blunt reason. Approve only if there are no P0 or P1 findings.
- **Requirement coverage**: table with columns, left to right: Source → Requirement → Status → Evidence. Source is where the requirement comes from: test case (sheet/tab and row), PRD (page and section), ticket ID, artifact, Figma, or other, with a link or key. Status is Implemented / Partially implemented / Not implemented.
- **Reviewed commit**: the PR head sha (or `git rev-parse HEAD` for a local-only review), and with `--local` a note that uncommitted changes were included. Later skills use it to detect a stale review.
- **Local changes reviewed** (only with `--local`): the files included (committed-ahead, staged, unstaged, untracked), anything skipped, and any warning such as a branch mismatch. Omit this line without `--local`.
- **Findings grouped by priority**, in this order. With `--local`, prefix each finding with `[PR]` or `[Local]`. Merge bugs, security issues, requirement gaps and rule/style violations into one list per level. Each finding: `file:line`, problem, why it matters, fix. Omit empty levels, but state the count per level at the top (e.g. `P0: 1 · P1: 3 · P2: 2 · P3: 4`).
  - **P0 – Blocker**: must not merge. Data loss, security hole, crash or outage risk, broken core requirement, or an unmet acceptance criterion.
  - **P1 – Major**: must fix before merge. Likely bug, missing requirement, missing or fake tests for changed behavior, violation of a CLAUDE.md rule, breaking change.
  - **P2 – Moderate**: should fix. Poor design, unnecessary complexity, edge cases, performance issues, unrequested scope creep.
  - **P3 – Minor**: nice to fix. Style or naming not caught by the linter, small cleanups.
- **Manual test results**: the table from `manual-test` (Target, Scenario, Method, Expected, Actual, Result, Evidence). Failed rows also appear in the priority list above.
- **PR naming**: the current PR title, pass/fail against the standard, and a suggested corrected title. Add commit message problems with their corrected messages. Naming findings also appear in the priority list above.
- **Needs validation**: each conflict between requirement sources: topic, statement A (source, owner) vs statement B (source, owner), what the PR currently does, and the person to ask. Say "none" if there are none.
- **Unreadable context / open questions**

Findings tagged `[Local]` sit on lines that are not in the PR yet, so they cannot be posted to the PR until the changes are pushed.

Do not post comments or approve on GitHub unless asked.
