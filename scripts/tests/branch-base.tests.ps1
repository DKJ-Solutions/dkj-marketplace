<#
.SYNOPSIS
    Contract tests for the branch-base lib that dkj-repo-workflow-bwj ships -- where a branch is cut
    from, refused at creation (Get-BranchBaseVerdict) and again from its ancestry once it exists
    (Get-CarriedBranchVerdict).

.DESCRIPTION
    Run:
        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/branch-base.tests.ps1

    WHAT THIS GUARDS. A store's start-task cut from wherever HEAD was and only printed a note about it,
    and a pull request once carried another in-flight branch's locale files into a Preview section that
    truthfully said its own commit touched no theme file. Nothing would have stopped that merge.

    THE ANCESTRY HALF WAS ALSO MEASURED AGAINST GIT, not only against this table. A scratch repository
    reproducing all five shapes -- the stack, a branch cut correctly from the trunk, a branch cut from
    that one, a squash-merged branch still standing on origin, and the PARENT of a stack -- gave exactly
    the verdicts below. That mattered most for the last two, which are the false positives a naive
    'which branches hold our commits' phrasing produces.

    WHAT IT CANNOT GUARD: that the caller gathers the ancestry facts correctly. These functions take
    booleans; git answers them in the caller.

    The lib ships in the plugin, and the suite lives here because this repo is its source (the same
    arrangement bwj-test-lib.tests.ps1 explains). Exit 0 = green. Pure ASCII.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$BwjRoot  = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\extensions\dkj-repo-workflow-bwj'
. (Join-Path $BwjRoot 'scripts\tests\test-lib.ps1')
trap { Add-SuiteFault $_ ; continue }
. (Join-Path $BwjRoot 'scripts\lib\branch-base.ps1')

Write-SuiteHeader 'branch-base.ps1 (dkj-repo-workflow-bwj)'

function New-Candidate {
    param([string]$Name, [bool]$InHead, [bool]$InTrunk)
    return [pscustomobject]@{ Name = $Name; TipIsAncestorOfHead = $InHead; TipIsAncestorOfTrunk = $InTrunk }
}

# ---------------------------------------------------------------------------------------------------
Write-Case 'On main with no flags: the ordinary case, and it says which base it used'
$v = Get-BranchBaseVerdict -Head 'main' -Trunk 'main'
Assert-Equal 'proceed' $v.Action  'nothing to do -- HEAD is already the trunk'
Assert-Equal 'main'    $v.Base    'the base is reported, so the summary line can print it'
Assert-False $v.Stacked           'cutting from the trunk is not a stack'

# ---------------------------------------------------------------------------------------------------
Write-Case 'THE SHAPE: on another branch with no flags, it refuses instead of noting'
$v = Get-BranchBaseVerdict -Head 'fix/other-work' -Trunk 'main'
Assert-Equal 'refuse' $v.Action                       'a note that is scrolled past is not a guardrail'
Assert-Match $v.Reason 'fix/other-work'       'the refusal names where HEAD actually is'
Assert-Match $v.Reason 'Preview section'              'and why it matters: the Preview claim is about the diff against the trunk'
Assert-Match $v.Reason '-Base main'                   'the way through is on the refusal itself'
Assert-Match $v.Reason '-Stacked'                     'both ways through, in fact'

# ---------------------------------------------------------------------------------------------------
Write-Case '-Base names the branch to cut from and checks it out first'
$v = Get-BranchBaseVerdict -Head 'fix/x' -Trunk 'main' -Base 'main'
Assert-Equal 'checkout' $v.Action 'the shared new-branch.ps1 has no start point, so HEAD has to move'
Assert-Equal 'main'     $v.Base   'and it moves to the named base'
Assert-False $v.Stacked           '-Base main is not a stack'

# -Base pointing at a NON-trunk branch is a stack with its parent spelled out, and is reported as one:
# the summary and the pull request both have to say so.
$v = Get-BranchBaseVerdict -Head 'main' -Trunk 'main' -Base 'feat/parent'
Assert-Equal 'checkout'    $v.Action  'a non-trunk base still needs the checkout'
Assert-Equal 'feat/parent' $v.Base    'the base is what was asked for'
Assert-True  $v.Stacked               'and cutting from a non-trunk branch IS a stack, whatever flag said so'

