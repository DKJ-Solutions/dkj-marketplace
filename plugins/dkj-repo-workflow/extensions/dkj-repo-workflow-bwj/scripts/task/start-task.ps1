<#
.SYNOPSIS
    Create a git branch and its branch document in one command, with the guardrails a Shopify store repo
    adds on top of the shared new-branch.ps1.

.DESCRIPTION
    This script is the STORE LAYER on top of the shared new-branch.ps1 from dkj-repo-workflow. The branch
    and its document are not store-specific and are therefore not done here: that step is handed to the
    plugin (found through plugin-payload-lib's Resolve-PluginScript), so exactly one version of that
    mechanism exists. What IS store-specific, and therefore lives here, are the guardrails that are
    STRICTER than the shared script's -- 'sync/' and 'dependabot/' are refused (those branches only ever
    arise by themselves), an unknown prefix is refused where the shared script merely warns, the base
    is refused when HEAD is not on the trunk, and a missing Shopify CLI is refused.

    ONE SCRIPT FOR BOTH STORES (a store issue, step 2 of the plugin-locator move). Each store carried its
    own copy of this file, one a later port of the other; the later copy's four hardenings are the
    superset that ships here. The store facts are not in it: the trunk comes from the repo's
    Get-TrunkBranchName seam (scripts/repo-config.ps1, 'main' by default), the store domain printed in
    the CLI repair from Get-ShopifyStoreDomain, and the branch prefix table from the repo's own
    scripts/lib/branch-info.ps1, which is read from the CHECKOUT, never from this plugin.

    IT DOES NOT CREATE A PREVIEW THEME, and that absence is the rule rather than an omission. Creating
    one is push-preview.ps1's job (the Shopify team plugin's script), which makes it when there is none --
    so only when there is genuinely something to show. It never touches the live theme and does not talk
    to Shopify at all.

    Guardrails, all checked BEFORE anything is created: the Shopify CLI must be on PATH, empty / the
    trunk / 'final' through Test-BranchName (the helper in the repo's branch-info.ps1, the same one the
    shared new-branch.ps1 reads, so the rule can never drift from the plugin's), the name must pass
    git check-ref-format, 'sync/' and 'dependabot/' are excluded, an unknown prefix is refused, and THE
    BASE IS REFUSED RATHER THAN NOTED when HEAD is not on the trunk.

    NO GIT-IDENTITY CHECK HERE, deliberately. An earlier copy refused before anything was created when
    no git author identity resolved, because the shared script then failed at its park commit, after the
    branch and its document existed. The shared new-branch.ps1 now owns that refusal itself
    (Test-GitCanCommit, right after the name validation and before any checkout or file), so a second
    copy here could only drift from it. One consequence worth knowing: with -Base, the checkout of the
    base happens before the shared script runs, so on a machine with no identity HEAD has moved to the
    base you asked for, and nothing else has.

    THE BASE REFUSAL, because it replaced something that looked like it was already handled. This script
    used to print a yellow "Note: you are on '<x>', not on the trunk" and carry on. The note worked as
    designed: it printed, and it was scrolled past, sitting as it does ahead of the branch creation and
    the document. What it cost is in branch-base.ps1, which holds the decision -- in short, a branch cut
    from another in-flight branch makes its pull request's Preview section a false claim, and that
    section is what decides whether the PR waits for the owner. Deliberate stacking stays available, on
    the command that does it: -Base and -Stacked.

    Pure ASCII (repo convention for .ps1): Windows PowerShell 5.1 reads a BOM-less script as ANSI.

.PARAMETER Name
    Branch name: '<prefix>/<short-kebab-name>', e.g. 'fix/cart-totals' or 'feat/size-chart-popup'.

.PARAMETER Title
    (Optional) title for the DEPLOY section. Without one the shared script writes a placeholder.

.PARAMETER Intent
    (Optional) the direction of the branch -- what still has to happen and where you left off. Recorded
    in the PLAN phase of the branch document.

.PARAMETER Base
    (Optional) the branch to cut from, regardless of where HEAD is standing. It is CHECKED OUT first and
    therefore needs a clean working tree. It does not fetch or fast-forward: '-Base <trunk>' cuts from
    the local trunk, and reading the world before work starts is the pre-task sync's job, not this one's.

.PARAMETER Stacked
    (Optional) deliberately cut from the current branch rather than from the trunk. Prints the
    'Stacked on:' line to paste into the pull request body, which is what stands the PR guardrail down.

.PARAMETER RootOverride
    The repo root, when this is not run from inside the checkout -- and the fixture root for a suite.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/start-task.ps1" -Name feat/size-chart-popup -Title "Size chart popup"

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/start-task.ps1" -Name docs/x -Title "..." -Base main

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/start-task.ps1" -Name docs/x -Title "..." -Stacked
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Name,
    [string]$Title,
    [string]$Intent,
    [string]$Base,
    [switch]$Stacked,
    [string]$RootOverride = ''
)
# NO -Store PARAMETER, deliberately: this script does not talk to Shopify, so a store parameter would
# claim that it does. push-preview.ps1 has one. Passing it here gives a loud parameter error, which is
# the right direction to fail in.
$ErrorActionPreference = 'Stop'

