## fix/4401-reconcile-base-crlf

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

Inbound #4401: `sync-main -ReconcileBase` reported "changes no file" while its restore commit re-normalised
a CRLF blob to LF. Verified cause: the restore ran `git checkout <trunk> -- <paths>` (blobs into the index
verbatim) and then `git commit -- <paths>`, which re-stages those paths from the working copy through the
clean filter -- under `core.autocrlf=true` a CRLF blob comes back as LF.

### CREATE

- [x] `scripts/task/sync-main.ps1` (and its plugin mirror): the restore commits the index with no pathspec
  (the tree is held clean before the write, so the index holds only these paths), then asserts
  `git diff --quiet <trunk> HEAD` and refuses to push a branch that would change a file.
- [x] `scripts/tests/sync-main.tests.ps1`: a `recbase/crlf` case -- a CRLF blob committed with autocrlf off,
  the run with it on; red on the old script, green on the new.

### TEST

- [x] `sync-main.tests.ps1` standalone: the new assert failed on the old script (1 of 197) and passes on the fix.

### DEPLOY: fix/4401-reconcile-base-crlf

`sync-main -ReconcileBase` now restores the trunk's blobs byte for byte: its "put the trunk content back"
commit no longer re-stages the paths through the working copy, so a file stored with CRLF in a repo with
`core.autocrlf=true` and no `.gitattributes` stops coming back as LF. The run also checks that the
branch's tree equals the trunk's before it pushes, so "changes no file" is measured rather than assumed
(#4401).

**Score:** 2

#### What makes this deploy extra special

A Shopify store's maintainer running `-ReconcileBase` on Windows no longer gets a whole-file
line-ending diff on the trunk from a branch that claims to change nothing.

**Score:** 2

#### Pull Request

sync-main -ReconcileBase: restore the trunk blobs byte-for-byte

