# issues-sweep -- why the loop reads the way it does

> The measurements behind steps 4, 5 and the close-out on [`SKILL.md`](SKILL.md). Read it when a
> step's rule is in question, or before changing one; a sweep that only follows the loop does not need
> it ([#4233](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4233)).

## Where the skill came from

**It was named `sweep-issues` until November 5, 2026**, renamed by Dave so the three sweeps share one prefix: `issues-sweep`, `issues-sweep-decisions` and `issues-sweep-reviews`. Admin's logbook still recognises a run recorded under the old name.

**It generalises a prompt block** that had to be pasted into a fresh session on every machine, whose
claim was prose a session had to type correctly, and whose race resolution did not close
([#2243](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/2243)). Nothing on these pages is
specific to the repo it came from.

**It was split by when each part is needed** on November 17, 2026
([#4233](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4233)). `/usage` attributed 32% of a
week's local usage to this skill, and `measure-skill` priced its single 35 KB page at ~12,200 on-invoke
tokens -- carried through every turn of a sweep's loop, while most of it applies only when a particular
state, refusal or lane comes up. The loop stays on `SKILL.md`; the rest moved, verbatim, to the pages
beside it.

## Step 4 -- why a sweep runs no gate itself

- **It ships** (the gates prove it): `ship-pr` runs the full gate before it pushes,
  and a pre-run is almost never credited -- `open-pr` skips a gate only on a recorded pass of the
  *identical* tree (HEAD plus every uncommitted file) in the *same* worktree. A pre-run before the commit,
  or one in a lane followed by a ship from the primary checkout, is a different tree or a different
  worktree, so the same gate simply runs twice. Measured
  ([#2372](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/2372)): 1,400s of `-GatesOnly`,
  then the same 1,400s again inside `ship-pr` on the same commit.
- **It stops** (a visible result, no pull request): the park is not the
  last chance the gates get. Once the owner has looked, step 6 ships the same branch with `ship-pr`, so
  `open-pr`'s own gate runs then, and so does the required CI check before the merge. A failure found
  there costs one fix commit. A `-GatesOnly` run at the park would be a third run of the same proof,
  paid while the requester waits, and nothing credits it later, because ticking the TEST step changes
  the tree. `-GatesOnly` also runs the **whole** suite pool rather than `open-pr`'s selection, since it
  assumes nothing runs after it. Measured
  ([#3304](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3304)): two hex values in
  `house-style.css` held the requester up for a ten-minute full-pool run before the park.

## Step 5 -- why a visible park moves the checkout on

A pull request is the question *may this go to the trunk*, and that question is not open while nobody
has looked. The branch survives on `origin` with its own document, and step 6 picks it up whenever the
answer comes.

**The checkout moves on because the sweep is meant to walk the whole backlog in one go.** Maikel,
October 27, 2026 ([#3552](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3552)): *"If it
waits on a visible result every time, it is no longer a sweep."* Measured the same day: a backlog of two
`free` issues, both visible results, took two sweeps, one issue each. So the sweep is the constitution's
one carve-out from *"the checkout stays on that branch until the owner has looked"*. The owner looks
later, by checking the parked branch out (`git checkout <branch>`), and a preview the repo serves from
the checkout follows that branch (this repo's product server restarts on a HEAD change; a Shopify
consumer's `push-preview` already gives each branch its own). Outside a sweep, a visible park still
keeps the checkout on its branch. This replaces the end-at-the-park rule Dave set on October 6, 2026
([#2833](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/2833)), whose reason was that
sentence of the constitution.

**`-Resolves <n>` is not optional.** A sweep branch is named after its issue and its entry cites it,
so `open-pr`'s resolves gate always finds a mention and refuses a bare `ship-pr` before anything is pushed
([#2376](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/2376)).

## The close-out -- why `ship-pr`'s receipt is not the sweep's

**The close-out `ship-pr` prints is one issue's receipt, not the sweep's**
([#2562](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/2562)). Its last lines read
*"Close-out: a receipt ... Session can be cleared"*, and in a sweep that is only the end of step 5.
Measured September 28, 2026: a sweep shipped one issue, took that template as its own close-out, and left
four `free` issues untouched.
