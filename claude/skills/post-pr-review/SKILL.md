---
name: post-pr-review
description: Post the validated output of the review-pr skill as comments on the GitHub PR. Manual only; run after review-pr and after you have validated its findings.
disable-model-invocation: true
---

Post the findings from the `review-pr` skill to the PR as line-by-line review comments, with no summary comment. Optional arguments in $ARGUMENTS: extra instructions (for example "request changes", "skip P3").

## 0. Preconditions

- Look in the current conversation for a `review-pr` output (the Verdict, the P0-P3 findings, Requirement coverage, PR naming, Needs validation) and the PR it reviewed (URL or number, repo, head commit).
- If there is no `review-pr` output in this conversation, stop. Tell the user to run `review-pr` first. Do not review the PR yourself and do not post anything.
- If the review covered a different PR than the one in $ARGUMENTS, stop and say so.

## 1. Build the final comment set from the validated state

The conversation after `review-pr` is the source of truth, not the original output. Apply everything the user said since the review:

- Findings the user rejected, said were wrong, or said to skip: drop them.
- Priorities the user changed: use the new priority.
- Findings the user clarified or reworded: use their wording.
- Findings tagged `[Local]` (from `review-pr --local`) are on lines that are not in the PR, so do not post them. List them in the draft preview as "not posted: local change, push first" and tell the user to push and run `review-pr` again if they want them posted.
- Items under **Needs validation** that the user resolved: restate as a normal finding or drop them, as the user decided. Items still unresolved: do not post them; mention them to the user in the draft preview as "not posted: still needs validation" so the user can decide.
- Anything the user added: include it.
If you are unsure whether a finding was accepted, ask before including it.

## 2. Draft

- **Language and tone**: write every comment in Indonesian, casual and human-like, the way a teammate would write in a PR thread: when the commenter refers to themselves, always use "gw" (never "saya", "aku" or "gue"), e.g. "gw kurang paham kenapa ini dibikin gini", "kayanya better di tes ulang deh menurut gw"; use relaxed everyday wording ("ini kayaknya bakal error kalau...", "ini belum ke-handle ya", "tolong dicek lagi"), contractions like "nggak", "udah", "bisa jadi". Short sentences, no corporate or stiff phrasing, no emoji spam (at most one occasionally), no lecturing. Still be direct and clear about what is wrong, why, and the fix; casual does not mean vague or soft on blockers. Write as a peer talking to a peer at the same level: friendly and casual, softening with words like "kayanya", "deh", "better", "coba", "ya", and phrasing issues as suggestions or observations ("kayanya ini bakal error kalau..."), not orders or accusations, while still stating clearly what the problem is and why. Register: more slang than textbook Indonesian, but not too slang. Use everyday spoken forms such as "waktu" (not "begitu/ketika"), "tapi" (not "sementara/namun"), "gaada" (e.g. "gaada di tiket", not "nggak diminta di tiket"), "route" (not "jalur"), "tetep", "liat", "pake", "kalo", "ato", "emang", "palingan", "jadi", "aja", "bahaya" (not "rapuh"), "tenggelam" (not "ketelen"). Avoid heavy slang (no "bgt", "wkwk", "anjir", no chat abbreviations beyond "gw"). Be respectful and never blaming. (1) Never use "lo" (or "kamu"/"kalian") to address the author; refer to the thing instead: "PR ini", "changes disini", "tiket ini", "bagian ini", "kodenya". (2) Never write an interrogative that puts the author on the spot ("ini sengaja ato gimana?", "emang gini ato gimana?"). When intent is unclear, state it as a condition plus a suggestion: "Kalo emang gini, better kasih note di PR", "Kalo ga gini, mungkin bisa disesuaiin", "Kalo ini nggak sengaja, mending dipisah". Use soft suggestions ("Mungkin bisa...", "palingan tambah...", "better ...") over commands ("Jangan...", "Tolong...") unless it is a real blocker, and even then describe what the code/PR needs, not what the author failed to do. Before → after examples of the wanted style:
  - "Begitu ONBOARDING_API_URL di-set, submit langsung ke Go service, sementara service-nya belum verifikasi OTP ... kayanya perlu ditulis di deskripsi PR." → "Waktu ONBOARDING_API_URL di-set, submit langsung ke Go service, tapi service-nya belum verifikasi OTP ... jadi kayanya perlu ditulis di deskripsi PR."
  - "Coba dicek apakah dua-duanya emang disengaja." → "Kalo dua-duanya emang sengaja, better kasih note di PR. Kalo nggak, mungkin bisa disesuaiin."
  - "Ngecek 'error tanpa pesan' lewat bandingin string "Client error" agak rapuh: kalau server beneran ngirim pesan yang sama, bakal ketelen." → "Ngecek 'error tanpa pesan' pake compare string "Client error" agak bahaya: kalo server cuma ngirim pesan yang sama, bakal tenggelam."
  - "Pakai exclude-list dengan default ["IF"] ... Coba didokumentasiin di PR, atau tambah gating berdasarkan tipe borrower." → "Pakai exclude-list dengan default ["IF"] ... Mungkin bisa didokumentasiin di PR, atau tambah gating berdasarkan tipe borrower."
  - "Ini nambah jalur registrasi baru langsung dari browser ke Go service tanpa lewat BFF, padahal scope LC-2075 cuma nambah field di form, dan LC-2076 (BFF routing) udah di-cancel. ... Tolong jelasin di deskripsi PR, dan pastiin route publik + CORS-nya udah siap" → "Ini nambah jalur registrasi baru langsung dari browser ke onboarding service tanpa lewat backend user portal, padahal scope LC-2075 cuma nambah field di form, dan LC-2076 (user portal routing) udah di-cancel. ... Palingan tambah deskripsi di PR, dan pastiin route publik + CORS-nya udah siap"
  - "Validasi trim buat full name ini nggak diminta di tiket, dan ikut ngubah jalur lama juga (lender dan product type yang di-exclude). Selain itu full_name tetep dikirim tanpa trim di jalur lama. Ini sengaja ato gimana? Kalo nggak, mending dipisah." → "Validasi trim buat full name ini gaada di tiket, dan ikut ngubah route lama juga (lender dan product type yang di-exclude). Selain itu full_name tetep dikirim tanpa trim di route lama. Kalo ini nggak sengaja, mending dipisah."
  - "... Mungkin bisa dibalikin (en/id), atau kasih tau alasannya di sini." → "... Mungkin bisa dibalikin (en/id), atau kalo emang ada perubahan scope bisa update di tiket." (when a PR drops something the ticket asked for, point to updating the ticket, not to the author explaining themselves)
  - "Coba map error per field ke form.setFieldError, atau kalau AC-nya emang mau diubah, tolong update tiketnya." → "Jadi perlu map error per field ke form.setFieldError, atau kalau AC-nya emang mau diubah, palingan update tiketnya aja."
  Prefer plain descriptive names over internal jargon when a teammate may not use the acronym ("backend user portal" and "user portal routing" instead of "BFF", "onboarding service" instead of "Go service"), unless the surrounding comment already uses the short name consistently. Describe the code, not the author. Keep code, identifiers, file names, commit/PR titles and the type prefixes (`feat`, `fix`, ...) in their original form; do not translate them. The suggested PR title stays in English as the Conventional Commits format requires.