# Captured before the repo's own config is dot-sourced below: scripts/repo-config.ps1 is the consumer's,
# and it may bind any name it likes -- the guard notify-live.ps1 and prepare-release.ps1 keep too.
$NameArg = $Name; $TitleArg = $Title; $IntentArg = $Intent; $BaseArg = $Base
$StackedArg = [bool]$Stacked; $RootArg = $RootOverride
$TitleGiven = $PSBoundParameters.ContainsKey('Title'); $IntentGiven = $PSBoundParameters.ContainsKey('Intent')

# A stderr redirect on a native exe MUST sit inside a function that first sets EAP=Continue: in Windows
# PowerShell 5.1 such a redirect wraps every stderr line in an ErrorRecord, and under EAP=Stop that is
# terminating -- even at exit code 0. 'git check-ref-format' writes to stderr precisely when a name is
# invalid, so without this wrapper the tidy error message below would never be reached.
function Test-RefFormat {
    param([string]$Branch)
    $ErrorActionPreference = 'Continue'
    & git check-ref-format --branch $Branch 2>&1 | Out-Null
    return ($LASTEXITCODE -eq 0)
}

. (Join-Path $PSScriptRoot '..\lib\repo-root-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\branch-base.ps1')
. (Join-Path $PSScriptRoot '..\lib\plugin-payload-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\machine-preflight.ps1')

$repoRoot = Resolve-BwjRepoRoot -Override $RootArg
# git resolves the repository from the CURRENT directory, so a run started elsewhere would read another repo.
Set-Location -LiteralPath $repoRoot

# THE BRANCH PREFIX TABLE IS THE CONSUMER'S, read from the checkout rather than from beside this script:
# from inside the plugin, a relative scripts\lib\branch-info.ps1 would point into the plugin. The shared
# new-branch.ps1 reads the same file the same way (it also refuses, with a pointer, when it is missing).
$branchInfoPath = Join-Path $repoRoot 'scripts\lib\branch-info.ps1'
if (-not (Test-Path -LiteralPath $branchInfoPath -PathType Leaf)) {
    Write-Error "start-task cannot run -- missing repo-owned file: $branchInfoPath (Get-BranchInfo / Test-BranchName / the branch prefix table). It belongs in the store repo's scripts/lib/."
    exit 1
}
. $branchInfoPath

