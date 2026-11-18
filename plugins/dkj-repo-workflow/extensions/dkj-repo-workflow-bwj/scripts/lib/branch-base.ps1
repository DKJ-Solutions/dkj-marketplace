<#
.SYNOPSIS
    Two decisions about where a branch was cut from, as pure functions: the one start-task.ps1 makes
    before it creates a branch, and the one the PR guardrail makes once it exists.

.DESCRIPTION
    Dot-source this file:

        . (Join-Path $PSScriptRoot 'branch-base.ps1')

    WHY THIS EXISTS (a store issue). start-task.ps1 cut the new branch from wherever HEAD happened to be and
    only NOTED it when that was not the trunk -- a yellow Write-Host in the middle of the scaffolding output,
    ahead of the branch creation, the dossier and the eight-line tier legend. It printed, and it was
    scrolled past.

    WHAT THAT COSTS, and it is not tidiness. The merge rule reads the PR's Preview section, and that
    section is a claim about THE DIFF AGAINST THE TRUNK. A branch cut from another in-flight branch inherits
    that branch's diff, so a commit that genuinely touches no theme file sits on a PR whose diff is full
    of locales/. The box is then ticked truthfully about the commit and falsely about the PR -- and since
    that box is what decides whether the PR waits for an owner, the PR merges on green and carries the parent
    branch's unapproved customer-visible work into the trunk with it. That happened once in a store: a
    branch was cut while another in-flight branch was checked out and carried that branch's five locale
    files, caught by hand rather than by anything in the repo.

    THE TWO FUNCTIONS ARE TWO MECHANISMS, NOT ONE STATED TWICE. Get-BranchBaseVerdict refuses at
    CREATION, which is where it is cheapest and where the base is still a choice. Get-CarriedBranchVerdict
    judges an EXISTING branch from its ancestry, so it also catches the branch created by hand with
    'git checkout -b', or through the plugin's own new-branch skill, which does not run the start-task
    wrapper at all. Either one alone leaves the other's route open.

    NO GIT IN HERE, deliberately -- the same split the rest of scripts/lib/ uses. These functions take
    facts and return a verdict; the callers (start-task.ps1 in this plugin, and a store's own
    lint script for the ancestry half) gather those facts and act on the verdict. That is what lets
    the plugin source's scripts/tests/branch-base.tests.ps1 measure the rule without a repository.

    No Set-StrictMode here: dot-sourcing would modify the calling script's strict mode.
    Pure ASCII (repo convention for .ps1): Windows PowerShell 5.1 reads a BOM-less script as ANSI.
#>

<#
.SYNOPSIS
    Where should this new branch be cut from -- and may it be cut at all?

