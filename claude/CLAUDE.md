# Personal coding preferences

## Scope

- Implement the requested behavior with the smallest coherent change.
- Work only within the requested scope; do not refactor unrelated code.
- Reuse existing patterns, helpers, dependencies, and file structure.
- Add a dependency, abstraction, configuration, or file only when the request or existing architecture requires it.
- Do not add speculative hardening, generalized frameworks, or hypothetical edge-case work.
- If the current behavior already satisfies the request, make no changes.
- If ambiguity would change behavior, scope, data, or external effects, ask one focused question; otherwise choose the least invasive interpretation.

## Execution

- Inspect the relevant files first and expand the search only when evidence requires it.
- Run the most targeted relevant test, typecheck, or lint command after editing. Run the full suite only when targeted checks are insufficient.
- Add or update focused tests when they prove changed behavior or prevent a likely regression; do not create tests that merely mirror the implementation.
- Before finishing, verify the acceptance criteria and inspect the diff for unrelated changes.
- Report changed files, validation performed, and unresolved risks briefly.

# Implementation style

- Solve the user's stated request directly with the smallest coherent change.
- Reuse existing code, patterns, and dependencies.
- Do not refactor unrelated code.
- Do not add abstractions, configuration, dependencies, or features speculatively.
- Ask a question only when ambiguity would change behavior or scope.
- Make reasonable assumptions and state them briefly.
- Run focused validation relevant to the change.
- Inspect the final diff for unrelated edits.
- Keep the final response concise: summarize changes, validation, and any remaining issue.