- **Inline comments**: one per finding that has a `file:line` inside the PR diff. Start with the priority in bold (`**P1**`), then the problem, why it matters, and the suggested fix, e.g. `**P1** Ini belum ke-handle kalau response-nya null, jadi halaman bisa crash. Coba tambahin pengecekan sebelum dipakai, misalnya ...`. Keep each short.
- **No summary comment.** Do not post a review summary, verdict, priority counts, requirement coverage table, PR naming result or open-questions section. Post only the line-by-line comments and the short per-finding standalone comments described below. The review body stays empty. Those items are for the user in the conversation, not for the PR.
- **Review event**: default `COMMENT`. Use `REQUEST_CHANGES` or `APPROVE` only if the user said so in $ARGUMENTS or in the conversation. Never choose `APPROVE` when there are P0 or P1 findings.
- Line-anchored findings go inline. A finding with no honest line (the problem is code that is missing from the diff, PR title or commit naming, empty PR description, wrong base branch, a config or deploy concern) is posted as a short standalone PR comment instead. Do not force it onto an unrelated line and do not ask the user first; just include it in the draft. Rules for standalone comments: one comment per finding (never a combined summary), 1 to 3 short sentences in the same casual Indonesian tone, start with the priority in bold, say what is wrong and the fix, no tables or headings. Example: `**P1** Helper text di bawah field company name harusnya ada (ada di scope LC-2075: "enter the name only, the entity type is selected separately"), tapi di PR ini udah dihapus dan cuma ditulis sebagai known limit. Mungkin bisa dibalikin (en/id), atau kalo emang ada perubahan scope bisa update di tiket.` Every PR naming comment (PR title or commit message) must end with this reference link, always, even when the comment is short: <https://commitizen-tools.github.io/commitizen/tutorials/writing_commits/> . If a repo-specific convention overrode the defaults in review-pr, also link that convention when it has a URL. Example: `**P1** Judulnya belum pas sama format conventional commits: kepanjangan (sekitar 104 karakter), ticket key-nya harusnya di akhir judul, dan "configured PO Financing borrowers" kurang tepat karena semua product type yang nggak di-exclude ikut lewat service. Coba: feat(registration): route borrower registration to onboarding service (LC-2075). Ref: https://commitizen-tools.github.io/commitizen/tutorials/writing_commits/` When suggesting a title, put the ticket key at the end in parentheses and keep the rest of the title within about 72 characters.

## 3. Confirm, then post

Show the user the full draft (event, every inline comment with its path and line, every standalone comment, and the findings left out because they still need validation) and ask for explicit confirmation. Posting is visible to others and cannot be fully undone. Do not post until the user says yes. If the user edits anything, update the draft and confirm again.

To post, write a JSON file in the scratchpad directory and submit one review so the comments arrive together:

```json
{ "commit_id": "<head sha>", "body": "", "event": "COMMENT",
  "comments": [ { "path": "<file>", "line": 12, "side": "RIGHT", "body": "<comment>" } ] }
```

Get the head sha with `pr view <pr> --json headRefOid`. Then run:
`gh api repos/<owner>/<repo>/pulls/<n>/reviews --method POST --input <file>`
Post each standalone comment as a PR conversation comment, one call each: `gh api repos/<owner>/<repo>/issues/<n>/comments --method POST -f body="<comment>"` (same `gh-nikel` rule). If there are no inline comments, skip the review call and post only the standalone comments.

Use `gh-nikel` instead of `gh` for repos owned by `impact-credit-solutions`; it is a zsh function, so run it as `zsh -ic 'gh-nikel api ...'` from inside a relevant repo checkout (see the review-pr skill for details). Use plain `gh` for other owners.

If the API rejects an inline comment (line not in the diff), post that finding as a short standalone comment instead and tell the user. If the PR head changed since the review, tell the user the line numbers may be stale and ask before posting.

## 4. Report

Say what was posted (review link and number of inline comments, plus the number of standalone comments) and what was left out and why. Do not post anything else.
