## feat/3860-today-page

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

The day plan from #3859 needs a place that stays open all day (Dave, November 7, 2026): a hub page that shows the
day goal, the plan with each item's live state, what got done and the week. A visible result, so this branch stops
for the owner's look before it merges.

### CREATE

- [x] `day-plan.ps1 -Status`: the page's model as JSON, the past-day filter shared with `-Close` (`Select-DayPlanDay`)
- [x] `plugins/dkj-policy/hub/lib/today-page-lib.ps1`: the renderer, brand book classes only
- [x] `serve-general-pages.ps1`: `Get-TodayModel` (the script as a child), the route, the cache, `/refresh?page=today`
- [x] `Get-GeneralPages`: Today first of the hub's own cards, with a calendar icon; the hub README row; the skill page

### TEST

- [x] `dayplan.tests.ps1` (69), `dev-pages.tests.ps1` (633) and `goals.tests.ps1` (56) green, the page order pins updated
- [x] A preview hub from this branch on port 4895 with a scratch state: the page renders, #3859 shows done live
- [x] Review: Victor (code), Sebastian (security), Edith (copy). Taken: titles kept whole through the child (gh read with `Invoke-NativeCapture -Utf8`, the `-Status` JSON written as pure ASCII with escapes, so no code page touches an accent or a dash; tested), the child bounded at 60 s like the other gh reads and a GitHub failure cached 30 s, a model date read whether it arrives as a string or a DateTime, item indexes never shifted, a day file the page cannot draw shown as a warning instead of a dropped connection, the README's two "first" cards, the week's last column named Result, the Done card and the footer worded for any day and for items marked done by hand
- [x] After the review: `dayplan.tests.ps1` 70 passed; a live `-Status` for November 6 matched #3857 through its PR

### DEPLOY: feat/3860-today-page

A new hub page and a `-Status` mode on `day-plan.ps1`; the hub's menu gains a card, first of its own, so the
Goals card moves one place along. The page reads the day file and runs the script as a child of the hub, so the
GitHub search has one source.

**Score:** 3

#### What makes this deploy extra special

Admin opens on Today: the day goal with a progress bar, the plan with each item ticked off as its PR or issue
closes, what got done outside the plan, what was deliberately left for another day, and the week so far. The day
you planned with Paula stays in view while you work, and at the end of it you can see what you did.

**Score:** 3

#### Pull Request

Admin page /dev/today: the day plan, what got done, and the week
