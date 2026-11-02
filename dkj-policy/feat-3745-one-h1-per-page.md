## feat/3745-one-h1-per-page

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

#### Status

Built by a sweep (#3745). The alarm changes what a hub page shows, so it is parked for the owner's eye with
`awaiting-review-dev` and no pull request.

### CREATE

- [x] Brand book rule 8 in `plugins/dkj-policy/assets/dkj-brandbook/README.md`: exactly one `h1`, rendered
  content never adds one, the home page under a site header the one page without one
- [x] `Format-FitAlarmHtml` also warns on more than one `h1`, or none where the trail is longer than Home, at
  every width; the fit half keeps its 1000 px gate
- [x] Four asserts in `scripts/tests/dev-pages.tests.ps1`

### TEST

- [x] `dev-pages.tests.ps1` standalone: 571 passed, 0 failed
- [ ] The owner looks at a hub page with two `h1` (and at the home page, which must stay quiet)

### DEPLOY: feat/3745-one-h1-per-page

The brand book now states that a page carries exactly one `h1`: content a page renders (a lens, a release
note, any markdown) never adds its own, and the home page under a site header is the one page without one
(rule 8, #3745). The hub's page shell checks the rule on sight. The fit alarm in the bottom right also
warns when the live page holds more than one `h1`, or none where its trail is longer than Home. It counts
the live document, so a body rendered after load is judged too, and it is not width-gated.

**Score:** 2

#### What makes this deploy extra special

Anyone opening a page in the hub (this repo's or a consumer's toolbox) now sees a warning when that page
carries two `h1`, where before nothing said so. A page that keeps the rule sees nothing new.

**Score:** 2

#### Pull Request

Brand book: a page carries exactly one h1, stated and checked

