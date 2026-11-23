---
name: doit
description: Implement either the in-scope requirements from get-ticket-context (--ticket) or the validated findings from review-pr (--review) with the smallest change, reusing and copying existing code and following CLAUDE.md. Always plans first and always manually tests afterwards. Manual only.
disable-model-invocation: true
---

Implement work gathered by an earlier skill. Arguments in $ARGUMENTS: one source flag, `--ticket` or `--review`, plus optional extra instructions (for example "FE only", "use dummy data", "skip tests").

Goal: the smallest coherent change that covers the work list, written the way this project already writes code, as flat and inline as possible, with no helper or indirection that the work does not need. Nothing more. Plan mode is always used, for both sources, and every implementation is manually tested before the report (step 6).

## 0. Pick the source and check preconditions
- `--ticket`: the work list is the in-scope requirements from the `get-ticket-context` output in this conversation.
- `--review`: the work list is the validated findings from the `review-pr` output in this conversation.
- Both flags: stop and ask the user to pick one.
- No flag: use the latest of the two outputs in the conversation and write `Source: ticket requirements` or `Source: review findings` as the first line of the plan. If it is unclear (both exist and belong to a different ticket, PR or branch than the current checkout, or you cannot tell which is later), ask with AskUserQuestion. The plan approval in step 2 is the confirmation.
- If the output for the chosen source is missing, stop and tell the user which skill to run first (`get-ticket-context` or `review-pr`). Do not gather requirements or review the code yourself and do not start coding.
- Confirm you are in the right repo and on the intended working branch (`git status`, `git branch --show-current`). Do not switch branches, commit or push unless the user asks.

**Ticket source**
- The in-scope requirements are the only work. Requirements marked out of scope, belonging to another sub-task, or "scope unclear" are not implemented; ask about "scope unclear" ones.
- Source conflicts and still-open questions that touch the work: do not implement the disputed part and do not guess. Tell the user which item is disputed and who to ask, and continue with the undisputed requirements only if the user says so.

**Review source**
- The work list is the validated state, not the raw review. Apply everything the user said since the review: drop findings they rejected or said to skip, use changed priorities and wording, include findings they added. Items still under Needs validation are not implemented. If you are unsure whether a finding was accepted, ask.
- Findings that are not code changes (PR title, commit naming, empty PR description, base branch, anything that needs a decision) are not touched. List them as "skipped: not a code change".
- Staleness: compare the review's "Reviewed commit" line with `git rev-parse HEAD`. If they differ, or the review was `--local` and the working tree may have changed since, say so in the plan and re-locate each finding by its code, not by line number. Drop a finding whose code is no longer there and say so.
- `[PR]` and `[Local]` findings are both fixed in the working tree. Nothing is committed.
- Work in priority order, P0 first. Fix each finding with the smallest change that resolves it, which is not necessarily the reviewer's suggested fix. Group findings that touch the same lines. A finding that a requirement is "Not implemented" is implemented like any requirement, with the same rules below.

## 1. Read before writing (always, in this order)
Call `EnterPlanMode` before anything else (if its schema is not loaded, load it with ToolSearch `select:EnterPlanMode,ExitPlanMode`), so all exploration is read-only and nothing is edited before you approve a plan. A hook blocks file changes until this reading is done, so do it first and with the Read tool (not `cat`):
1. **Every CLAUDE.md that applies**: the repo root one and any in directories you will touch. Follow them exactly; they decide scope, structure and what not to do.
2. **Style, tooling and contribution docs** that exist: `.editorconfig`, eslint/prettier/ruff/golangci/tsconfig, lint and test scripts in `package.json`/`Makefile`, and `CONTRIBUTING.md` and the README's development section. Rules in CLAUDE.md and lint config win over the granularity rules in step 3 if they conflict (say so in the plan); a general sentence in CONTRIBUTING or the README does not.
3. **Existing code to reuse or copy.** Search the codebase before designing anything: grep for similar function, component, hook, util, constant, endpoint, i18n key and test names, and for the strings and fields in the work list. Find (a) whole units that already do the job or a distinct part of it (a component, hook, thunk, handler, endpoint, or util with its own purpose; not fragments to stitch together), and (b) the closest existing implementation of the same kind of thing (a similar component, page, thunk/store, endpoint, handler, migration, or test). Read both fully, plus the neighbours of every file you will edit. For the review source, also read the code around each finding.
4. **The data contract**: the request/response shape from the ticket, PRD, design artifact, `api-contract/` or backend code if present.
5. **Where each kind of logic lives in this repo.** For each kind you will write (validation, business rule, data access, request/response mapping), find the closest existing example and note which layer or package holds it, which validation library it uses, and how long and how nested its functions are. New code goes in the same layer and uses the same library.

In a large repo you may delegate the searching to an `Explore` subagent (find the closest existing implementation, the style config, the contract) to keep this context small. The hook only counts Read calls made in this main session, so after the subagent reports, Read the CLAUDE.md files and the 1 to 3 reference files it names yourself. Never rely on the subagent's summary of CLAUDE.md or style.

