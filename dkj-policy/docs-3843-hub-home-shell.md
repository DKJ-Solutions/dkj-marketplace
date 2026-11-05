## docs/3843-hub-home-shell

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

Issue #3843: two docs still described Admin's home in its pre-#3830 form (site header, breadcrumb bar, a
`.grid-3` of card links). Measured against the code: `Format-RepoHomeHeadHtml` opens
`Format-AdminShellOpen -Current '/' -Bare`, and `Format-PluginRepoHubHtml` / `Format-PluginRepoRepositoryHtml`
draw one `.table--dense` each. The issue's open question (does the old form live on?) is answered by #3831's
code: the site header and the breadcrumb bar live on as a product's home (`Format-ProductHomeHeadHtml` in
dkj-solutions), so nothing is retired that the product layer still uses.

### CREATE

- [x] `plugins/dkj-policy/assets/dkj-brandbook/README.md`, "The hub": the intro note, the one-page and
  own-page paragraphs, both block tables (home and GitHub page), the row order, "What is fixed", and the
  page-column paragraph, rewritten for the shell; the card component left as the shared one it is.
- [x] `plugins/dkj-policy/hub/README.md`, "The hub has one form": the same, in its shorter form.
- [x] The two dkj-solutions pattern pages (`repo-dashboard.html`, `repo-repository.html`) still draw the old
  form; changing them is a different subject, filed as #3849 and named in the README.

### TEST

- [x] Every class and function named was read in the code it names (`general-pages-lib.ps1`,
  `repo-hub-page.ps1`, `product-pages-lib.ps1`); the lint gate runs in `ship-pr`.

### DEPLOY: docs/3843-hub-home-shell

The brand book's "The hub" and the hub README describe Admin's home and GitHub page as the desktop shell draws
them since #3830: the shell's bar and side navigation with no toolbar on the home page, then one `.table--dense`
of links, a row per page
([#3843](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3843)). The site header and card grid they
used to describe are the product layer's.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

The hub docs describe Admin's home as the desktop shell draws it

