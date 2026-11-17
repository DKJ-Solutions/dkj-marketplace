## fix/4234-fast-session-start

> **How this file is read.** A step is `- [ ]` until it is resolved -- `- [x]` done, or
> `- [~]` dropped with the reason, which exists so nobody ticks a box for work they did not do.
> open-pr and ship-pr both refuse while one is still open, and there is no `-Force`.
>
> **FOUR `###` HEADINGS, AND NEVER A FIFTH** -- PLAN, CREATE, TEST, DEPLOY are the whole top
> level. A section needing its own heading goes in as a `####` UNDER whichever of the four owns
> it. No gate in YOUR repo reads a heading, so this half is on you -- only the repo that authors
> this workflow refuses a fifth (Dave, August 26, 2026).
>
> **AND NOTHING BRANCH-SPECIFIC ABOVE THE FIRST OF THOSE FOUR HEADINGS** -- everything between the
> title and it is this guidance, which is identical in every branch document. A status line, a note about
> THIS branch or an instruction to a session belongs under one of the four, normally as a `####`
> in PLAN. THIS half open-pr refuses, in every repo, before the push -- it reads the shape, so a
> guidance block in your own language passes and your own paragraph here does not (Dave,
> August 26, 2026; refused since #1650).
>
> **DEPLOY takes no steps of its own, and it is WRITTEN LAST** -- it is what the branch DID, once
> TEST says so. Written while steps above it are still open it states an INTENTION, and no gate
> holds it against what landed: the step gate splits this file at that heading and counts only
> above it. The PR title is the one exception -- new-branch -Title writes it at creation, because
> open-pr composes the PR title from it. It is the one part of this file that travels verbatim
> into `CHANGELOG.md` at the merge. In each tier, write the reason
> ABOVE the Score line -- anything below it is discarded.
>
> Relative links in that text resolve FROM THIS DIRECTORY -- `CHANGELOG.md` sits here too, so
> write each path exactly as it reads in this file.
>
> For tier 2 audiences: the user who relies on what this repo ships, and decides whether to take the next version -- a subscriber of a service, or the user of a tool, its own maintainer included. That reader and nobody else -- what matters only
> inside this repo belongs under the first `**Score:**`. If the change reaches that reader
> not at all, N/A is a complete answer and the common one. **One hop and no further:** where that
> reader is itself a business, ITS own customers sit one hop past this repo and are never the reader
> here -- they take nothing this repo ships. Name the party that runs the upgrade, and score
> against them.
>
> The phase arc, the marks and the whole form: `DEVELOPMENT-portable.md`, which ships
> with this workflow.

### PLAN

#4234 guessed that the PR and consumer scans in `sessioncheck-dispatch` carry the session-start tail. Measured
per hook from the transcripts' `hook_success` attachments (120 sessions), they do not: the dispatcher's p95 is
7.4 s and it never passed 10 s. The tail is the brand book check (median 9.2 s, p95 19.2 s) and the dev-preview
hook (p95 10.9 s). Profiled on this repo, the brand book check spends ~8.7 s reading and pattern-matching 602
tracked files (25 MB); the tag-page fetch is 0.8 s and only runs on a pin finding. So this branch caches that
scan per file, for the session-start hook only. The dev-preview tail is split out to #4243.

### CREATE

- [x] `Invoke-HouseStyleCheck -CachePath`: a file whose size and write time match the last run gives back its hits from the cache; the key covers the lib's own text, the pinned tag and the house and retired names
- [x] `Get-HouseStyleCachePath`, `Get-HouseStyleCacheKey`, `Read-HouseStyleScanCache`, `Write-HouseStyleScanCache`: the cache lives in the temp directory, one file per repo root, written through a temp file and only when something changed; an unreadable cache is no cache
- [x] `house-style-sessioncheck.ps1` passes the cache; `check-house-style.ps1` (the CI gate) does not, so CI always reads every file
- [x] The scan loop uses one `FileInfo` per file and hash sets for the copy and extension lookups

### TEST

- [x] `check-house-style.tests.ps1`: 182 passed, 0 failed, including new asserts: the cached scan equals the full one, an unchanged file's hits come from the cache, a changed file is read again, another key and a broken cache are ignored
- [x] Measured on this repo: the hook 9.1 s cold, 0.78 / 0.74 s warm, output identical

### DEPLOY: fix/4234-fast-session-start

The brand book's session check no longer re-reads every file at each session start. It keeps a per-file
cache of what it found, and reads again only the files whose size or write time changed since the last start.
On this repo that took the check from about 9 s to under 1 s on a warm start, and it was the slowest hook a
session start waited for. The CI gate still reads every file.

**Score:** 2

#### What makes this deploy extra special

A session in a repo with the brand book starts several seconds sooner after `/clear` or a new session, typically under 1 s for this check instead of 9 to 20 s.

**Score:** 2

#### Pull Request

The brand book session check caches its scan, cutting about 8 s from a session start