.DESCRIPTION
    The rule in one line: A BRANCH IS CUT FROM THE TRUNK UNLESS SOMEBODY SAYS OTHERWISE ON THE COMMAND
    THAT CUTS IT.

    Three answers, and the caller acts on Action:

      'proceed'  -- HEAD is already the right place; hand off to the shared new-branch.ps1 as before.
      'checkout' -- check Base out first, THEN hand off. The shared script has no start-point parameter
                    (it runs a bare 'git checkout -b <name>'), so moving HEAD is the only way to change
                    where it cuts from without this repo growing a second copy of that mechanism --
                    which is the whole reason the branch creation is handed to the plugin at all.
      'refuse'   -- print Reason and exit 1, having created nothing.

    WHY -Base MOVES HEAD RATHER THAN ONLY NAMING A START POINT. That was the open decision in the store issue,
    and the shared script settles it rather than taste: it takes -Name, -Title, -Intent, -RepoRoot,
    -NoPush and -Park, and no start point. Passing one would mean not calling it. Since the end state of
    start-task is HEAD on the new branch anyway, the checkout is not a side effect the caller is left
    with -- it is a step on the way to where they were already going.

    AND IT DOES NOT PULL. -Base main cuts from the LOCAL main. Fetching or fast-forwarding here would put
    network work and a moving target inside a branch-creation command, and this repo already has one
    place that reads the world before work starts: the pre-task sync (a store's sync-main.ps1). A
    second, quieter one is how the two come to disagree.

    A DIRTY TREE REFUSES A CHECKOUT, and only a checkout. 'git checkout' either carries uncommitted edits
    across to the new base or aborts halfway, and neither belongs inside a script that is about to
    scaffold a document. When Action is 'proceed' nothing moves, so the tree is not this function's
    business.

.PARAMETER Head
    The branch HEAD is on now, as 'git rev-parse --abbrev-ref HEAD' answers it -- so the literal string
    'HEAD' when the checkout is detached.

.PARAMETER Trunk
    The branch this repo cuts from, as its Get-TrunkBranchName seam answers ('main' by default); a
    parameter so the tests can say so out loud.

.PARAMETER Base
    -Base as the caller passed it, or '' when they did not.

.PARAMETER Stacked
    -Stacked as the caller passed it: a deliberate cut from the current branch.

.PARAMETER TreeIsClean
    Whether the working tree has no uncommitted changes. Only consulted when a checkout is needed.
#>
function Get-BranchBaseVerdict {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Head,
        [Parameter(Mandatory = $true)][string]$Trunk,
        [string]$Base = '',
        [bool]$Stacked = $false,
        [bool]$TreeIsClean = $true
    )

    $h = $Head.Trim()
    $t = $Trunk.Trim()
    $b = $Base.Trim()

    $verdict = {
        param([string]$Action, [string]$BaseBranch, [bool]$IsStacked, [string]$Reason)
        [pscustomobject]@{
            Action  = $Action
            Base    = $BaseBranch
            Stacked = $IsStacked
            Reason  = $Reason
        }
    }

    # The two flags are two different answers to the same question, so carrying both is not an emphatic
    # answer -- it is an unanswered one. Refused before anything else looks at HEAD.
    if ($b -and $Stacked) {
        return & $verdict 'refuse' '' $false "-Base '$b' and -Stacked contradict each other: one names the branch to cut from, the other says to cut from wherever HEAD is. Pass one of them."
    }

    # A detached HEAD has no branch name to record, so neither the summary line nor the pull request
    # could say what this was cut from. -Base is the way through, because it supplies the missing name.
    if (-not $b -and $h -eq 'HEAD') {
        return & $verdict 'refuse' '' $false "HEAD is detached, so there is no branch name to record as this branch's base. Pass -Base $t (or -Base <branch>)."
    }

    if ($b) {
        $isStacked = ($b -ne $t)
        if ($b -eq $h) {
            # Already standing on it. Saying -Base main while on main is not an error; it is the default
            # instruction written out, and a script that refused it would punish being explicit.
            return & $verdict 'proceed' $b $isStacked ''
        }
        if (-not $TreeIsClean) {
            return & $verdict 'refuse' '' $false "-Base '$b' has to check that branch out first, and the working tree has uncommitted changes. Commit or stash them, then run this again."
        }
        return & $verdict 'checkout' $b $isStacked ''
    }

    if ($Stacked) {
        # -Stacked claims this branch deliberately sits on another one. On the trunk that claim is false,
        # and a flag saying something untrue is worse than no flag: the pull request would announce a
        # stack that is not there, and the guardrail would stand down for nothing.
        if ($h -eq $t) {
            return & $verdict 'refuse' '' $false "-Stacked says you are deliberately cutting from another branch, but HEAD is on '$t'. Leave the flag off."
        }
        return & $verdict 'proceed' $h $true ''
    }

    if ($h -eq $t) {
        return & $verdict 'proceed' $t $false ''
    }

    # Padded rather than spaced by hand: the trunk's name is a parameter, so a literal run of spaces
    # aligns for 'main' and for nothing else.
    $optBase = ("-Base $t").PadRight(14)
    $optStacked = "-Stacked".PadRight(14)
    $reason = @"
HEAD is on '$h', not on '$t', so this branch would be cut from there and its pull request would carry '$h''s commits as well as its own.

That is what defeats the merge rule: the Preview section is a claim about the diff against '$t', so a change touching no theme file can sit on a pull request whose diff does -- ticked truthfully about the commit and falsely about the pull request. It has merged unapproved storefront work into '$t' before.

  $optBase cut from '$t' instead (checks it out first; needs a clean tree)
  $optStacked deliberate: cut from '$h', and say so in the pull request
"@
    return & $verdict 'refuse' '' $false $reason
}

