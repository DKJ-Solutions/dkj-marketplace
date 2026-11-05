## fix/3834-cross-site-top-level-get

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

#3834: Claude in Chrome cannot open an Admin page -- its navigations arrive `Sec-Fetch-Site: cross-site`,
which `Test-LoopbackCrossSite` refused always. Serve a cross-site top-level GET navigation into a document,
keep every other cross-site request refused, and have the 403 name the headers it judged, since the
extension's exact headers were inferred and not measured.

### CREATE

- [x] `Read-LoopbackRequest` reads `Sec-Fetch-Dest`; `Test-LoopbackCrossSite` serves `cross-site` only for
      mode `navigate` + `GET` + dest `document`, so a frame stays refused (the pages send no
      `frame-ancestors`) (`plugins/dkj-policy/hub/lib/loopback-server-lib.ps1`).
- [x] `Format-LoopbackCrossSiteRefusal`: the 403 names the three headers, cut to token characters; both
      servers use it (`serve-general-pages.ps1`, `scripts/dashboard/serve-consumer-dashboard.ps1`).
- [x] The hub README's Fetch Metadata paragraph states the new rule and why it is safe.
- [x] Asserts in `consumer-dashboard.tests.ps1` and `dev-preview-sessionstart.tests.ps1`: document served,
      frame / POST / non-navigation / no-dest refused, the 403's sanitising.

### TEST

- [x] Security review (Sebastian #23) on the diff, as the issue asks.
- [~] Claude in Chrome opening an Admin page: not available to this session. The 403 now names the headers,
      so a refusal that remains measures itself.

### DEPLOY: fix/3834-cross-site-top-level-get

The Admin and product servers now serve a cross-site top-level `GET` navigation into a document, so Claude
in Chrome can open their pages. Every other cross-site request, a frame included, is still refused, and the
403 names the `Sec-Fetch-*` headers it judged.

**Score:** 3

#### What makes this deploy extra special

A session driving Chrome can open the Admin page it built and look at it before handing it to the owner.

**Score:** 3

#### Pull Request

Admin serves a cross-site top-level GET navigation, so Claude in Chrome can open it

