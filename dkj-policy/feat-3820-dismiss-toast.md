## feat/3820-dismiss-toast

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

#3820: the airsquats toast could only be put away by ticking the box, which claims the squats were done. Give it a
close button that sinks it without touching the server's count, and keep it down until something new happens.

### CREATE

- [x] A ghost `.icon-btn` with a cross at the end of the toast's row, in house classes and tokens
      (`Format-RepoHubBanner`, `plugins/dkj-policy/hub/lib/general-pages-lib.ps1`).
- [x] Closing keeps the count it was closed on in `sessionStorage`, so another Admin page in the same tab does not
      bring it back; another hour owed, or the hub going offline again, does.
- [x] `dev-pages.tests.ps1`: the existing banner asserts follow the new lines, and one new assert covers the button.

### TEST

- [x] `dev-pages.tests.ps1` on its own: 599 passed, 0 failed.
- [~] The owner looks at the toast on an Admin page: the cross sits at the end of the row and closes it. Not done as a separate look: Dave approved the branch through issues-sweep-reviews on 2026-11-05 without one.

### DEPLOY: feat/3820-dismiss-toast

The airsquats toast on every Admin page now has a close button at the end of its row. It puts the toast away without
ticking the squats off, and it stays away in that tab until another hour comes due or the hub goes offline again.

**Score:** 2

#### What makes this deploy extra special

A user of the Toolbox who does not want the reminder on screen right now can close it, instead of ticking off squats
they have not done.

**Score:** 2

#### Pull Request

The airsquats toast gets a close button