<#
.SYNOPSIS
    Does this branch carry commits belonging to another, unmerged branch?

.DESCRIPTION
    The second mechanism, and the one that does not depend on how the branch was created. It reads
    ancestry rather than intent: a branch cut from another in-flight branch has that branch's TIP in its
    own history, and that tip is not yet in the trunk.

    THE TEST, per candidate branch X (any remote branch that is not this one):

        X's tip is an ancestor of this branch's HEAD   AND   X's tip is NOT an ancestor of the trunk
        =>  this branch was cut from X (or merged it), X's work is unmerged, and this pull request
            carries it.

    WHY THAT SHAPE AND NOT 'WHICH BRANCHES HOLD OUR COMMITS'. The obvious phrasing -- flag any branch
    containing commits from this pull request's range -- also flags a branch cut FROM this one, which is
    the opposite situation and none of this pull request's business. Asking whether X's TIP is behind us
    separates the two: a parent's tip is behind us, a child's is ahead.

    AND IT NEEDS NO LIST OF EXCEPTIONS. A branch already merged into the trunk fails the second half. A
    squash-merged branch still standing on origin fails the first, because the squash commit is a
    different object and its tip is not in our history at all. The trunk itself fails the second half
    against itself. All three fall out of the rule instead of being named, which is what stops this from
    growing a list that goes stale.

    A DELIBERATE STACK IS DECLARED IN THE PULL REQUEST BODY, not by a switch on a script the pull request
    does not remember. 'Stacked on: <branch>' in the body stands the check down -- the same shape as the
    Preview section the merge rule already reads from the body, and for the same reason: the body is the
    one artefact both a reviewer and a gate can see. start-task -Stacked prints that line to paste.

.PARAMETER HeadRef
    The pull request's head branch name, without the 'origin/' prefix.

.PARAMETER Candidates
    One object per remote branch, with three properties: Name (short, e.g. 'fix/cart-totals'),
    TipIsAncestorOfHead (bool) and TipIsAncestorOfTrunk (bool). The caller answers the last two with
    'git merge-base --is-ancestor'.

.PARAMETER StackedDeclaration
    The 'Stacked on: <branch>' line found in the pull request body, or '' when there is none.
#>
function Get-CarriedBranchVerdict {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$HeadRef,
        [object[]]$Candidates = @(),
        [string]$StackedDeclaration = ''
    )

    $headRef = $HeadRef.Trim()
    $declared = $StackedDeclaration.Trim()

    $carried = @()
    foreach ($c in $Candidates) {
        if (-not $c) { continue }
        $name = ([string]$c.Name).Trim()
        if (-not $name) { continue }
        # The branch itself, however the caller spells it. Its own tip is trivially an ancestor of
        # itself, so leaving it in would flag every pull request ever opened.
        if ($name -eq $headRef -or $name -eq "origin/$headRef") { continue }
        if ($c.TipIsAncestorOfHead -and -not $c.TipIsAncestorOfTrunk) { $carried += $name }
    }
    $carried = @($carried | Sort-Object -Unique)

    if ($carried.Count -eq 0) {
        return [pscustomobject]@{
            IsClean = $true
            Carried = @()
            Waived  = $false
            Reason  = 'This branch carries only its own commits.'
        }
    }

    $list = $carried -join ', '
    if ($declared) {
        return [pscustomobject]@{
            IsClean = $true
            Carried = $carried
            Waived  = $true
            Reason  = "This pull request carries the unmerged branch(es) $list, and says so: '$declared'. A declared stack is allowed -- the reviewer can see what the diff really holds."
        }
    }

    $reason = @"
This pull request carries commits from the unmerged branch(es) $list, so its diff is not only this branch's work.

That breaks the merge rule rather than merely widening the diff: the Preview section is a claim about the diff against the trunk, so this pull request can be ticked 'nothing a visitor can see' truthfully about its own commits and falsely about what it would merge.

Either rebase this branch onto the trunk, or -- when the stack is deliberate -- add a line to the pull request body:

  Stacked on: $($carried[0])
"@
    return [pscustomobject]@{
        IsClean = $false
        Carried = $carried
        Waived  = $false
        Reason  = $reason
    }
}