## 2. Plan, then get approval (mandatory)
Write a short plan that starts with the `Source:` line. Use a table: for the ticket source, requirement → file(s) → smallest change → reuse; for the review source, finding (priority, file:line) → file(s) → smallest fix → reuse. "Reuse" is what existing function or code it calls or is copied from, with file:line. Add the tests you will add, how you will manually test it (how the app is run, which local environment, and the scenarios from step 6), any dummy data and why, and the items you will not change (already satisfied, skipped as not code, dropped as stale or out of scope). Add two lines:
- **New functions**: each new function with its layer and its number of callers. A function with one caller needs a reason that step 3 allows, otherwise it is written inline.
- **Indirection**: each new callback, closure that writes to outer state, function-typed parameter, or interface with one implementation, with the reason from step 3 that allows it (repo idiom, the callee controls when it runs, import cycle) and the simpler option you considered; write `none` if there is none.
Check each row:
- Is it required by the work list? If not, drop it.
- Does an existing unit already do it (same purpose, not a fragment)? Reuse it (see the reuse order in step 3). Writing new code needs a reason only when such a unit exists; then say why it does not fit.
- If the current code already satisfies it, make no change and say so.
If something is ambiguous in a way that changes behavior, scope or data, the contract cannot be found or inferred, or a needed decision belongs to someone else, ask one focused question first (AskUserQuestion works inside plan mode). Do the same when the only way to satisfy a work item without restructuring existing code is an indirection (a callback, a closure over outer state, a function passed across layers, a new interface): do not choose it silently; ask whether the requirement can be read more simply or whether moving code is acceptable.

Call `ExitPlanMode` with the plan as the plan text and wait for the user's approval. Do not edit anything until it is approved. If the user rejects it or changes it, update the plan and submit it again.

## 3. Implement minimally
- Touch only files the plan names.
- **Reuse order, strictly in this order:**
  1. **Call or import what already exists**, unchanged (function, component, hook, util, constant, type, i18n key, datasource/thunk). Do not rewrite something that can be called.
  2. **Extend an existing one only if it almost fits**, and only with a tiny, backward-compatible change (an optional argument, a new case) that keeps the callers that remain after your change, and their tests, working. Grep its callers first: if your change moves its only caller, change the function in place instead of extending it. Prefer composing existing pieces over changing shared code.
  3. **Copy the closest existing implementation and adapt it**, when the work is a variation of something already built (another form field, list, page, thunk, endpoint, handler, test). Copy the real code, not a paraphrase: keep its file layout, naming, imports, ordering, error handling, i18n, state handling and test style, and change only what the work differs in. Tiny single-use wrappers are the exception (see Granularity, indirection and readability below).
  4. **Write new code last**, only where nothing existing applies, mirroring the neighbouring files.
- **When copying:** adapt everything (names, comments, strings, types, test titles); leave no leftover names, dead branches, unused imports or features from the source; do not copy parts the work does not need; do not "improve" the copied code; if the source looks buggy or outdated, copy its pattern anyway and mention it in the report instead of fixing it.
- Do not copy-paste a whole existing unit (a component, handler, query) that could be called as it is. This does not apply to tiny code: a few similar lines are fine.
- Do not add abstractions (helper functions, callbacks or function-typed parameters without a reason from the rules below, closures that write to outer state, interfaces with no second implementation or test fake, combinator or rule-table frameworks), configuration, feature flags, dependencies, new files, error handling or edge-case work that nothing in the work list asks for. Do not refactor, rename or reformat unrelated code. Do not "improve" code you were not asked to change.
- Stay in your layer: do not implement another sub-task's work (for example BE endpoints while doing an FE sub-task, or the reverse).
- Keep the existing style (naming, layout, formatting, conventions) even where you would choose differently. The rules below decide how much to split, not the neighbours' habits.
- Text for users follows the project's i18n approach (add keys in every locale the project keeps).

**Granularity, indirection and readability**
- **Inline by default.** Write the code where it is used. Extract a function only when it has 2 or more callers in this change, or an interface or framework hook requires it, or the function does several distinct steps and is hard to follow in one read (then split by step, each step a real named unit). Never add a function with one caller just to name a step, wrap one call, or discard a return value.
- **Do not copy tiny single-use wrappers.** When the closest existing implementation has one (for example a `Validate()` method on a request struct with one caller, or a 5-line helper used once), copy its structure and conventions but write the code at the call site. Keep the wrapper only if other code needs it (an interface, a framework hook, 2 or more callers).
- **No mode flags.** No boolean or mode parameter that picks behavior for different callers, and no wrapper that exists only to give one value of it a name. A flag is allowed only if each value has 2 or more callers or the repo already does the same; otherwise change the function in place, or split it. A boolean that is plain input data (for example `isActive`) is fine.
- **Orphans.** When your change moves or removes the last production caller of a function, type, field, constant or test helper, change or delete it, and its tests, in the same change. Grep its callers before you keep it, and do not keep code alive only for its own test. A test must be able to fail: do not write one that sets a value no code reads.
- Two or three similar lines are fine; do not extract them. No mini-frameworks (combinators, rule tables, generic helpers) unless the repo already uses that pattern or there are about 5 or more identical cases.
- **Pass data across layers, not behavior.** For a function you define, the default is to take data and return results. A callback or function-typed parameter needs a stated reason, one of:
  - the repo already does the same, or the language or framework idiom requires it;
  - the callee must control when, whether or how many times it runs (a transaction, retry, lock, lazy or per-item work);
  - it breaks an import cycle through an interface with 2 or more implementations (a test fake counts as the second).
  Calling stdlib or framework APIs that take functions (sort, map, transactions, handlers) is always fine. If a callback has one call site, runs exactly once and synchronously, and only produces a value, pass the value or return it instead. Never hand a result back by writing it to an outer variable inside a closure; return it. An interface needs a second implementation or a test fake. Otherwise prefer moving the data, or the small piece of code, to the layer that needs it.
