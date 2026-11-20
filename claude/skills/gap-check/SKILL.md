---
name: gap-check
description: List the missing or half-done features of the current work (local changes or a PR) against the ticket, PRD, QA test cases, docs and what was discussed in the conversation. For each point gives the requirement source, the problem, what to do, and a critical verdict on whether it is needed. Read-only. Use when asked what is missing, to validate work against requirements, or to list missing features or criteria.
---

Find what is missing in the work in $ARGUMENTS, compared with what was asked for. Arguments: optional PR URL or number, optional ticket key or links, optional extra instructions (for example "FE only"). No arguments means: the current local work.

This skill only reads and reports. It does not edit code, run the app, post comments or judge code quality, style, security or PR naming (that is `review-pr`). Write in simple, short, plain English.

## 1. Pick the code to compare
- **No PR given**: the current work is the diff against `git merge-base HEAD origin/<default branch>` (default branch from `git symbolic-ref refs/remotes/origin/HEAD`), which covers commits ahead, staged and unstaged changes, plus untracked files from `git status --porcelain` (read them with the Read tool). Skip lock files, build output and binaries, and say what you skipped.
- **PR given**: read it with `zsh -ic 'gh-nikel pr view <pr> --json title,body,headRefName,baseRefName,files,commits'` and `zsh -ic 'gh-nikel pr diff <pr>'` for repos owned by `impact-credit-solutions` (plain `gh` for any other owner). `gh-nikel` is a zsh function, so run it through an interactive zsh from inside a relevant checkout. If the PR is in another repo, use `--repo <owner>/<repo>`.
- If there is no change to compare, say so and stop. Do not switch branches, stash, reset or commit.
- Read the changed files in full, not only the diff hunks, and read the code they call when a requirement depends on it. A requirement may be met by code the diff does not touch.

## 2. Gather what was asked for
- Call the `get-ticket-context` skill with the ticket key and links from the arguments, branch name, PR title or description, or local commit messages. If its output for this ticket is already in the conversation, reuse it and do not call it again. Its scope rules apply as they are (a sub-task assigned to the user counts only its own requirements).
- Add the **conversation** as a source: decisions, requirements and changes the user stated in this session, and any docs they pasted. Label these `Conversation` and quote the words briefly. If the conversation contradicts a document, treat it as a source conflict (step 3), not as an override.
- If no ticket or document can be found, say so and use the conversation and the code only. Do not invent requirements.

## 3. Compare requirement by requirement
For every in-scope requirement, acceptance criterion and test case, decide from the code you read:
- **Done**: the code does what the source asks. Count it, do not list it.
- **Partly done**: some of it exists. A feature that runs on dummy data or is not connected to its endpoint is partly done, and the point says so.
- **Missing**: nothing in the code does it.
Rules:
- If any source (PRD, ticket, artifact, design, test case, conversation) asks for more than the code does, it is missing or partly done. Do not excuse it as "later" or "another ticket" unless a source says so.
- If sources conflict with each other (use "Source conflicts" from `get-ticket-context`, or a conflict you find with the conversation), do not decide which is right and do not count the code against it. Put it under Need to confirm with both statements, each source, who owns each, and who to ask.
- Judge from the code, not from file names, comments or the PR description. Name what you checked.
- Check that each test case from the ticket has matching behavior in the code. Only say a test (automated) is missing if a source asks for tests.

## 4. Judge each gap critically
For every Missing or Partly done point, decide whether it is needed. Argue against the requirement, do not just repeat it. Look at: how strong the evidence is (one place or several), whether a later comment or doc replaces it, whether it is vague or contradicts the rest of the flow, whether another sub-task or story owns it, whether a source marks it optional, and whether a QA case or acceptance criterion depends on it.
Verdicts:
- **Needed**: a core requirement or acceptance criterion, or something a QA test case checks.
- **Needed, small**: required, but a user rarely hits it (a wording, an edge state).
- **Questionable**: weak or one-sided evidence (only one place, older than a later comment, vague, odd for the flow). The reason says what to check and with whom.
- **Not needed**: owned by another sub-task or story, handled elsewhere, or pointless. The reason must cite the proof (for example "GJ-1490 owns this", "comment of 3 Nov replaces it", "PRD says optional").
Never drop a point silently. "Not needed" and "Questionable" always cite proof. With no proof, the verdict is Needed or Questionable. The verdict is a judgment for the user to overrule, so say it plainly and show why.

## 5. What to do
For each point give the smallest change that closes it, naming existing code to reuse or copy with file:line (search the codebase for the closest existing implementation before answering). If the dependency does not exist yet, say what is possible (slicing or dummy data for FE) and what needs another team. Do not design beyond the point.

## Output
Start with one line: `Compared: <what> (<N files, commit or PR>) against <sources>` and one line with the count, for example `12 of 17 requirements done · 3 missing · 2 partly done`.

Then the points, in this order: Needed (core first, then small), Questionable, Not needed. Number them. Each point is a block, not a table:

> **1. <short name of the feature or criterion>**
> - **Source:** <exact place: QA-TC row 14, PRD §3.2, GJ-1554 AC #2, Conversation: "...", Figma frame> (link or key)
> - **Problem:** <what is missing or half-done, in simple words, and what was checked in the code>
> - **What to do:** <smallest change, with the existing code to reuse or copy (file:line)>
> - **Needed:** <verdict>. <one or two sentences of reason, with proof when Not needed or Questionable>

After the points:
- **Need to confirm**: each source conflict: topic, statement A (source, owner) vs statement B (source, owner), what the code does now, who to ask. Omit if none.
- **Couldn't check**: sources that were unreadable, and requirements that cannot be judged from code (for example visual details with no design access). Omit if none.

Do not list Done items. If the user asks for the full list, give a short table of Source → Requirement → Status → Evidence. If nothing is missing, say so in one line with the count and what was checked.

After the report, say that `doit --ticket` can implement the Needed points, and that nothing was changed or posted.