# THE TRUNK, from the repo's optional Get-TrunkBranchName seam, 'main' unless it says otherwise -- the same
# answer the shared new-branch.ps1 gives, so the two cannot disagree about what the trunk is. repo-config
# is OPTIONAL: absent, or failing to load, is a reason for the default and not for stopping. The probe is
# a command-table lookup rather than Get-Command, which would resolve a same-named script on PATH.
$trunk = 'main'
$configPath = Join-Path $repoRoot 'scripts\repo-config.ps1'
if (Test-Path -LiteralPath $configPath -PathType Leaf) {
    try {
        . $configPath
        if (@($ExecutionContext.InvokeCommand.GetCommands('Get-TrunkBranchName', 'Function', $false)).Count -gt 0) {
            $v = ([string](Get-TrunkBranchName)).Trim()
            if ($v) { $trunk = $v }
        }
    } catch {
        # The exception's TYPE, never its message: a repo-config that does not parse returns its own
        # source line verbatim.
        Write-Warning "scripts/repo-config.ps1 threw $($_.Exception.GetType().Name) while being read -- using the built-in trunk 'main'."
    }
}

# --- Shopify CLI: checked BEFORE anything is created ----------------------------------------------
# The pre-task sync refuses on a CLI-less profile, so a branch created here is a branch whose first
# gatekeeper never ran. Worse, nothing downstream says so -- a store's theme-check lint SKIPS on a
# missing CLI and exits 0, deliberately and correctly (a missing tool is not a finding about the theme),
# which means the branch's only local gate would report success without having looked at a single file.
#
# UNIFORM, NOT PER-PREFIX, and that is the decision worth reading rather than the check. The obvious
# narrower rule -- refuse only the theme-capable prefixes -- was rejected twice over:
#   - It is a gate with a hole shaped like whatever the prefix mis-measures. A 'docs/' branch that ends
#     up touching locales/ is not hypothetical; the merge rule exists precisely because the prefix and
#     the diff are different claims.
#   - It gives no answer at all on the route this matters most on. The release cut runs from the trunk,
#     where there is no prefix and no branch diff to read, and a release is a push to a revenue-serving
#     theme. That half is closed by the machine-preflight suite case open-pr and the cut run BEFORE they
#     write -- and a suite case cannot be per-prefix either.
# So it is one rule in all three places: a store's work needs the CLI, and a profile without it is told
# at the cheapest possible moment instead of at the release.
#
# NO SKIP SWITCH: an exemption parameter on a check whose whole value is that it cannot be forgotten is a
# hole rather than a convenience.
if (-not (Test-ShopifyCliPresent)) {
    $repair = (Get-ShopifyCliRepairLines) -join "`n"
    Write-Error @"
The Shopify CLI is not on PATH, so this profile cannot run this repo's gates -- refusing before anything is created.

Nothing has been touched: no branch, no branch document, no commit. Letting the branch through would be
worse than a failure, because it would be a silent pass -- the pre-task sync refuses outright, and the
theme-check lint SKIPS with exit 0, so the branch's only local gate would report green without having
read a file.

$repair

Already have a mirror pulled elsewhere and only need the sync? The sync's -MirrorPath route needs no
CLI. That exemption is the sync's alone and does not extend to here: a branch outlives one sync.
"@
    exit 1
}

# --- Name validation: everything BEFORE anything is created ---------------------------------------
$branch = $NameArg.Trim()

# Empty / trunk / 'final' through the repo's helper rather than repeated inline -- the shared
# new-branch.ps1 reads the same function, so the rule cannot drift from the plugin's.
$check = Test-BranchName -Branch $branch
if (-not $check.IsValid) {
    Write-Error "Invalid branch name '$NameArg': $($check.Reason)"
    exit 1
}
if (-not (Test-RefFormat -Branch $branch)) {
    Write-Error "'$branch' is not a valid git branch name (git check-ref-format refuses it)."
    exit 1
}