# ---------------------------------------------------------------------------------------------------
Write-Case '-Base you are already standing on moves nothing'
$v = Get-BranchBaseVerdict -Head 'main' -Trunk 'main' -Base 'main'
Assert-Equal 'proceed' $v.Action 'being explicit about the default is not an error'
Assert-Equal 'main'    $v.Base   'and the base is still recorded'

# ---------------------------------------------------------------------------------------------------
Write-Case 'A checkout needs a clean tree; a plain proceed does not'
$v = Get-BranchBaseVerdict -Head 'fix/x' -Trunk 'main' -Base 'main' -TreeIsClean $false
Assert-Equal 'refuse' $v.Action                'git checkout would carry the edits across or abort halfway'
Assert-Match $v.Reason 'uncommitted changes'   'and it says why'
# The dirty tree is only the checkout's business -- refusing here would block the ordinary case for a
# reason that does not apply to it.
$v = Get-BranchBaseVerdict -Head 'main' -Trunk 'main' -TreeIsClean $false
Assert-Equal 'proceed' $v.Action 'a dirty tree on the trunk moves nothing and is not this check''s business'

# ---------------------------------------------------------------------------------------------------
Write-Case '-Stacked is the deliberate route, and it is a claim that has to be true'
$v = Get-BranchBaseVerdict -Head 'feat/parent' -Trunk 'main' -Stacked $true
Assert-Equal 'proceed'     $v.Action 'nothing moves -- HEAD is already where the caller wants to cut'
Assert-Equal 'feat/parent' $v.Base   'the parent is recorded so the pull request can declare it'
Assert-True  $v.Stacked              'and it is marked as a stack'

$v = Get-BranchBaseVerdict -Head 'main' -Trunk 'main' -Stacked $true
Assert-Equal 'refuse' $v.Action        'on the trunk the flag claims something untrue'
Assert-Match $v.Reason 'Leave the flag off' 'a stack that is not there would stand the guardrail down for nothing'

# ---------------------------------------------------------------------------------------------------
Write-Case 'The two flags together are an unanswered question, not an emphatic answer'
$v = Get-BranchBaseVerdict -Head 'fix/x' -Trunk 'main' -Base 'main' -Stacked $true
Assert-Equal 'refuse' $v.Action        'they say two different things about the same question'
Assert-Match $v.Reason 'contradict'    'and the refusal says so rather than picking one'

# ---------------------------------------------------------------------------------------------------
Write-Case 'A detached HEAD has no base to record, and -Base is the way through'
$v = Get-BranchBaseVerdict -Head 'HEAD' -Trunk 'main'
Assert-Equal 'refuse' $v.Action    'git rev-parse --abbrev-ref answers the literal string HEAD there'
Assert-Match $v.Reason 'detached'  'and the refusal names the actual condition'
$v = Get-BranchBaseVerdict -Head 'HEAD' -Trunk 'main' -Base 'main'
Assert-Equal 'checkout' $v.Action  '-Base supplies the name that was missing'

# ---------------------------------------------------------------------------------------------------
Write-Case 'The trunk is a parameter, so a repo that does not call it main is not silently refused'
$v = Get-BranchBaseVerdict -Head 'master' -Trunk 'master'
Assert-Equal 'proceed' $v.Action 'nothing in the rule hard-codes the word main'

# ---------------------------------------------------------------------------------------------------
Write-Case 'ANCESTRY: a branch cut from an unmerged branch is refused (the stacked-by-accident shape)'
$v = Get-CarriedBranchVerdict -HeadRef 'docs/branch-cleanup' -Candidates @(
    (New-Candidate 'origin/fix/other-work' $true  $false),
    (New-Candidate 'origin/main'                   $true  $true)
)
Assert-False $v.IsClean                                    'the pull request carries somebody else''s unmerged work'
Assert-Equal 1 @($v.Carried).Count                         'exactly one branch is carried'
Assert-Equal 'origin/fix/other-work' $v.Carried[0] 'and it is named'
Assert-Match $v.Reason 'Stacked on:'                       'with the declaration that would allow it deliberately'

