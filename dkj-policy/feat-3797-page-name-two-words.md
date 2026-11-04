## feat/3797-page-name-two-words

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

Inbound #3797 (Dave): a page name, its `h1` and its current crumb, is at most two words, stated in the brand
book and checked by the hub's fit alarm the way #3745 checks the one `h1`. Verified on pickup: rule 8 capped
every heading at five words and nothing capped the page name; the fit alarm counted `h1`s and no words.

#### Parked for the owner's look

The alarm is a visible result, as #3745's was, so the branch parks without a pull request.
Owner's look done, November 4, 2026: "gezien en akkoord".

### CREATE

- [x] Brand book `README.md`: rule 8 gains the two-word page name; "The labels" under the breadcrumb bar say a crumb is two words at most.
- [x] `Format-FitAlarmHtml`: warns when the live `h1` or the `aria-current` crumb runs past two words; a hyphenated word counts once, a lone dash not at all; not width-gated.

### TEST

- [x] `dev-pages.tests.ps1`: three asserts on the new half (what it reads, how it counts a word, not width-gated); the suite passes 587 of 587 standalone.

### DEPLOY: feat/3797-page-name-two-words

The brand book now holds a page's name, its `h1` and the breadcrumb crumb that reads the same, to two words at most (rule 8 and the breadcrumb bar's labels; #3797). The five-word cap stays for `h2` and `h3`. The hub's fit alarm checks it on sight and warns when the live page's `h1` or its current crumb runs longer. A hyphenated word counts as one.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions app that takes this brand book now has a two-word page name to follow, so a page title such as "Subject - a subtitle" moves its subtitle into the page. Every hub page warns about a name that does not.

**Score:** 2

#### Pull Request

Brand book: a page name is at most two words, checked by the page shell