# Get-BranchInfo only parses the name string, so this runs before the branch exists.
$info = Get-BranchInfo -Branch $branch
if ($info.Prefix -eq 'sync') {
    Write-Error "You do not create sync/ branches by hand; they arise only when live drift is pulled back into git (the store's sync-main.ps1)."
    exit 1
}
if ($info.Prefix -eq 'dependabot') {
    Write-Error "'dependabot/' is the prefix Dependabot puts on its own branches; you never type it."
    exit 1
}
if (-not $info.IsKnown) {
    $valid = ($script:BranchPrefixTable.Keys | Sort-Object) -join ', '
    Write-Error "Unknown branch prefix '$($info.Prefix)'. Valid prefixes: $valid (the canonical table is scripts/lib/branch-info.ps1)."
    exit 1
}

# Title and intent travel to the shared script as separate CLI arguments, and a double quote inside one
# breaks the argv reconstruction across that process boundary. The plugin solves it internally with
# environment variables, but new-branch.ps1 sets those itself, so all that fits here is a refusal --
# with a hint, instead of a half-created branch carrying a mangled title.
#
# BEST-EFFORT, and that is measured: if this script is itself invoked through a 'powershell -File' hop
# with a quote in the title, the quote is already gone BEFORE this check sees it. So it catches the
# direct call, not every route. The real net is that the title lives in the entry file, which the
# author updates before the PR anyway.
foreach ($pair in @(@{ N = 'Title'; V = $TitleArg }, @{ N = 'Intent'; V = $IntentArg })) {
    if ($pair.V -and $pair.V.Contains('"')) {
        Write-Error "-$($pair.N) must not contain a double quote (it breaks the argument handover to the shared script). Leave it out and fill the text in by hand in the entry file."
        exit 1
    }
}

# --- Where this branch is cut from ----------------------------------------------------------------
# The decision is Get-BranchBaseVerdict's (branch-base.ps1); everything here is the git that answers it
# and the git that acts on it. Same split as the rest of the plugin's libs, and the reason it can be
# measured without a repository.
$current = (git rev-parse --abbrev-ref HEAD).Trim()

# 'git status --porcelain' is empty exactly when the tree is clean, which is the only thing the verdict
# needs to know -- and it is only consulted when a checkout is actually required.
$treeIsClean = -not ((git status --porcelain) | Where-Object { $_ })

$baseVerdict = Get-BranchBaseVerdict -Head $current -Trunk $trunk -Base $BaseArg -Stacked $StackedArg -TreeIsClean ([bool]$treeIsClean)

if ($baseVerdict.Action -eq 'refuse') {
    Write-Error $baseVerdict.Reason
    exit 1
}

if ($baseVerdict.Action -eq 'checkout') {
    # Verified before the checkout rather than after it: 'git checkout <name>' on a name git does not
    # know creates nothing but prints a pathspec error, and the caller would then be reading a git
    # message about a file when what they mistyped was a branch.
    $null = & git rev-parse --verify --quiet ("refs/heads/" + $baseVerdict.Base) 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "-Base '$($baseVerdict.Base)' is not a local branch. Check the name, or fetch it first."
        exit 1
    }
    Write-Host "Checking out '$($baseVerdict.Base)' to cut from it ..." -ForegroundColor Cyan
    $prevEap = $ErrorActionPreference
    try {
        # git writes ordinary progress to stderr; under EAP=Stop PS 5.1 promotes that to a terminating
        # error before $LASTEXITCODE is ever read (the same pitfall Test-RefFormat above works around).
        $ErrorActionPreference = 'Continue'
        $checkoutOutput = & git checkout $baseVerdict.Base 2>&1
        $checkoutCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $prevEap
    }
    $checkoutOutput | ForEach-Object { Write-Host $_ }
    if ($checkoutCode -ne 0) {
        Write-Error "Could not check out '$($baseVerdict.Base)'; nothing has been created."
        exit 1
    }
}

$baseBranch = $baseVerdict.Base