# ---------------------------------------------------------------------------------------------------
Write-Case 'ANCESTRY: a branch cut from the trunk is clean'
$v = Get-CarriedBranchVerdict -HeadRef 'docs/good' -Candidates @(
    (New-Candidate 'origin/main'      $true  $true),
    (New-Candidate 'origin/docs/good' $true  $false)
)
Assert-True  $v.IsClean            'only its own branch and the trunk are behind it'
Assert-Equal 0 @($v.Carried).Count 'nothing carried'

# ---------------------------------------------------------------------------------------------------
Write-Case 'ANCESTRY: the PARENT of a stack stays green -- the false positive that shaped the rule'
# docs/child is cut from feat/parent, so feat/parent's commits sit inside docs/child. Judging
# feat/parent, docs/child's TIP is AHEAD of us, not behind -- which is exactly how the rule tells a
# parent from a child without needing to know which is which.
$v = Get-CarriedBranchVerdict -HeadRef 'feat/parent' -Candidates @(
    (New-Candidate 'origin/main'       $true  $true),
    (New-Candidate 'origin/docs/child' $false $false)
)
Assert-True $v.IsClean 'a branch cut FROM this one is none of this pull request''s business'

# ---------------------------------------------------------------------------------------------------
Write-Case 'ANCESTRY: a squash-merged branch still standing on origin is not carried'
# The squash commit is a different object, so the old tip is an ancestor of neither side. It falls out
# of the rule rather than being excluded by name, which is what keeps the rule from growing a list.
$v = Get-CarriedBranchVerdict -HeadRef 'docs/good' -Candidates @(
    (New-Candidate 'origin/feat/squashed' $false $false)
)
Assert-True $v.IsClean 'nothing to do with us -- its tip is not in our history'

# ---------------------------------------------------------------------------------------------------
Write-Case 'ANCESTRY: the branch never flags itself, however the caller spells it'
foreach ($spelling in @('docs/good', 'origin/docs/good')) {
    $v = Get-CarriedBranchVerdict -HeadRef 'docs/good' -Candidates @((New-Candidate $spelling $true $false))
    Assert-True $v.IsClean "its own tip is trivially behind it ('$spelling')"
}

# ---------------------------------------------------------------------------------------------------
Write-Case 'ANCESTRY: a declared stack is allowed, and still says what it carries'
$v = Get-CarriedBranchVerdict -HeadRef 'docs/x' -StackedDeclaration 'Stacked on: feat/parent' -Candidates @(
    (New-Candidate 'origin/feat/parent' $true $false)
)
Assert-True  $v.IsClean                       'a declaration stands the check down'
Assert-True  $v.Waived                        'and is reported as a waiver rather than as nothing found'
Assert-Equal 1 @($v.Carried).Count            'what it carries is still named, because the reviewer needs it'
Assert-Match $v.Reason 'feat/parent'          'in the message too'

# ---------------------------------------------------------------------------------------------------
Write-Case 'ANCESTRY: more than one carried branch is reported as more than one'
$v = Get-CarriedBranchVerdict -HeadRef 'docs/x' -Candidates @(
    (New-Candidate 'origin/feat/a' $true $false),
    (New-Candidate 'origin/feat/b' $true $false),
    (New-Candidate 'origin/main'   $true $true)
)
Assert-False $v.IsClean            'still refused'
Assert-Equal 2 @($v.Carried).Count 'and both are listed -- a stack can be two deep'

# ---------------------------------------------------------------------------------------------------
Write-Case 'ANCESTRY: no candidates at all is clean, not an error'
# A fresh clone with a single remote branch, or a runner that fetched nothing else. Nothing is carried,
# and inventing a failure there would make the gate red on the repo's very first branch.
$v = Get-CarriedBranchVerdict -HeadRef 'docs/x'
Assert-True $v.IsClean 'nothing known, nothing carried'

Complete-Suite