- **Keep logic in its layer** (the examples from step 1.5). Validation goes where the repo validates and uses the repo's validation library; check what it offers before writing helpers. Business decisions never go in the repository or data layer, which only loads and saves. If a transaction or lock seems to force logic into the data layer, stop, say so in the plan, and ask.
- **Flat flow.** Use guard clauses and early returns before extracting anything (aim for nesting of 3 or less). No assignments inside conditions except `err`. Give a repeated long expression a short local name.

## 4. Dependencies that do not exist yet
Check whether the dependency really is missing before deciding (search `api-contract/`, the backend code, the ticket and PRD). Do not assume.
- **FE, endpoint exists**: use it through the project's existing data layer.
- **FE, endpoint does not exist yet**: do not build or mock a backend. Choose the lighter of:
  - **Slicing only**: build the UI from props and local state, with no data layer, when the work is about layout, states and copy.
  - **Dummy data**: when states need data to render (lists, filters, details). Put it in one clearly named place (for example `<feature>.mock.ts`), shaped exactly like the contract from the ticket or PRD, returned through the same function signature the real call will use, so replacing it is a one-place change. Mark it `// TODO(<TICKET-KEY>): replace with <METHOD /path>`. Use no fake business logic beyond displaying the data, and no mock server or MSW unless the repo already uses it.
- **Other layers (BE, jobs, etc.)**: do not create what another sub-task owns (a migration, another service). Code against the agreed contract and note the dependency. If it blocks the work, ask.
Say in the report exactly what is real and what is dummy.

## 5. Tests and checks
- Add or update focused tests only where they prove a requirement or a fix, or prevent a likely regression, in the project's existing test style. Do not write tests that merely mirror the implementation. For the ticket source, use the ticket's test cases (from get-ticket-context) as the source for what to cover when present.
- Run the most targeted relevant test, typecheck and lint for the files you changed. Run the full suite only if targeted checks are not enough. If something cannot run (missing install, broken lock file), say so; do not claim it passed.

## 6. Manual test (always)
After the automated checks, run the `manual-test` skill on the work list: Playwright MCP for FE changes, curl for BE endpoints, and the real command or trigger for anything else (CLI, jobs, migrations). Use the manual test plan the user approved in step 2. Local or dev environment only; follow the safety rules of `manual-test`.
- If a scenario fails, fix the cause within the plan's scope, keeping the reuse and minimal-change rules, and rerun it. Stop after 3 rounds on the same failure and report it.
- If it cannot be run (app will not start, missing credentials, no local backend), report Not tested with the exact blocker. Do not claim it works.
- Never skip this step. Only the run itself can be reported as impossible.

## 7. Verify and report
- **Ticket source**: walk every in-scope requirement and acceptance criterion: Implemented (file:line), Partially implemented (what is missing and why), or Not implemented (why: disputed, blocked, out of scope).
- **Review source**: walk every finding: Fixed (file:line, pending re-review), Not fixed (why), or Skipped (why: not a code change, needs validation, stale). Never call a P0 or P1 resolved on your own; say it needs a re-review, and tell the user to run `review-pr --local` (or push and run `review-pr`) to confirm.
- Read `git diff` (staged and unstaged, plus untracked files from `git status`) and remove anything that is not needed for the work list. Remove edits no work item asked for (renames, reformatting, reordering).
- Structure check on the diff. List every new function with its caller count and inline the ones with a single caller unless step 3 allows it; list new callbacks, function-typed parameters, closures that write to outer variables and new interface methods, and give each its allowed reason from step 3 or replace it with data; list nesting deeper than 3 and assignments inside conditions; list boolean or mode flag parameters; list every function, type, field, constant or test helper that your change left without a production caller (grep the callers of each thing whose caller you moved or removed); list logic that sits in a layer where the repo does not keep that kind of logic. Fix each one or justify it in the report.
- Report briefly: changed files, what was reused or copied from where (file:line) and what is new code and why, the checklist above, tests/lint/typecheck run and results, the manual test table from `manual-test` (Passed, Failed, Not tested, with evidence), what is dummy, and unresolved risks or questions. Do not commit, push or open a PR unless asked.