# --- Branch + document: handed to the plugin ------------------------------------------------------
# A branch is never entry-less; the shared script does both in one idempotent step and reads the repo's
# own scripts/lib/branch-info.ps1 to do it. CLAUDE_PROJECT_DIR is passed explicitly so the script does
# not have to guess the repo root, and cleaned up in finally so nothing leaks to a later process.
$newBranchScript = Resolve-PluginScript -RelativePath 'scripts\task\new-branch.ps1' -RepoRoot $repoRoot

$entryArgs = @('-Name', $branch)
if ($TitleGiven  -and $TitleArg)  { $entryArgs += @('-Title', $TitleArg) }
if ($IntentGiven -and $IntentArg) { $entryArgs += @('-Intent', $IntentArg) }

$prevProjectDir = $env:CLAUDE_PROJECT_DIR
try {
    $env:CLAUDE_PROJECT_DIR = $repoRoot
    & powershell -NoProfile -ExecutionPolicy Bypass -File $newBranchScript @entryArgs
    $sharedCode = $LASTEXITCODE
} finally {
    if ($null -eq $prevProjectDir) {
        Remove-Item Env:CLAUDE_PROJECT_DIR -ErrorAction SilentlyContinue
    } else {
        $env:CLAUDE_PROJECT_DIR = $prevProjectDir
    }
}
if ($sharedCode -ne 0) {
    Write-Error "The shared new-branch.ps1 exited with $sharedCode."
    exit 1
}

# --- Only AFTER success: the branch must genuinely be checked out ---------------------------------
# The shared script checks the branch out. Verifying that explicitly matters because the message below
# names the branch and the next step, and a name that is not where HEAD sits is exactly the kind of
# quiet confusion push-preview runs aground on later.
#
# THE SHARED SCRIPT MAY COMPLETE THE NAME, so an exact match is the wrong test. An older new-branch
# appended a cycle version -- '-v1', and '-v2' for a deliberate second cycle -- and a payload that does
# so must not have the very branch it just created refused: the branch existed, its document was written
# and it was already parked, and the only thing that failed was the assertion about its name. A guard
# whose failure mode is "the work is done, now panic" is worse than no guard.
#
# So the test is that HEAD is on the branch we asked for OR on that name plus a version suffix, and
# everything downstream uses $head rather than $branch -- what was actually created is the truth here.
$head = (git rev-parse --abbrev-ref HEAD).Trim()
if ($head -ne $branch -and $head -notmatch ('^' + [regex]::Escape($branch) + '-v\d+$')) {
    Write-Error "HEAD is on '$head' instead of '$branch' (or '$branch-v<n>')."
    exit 1
}
if ($head -ne $branch) {
    Write-Host "Cycle version: the shared script created '$head' for the requested '$branch'." -ForegroundColor DarkGray
    $branch = $head
}

# THE BASE GOES ON THE SUMMARY LINE, and that placement is the point rather than the wording. This is the
# line the caller reads -- the old note about a non-trunk HEAD was true, printed and scrolled past because
# it sat five screens earlier. A fact worth acting on belongs where the eye already is.
Write-Host "Branch '$branch' created, cut from '$baseBranch' (no preview theme -- push-preview.ps1 makes one when you need it)." -ForegroundColor Green

if ($baseVerdict.Stacked) {
    # The refusal above let this through because somebody said so on the command. The pull request has
    # to say so as well: the guardrail job reads the BODY, not this script's memory, because by the time
    # the PR exists this run is long gone. See the store's pr-guardrails workflow.
    Write-Host ""
    Write-Host "STACKED on '$baseBranch'. Until '$baseBranch' merges, this branch's pull request carries its commits" -ForegroundColor Yellow
    Write-Host "too -- so its Preview section describes a diff wider than what you are about to change. Put this line" -ForegroundColor Yellow
    Write-Host "in the pull request body, or the branch-base guardrail refuses it:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Stacked on: $baseBranch" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Next: change the code, then run push-preview.ps1 once there is something to see."
