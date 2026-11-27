<#
.SYNOPSIS
    The CI floor, in a consuming repo: place the runners that keep the fold and the resolves
    verification alive across a merge this session never observes, place the scheduled check that a
    GitHub-side repo setting has not silently drifted, report whether a required status check exists at
    all -- the one detect-and-rebase reads -- and, where none does, print the exact `gh api` call that
    would create one, WITHOUT running it, AND where nothing in the tree triggers on pull_request at all,
    offer a minimal CI skeleton to require. A repo that has CHOSEN a merge queue is pointed at the UI
    instead: that switch is not composed here. Issues #1516, #1546, #1843, #1903, #1972.

.DESCRIPTION
    NAMED adopt-merge-queue.ps1 UNTIL SEPTEMBER 13, 2026 (#1903), AND THE OLD NAME IS GONE RATHER THAN
    FORWARDED. Nothing machine-side ever called it -- the one executable reference is the run line on
    adopt-dkj-repo-workflow's Part 3 page, and that page ships in the same plugin release as this file, so the
    two cannot disagree in a consumer's tree. A shim at the old path would need its own registry entry
    and its own test: two maintained names for one script, which is precisely the ambiguity the rename
    removes. A consumer who had automated the old path gets a loud file-not-found instead of a second
    silent name. The queue is the last and least reachable thing this command covers -- see the next
    paragraph -- and the name now says what the rest of it does.

    A MERGE QUEUE IS NO LONGER THIS WORKFLOW'S POLICY (Dave, September 7, 2026, #1546). It was, from
    September 6 (#1492) -- and the policy was set in the one repo where its central constraint cannot
    be felt. GitHub offers merge queue on a PRIVATE repo only under Enterprise Cloud, and otherwise
    only on a PUBLIC repo owned by an organization; on Free, Pro or Team it HIDES the 'Require merge
    queue' checkbox rather than disabling it. This workflow's source repo is public on plan 'free', so
    it qualifies through the public clause while most consumers do not -- and this script reported that
    unreachable setting as a closable '[gap]', sending its reader through the ruleset UI after a
    control that is not rendered (#1540, measured in BWJ-Development/smartwatchbanden: private, plan
    'team', the whole floor built before the missing checkbox surfaced).

    SO THE STANDING MECHANISM IS DETECT-AND-REBASE, which every repo can run. ship-pr dates a PR's
    certificate from the run behind a REQUIRED check, counts what the trunk gained after it, and
    refuses the merge when that is not zero. It converges by repetition rather than by construction --
    bring the branch forward, CI re-runs, ship again -- which is weaker than a queue and available.

    WHICH MOVES THE ONE GAP THAT MATTERS. With no required check named, ship-pr says so and skips the
    step, so the staleness guard is simply off. That is now this script's headline finding, where it
    used to read as a precondition for a switch a reader might never be able to flip.

    THE FOLD AND RESOLVES RUNNERS ARE EVERY REPO'S, QUEUE OR NO QUEUE, and this is the half most easily
    mis-read as queue machinery. What breaks the fold is a merge THE SHIPPING SESSION DOES NOT OBSERVE,
    and the GitHub UI merge button produces one in every repo on earth. A queue only makes it the normal
    case. The THIRD runner this command places -- the repo-settings drift check (#1843) -- is not queue-
    related at all, which is why $targets carries a QueueRelated flag per entry rather than a count.

      1. THE MERGE. Under a queue `gh pr merge` does not merge -- gh's own help: "When targeting a
         branch that requires a merge queue ... the pull request will be added to the merge queue."
         ADDED, exit 0, not merged. ship-pr handles this already (#1506): it reads the trunk's rules
         before it merges and, where it finds a queue, enqueues, ends successfully, and folds nothing.
         That half travels with the plugin, so it is true in every consumer the day they install it and
         this script does not have to place it.

      2. THE FOLD. It ran from exactly one place -- ship-pr's own next step after its own merge call
         returned. Any merge that session does not observe skips it: a queue merge, and equally a PR
         merged from the GitHub UI by anybody at all. The branch document then sits on the trunk
         unfolded, with CHANGELOG.md never receiving the entry and a release cut in that window missing
         the change. The source repo answered it with .github/workflows/fold-on-merge.yml (#1493,
         #1507). A consumer has no such file, and nothing tells them: ship-pr's enqueue arm PROMISES one.

      3. THE RESOLVES VERIFICATION. verify-resolved-issues.ps1 is ship-pr's step 6, and it went the
         same way for the same reason (#1511). The closing itself is not at risk -- GitHub honours a
         body's keywords on any merge -- but the verification is, and so is the repair when a keyword
         missed, which is the case the script was built for.

    A FOURTH FILE THIS SCRIPT PLACES IS NOT ABOUT AN UNOBSERVED MERGE AT ALL (issue #1843):
    .github/workflows/repo-settings.yml, a SCHEDULED leg that asks whether a GitHub-side repo setting --
    a bypass actor, allow_auto_merge, which check is required -- still matches what scripts/repo-config.ps1
    declares (Get-ExpectedRepoSettings). It rides along in this same command because this is already the
    one place a consumer runs to build their CI floor, and the source repo measured three such drifts in
    eight days with nothing in its own tree saying so before it built the check this places
    (check-repo-settings.ps1). "The reachable goal is identical scripts available, not identical rules
    enforced" (Dave, September 12, 2026, on #1843) is why the VALUES stay the consumer's own to declare --
    an empty or absent declaration is a harmless [SKIP], never a refusal -- while the SCRIPT that compares
    them against GitHub is shared.

    A FIFTH FILE ANSWERS THE OTHER HALF OF #1843 -- A CONSUMER WITH NOTHING TO REQUIRE AT ALL. Section 1
    can compose the ruleset call the moment a required check exists somewhere in the tree, but until now
    a repo with NO workflow triggering on pull_request had nothing for that call to name -- only a
    placeholder. Where that is the state, this script also offers .github/workflows/ci.yml: a minimal
    workflow whose one job carries a placeholder step, empty on purpose ("a skeleton is portable; the
    body is not" -- what a merge should prove is this repo's own choice, never this script's to assert).
    Its job is named from the Get-CiTestCheckName seam when the repo has declared one, so the check this
    skeleton carries and the check open-pr's own local-gate-skip logic already looks for are the same
    name rather than two to reconcile by hand. Offered only when nothing else already triggers on
    pull_request, and only additively, like every other target here.

    A SIXTH FILE CLOSES A PROMISE ship-pr ALREADY MAKES IN EVERY CONSUMER (#2329):
    .github/workflows/merge-on-green.yml. ship-pr arms a pull request it refused on a red or pending
    required check with the merge-when-green label and says a sweep will finish the merge; this is that
    sweep, derived from the source repo's own runner (#2319). It reaches the plugin's
    pick-merge-on-green.ps1 and ship-pr.ps1 through the same checkout of the plugin tree, and runs both
    against THIS tree via CLAUDE_PROJECT_DIR -- from three sibling checkouts (#2449): the plugin tree, a
    token-free trunk the two repo-owned seams and the fold come from, and a token-free checkout of the
    picked branch. An existing runner of the older single-workspace shape is reported on a re-run, since
    this command never rewrites it. Its FOLD_PUSH_TOKEN needs Pull requests: write as well, and the run
    says so when it places the file.

    A SEVENTH FILE IS ABOUT THE TRACKER, NOT A MERGE (#3422): .github/workflows/close-parked-recurrences.yml
    closes an issue parked on a recurrence label as not planned, with its [RECORD] prefix, the moment it
    is parked -- a rule CONTRIBUTING-portable.md states and nothing held. It reads no tree and calls no
    shared script, so it is the source repo's own file byte for byte, and it needs no secret: issues:
    write on the job-scoped token is all it holds. It matches the labels' former names too, among them
    the plain `record` and `dossier`, so a repo using either as an ordinary label renames it first.

    AND ONE PREREQUISITE BELONGS TO THE QUEUE ALONE (#1325): every workflow carrying a REQUIRED check
    context must trigger on `merge_group`. A required workflow without it never runs for a queue entry,
    so its check never reports -- and GitHub's own warning is that the merge then fails. That is a TOTAL
    MERGE OUTAGE on the trunk, not a degradation, and it is invisible until the first merge after the
    switch. In a repo with NO queue it is inert, so leaving it out costs nothing -- which is why it is
    reported as a gap only where a queue is actually active.

    DO NOT CONFUSE IT WITH THE REQUIRED CHECK ITSELF, because the two point opposite ways. Making a
    check required is every repo's business and turns detect-and-rebase on. Adding merge_group to it is
    a queue repo's business and does nothing anywhere else. A consumer who follows the second without
    the first has done work for a queue they do not have.

    AND THE PLUGIN'S OWN branch-entry GATE CANNOT BE THAT REQUIRED CHECK (#1538). It reads
    github.head_ref, which is empty in a merge_group event -- there is no pull request left to read --
    so it stays a pull-request check. The source repo requires its own lint-en-tests instead, a
    repo-owned workflow triggering on both pull_request and merge_group; that arrangement is right and
    was nowhere written down, so a consumer could not reach it by reading. This script now says it.

    SO THE ORDER MATTERS AND THIS SCRIPT KEEPS IT: report the required check and the trigger first, then
    the runners, and the queue last. A run that placed the queue first would be the outage.

    IT NEVER FLIPS THE SETTING, AND THAT IS A RULE RATHER THAN A LIMITATION. A ruleset is a
    repo-settings change: irreversible in the sense that matters (it changes what every contributor's
    merge does, immediately, for everybody) and outward-facing. This workflow's own constitution puts
    that class in the owner's hands. FOR THE REQUIRED-CHECK RULESET (section 1's '[gap]', #1972) the
    run composes the exact `gh api` call and stops -- reading the rules needs only a token that can
    read them; writing them needs one that can administer the repo, and a script that quietly held the
    second would be a different kind of tool. THE MERGE QUEUE (section 3) STAYS A UI HANDOVER, and
    that is not the same rule said twice for two different targets: composing it would mean asserting
    seven scheduling parameters -- merge method, grouping strategy, three limits, two timeouts -- that
    are policy nobody here has chosen, where the required-check payload has exactly one free choice
    (which job) and this script already knows how to answer that one from the tree it is standing in.

    STRICTLY ADDITIVE, NEVER OVERWRITES, DRY RUN BY DEFAULT -- the same three properties
    adopt-workflow-folder and adopt-config are trusted on, and for the same reason: the first run of a
    command that adds files to your repo should show you the list. A workflow file that is already
    there is left exactly as it is, whatever it contains.

    REFUSED IN THE REPO THAT PUBLISHES THIS WORKFLOW. The source arranges its own runners by hand --
    they are the originals these are derived from, they call its in-repo scripts rather than a
    checked-out mirror, and its fold runner holds a credential decision no scaffold should assert on
    somebody's behalf. Same refusal, same reasoning and the same test (Test-IsWorkflowSourceRepo) as
    adopt-workflow-folder's.

    RUN IT FROM THE ROOT OF THE CONSUMING REPO:

        powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/adopt-ci-floor.ps1"
        powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/adopt-ci-floor.ps1" -Apply

    Exit 0 while the queue is off and the floor is merely unbuilt -- that is a to-do, not a defect.
    Exit 1 when the queue is ACTIVE on the trunk and a piece of the floor is missing, because that is a
    live defect: entries are being stranded, or merges are about to stop.

    Pure ASCII, per this repo's script-layer convention.

.PARAMETER Apply
    Write the runner workflows this repo does not have. Without it the command is a DRY RUN that prints
    exactly what it would create and touches nothing.

.PARAMETER RulesJsonOverride
    A file holding a `gh api repos/<repo>/rules/branches/<trunk>` payload, read instead of calling gh.
    For the test suite, which has to reach the queue-is-active arm without a network or a trunk. A
    consumer never types it.

.PARAMETER SharedRefOverride
    The ref the three write runners check the shared scripts out at, used instead of resolving this
    plugin's release tag over the network. For the test suite, like -RulesJsonOverride. A consumer
    never types it.

.EXAMPLE
    .\scripts\task\adopt-ci-floor.ps1
    .\scripts\task\adopt-ci-floor.ps1 -Apply
#>

[CmdletBinding()]
param(
    [switch]$Apply,
    [string]$RulesJsonOverride = '',
    [string]$SharedRefOverride = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# THE SOURCE-REPO GUARD: refuses this script when it is a released copy running in the repo that
# maintains it. Guarded dot-source, so a tree without the lib behaves as before. Why: the lib's header.
$guardLib = Join-Path $PSScriptRoot '..\lib\source-repo-guard-lib.ps1'
if (Test-Path -LiteralPath $guardLib -PathType Leaf) { . $guardLib; Assert-OwnCopy -ScriptPath $PSCommandPath }

# Dual-context repo root: a consumer running the plugin mirror gets it from CLAUDE_PROJECT_DIR, the
# source's root copy falls back to the git root. Same resolution as every other mirrored script.
# JUDGED (#1917): Resolve-RepoRootOrFail is check-report-lib's refusing sibling of Resolve-CheckRoot
# -- same precedence, but it names git's exit code and stderr instead of dying on $null.Trim().
. (Join-Path $PSScriptRoot '..\lib\check-report-lib.ps1')
$repoRoot = Resolve-RepoRootOrFail -ScriptName 'adopt-ci-floor.ps1'

# repo-config.ps1 first and optional, exactly as adopt-workflow-folder loads it: it supplies the repo
# slug (Get-RepoName) and any trunk override, and every read below has a fallback.
$repoConfig = Join-Path $repoRoot 'scripts\repo-config.ps1'
if (Test-Path -LiteralPath $repoConfig -PathType Leaf) {
    try { . $repoConfig } catch { Write-Warning "scripts/repo-config.ps1 failed to load ($(Format-SafeProseToken -Value $_.Exception.Message)) -- the built-in defaults are used." }
}

. (Join-Path $PSScriptRoot '..\lib\entry-scaffold-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\seam-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\pr-issues-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\native-capture-lib.ps1')
# THE PRINT-SAFETY CONVENTION (issue #1972, security review). The section 1 '[gap]' arm below fills a
# ruleset payload with a job CONTEXT that can come off a workflow's `name:` VALUE -- arbitrary text off
# a line of the CONSUMER'S OWN YAML, not the restricted job-key charset -- so it is foreign text by the
# same reasoning ref-print-lib.ps1 was built for, not merely untrusted-in-theory. This is the one
# definition of "safe to paste" and of the prose-display strip; a fourth hand-rolled copy of either is
# exactly what pr-issues.tests.ps1's THREE-libs assert exists to catch.
. (Join-Path $PSScriptRoot '..\lib\ref-print-lib.ps1')
# Get-WriteTargetReparsePoint (issue #2546): a runner this floor creates is refused when its path passes
# through a symlink or junction -- a junctioned .github/ -- because the write would land outside the repo.
. (Join-Path $PSScriptRoot '..\lib\write-target-lib.ps1')
# The runners this command places, their constants and the tree readers they share with the drift check
# (#4529). After ref-print-lib and write-target-lib, which it uses.
. (Join-Path $PSScriptRoot '..\lib\ci-floor-runners-lib.ps1')

# THE SOURCE OF *THIS* WORKFLOW arranges its runners by hand -- see the header -- so this command
# refuses there. Below the dot-sources because the test lives in seam-lib, and still before anything is
# written: loading a lib changes nothing on disk.
if (Test-IsWorkflowSourceRepo -RepoRoot $repoRoot) {
    Write-Host 'REFUSED: this repo publishes this workflow, so it is its source rather than a consumer.' -ForegroundColor Red
    Write-Host 'Its fold-on-merge.yml and verify-resolved.yml are the ORIGINALS these are derived from:'
    Write-Host 'they call its in-repo scripts rather than a checked-out mirror, and the fold runner carries'
    Write-Host 'a push-credential decision no scaffold should make on somebody else''s behalf. Nothing was'
    Write-Host 'written.'
    exit 1
}

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$nl = "`n"

# THE TRUNK IS READ, NOT ASSUMED. Every string below names it -- the workflow triggers, the rules
# endpoint, the ruleset payload -- and a repo that renamed its trunk would otherwise be handed a floor
# built for a branch it does not have. Get-BranchTrunkName reads the optional Get-TrunkBranchName seam
# and falls back to 'main'.
$trunk = Get-BranchTrunkName

# THE SOURCE OF THE SHARED SCRIPTS the placed runners call. Both files check the plugin's own tree out
# beside the consumer's, exactly as adopt-workflow-folder's branch-entry.yml does, and for the same
# reason: there is ONE definition of the fold and of the resolves check in this system, and a runner
# that carried a hand-written copy would be a second one, free to drift from the first.
# Get-CiFloorConstants (ci-floor-runners-lib.ps1, #4529) holds the shared repo, its checkout path and the
# actions/checkout pin, so the runners this command places and the drift check that reads them agree.
$ciFloor    = Get-CiFloorConstants
$sharedRepo = $ciFloor.SharedRepo
$sharedRef  = 'main'
$sharedPath = $ciFloor.SharedPath
$pluginDir  = $ciFloor.PluginDir

# ACTIONS/CHECKOUT IS PINNED BY SHA IN THE WRITE-CAPABLE RUNNERS (issue #1904) -- the reasoning, and how
# the pin is refreshed, sit beside Get-CiFloorConstants in ci-floor-runners-lib.ps1 since #4529.
$checkoutPin = $ciFloor.CheckoutPin

# THE SHARED SCRIPTS ARE PINNED TOO -- IN THE THREE WRITE RUNNERS (issue #2333), AND SINCE #4237 IN THE
# READ-ONLY ONE AS WELL (below).
# Pinning the ACTION is half of the job. The second checkout in each of those runners fetches this
# workflow's own scripts out of $sharedRepo and then EXECUTES them, in a job that holds FOLD_PUSH_TOKEN
# (fold, merge-on-green) or issues: write (resolves). At ref: main, a change landing on the source
# repo's trunk -- a bad merge, a compromised account -- reached standing Contents and Pull requests
# write in every adopted consumer on its next run, with no release in between. So those three check
# the scripts out at the commit the RELEASE THIS SCAFFOLDER CAME FROM was tagged at: the version is read
# off this plugin's own plugin.json, and the tag is resolved to its commit SHA, because a tag can be
# moved by the same account that could push a bad commit and a SHA cannot.
#
# THE READ-ONLY RUNNER IS PINNED TOO SINCE #4237, WHICH REVERSES #1805's CHOICE FOR IT. repo-settings.yml
# holds no write scope and no secret, and #1805 kept it on main so a gate would not go on enforcing a
# stale convention. The #4209 rename measured the other side of that trade: it moved every script path
# on main a day before any release carried it, and every consumer runner on ref: main went red at once
# while the pinned write runners kept working. A pin moves when the consumer adopts the release, which
# is the moment its own tree takes the matching shape. So it takes the same ref the write runners take.
#
# A PIN HAS TO MOVE, AND THIS SCRIPT IS WHAT SAYS SO. It writes a runner once and never rewrites it, so
# re-running it reports every existing runner still on main or pinned behind the version running now
# (section 2 below). Bumping it is editing one ref: line per file -- the value this run prints.
#
# WHERE THE SHA CANNOT BE RESOLVED (offline, no git), THE TAG IS WRITTEN AND THE RUN SAYS SO. A tag is
# weaker than a SHA and far stronger than main, and refusing the floor over it would leave the fold
# unguarded instead. Where not even the version can be read, the runners fall back to main, loudly.
# Get-ScaffoldingPluginVersion is release-pin-lib's, shared with adopt-workflow-folder (#4237).
. (Join-Path $PSScriptRoot '..\lib\release-pin-lib.ps1')

$writeRunnerVersion = Get-ScaffoldingPluginVersion
$writeRunnerRef = $sharedRef
$writeRunnerPinState = 'unpinned'
if ($SharedRefOverride) {
    # The test suite's route: a runner with no network still has to be read for WHERE the pin lands.
    $writeRunnerRef = $SharedRefOverride
    $writeRunnerPinState = 'override'
} elseif ($writeRunnerVersion) {
    $writeRunnerTag = "v$writeRunnerVersion"
    $lsRemote = Invoke-NativeCapture -FilePath 'git' -DiscardStderr -TimeoutSeconds $NativeCaptureNetworkTimeoutSeconds -Arguments @('ls-remote', "https://github.com/$sharedRepo.git", "refs/tags/$writeRunnerTag", "refs/tags/$writeRunnerTag^{}")
    $tagSha = ''
    if ($lsRemote.ExitCode -eq 0) {
        # An annotated tag answers twice: the tag object, and the commit it points at under '^{}'. The
        # commit is the one actions/checkout can take as a ref, so the peeled line wins when present.
        foreach ($line in @($lsRemote.Output)) {
            $m = [regex]::Match([string]$line, '^(?<sha>[0-9a-f]{40})\s+refs/tags/(?<tag>\S+)$')
            if (-not $m.Success) { continue }
            if ($m.Groups['tag'].Value -eq "$writeRunnerTag^{}") { $tagSha = $m.Groups['sha'].Value; break }
            if ($m.Groups['tag'].Value -eq $writeRunnerTag) { $tagSha = $m.Groups['sha'].Value }
        }
    }
    if ($tagSha) {
        $writeRunnerRef = "$tagSha # $writeRunnerTag"
        $writeRunnerPinState = 'sha'
    } else {
        $writeRunnerRef = $writeRunnerTag
        $writeRunnerPinState = 'tag'
    }
}

# The comment every write runner carries above its shared checkout lives in Get-CiFloorRunnerTargets
# (ci-floor-runners-lib.ps1, #4529).

# --- What the trunk's own rules say -----------------------------------------------------------------
# READ, NEVER WRITTEN, and read once: both questions below (is there a queue, and which contexts are
# required) come off the same payload, which is the same economy ship-pr's step 0b makes.
#
# AN UNREADABLE PAYLOAD IS NOT "NO QUEUE", and this script must not collapse the two any more than
# ship-pr does. A consumer whose token cannot read a ruleset, or who is offline, gets a report that says
# the question was not answered -- and it still reports and places everything that does not depend on
# the answer, because the floor is worth building either way.
$rulesJson = ''
$rulesSource = ''
# $repoSlug IS HOISTED HERE (issue #1972). It used to live inside the `else` branch below, so under
# Set-StrictMode -Version Latest it was undefined on the -RulesJsonOverride path -- exactly the path
# the test suite takes, and the one the printed ruleset instruction in section 1 below also needs it
# on. Resolved from the Get-RepoName seam first, same as always; the gh fallback stays inside the
# network-reading branch below, because a consumer running with an override file and no network has
# no way to answer it and none is owed one -- section 1 prints a placeholder there instead.
$repoSlug = ''
if (Test-FunctionDefined 'Get-RepoName') { $repoSlug = [string](Get-RepoName) }
if ($RulesJsonOverride) {
    if (Test-Path -LiteralPath $RulesJsonOverride -PathType Leaf) {
        $rulesJson = [System.IO.File]::ReadAllText($RulesJsonOverride)
        $rulesSource = "the payload in $RulesJsonOverride"
    }
} else {
    if (-not $repoSlug) {
        # No seam answer: ask gh what repo this checkout is. A consumer that has not answered
        # Get-RepoName yet is exactly the fresh adoption this command is for, so refusing here would
        # gate the floor on a seam that has nothing to do with it.
        $slugRead = Invoke-NativeCapture -FilePath 'gh' -DiscardStderr -Arguments @('repo', 'view', '--json', 'nameWithOwner', '--jq', '.nameWithOwner')
        if ($slugRead.ExitCode -eq 0) { $repoSlug = ($slugRead.Output -join '').Trim() }
    }
    if ($repoSlug) {
        # -DiscardStderr because this output is PARSED: a gh warning merged into it would break the
        # ConvertFrom-Json and cost the read. Same reasoning as ship-pr's own rules call.
        $rulesRead = Invoke-NativeCapture -FilePath 'gh' -DiscardStderr -Arguments @('api', "repos/$repoSlug/rules/branches/$trunk")
        if ($rulesRead.ExitCode -eq 0) {
            $rulesJson = $rulesRead.Output -join "`n"
            $rulesSource = "gh api repos/$repoSlug/rules/branches/$trunk"
        }
    }
}

$queueVerdict = Get-MergeQueueVerdict -BranchRulesJson $rulesJson
$queueReadable = $queueVerdict.Readable
$queueActive = ($queueVerdict.Readable -and $queueVerdict.Active)

# The REQUIRED check contexts, off the same payload. Get-DirectPushBlockingRules already collects them
# -- it reads them so its own refusal can name what the remote would have named -- so asking it here
# adds no parsing of its own and cannot disagree with what ship-pr reads.
$requiredContexts = @()
if ($queueReadable) {
    foreach ($rec in (Get-DirectPushBlockingRules -BranchRulesJson $rulesJson).Blocking) {
        $requiredContexts += @($rec.Contexts)
    }
    $requiredContexts = @($requiredContexts | Sort-Object -Unique)
}

# --- Which workflow carries which required check ----------------------------------------------------
# Get-WorkflowFacts lives in ci-floor-runners-lib.ps1 since #4529: the drift check reads the same facts.

$workflowDir = Join-Path $repoRoot '.github\workflows'
$workflows = Get-WorkflowFacts -WorkflowDir $workflowDir

# --- The CI skeleton, for a consumer with NO pull_request workflow at all (issue #1843) --------------
# Section 1 below already tells such a consumer how to make a check required; until now it could only
# print a placeholder job id, because there was nothing in the tree to name. This is the fourth thing
# this command offers: a minimal, adoptable .github/workflows/ci.yml that gives such a consumer
# something to require. THE BODY IS DELIBERATELY EMPTY -- "a skeleton is portable; the body is not" is
# the #1843 assessment's own phrase for it: lint/test/build steps are this repo's own choice, never this
# workflow's to assert, exactly the same line ci.yml itself would not cross if it tried to travel.
#
# OFFERED ONLY WHEN NOTHING ELSE ALREADY TRIGGERS ON pull_request. A consumer running CI under any other
# file name already has what this exists to give; placing a second, empty workflow beside a real one
# would be noise. Once either file carries that trigger, $workflows picks it up on the very next run and
# this arm has nothing left to offer -- no separate "already adopted" state to track.
#
# "ELSE" MEANS THIS REPO'S OWN WORKFLOWS (inbound #2677): the plugin's PR gates Part 1 places are left
# out here and from the candidate checks below, because neither can be the required check -- see
# PluginGate in Get-WorkflowFacts. Without that, the order the parts ran in decided the result.
$ciSkeletonRel = '.github/workflows/ci.yml'
$ciSkeletonAbs = Join-Path $repoRoot ($ciSkeletonRel -replace '/', '\')
$repoPrWorkflows = @($workflows | Where-Object { $_.OnPullRequest -and -not $_.PluginGate })
$noPrWorkflowAtAll = $repoPrWorkflows.Count -eq 0
$ciSkeletonOffered = $noPrWorkflowAtAll -and -not (Test-Path -LiteralPath $ciSkeletonAbs)

# Test-QuotedScalarSafe, shared by the skeleton's job name and section 1's ruleset advice, lives in
# ci-floor-runners-lib.ps1 since #4529, beside the merge-on-green wake list that also needs it.

$ciSkeletonDeclaredName = if (Test-FunctionDefined 'Get-CiTestCheckName') { [string](Get-CiTestCheckName) } else { '' }
$ciSkeletonJobKey = 'ci'
$ciSkeletonCheckName = if (Test-QuotedScalarSafe -Value $ciSkeletonDeclaredName) { $ciSkeletonDeclaredName } else { $ciSkeletonJobKey }

$ciSkeletonRunner = @(
    '# A minimal CI workflow, scaffolded because no workflow of this repo''s own triggered on pull_request',
    '# (issue #1843; the dkj-repo-workflow PR gates do not count, #2677). Its only purpose is to give this repo something to require on the trunk, which is',
    '# what switches ship-pr''s detect-and-rebase staleness guard on -- see this command''s own section 1:',
    '# with no required check named, that guard has no certificate to date and is simply off.',
    '#',
    '# THE BODY IS DELIBERATELY EMPTY. What a merge should have to prove -- lint, tests, a build -- is',
    '# this repo''s own choice, never this workflow''s to assert. REPLACE THE PLACEHOLDER STEP BELOW',
    '# before making this check required.',
    '#',
    '# merge_group IS ALREADY HERE, EVEN IF THIS REPO RUNS NO QUEUE (issue #1325). It is inert until one',
    '# exists, and a total merge outage the day one is switched on without it, on any workflow carrying a',
    '# required check -- cheaper to place now than to remember later.',
    '#',
    '# THE JOB''S name: NAMES THE CHECK adopt-ci-floor.ps1''s own ruleset advice already assumes: it reads',
    '# Get-CiTestCheckName, so a repo that has declared that seam gets a skeleton whose check IS the one',
    '# open-pr''s local-gate-skip logic already looks for, rather than a second name to reconcile by hand.',
    'name: CI',
    '',
    'permissions:',
    '  contents: read',
    '',
    'on:',
    '  pull_request:',
    '  merge_group:',
    '',
    'jobs:',
    ('  ' + $ciSkeletonJobKey + ':'),
    ('    name: "' + $ciSkeletonCheckName + '"'),
    '    runs-on: ubuntu-latest',
    '    # THE ONE NUMBER IN THIS FILE YOU ARE EXPECTED TO RE-SIZE (issue #2296). A job with no',
    '    # timeout-minutes runs to GitHub''s SIX-HOUR default, and a wedged job that carries a REQUIRED',
    '    # check does not fail the branch -- it leaves the check unreported, which reads as "still',
    '    # running" to every gate and to every person. 30 is a placeholder for a placeholder step: when',
    '    # you replace the step below with this repo''s own lint/test/build, re-size this to roughly',
    '    # twice the slowest run you have actually measured.',
    '    timeout-minutes: 30',
    '    steps:',
    '      - uses: actions/checkout@v7',
    '      - name: Replace this with whatever this repo wants a merge to prove',
    '        run: |',
    '          echo "TODO (issue #1843 template): this step is a placeholder."',
    '          echo "Replace it with this repo''s own lint/test/build, then make this check required."',
    '          exit 0'
)

# --- The runners, consumer-shaped ---------------------------------------------------------------
# COMPOSED IN ci-floor-runners-lib.ps1 SINCE #4529 (Get-CiFloorRunnerTargets), so the session check can
# hold a placed copy against the current template; the reasoning paragraphs travel with them there.
# Which workflows wake merge-on-green.yml is read off this tree (Get-CiFloorWakeNames, #2329).
$mogWakeNames = @(Get-CiFloorWakeNames -Workflows $workflows -CiSkeletonOffered:$ciSkeletonOffered)
$targets = @(Get-CiFloorRunnerTargets -Trunk $trunk -WriteRunnerRef $writeRunnerRef -WakeNames $mogWakeNames)
# THE CI SKELETON IS CONDITIONAL, UNLIKE EVERY TARGET ABOVE (issue #1843): it is offered only when
# nothing in the tree triggers on pull_request at all, never merely because this one file is absent --
# a consumer running CI under a different file name must not be handed a second, empty workflow beside
# their real one. Appended rather than folded into the literal above, so that condition stays readable
# beside the flag it reads instead of buried inside a one-line hashtable.
if ($ciSkeletonOffered) {
    $targets += @{ Rel = $ciSkeletonRel; Content = (($ciSkeletonRunner -join $nl) + $nl); What = 'a minimal CI workflow to require, for a repo with no pull_request check at all'; QueueRelated = $false }
}

# THE ONLY TARGET THAT NEEDS FOLD_PUSH_TOKEN. Tracked by name rather than by "was anything created this
# run", because with three targets that counter no longer says which file is missing: a repo that is
# only missing repo-settings.yml (no secret involved at all) would otherwise be told to go create one.
$foldRunnerRel = '.github/workflows/fold-on-merge.yml'
# THE SECOND TARGET THAT NEEDS IT, AND THE ONE THAT NEEDS IT WIDER (#2329): merging needs Pull requests:
# write on top of the fold's Contents: write. Tracked by name for the same reason as the fold runner.
$mergeOnGreenRunnerRel = '.github/workflows/merge-on-green.yml'
# THE THREE THAT HOLD A WRITE CREDENTIAL, and therefore the three whose shared scripts are pinned (#2333).
$writeRunnerRels = @($foldRunnerRel, '.github/workflows/verify-resolved.yml', $mergeOnGreenRunnerRel)
# THE READ-ONLY RUNNER, pinned since #4237 for a reason of its own, and read for that pin on a re-run.
$repoSettingsRunnerRel = '.github/workflows/repo-settings.yml'

function Write-WriteRunnerPinVerdict {
    <#
        One line about the ref an EXISTING write runner fetches the shared scripts at (#2333): on main,
        pinned behind the release this run came from, pinned at a SHA it cannot date, or unreadable.
        Silent where the pin is at or ahead of this release -- that is the ordinary state.

        READ IN THE SHAPE THIS SCAFFOLDER WRITES, AND NO FURTHER: the `ref:` of the same ten-space
        `with:` block as a `repository:` naming this repo under either name it has carried (a runner
        scaffolded before the #1769 rename still names the old one). A hand-edited file this cannot
        read is said to be unread, never judged clean.
    #>
    param([string]$Rel, [string]$Text, [switch]$ReadOnly)

    $m = [regex]::Match($Text, '(?m)^ {10}repository:\s*\S*/(?:dkj-marketplace|dkj-claude-plugins|claude-code-specialists)\s*$(?:\n {10}[^\n]*)*?\n {10}ref:[ \t]*(?<ref>[^\s#]+)[ \t]*(?:#[ \t]*(?<tag>\S+))?[ \t]*$')
    if (-not $m.Success) {
        Write-Host "            its shared-scripts ref could not be read, so whether it is pinned was NOT established." -ForegroundColor DarkGray
        return
    }
    $ref = $m.Groups['ref'].Value
    $tag = if ($m.Groups['tag'].Success) { $m.Groups['tag'].Value } else { $ref }
    $bump = if ($writeRunnerPinState -eq 'unpinned') { 'a release commit of the dkj-repo-workflow plugin' } else { Get-DisplayRef -Ref $writeRunnerRef }

    $vm = [regex]::Match($tag, '^v?(?<v>\d+\.\d+\.\d+)$')
    if (-not $vm.Success) {
        if ($ref -match '^[0-9a-f]{40}$') {
            Write-Host '            [pin] it fetches the shared scripts at a SHA with no version beside it, so whether that is' -ForegroundColor DarkGray
            Write-Host '            behind this release could not be told.' -ForegroundColor DarkGray
        } else {
            if ($ReadOnly) {
                # NO CREDENTIAL HERE, SO THE REASON IS A DIFFERENT ONE (#4237): a script path moved on the
                # source's main reaches this runner before this repo adopts the release carrying the move.
                Write-Host "            [pin] it fetches the shared scripts at '$(Get-DisplayRef -Ref $ref)' -- a moving ref, so a script moved on the" -ForegroundColor Yellow
                Write-Host "            source's main turns it red before you adopt that release (#4237). Change that ref: line to $bump." -ForegroundColor Yellow
            } else {
                Write-Host "            [pin] it fetches the shared scripts at '$(Get-DisplayRef -Ref $ref)' -- a moving ref, beside a write credential" -ForegroundColor Yellow
                Write-Host "            (#2333). Change that ref: line to $bump." -ForegroundColor Yellow
            }
        }
        return
    }
    if (-not $writeRunnerVersion) { return }
    if ([version]$vm.Groups['v'].Value -lt [version]$writeRunnerVersion) {
        Write-Host "            [pin] it fetches the shared scripts at $(Get-DisplayRef -Ref $tag), behind v$writeRunnerVersion which this run came from." -ForegroundColor Yellow
        Write-Host "            Move that ref: line to $bump." -ForegroundColor Yellow
    }
}

function Write-MergeOnGreenShapeVerdict {
    <#
        One line about the checkout SHAPE of an existing merge-on-green.yml (#2449): the single
        token-bearing workspace this scaffolder wrote before #2449, the three sibling checkouts it writes
        now, or neither. It prints nothing when the file already has the current shape.

        WHY THIS IS SAID AT ALL. This scaffolder never rewrites an existing runner, so a consumer adopted
        before #2449 keeps the old shape -- the branch's own seams run beside FOLD_PUSH_TOKEN -- and a re-run
        of this command is the one moment anything looks at that file again. The shared lib's standing
        refusal of .workflow-scripts/ (#2553) still covers the plugin-tree overwrite in that shape; it
        cannot cover the seams, which is what re-scaffolding fixes.

        READ IN THE SHAPE THIS SCAFFOLDER WRITES, AND NO FURTHER: the old shape is a ten-space `token:`
        naming FOLD_PUSH_TOKEN beside a checkout at the plugin path; the new one is a `path:` of both
        trusted-main and pr-branch. A hand-edited file that is neither is said to be unread, never judged
        clean.
    #>
    param([string]$Text)

    $old = ($Text -match '(?m)^ {10}token:[ \t]*\$\{\{[ \t]*secrets\.FOLD_PUSH_TOKEN[ \t]*\}\}[ \t]*$') -and
           ($Text -match ('(?m)^ {10}path:[ \t]*' + [regex]::Escape($sharedPath) + '[ \t]*$'))
    $new = ($Text -match '(?m)^ {10}path:[ \t]*trusted-main[ \t]*$') -and ($Text -match '(?m)^ {10}path:[ \t]*pr-branch[ \t]*$')
    if ($new -and -not $old) { return }
    if ($old) {
        Write-Host '            [shape] it checks the trunk out ONCE with FOLD_PUSH_TOKEN and switches that workspace to the' -ForegroundColor Yellow
        Write-Host '            picked branch, so the branch''s own scripts/repo-config.ps1 and branch-info.ps1 run beside' -ForegroundColor Yellow
        Write-Host '            the token (#2449). Re-scaffold it: delete this file and re-run adopt-ci-floor -Apply.' -ForegroundColor Yellow
        return
    }
    Write-Host '            its checkout shape could not be read, so whether it still runs the branch''s seams beside the' -ForegroundColor DarkGray
    Write-Host '            token (#2449) was NOT established.' -ForegroundColor DarkGray
}

function Write-MergeOnGreenScopeVerdict {
    <#
        One line about the job-token scopes of an existing merge-on-green.yml (#3491): a top-level
        permissions block without checks:, statuses: and actions: read (the last since #3619, because gh
        resolves the workflow run behind each check run). It prints nothing when all three are there.

        WHY THIS IS SAID AT ALL -- #2449's reason, for a different correction. In a private repo that
        block leaves the picker unable to read the required checks, so it never picks anything and every
        run still concludes success. The file is never rewritten, so a re-run of this command is the one
        moment anything looks at it again.

        READ IN THE SHAPE THIS SCAFFOLDER WRITES, AND NO FURTHER: a column-0 `permissions:` and the
        two-space lines under it, a column-0 comment among them not ending it. A file without that block is said to be unread, never judged clean.
    #>
    param([string]$Text)

    $m = [regex]::Match($Text, '(?m)^permissions:[ \t]*\n(?<body>(?: {2}[^\n]*\n?|#[^\n]*\n|[ \t]*\n)*)')
    if (-not $m.Success) {
        Write-Host '            its top-level permissions block could not be read, so whether the picker can read the' -ForegroundColor DarkGray
        Write-Host '            required checks (#3491) was NOT established.' -ForegroundColor DarkGray
        return
    }
    $missing = @('checks', 'statuses', 'actions' | Where-Object { $m.Groups['body'].Value -notmatch ('(?m)^ {2}' + $_ + ':[ \t]*(read|write)[ \t]*(#.*)?$') })
    if ($missing.Count -eq 0) { return }
    Write-Host "            [scope] its job token has no $(($missing | ForEach-Object { "$($_): read" }) -join ' and '), so in a private repo the" -ForegroundColor Yellow
    Write-Host '            picker cannot read the required checks and never merges anything (#3491, #3619). Add the missing' -ForegroundColor Yellow
    Write-Host '            line(s) under permissions:, or delete this file and re-run adopt-ci-floor -Apply.' -ForegroundColor Yellow
}

function Write-MergeOnGreenSettleVerdict {
    <#
        One line about the picker line of an existing merge-on-green.yml (#3857): it runs
        pick-merge-on-green.ps1 without -WaitForSettleSeconds, which this scaffolder has written since
        #3810. It prints nothing when the flag is there.

        WHY THIS IS SAID AT ALL -- #2449's reason, for a correction that lives in the YAML rather than in
        the scripts. The picker defaults the wait to 0, so moving the runner's ref: pin to a newer release
        (the [pin] advice) does not deliver #3809's repair: the pull request that goes green LAST is
        refused at its only workflow_run wake by the 10-minute settle window and waits for the schedule
        or a hand dispatch. The file is never rewritten, so a re-run of this command is the one moment
        anything looks at it again.

        READ IN THE SHAPE THIS SCAFFOLDER WRITES, AND NO FURTHER: a line invoking pick-merge-on-green.ps1.
        A file without one is said to be unread, never judged clean.
    #>
    param([string]$Text)

    $line = [regex]::Match($Text, '(?m)^[^\n#]*pick-merge-on-green\.ps1[^\n]*$')
    if (-not $line.Success) {
        Write-Host '            its picker line could not be read, so whether the last pull request to go green waits out' -ForegroundColor DarkGray
        Write-Host '            the settle window (#3809) was NOT established.' -ForegroundColor DarkGray
        return
    }
    if ($line.Value -match '-WaitForSettleSeconds\b') { return }
    Write-Host '            [settle] its picker runs without -WaitForSettleSeconds, so the pull request that goes green' -ForegroundColor Yellow
    Write-Host '            LAST is refused by the 10-minute settle window and waits for the next schedule or a hand' -ForegroundColor Yellow
    Write-Host '            dispatch (#3809). A newer ref: alone does not fix it: append -WaitForSettleSeconds 660 to the' -ForegroundColor Yellow
    Write-Host '            pick-merge-on-green.ps1 line, or delete this file and re-run adopt-ci-floor -Apply.' -ForegroundColor Yellow
}

function Write-MergeOnGreenRedispatchVerdict {
    <#
        One line about an existing merge-on-green.yml that has no redispatch job (#4198): placed before
        this scaffolder wrote one. It prints nothing when the job is there.

        WHY THIS IS SAID AT ALL -- #2449's reason, for a correction that lives in the YAML. ship-pr exits
        75 on a merge GitHub did not confirm after a 5xx, and only the job reads that code; without it
        the pull request stays armed until the next CI wake or schedule, hours later. A newer ref: pin
        does not deliver it. The file is never rewritten, so a re-run of this command is the one moment
        anything looks at it again.

        READ IN THE SHAPE THIS SCAFFOLDER WRITES, AND NO FURTHER: a line calling
        Get-MergeOnGreenRedispatchVerdict. Its absence is reported, never judged clean.
    #>
    param([string]$Text)

    if ($Text -match '(?m)^[^\n#]*Get-MergeOnGreenRedispatchVerdict\b') { return }
    Write-Host '            [redispatch] it has no redispatch job, so after a 5xx on a merge the pull request stays armed' -ForegroundColor Yellow
    Write-Host '            until the next CI wake or schedule, hours later (#4198). A newer ref: alone does not add it:' -ForegroundColor Yellow
    Write-Host '            delete this file and re-run adopt-ci-floor -Apply, or copy the redispatch job from the template.' -ForegroundColor Yellow
}

function Write-MergeOnGreenRefusalVerdict {
    <#
        One line about an existing merge-on-green.yml that has no refusal step (#4449): placed before this
        scaffolder wrote one. It prints nothing when the step is there.

        WHY THIS IS SAID AT ALL -- the redispatch verdict's reason. Without the step, a pull request ship-pr
        refuses on every sweep is picked on every sweep, being the lowest-numbered eligible one, and every
        armed pull request above it waits. The picker's skip reads a label and marker only that step writes.

        READ IN THE SHAPE THIS SCAFFOLDER WRITES, AND NO FURTHER: a line calling
        Get-MergeOnGreenRefusalComment. Its absence is reported, never judged clean.
    #>
    param([string]$Text)

    if ($Text -match '(?m)^[^\n#]*Get-MergeOnGreenRefusalComment\b') { return }
    Write-Host '            [refusal] it has no refusal step, so a pull request ship-pr keeps refusing is picked again on' -ForegroundColor Yellow
    Write-Host '            every sweep and starves every armed pull request above it (#4449). A newer ref: alone does not' -ForegroundColor Yellow
    Write-Host '            add it: delete this file and re-run adopt-ci-floor -Apply, or copy the refusal step from the template.' -ForegroundColor Yellow
}

function Write-RunnerGroupVerdict {
    <#
        One line about the concurrency group of an existing fold-on-merge.yml or verify-resolved.yml
        (#2816): still the single github.ref-keyed group this scaffolder wrote before #2813, or neither
        that nor the current one. It prints nothing when the group line is the template's own.

        WHY THIS IS SAID AT ALL -- #2449's reason, for a different correction. In the old shape a
        fold-only push, which the job's if: skips, shares the group with a merge's pending run and
        cancels it, so that merge's fold (or its resolves check) never runs (#2813). The file is never
        rewritten, so a re-run of this command is the one moment anything looks at it again.

        THE CURRENT LINE IS READ FROM THE TEMPLATE THIS RUN WOULD PLACE, not restated here, so a later
        change to that line needs no second edit. The OLD line is spelled out, because it is gone from
        the template. A group line that is neither is said to be unread, never judged clean.
    #>
    param([string]$Rel, [string]$Text, [string]$TemplateText)

    $groupLine = { param($y) [regex]::Match($y, '(?m)^\s*group:[^\n]*$').Value.Trim() }
    $have = & $groupLine $Text
    if ($have -and $have -eq (& $groupLine $TemplateText)) { return }
    $name = [System.IO.Path]::GetFileNameWithoutExtension($Rel)
    if ($have -match ('^group:[ \t]*' + [regex]::Escape($name) + '-\$\{\{[ \t]*github\.ref[ \t]*\}\}$')) {
        Write-Host '            [group] a fold-only push shares its concurrency group with the merge before it, and can' -ForegroundColor Yellow
        Write-Host '            cancel that merge''s pending run, so its work never runs (#2813). Replace the group: line' -ForegroundColor Yellow
        Write-Host '            with the one this command places, or delete this file and re-run adopt-ci-floor -Apply.' -ForegroundColor Yellow
        return
    }
    Write-Host '            its concurrency group could not be read, so whether a fold-only push can cancel a merge''s' -ForegroundColor DarkGray
    Write-Host '            pending run (#2813) was NOT established.' -ForegroundColor DarkGray
}

# --- Report ------------------------------------------------------------------------------------------
Write-Host "== adopt-ci-floor -- $repoRoot ==" -ForegroundColor Cyan
if (-not $Apply) { Write-Host '  DRY RUN -- nothing is written. Re-run with -Apply to place the files below.' -ForegroundColor Yellow }
Write-Host ''

$liveDefects = 0

# 1. THE TRIGGER, FIRST, because it is the one that is an OUTAGE rather than a gap. It is also the one
#    piece of the floor this command cannot place: the workflow carrying your required check is yours,
#    and adding a trigger to it is an edit to somebody else's file rather than an addition beside it.
Write-Host '-- 1. the required check, and (queue only) its merge_group trigger --' -ForegroundColor Cyan
if (-not $queueReadable) {
    Write-Host "  [skip]    the trunk's rules could not be read, so which checks are REQUIRED is unknown." -ForegroundColor DarkGray
    Write-Host '            Every workflow below is listed with its trigger so you can judge it yourself.' -ForegroundColor DarkGray
    foreach ($w in $workflows | Where-Object { $_.OnPullRequest }) {
        $mark = if ($w.HasMergeGroup) { 'has merge_group' } else { 'NO merge_group' }
        # #2248: $w.Rel is a filename read off THIS CONSUMER's own directory -- foreign text.
        Write-Host "            $(Get-DisplayPath -Path $w.Rel) -- $mark" -ForegroundColor DarkGray
    }
} elseif ($requiredContexts.Count -eq 0) {
    # THE REASON CHANGED WITH THE POLICY (#1546), AND IT GOT STRONGER. This used to read as a
    # precondition for switching a queue on -- which made it somebody else's problem in a repo that was
    # never going to have one. Detect-and-rebase reads the RUN BEHIND A REQUIRED CHECK to date the
    # certificate, so with nothing required ship-pr prints 'no required check name is known -- not
    # checked' and the staleness guard is simply off. That is the standing mechanism now, so this is the
    # one gap on this page that every repo should close.
    Write-Host "  [gap]     no required status check on '$trunk', so the staleness guard is OFF." -ForegroundColor Yellow
    Write-Host '            ship-pr dates a PR certificate from the run behind a REQUIRED check; with none' -ForegroundColor Yellow
    Write-Host '            named it says so and skips the step, which is honest and is also blind. Making' -ForegroundColor Yellow
    Write-Host '            one CI check required on the trunk is what turns detect-and-rebase on.' -ForegroundColor Yellow
    Write-Host '' -ForegroundColor Yellow
    Write-Host '            IT MUST BE A CHECK THAT CAN CARRY THE ROLE, and the branch-entry gate this' -ForegroundColor Yellow
    Write-Host '            plugin ships CANNOT: it reads github.head_ref, which is empty outside a pull' -ForegroundColor Yellow
    Write-Host '            request, so it stays a pull-request check. Use your own CI workflow. If you also' -ForegroundColor Yellow
    Write-Host '            run a queue, that workflow needs the merge_group trigger of this section too.' -ForegroundColor Yellow
    Write-Host '' -ForegroundColor Yellow

    if ($ciSkeletonOffered) {
        Write-Host '            NOTHING IN THIS TREE TRIGGERS ON pull_request AT ALL (the plugin''s own PR gates' -ForegroundColor Yellow
        Write-Host '            aside -- they cannot carry the role), so section 2 below will' -ForegroundColor Yellow
        Write-Host "            offer to scaffold $ciSkeletonRel -- a minimal, empty CI workflow to require." -ForegroundColor Yellow
        Write-Host "            Its one job is named '$ciSkeletonCheckName'; replace its placeholder step with" -ForegroundColor Yellow
        Write-Host '            whatever this repo wants a merge to prove before making it required (issue #1843).' -ForegroundColor Yellow
        Write-Host '' -ForegroundColor Yellow
    }

    # THE PASTE-READY CALL (#1972). This is the one place in this script that composes a `gh api` call
    # rather than merely pointing at a UI -- see the reasoning at the top of this file for why this arm
    # earns that and the queue (section 3) does not: the payload below has exactly one free choice
    # (which check), and the tree this script is standing in can usually answer that itself.
    #
    # THE CONTEXT IS A JOB, NOT A GUESS. Collected the same way Get-WorkflowFacts already collects a
    # required check's owner above: every job key or job name declared by a workflow that triggers on
    # pull_request. Exactly one such id across the whole tree, AND SAFE TO PASTE, is filled in directly;
    # everything else -- more than one candidate, none at all, or a lone candidate this script will not
    # vouch for -- is left as an obvious placeholder, and every candidate is printed (as prose, so a
    # foreign one cannot repaint the console) so picking one is a copy from a list rather than a hunt
    # through .github/workflows/.
    #
    # REFUSE, DO NOT ESCAPE (security review on #1972). A job CONTEXT can come off a workflow's `name:`
    # VALUE, which Get-WorkflowFacts reads as arbitrary text off a line of the CONSUMER'S OWN YAML --
    # not the restricted job-key charset. Hand-quoting that into the JSON template below would mean this
    # script inventing a fourth copy of the escape ref-print-lib.ps1 already owns (pr-issues.tests.ps1
    # pins the three files allowed to carry that pattern), and getting it wrong in the one place a wrong
    # answer is a payload that widens conditions.ref_name, flips enforcement, or reshapes the ruleset
    # while the surrounding prose still says "paste it as-is".
    #
    # NOT Test-RefPasteSafe (second security review on #1972). That predicate is right for what it was
    # built for -- a REF interpolated into a SHELL command line -- and wrong for this value, which is
    # neither: it lands inside a JSON STRING LITERAL, inside a PowerShell here-string, and never touches
    # a shell word. Its allowlist has no space, but a GitHub Actions job `name:` routinely has one
    # ('Lint and tests', 'build (ubuntu-latest)') and the check context GitHub reports for such a job
    # IS that name, spaces included -- so judging it against the ref allowlist refused the common case
    # outright and printed a FALSE reason for doing so ("not safe to paste") about a value a JSON string
    # swallows without complaint. Test-QuotedScalarSafe (defined once, at script scope, above -- shared
    # with the CI skeleton's own job-name check, issue #1843) is the narrower, correct predicate: it does
    # NOT widen $script:RefPasteSafePattern to admit a space (that lib's own header already names that
    # repair wrong for the neighbouring case, #1762 -- a wider ref allowlist would also admit a space into
    # a value that DOES reach a shell line elsewhere in this workflow) and it does not retype
    # '[\p{Cc}\p{Cf}\p{Zl}\p{Zp}\p{Mn}\p{Me}]' as a fourth copy of that pattern (Get-DisplayRef already
    # owns the one definition; pr-issues.tests.ps1 pins the three files allowed to carry it as literal
    # text). A NEWLINE NEVER REACHES IT HERE: Get-WorkflowFacts' own capture for a job `name:` is
    # anchored on '[^\r\n]*$', so a job id or name is already single-line by construction before it ever
    # reaches this predicate -- which is what keeps it from closing the surrounding here-string early
    # (that closes only on a line that STARTS with `'@`).

    $prJobIds = @($repoPrWorkflows | ForEach-Object { $_.JobIds } | Sort-Object -Unique)
    $autoFillContext = $null
    if ($prJobIds.Count -eq 1 -and (Test-QuotedScalarSafe -Value $prJobIds[0])) { $autoFillContext = $prJobIds[0] }
    # NO REAL CANDIDATE, BUT THE SKELETON ABOUT TO BE PLACED HAS ONE (issue #1843): its check name was
    # already proven safe above via the same Test-QuotedScalarSafe call the CI skeleton's own job name
    # uses, so it needs no second proof here. This is the one case where the auto-fill answers for a
    # file that does not exist on disk yet -- correct, because section 2 below
    # places it with exactly this name, in the same run that printed this advice.
    $autoFillFromSkeleton = $false
    if (-not $autoFillContext -and $ciSkeletonOffered) { $autoFillContext = $ciSkeletonCheckName; $autoFillFromSkeleton = $true }
    $rulesetContext = if ($autoFillContext) { $autoFillContext } else { 'REPLACE-WITH-A-JOB-ID-BELOW' }

    # $trunk AND $repoSlug ARE LOWER-RISK -- $trunk off this repo's own Get-TrunkBranchName seam,
    # $repoSlug off GitHub's own owner/repo charset -- but neither is refused a defence this cheap.
    # Same gate, same reasoning, and both fall back to an already-existing placeholder rather than a
    # new one: a repo whose OWN config fails this allowlist is not a case worth a bespoke message.
    $rulesetTrunk = if (Test-RefPasteSafe -Ref $trunk) { $trunk } else { '<trunk>' }
    $repoSlugPasteSafe = [bool]($repoSlug -and (Test-RefPasteSafe -Ref $repoSlug))
    $rulesetSlug = if ($repoSlugPasteSafe) { $repoSlug } else { '<owner>/<repo>' }

    Write-Host '            THIS CREATES A NEW RULESET REQUIRING THAT CHECK ON THE TRUNK -- paste it as-is' -ForegroundColor Yellow
    if ($autoFillFromSkeleton) {
        Write-Host "            (the check the skeleton below will carry, '$autoFillContext', is already filled in --" -ForegroundColor Yellow
        Write-Host '            apply and push it before pasting this, or the ruleset requires a check that does not exist yet):' -ForegroundColor Yellow
    } elseif ($autoFillContext) {
        Write-Host "            (the one candidate job, '$autoFillContext', is already filled in):" -ForegroundColor Yellow
    } else {
        Write-Host '            once you have replaced REPLACE-WITH-A-JOB-ID-BELOW with your own choice:' -ForegroundColor Yellow
        if ($prJobIds.Count -eq 1) {
            Write-Host "            (the one candidate, '$(Get-DisplayRef -Ref $prJobIds[0])', is not safe to paste as-is --" -ForegroundColor Yellow
            Write-Host '            it carries characters this print will not put in a command unescaped. Pick it up' -ForegroundColor Yellow
            Write-Host '            from the list below and quote it yourself for the shell you are in.)' -ForegroundColor Yellow
        }
    }
    if (-not $repoSlug) {
        Write-Host '            THE REPO SLUG COULD NOT BE RESOLVED -- replace <owner>/<repo> yourself.' -ForegroundColor Yellow
    } elseif (-not $repoSlugPasteSafe) {
        Write-Host "            THE REPO SLUG ('$(Get-DisplayRef -Ref $repoSlug)') IS NOT SAFE TO PASTE --" -ForegroundColor Yellow
        Write-Host '            replace <owner>/<repo> with it yourself, quoted for your shell.' -ForegroundColor Yellow
    }
    Write-Host '' -ForegroundColor Yellow
    $rulesetLines = @(
        '$json = @''',
        '{',
        "  ""name"": ""require $rulesetContext on $rulesetTrunk"",",
        '  "target": "branch",',
        '  "enforcement": "active",',
        "  ""conditions"": { ""ref_name"": { ""include"": [""refs/heads/$rulesetTrunk""], ""exclude"": [] } },",
        '  "bypass_actors": [ { "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always" } ],',
        '  "rules": [',
        '    {',
        '      "type": "required_status_checks",',
        '      "parameters": {',
        "        ""required_status_checks"": [ { ""context"": ""$rulesetContext"" } ],",
        '        "strict_required_status_checks_policy": false',
        '      }',
        '    }',
        '  ]',
        '}',
        "'@",
        "`$json | gh api --method POST repos/$rulesetSlug/rulesets --input -"
    )
    foreach ($ln in $rulesetLines) { Write-Host $ln -ForegroundColor DarkGray }
    Write-Host '' -ForegroundColor Yellow
    # STRICT MODE, NAMED (Sebastian's non-blocking note on #1972). Off is the same choice ship-pr's own
    # staleness guard already rests on: catching a branch up with the trunk is detect-and-rebase's job,
    # not the ruleset's, so a stale-but-green branch is still allowed to merge. Flip it to true instead
    # if you want GitHub itself, rather than ship-pr, to refuse a merge whose branch is behind the trunk.
    Write-Host '            STRICT MODE IS OFF ABOVE, ON PURPOSE: this workflow leaves "is my branch caught up"' -ForegroundColor Yellow
    Write-Host '            to ship-pr''s own detect-and-rebase rather than to GitHub. Set it to true instead if' -ForegroundColor Yellow
    Write-Host '            you want the ruleset itself to refuse a merge whose branch is behind the trunk.' -ForegroundColor Yellow
    Write-Host '' -ForegroundColor Yellow
    # THE BYPASS ACTOR IS NOT OPTIONAL (#2681). The fold is a direct push to the trunk, and a required
    # status check can never be satisfied by a direct push -- so a ruleset with no bypass_actors refuses
    # every fold (local ship-pr, fold-on-merge.yml, merge-on-green.yml) from the next PR on. Measured in a
    # consumer, October 1, 2026: this payload pasted as-is, and ship-pr's next run read
    # current_user_can_bypass = never for an org AND repo admin. RepositoryRole 5 (repository admin) is
    # the one actor valid on a user-owned and an org-owned repo alike -- OrganizationAdmin, the second
    # type the source repo declares, is refused on a user-owned one -- and an org owner holds the admin
    # role on every repo of the org, so this single entry already covers them.
    Write-Host '            THE BYPASS ACTOR ABOVE IS WHAT LETS THE FOLD LAND: the fold is a direct push to the' -ForegroundColor Yellow
    Write-Host '            trunk, which a required check can never be satisfied by. It names repository admins' -ForegroundColor Yellow
    Write-Host '            (an org owner is one on every repo), so a FOLD_PUSH_TOKEN must belong to one.' -ForegroundColor Yellow
    Write-Host '            Remove it and every fold is refused from the next pull request on.' -ForegroundColor Yellow
    Write-Host '' -ForegroundColor Yellow
    if (-not $autoFillContext) {
        Write-Host '            CANDIDATE CHECKS (job id -- from workflow), since more than one exists (or none' -ForegroundColor Yellow
        Write-Host '            does, or the one candidate was not safe to paste): pick the one your merge should' -ForegroundColor Yellow
        Write-Host '            actually wait on.' -ForegroundColor Yellow
        if ($repoPrWorkflows.Count -eq 0) {
            Write-Host '              (no workflow of this repo''s own triggers on pull_request)' -ForegroundColor DarkGray
        }
        foreach ($w in $repoPrWorkflows) {
            foreach ($jid in $w.JobIds) {
                # #2248: $w.Rel beside it is the same foreign-filename class $jid was already guarded for.
                Write-Host "              $(Get-DisplayRef -Ref $jid) -- from $(Get-DisplayPath -Path $w.Rel)" -ForegroundColor DarkGray
            }
        }
        Write-Host '' -ForegroundColor Yellow
    }
    Write-Host '            THIS POSTS A NEW RULESET, AND RULESETS LAYER: a trunk already protected by one' -ForegroundColor Yellow
    Write-Host '            gets a second, additive ruleset rather than an edit to the first -- which is' -ForegroundColor Yellow
    Write-Host '            harmless but not always what you want. To fold this rule into an existing' -ForegroundColor Yellow
    Write-Host '            ruleset instead, list them first and edit that one in the UI or via its own id:' -ForegroundColor Yellow
    Write-Host "              gh api repos/$rulesetSlug/rulesets" -ForegroundColor DarkGray
} else {
    foreach ($ctx in $requiredContexts) {
        # #2248: $ctx is the ruleset's required-check CONTEXT NAME off the repo's own ruleset JSON --
        # foreign text, same class Test-CiSuiteCertified already sends through Get-DisplayRef.
        $ctxDisplay = Get-DisplayRef -Ref $ctx
        $owner = @($workflows | Where-Object { $_.JobIds -contains $ctx })
        if ($owner.Count -eq 0) {
            Write-Host "  [note]    required check '$ctxDisplay' matches no job in .github/workflows/ -- it comes from" -ForegroundColor Yellow
            Write-Host '            somewhere else (another app, or a job name this reader cannot see). If it IS an' -ForegroundColor Yellow
            Write-Host '            Actions job, that workflow needs the merge_group trigger too.' -ForegroundColor Yellow
            continue
        }
        foreach ($w in $owner) {
            # #2248: $w.Rel is the consumer's own workflow filename, guarded the same way as $w.Rel above.
            $wRelDisplay = Get-DisplayPath -Path $w.Rel
            if ($w.HasMergeGroup) {
                Write-Host "  [ok]      required check '$ctxDisplay' -> $wRelDisplay, which triggers on merge_group." -ForegroundColor Green
            } elseif ($queueActive) {
                $liveDefects++
                Write-Host "  [ERROR]   required check '$ctxDisplay' -> $wRelDisplay, which does NOT trigger on merge_group," -ForegroundColor Red
                Write-Host "            and a queue is ACTIVE on '$trunk'. That check never reports for a queue entry," -ForegroundColor Red
                Write-Host '            so every merge fails. Add to its on: block, at two spaces of indent:' -ForegroundColor Red
                Write-Host '              merge_group:' -ForegroundColor Red
            } else {
                Write-Host "  [gap]     required check '$ctxDisplay' -> $wRelDisplay, which does NOT trigger on merge_group." -ForegroundColor Yellow
                Write-Host '            Inert today; a TOTAL MERGE OUTAGE the moment a queue is switched on. Add to its' -ForegroundColor Yellow
                Write-Host '            on: block, at two spaces of indent:' -ForegroundColor Yellow
                Write-Host '              merge_group:' -ForegroundColor Yellow
            }
        }
    }
}
Write-Host ''

# 2. THE RUNNERS THIS COMMAND CAN PLACE: new files beside yours, not edits to one of them, which is the
#    same line adopt-workflow-folder draws. Two answer an unobserved merge; the third (repo-settings)
#    answers a GitHub-side setting drifting on its own, and needs neither a queue nor a merge to matter;
#    merge-on-green finishes a ship whose session is gone; close-parked-recurrences (#3422) acts on the
#    tracker; and ci.yml (issue #1843) appears only on a trunk with nothing to require at all.
Write-Host '-- 2. the runners this floor places (an unobserved merge; on a schedule, GitHub-side drift; and, if nothing else exists, something to require) --' -ForegroundColor Cyan
$created = 0
$kept = 0
$foldRunnerCreated = $false
$mergeOnGreenRunnerCreated = $false
$writeRunnerCreated = $false
$refused = 0
foreach ($t in $targets) {
    $abs = Join-Path $repoRoot ($t.Rel -replace '/', '\')
    # BEFORE the existence test, as in adopt-workflow-folder (#2540): Test-Path follows a reparse point, so
    # a dangling symlink reads as absent and a junctioned .github/ takes the write outside the repo.
    $reparse = Get-WriteTargetReparsePoint -Path $abs -Root $repoRoot
    if ($reparse) {
        $refused++
        # A refused queue runner is as absent as a missing one, under -Apply too since nothing places it --
        # so it counts toward the live-defect exit code rather than turning an incomplete floor into exit 0.
        if ($queueActive -and $t.QueueRelated) { $liveDefects++ }
        Write-Host "  [refused] $($t.Rel) -- reached through a symlink or junction ($reparse), so writing it would land outside the repo; place it by hand" -ForegroundColor Yellow
        continue
    }
    if (Test-Path -LiteralPath $abs) {
        $kept++
        Write-Host "  [exists]  $($t.Rel) -- left as it is" -ForegroundColor DarkGray
        # AND HELD TO THE TEMPLATE THIS RUN COMPOSES, PIN ASIDE (#4529): the per-gap probes below each name
        # one known change, and this names any of them, including the ones no probe was written for. The
        # same comparison check-script-contract makes at every session start (Get-CiFloorRunnerDrift).
        if ($t.Rel -ne $ciSkeletonRel -and ((ConvertTo-PinNeutralRunnerText -Text ([System.IO.File]::ReadAllText($abs))) -cne (ConvertTo-PinNeutralRunnerText -Text $t.Content))) {
            Write-Host '            [behind] it differs from the template this run composes, its pin aside (#4529). To take the' -ForegroundColor Yellow
            Write-Host '            change: delete it, re-run with -Apply, and read git diff before committing.' -ForegroundColor Yellow
        }
        # AN EXISTING WRITE RUNNER IS READ FOR ITS PIN (#2333), because this is the only moment anything
        # looks at it again: the file is never rewritten, so a floor adopted on ref: main, or pinned at
        # an older release, stays there until somebody is told. Advisory -- the file stays untouched.
        if ($writeRunnerRels -contains $t.Rel) {
            $existing = ([System.IO.File]::ReadAllText($abs)) -replace "`r`n", "`n"
            Write-WriteRunnerPinVerdict -Rel $t.Rel -Text $existing
            if ($t.Rel -eq $mergeOnGreenRunnerRel) {
                Write-MergeOnGreenShapeVerdict -Text $existing
                Write-MergeOnGreenScopeVerdict -Text $existing
                Write-MergeOnGreenSettleVerdict -Text $existing
                Write-MergeOnGreenRedispatchVerdict -Text $existing
                Write-MergeOnGreenRefusalVerdict -Text $existing
            }
            else { Write-RunnerGroupVerdict -Rel $t.Rel -Text $existing -TemplateText $t.Content }
        }
        # THE READ-ONLY RUNNER IS READ FOR ITS PIN TOO (#4237): one adopted before it was pinned is still
        # on main, and this is the one moment anything says so.
        elseif ($t.Rel -eq $repoSettingsRunnerRel) {
            $existing = ([System.IO.File]::ReadAllText($abs)) -replace "`r`n", "`n"
            Write-WriteRunnerPinVerdict -Rel $t.Rel -Text $existing -ReadOnly
        }
        continue
    }
    if ($writeRunnerRels -contains $t.Rel) { $writeRunnerCreated = $true }
    # QUEUE-RELATED ONLY: repo-settings.yml missing is an ordinary to-do regardless of queue state, so
    # it must never count toward the ACTIVE-QUEUE-AND-INCOMPLETE-FLOOR exit code below.
    if ($queueActive -and -not $Apply -and $t.QueueRelated) { $liveDefects++ }
    $created++
    if ($t.Rel -eq $foldRunnerRel) { $foldRunnerCreated = $true }
    if ($t.Rel -eq $mergeOnGreenRunnerRel) { $mergeOnGreenRunnerCreated = $true }
    if ($Apply) {
        $dir = Split-Path -Parent $abs
        if (-not (Test-Path -LiteralPath $dir)) { $null = New-Item -ItemType Directory -Path $dir -Force }
        [System.IO.File]::WriteAllText($abs, $t.Content, $Utf8NoBom)
        Write-Host "  [created] $($t.Rel) -- $($t.What)" -ForegroundColor Green
    } else {
        $marker = if ($queueActive -and $t.QueueRelated) { '[MISSING]' } else { '[create] ' }
        $colour = if ($queueActive -and $t.QueueRelated) { 'Red' } else { 'Green' }
        Write-Host "  $marker $($t.Rel) -- $($t.What)" -ForegroundColor $colour
    }
}
# WHAT WAKES THE SWEEP IS SAID OUT LOUD (#4258). The workflow_run list is read off the pull_request
# workflows in this tree AT THIS MOMENT, so a run made while Part 1's two gate callers were deleted (the
# delete-and-re-run repair for stale pins) placed a list without them, and nothing said so: the schedule
# still sweeps, only later, and a diff against the old file reads like template drift.
if ($mergeOnGreenRunnerCreated) {
    $wakeShown = if ($mogWakeNames.Count -gt 0) { ($mogWakeNames | ForEach-Object { '"' + $_ + '"' }) -join ', ' } else { '(none -- the schedule alone carries the sweep)' }
    Write-Host "  [wake]    merge-on-green.yml wakes on: $wakeShown" -ForegroundColor DarkGray
    $part1Missing = @(@('.github/workflows/branch-entry.yml', '.github/workflows/always-on-budget.yml') | Where-Object {
        -not (Test-Path -LiteralPath (Join-Path $repoRoot ($_ -replace '/', '\')) -PathType Leaf)
    })
    if ($part1Missing.Count -gt 0) {
        Write-Host "            $($part1Missing -join ' and ') not in this tree, so the sweep does not wake on them." -ForegroundColor Yellow
        Write-Host '            Part 1 (adopt-workflow-folder.ps1 -Apply) places them: run it first, then delete' -ForegroundColor Yellow
        Write-Host '            merge-on-green.yml and re-run this with -Apply (#4258).' -ForegroundColor Yellow
    }
}
if ($writeRunnerCreated) {
    switch ($writeRunnerPinState) {
        'sha'      { Write-Host "  [pin]     the write runners fetch the shared scripts at $writeRunnerRef -- this plugin's own release." -ForegroundColor DarkGray }
        'override' { Write-Host "  [pin]     the write runners fetch the shared scripts at $(Get-DisplayRef -Ref $writeRunnerRef) (-SharedRefOverride)." -ForegroundColor DarkGray }
        'tag'      {
            Write-Host "  [pin]     the write runners fetch the shared scripts at the TAG ${writeRunnerRef}: its commit SHA could" -ForegroundColor Yellow
            Write-Host '            not be resolved (git ls-remote did not answer). A tag can be moved and a SHA cannot --' -ForegroundColor Yellow
            Write-Host '            re-run this with a network to write the SHA, or replace the ref: lines by hand.' -ForegroundColor Yellow
        }
        default    {
            Write-Host '  [pin]     this plugin''s version could not be read, so the write runners fetch the shared scripts' -ForegroundColor Yellow
            Write-Host '            at main -- the tip, beside a write credential (#2333). Replace their ref: lines with a' -ForegroundColor Yellow
            Write-Host '            release commit of the dkj-repo-workflow plugin before you store FOLD_PUSH_TOKEN.' -ForegroundColor Yellow
        }
    }
}
Write-Host '  [note]    repo-settings.yml runs on a SCHEDULE, not per merge -- it answers a different' -ForegroundColor DarkGray
Write-Host '            question (has a GitHub-side setting drifted since it was declared) and reports' -ForegroundColor DarkGray
Write-Host '            nothing unless scripts/repo-config.ps1 declares Get-ExpectedRepoSettings; an' -ForegroundColor DarkGray
Write-Host '            empty or absent declaration is the default and is a [SKIP] there, not a gap here.' -ForegroundColor DarkGray
# THE SECRET REMINDER NAMES THE FOLD RUNNER SPECIFICALLY, and only fires when THAT target is the one
# missing -- not on the generic $created count, which with three targets no longer says which file that
# was. A repo missing only repo-settings.yml (no secret involved at all) must never be told to go create
# a FOLD_PUSH_TOKEN it does not need.
if ($foldRunnerCreated) {
    Write-Host ''
    Write-Host '  THE FOLD RUNNER NEEDS A SECRET YOU HAVE TO CREATE: FOLD_PUSH_TOKEN.' -ForegroundColor Yellow
    Write-Host '  A merge_queue rule blocks every direct push to the trunk, and the default GITHUB_TOKEN' -ForegroundColor Yellow
    Write-Host '  cannot be given a bypass. Create a fine-grained PAT owned by somebody who already bypasses' -ForegroundColor Yellow
    Write-Host '  the ruleset, scoped to this repository and to Contents: Read and write, and store it as' -ForegroundColor Yellow
    Write-Host '  the repository secret FOLD_PUSH_TOKEN. Without it -- or with one that does not grant this' -ForegroundColor Yellow
    Write-Host '  repository -- actions/checkout FAILS and the job never reaches the fold: every later step' -ForegroundColor Yellow
    Write-Host '  shows skipped. Create it BEFORE you merge the floor, not after. (A fine-grained PAT lists' -ForegroundColor Yellow
    Write-Host '  repositories one by one, so a repo created rather than transferred falls outside an' -ForegroundColor Yellow
    Write-Host '  existing token''s selection.)' -ForegroundColor Yellow
}
if ($mergeOnGreenRunnerCreated) {
    Write-Host ''
    Write-Host '  THE MERGE-ON-GREEN RUNNER USES THAT SAME FOLD_PUSH_TOKEN, AND NEEDS ONE MORE SCOPE ON IT:' -ForegroundColor Yellow
    Write-Host '  Pull requests: Read and write, beside Contents: Read and write. A merge made with the' -ForegroundColor Yellow
    Write-Host '  job-scoped GITHUB_TOKEN starts no workflow runs, so it would silence this repo''s CI on the' -ForegroundColor Yellow
    Write-Host '  trunk and the fold and resolves runners in one go. Without the scope the merge fails with a' -ForegroundColor Yellow
    Write-Host '  403, loudly, and nothing is merged. It also READS as that token (#4447): add Checks,' -ForegroundColor Yellow
    Write-Host '  Commit statuses, Actions and Issues, each Read-only, or ship-pr reads zero checks and' -ForegroundColor Yellow
    Write-Host '  refuses a green pull request after 1800s as "never registered".' -ForegroundColor Yellow
    Write-Host '  Its workflow_run trigger names these workflows:' -ForegroundColor Yellow
    if ($mogWakeNames.Count -gt 0) {
        foreach ($n in $mogWakeNames) { Write-Host "    $(Get-DisplayRef -Ref $n)" -ForegroundColor DarkGray }
    } else {
        Write-Host '    (none -- no pull_request workflow here declares a usable top-level name:, so only the' -ForegroundColor DarkGray
        Write-Host '    every-3-hours schedule wakes it; add a workflow_run trigger by hand if you want it sooner)' -ForegroundColor DarkGray
    }
}
Write-Host ''

# 3. WHAT THIS FLOOR COSTS ON A METERED (PRIVATE) REPO (issue #2487). PURE STATIC TEXT -- no repo-
# visibility check and no network call: this script already refuses to guess at anything it cannot
# read from the tree or a token, and "is this repo private" is exactly that kind of guess. A follow-up
# (#2488) moved three of the four runners to ubuntu-latest + pwsh, and #2616 moved merge-on-green.
Write-Host '-- 3. what this floor costs on a metered (private) repo --' -ForegroundColor Cyan
Write-Host '  Actions minutes are FREE and unlimited on a PUBLIC repo''s standard runners. On a PRIVATE' -ForegroundColor DarkGray
Write-Host '  repo they are METERED against your plan''s included allowance and billed past it: every job' -ForegroundColor DarkGray
Write-Host '  is billed rounded UP to a whole minute even where it runs in seconds, and a Windows minute' -ForegroundColor DarkGray
Write-Host '  costs more than a Linux one -- every runner this floor places runs on Linux' -ForegroundColor DarkGray
Write-Host '  (ubuntu-latest).' -ForegroundColor DarkGray
Write-Host '  What starts a billed job, per runner:' -ForegroundColor DarkGray
Write-Host '    fold-on-merge.yml + verify-resolved.yml -- one job EACH per trunk push that is not a lone' -ForegroundColor DarkGray
Write-Host '      fold: commit (skipped at the job level on that push, unbilled -- see section 2 above).' -ForegroundColor DarkGray
Write-Host '    repo-settings.yml -- 1 scheduled job/day, about 30/month.' -ForegroundColor DarkGray
Write-Host '    merge-on-green.yml -- 8 scheduled jobs/day, about 240/month, PLUS one per completed run' -ForegroundColor DarkGray
Write-Host '      of every workflow named in its workflow_run trigger, above -- and a sweep the settle' -ForegroundColor DarkGray
Write-Host '      window alone refused waits it out, up to about 11 more billed minutes (#3809).' -ForegroundColor DarkGray
Write-Host '    close-parked-recurrences.yml -- one job per issue opened with, or given, a recurrence label;' -ForegroundColor DarkGray
Write-Host '      every other issue event is skipped at the job level, unbilled.' -ForegroundColor DarkGray
Write-Host ''

# 4. THE QUEUE, LAST, NEVER PULLED HERE -- AND NEVER REPORTED AS A GAP (issues #1540, #1546).
#    It was a '[gap]' until September 7, 2026, on the reading that every repo running this workflow
#    adopts one. Most of them are not ALLOWED to: GitHub offers merge queue on private repos only under
#    Enterprise Cloud, and otherwise only on public repos owned by organizations -- and on Free, Pro or
#    Team it hides the 'Require merge queue' checkbox rather than disabling it. So the instruction could
#    not be followed and the gap could not be closed, and the reader went looking through the ruleset UI
#    for a control that is not rendered. Measured: this workflow's own source repo is public on plan
#    'free' and qualifies through the public clause, which is why the policy looked universal to the one
#    repo that set it. A missing queue is now the ORDINARY state and prints as a note.
Write-Host '-- 4. the queue (optional -- not this workflow''s policy) --' -ForegroundColor Cyan
if (-not $queueReadable) {
    Write-Host "  [skip]    the trunk's rules could not be read here -- no gh, no network, or a token that" -ForegroundColor DarkGray
    Write-Host '            cannot read rulesets. That is not "no queue": nothing above assumed either way.' -ForegroundColor DarkGray
    Write-Host "            Read it yourself with:  gh api repos/<owner>/<repo>/rules/branches/$trunk --jq '[.[].type]'" -ForegroundColor DarkGray
} elseif ($queueActive) {
    Write-Host "  [ok]      a merge_queue rule is active on '$trunk' ($rulesSource)." -ForegroundColor Green
    Write-Host '            Point 1 above is what keeps it honest -- a required check with no merge_group' -ForegroundColor DarkGray
    Write-Host '            trigger stops every merge in this repo.' -ForegroundColor DarkGray
} else {
    Write-Host "  [note]    no merge_queue rule on '$trunk' -- which is the ordinary state, not a gap." -ForegroundColor DarkGray
    Write-Host '            This workflow relies on detect-and-rebase instead: ship-pr refuses to merge on a' -ForegroundColor DarkGray
    Write-Host '            certificate the trunk has moved past, and you bring the branch forward. That works' -ForegroundColor DarkGray
    Write-Host '            in every repo, which a queue does not -- GitHub offers one on a PRIVATE repo only' -ForegroundColor DarkGray
    Write-Host '            under Enterprise Cloud, and otherwise only on a PUBLIC repo owned by an org. On' -ForegroundColor DarkGray
    Write-Host '            Free, Pro or Team the checkbox is not rendered at all, so this is usually not even' -ForegroundColor DarkGray
    Write-Host '            an available choice. What detect-and-rebase DOES need is point 1 above: a required' -ForegroundColor DarkGray
    Write-Host '            check to read a certificate from.' -ForegroundColor DarkGray
    Write-Host '' -ForegroundColor DarkGray
    Write-Host '            If your repo is eligible and you want one anyway, add the rule named' -ForegroundColor DarkGray
    Write-Host "            'Require merge queue' in Settings -> Rules -> Rulesets, on the ruleset that" -ForegroundColor DarkGray
    Write-Host "            already protects '$trunk'." -ForegroundColor DarkGray
    Write-Host '            THIS COMMAND WILL NOT DO IT FOR YOU, deliberately: a ruleset changes what' -ForegroundColor DarkGray
    Write-Host '            every contributor''s merge does, immediately, for everybody. Do points 1 and 2' -ForegroundColor DarkGray
    Write-Host '            FIRST -- flipping it with a required check that has no merge_group trigger is a' -ForegroundColor DarkGray
    Write-Host '            total merge outage on the first merge afterwards.' -ForegroundColor DarkGray
}
Write-Host ''

if ($Apply) {
    Write-Host "Done: $created runner(s) created, $kept left as they were." -ForegroundColor Green
} else {
    Write-Host "Would create $created runner(s); $kept already exist. Re-run with -Apply." -ForegroundColor Yellow
}
if ($refused -gt 0) {
    Write-Host "$refused runner(s) refused -- reached through a symlink or junction; see the [refused] lines above." -ForegroundColor Yellow
}

# EXIT 1 ONLY ON A LIVE DEFECT, and the distinction is the whole point of the two vocabularies above. A
# '[gap]' is work not yet done on a repo whose merges are fine today; an '[ERROR]' is a queue that is
# already running against a floor that is not there -- entries being stranded on the trunk, or merges
# about to stop. Exiting 1 on the first would make an honest to-do list read as a broken repo, which is
# how a report earns being ignored.
if ($liveDefects -gt 0) {
    Write-Host "$liveDefects live defect(s): the queue on '$trunk' is ACTIVE and the floor under it is incomplete." -ForegroundColor Red
    exit 1
}
exit 0
