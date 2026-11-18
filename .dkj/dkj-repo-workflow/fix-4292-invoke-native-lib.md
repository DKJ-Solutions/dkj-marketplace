## fix/4292-invoke-native-lib

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

#4292: `Invoke-Native` was defined three times in the extension's task scripts, and the copies had
diverged. `build-golive-block.ps1` returned raw `Output` and had no catch, so a missing `gh` or `git`
threw `CommandNotFoundException` instead of returning a failed call. `notify-live.ps1` returned stringified
`Lines`, and `prepare-release.ps1` returned trimmed `Lines` with blank lines dropped. The three move into
one lib that keeps every caller's shape: `Output`, `Lines` and `Code`, plus `-Compact` for the trimmed
form. The catch now applies to all three, because that is the more correct behaviour.

### CREATE

- [x] New `extensions/dkj-repo-workflow-bwj/scripts/lib/native-command-lib.ps1` with the one
      `Invoke-Native` (`Output`, `Lines`, `Code`, and `-Compact`), keeping the try/catch/finally shape
      that the redirect guard exonerates.
- [x] `build-golive-block.ps1`, `notify-live.ps1` and `prepare-release.ps1` dot-source it and lose their
      local copies. Every call in prepare-release passes `-Compact`, so its trimmed `Lines` are unchanged.
- [x] Tests in `scripts/tests/dkj-repo-workflow-bwj.tests.ps1`: no local definition left, the lib is
      dot-sourced, a missing executable returns `-1`, stderr does not throw, and `-Compact` against the
      default.

### TEST

- [x] `dkj-repo-workflow-bwj.tests.ps1` passes 1084/1084, and `shared-scripts.tests.ps1` passes
      1299/1299, so the redirect guard accepts the lib. The full gate runs in ship-pr.

### DEPLOY: fix/4292-invoke-native-lib

The BWJ go-live block builder (`build-golive-block`) no longer stops with an error when `gh` or `git` is
missing from the machine. It now reports that call as failed, as `notify-live` and `prepare-release`
already did. The three scripts now share one copy of the helper that runs `gh` and `git`, so a later fix
to that helper reaches all three at once.

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

One Invoke-Native lib for the dkj-repo-workflow-bwj task scripts

