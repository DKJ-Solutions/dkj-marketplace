<#
.SYNOPSIS
    The two CI gate callers adopt-workflow-folder.ps1 places, composed in one place so a placed copy can
    be held against them (issue #4537).

.DESCRIPTION
    adopt-workflow-folder.ps1 places .github/workflows/branch-entry.yml and
    .github/workflows/always-on-budget.yml -- each a few-line caller of a reusable workflow in the source
    -- and never rewrites one it finds. Until #4537 the composition lived inline in that script, so
    nothing else could ask what the CURRENT template of a caller is, and an existing copy was only read
    for two known gaps (the @main pin, #4237, and the live branch, #4374). #4529 did the same for the
    five CI-floor runners (ci-floor-runners-lib.ps1); this is the same treatment for the two callers.

    So the composition is here -- the live-branch resolution (Resolve-WorkflowFolderLiveBranch), the two
    callers (Get-WorkflowFolderCallerTargets) -- and Get-WorkflowFolderCallerDrift compares each PLACED
    caller with them, pin neutral. The pin is the one thing a placed copy is EXPECTED to differ on: the
    `@<ref>` ending the `uses: .../reusable-*.yml@...` line and the `scripts-ref:` value, a vX.Y.Z tag,
    main, or the placeholder the template is composed with. check-script-contract.ps1 reports the result
    at every session start as a non-counting [BEHIND] line.

    Needs ci-floor-runners-lib.ps1 (Get-FirstDifferingLine, and through it write-target-lib's
    Get-WriteTargetReparsePoint), command-probe-lib.ps1 (Test-FunctionDefined) and check-report-lib.ps1
    (Format-SafeProseToken), each loaded from this file's own directory when the caller has not loaded
    it already.

    Pure ASCII, per this repo's script-layer convention.
#>

if (-not (Get-Command -Name Get-CiFloorRunnerDrift -CommandType Function -ErrorAction SilentlyContinue)) { . (Join-Path $PSScriptRoot 'ci-floor-runners-lib.ps1') }
if (-not (Get-Command -Name Test-FunctionDefined -CommandType Function -ErrorAction SilentlyContinue)) { . (Join-Path $PSScriptRoot 'command-probe-lib.ps1') }
if (-not (Get-Command -Name Format-SafeProseToken -CommandType Function -ErrorAction SilentlyContinue)) { . (Join-Path $PSScriptRoot 'check-report-lib.ps1') }

# The ref the template is composed with when only its shape matters; read as '<pin>' on both sides.
$script:WorkflowFolderCallerPlaceholderRef = '@@GATE_REF@@'

function Resolve-WorkflowFolderLiveBranch {
    <#
        The live deploy branch a Shopify consumer's hotfix lane ships PRs to, as the repo's own
        scripts/repo-config.ps1 answers it, and the sentence that explains an answer this command cannot
        use. Returns @{ Branch; Note }: Branch is '' when nothing usable is answered, Note is '' unless
        something was answered and refused.

        THE LIVE BRANCH IS A SECOND BASE FOR THE BRANCH-ENTRY CALLER (#4374). A Shopify consumer with a hotfix
        lane ships branches as PRs to its live deploy branch (the name Get-ShopifyLiveDeployBranch answers in
        scripts/repo-config.ps1) and only later flows live back to the trunk. A caller on `branches: [main]`
        never ran on those PRs, so a malformed DEPLOY section landed on the live branch unjudged, rode the
        back-flow onto the trunk, and turned the fold red on every later merge. The gate itself judges the HEAD
        branch's own document and assumes no base (check-branch-entry.ps1), so the trigger is the whole fix.

        ONLY THE BRANCH-ENTRY CALLER, because the always-on budget gate holds what every session pays and that
        is measured against the trunk. The seam is read in a child scope, StrictMode off, inside a try, because
        the file is the consumer's and a fault in it must degrade to "unanswered". The check is the plain-name
        one adopt-shopify-floor applies before it writes the answer into a workflow (letters, digits, . _ / -,
        no leading '-'), plus the answers that would be wrong here: a VUL-IN placeholder, a refs/ spelling, '..',
        and the trunk itself, which is already listed. Read from the file as it stands NOW, so a seam this very
        run appends is not counted: answer it, then re-run. The trunk stays the literal 'main', as it has been.
    #>
    param([Parameter(Mandatory)][string]$RepoConfigPath)
    $liveBranch = ''
    $liveBranchNote = ''
    $liveAnswer = & {
        Set-StrictMode -Off
        $answer = ''
        if (Test-Path -LiteralPath $args[0] -PathType Leaf) {
            try {
                . $args[0]
                if (Test-FunctionDefined 'Get-ShopifyLiveDeployBranch') { $answer = ([string](Get-ShopifyLiveDeployBranch)).Trim() }
            } catch { }
        }
        return $answer
    } $RepoConfigPath
    if ($liveAnswer) {
        if ($liveAnswer -notmatch '^(?!-)[A-Za-z0-9._/-]+$' -or $liveAnswer -match 'VUL-IN' -or $liveAnswer -match '^refs/' -or $liveAnswer.Contains('..') -or $liveAnswer -ceq 'main') {
            $liveBranchNote = "Get-ShopifyLiveDeployBranch answers '$(Format-SafeProseToken -Value $liveAnswer)', which is not a usable live branch name (a plain name other than main, no VUL-IN placeholder, no refs/ prefix), so the branch-entry caller lists main only"
        } else { $liveBranch = $liveAnswer }
    }
    return @{ Branch = $liveBranch; Note = $liveBranchNote }
}

function Get-WorkflowFolderCallerTargets {
    <#
        The two callers as @{ Rel; Content } records, in the order adopt-workflow-folder places them,
        pinned to -GateRef (a 'vX.Y.Z' tag, or 'main') with -LiveBranch (or '') as a second base of the
        branch-entry caller's trigger. Composed with LF line endings and one trailing newline.
    #>
    param(
        [Parameter(Mandatory)][string]$GateRef,
        [string]$LiveBranch = ''
    )
    $gateRef = $GateRef
    $liveBranch = $LiveBranch
    $nl = "`n"

    $entryGateWorkflow = @(
        '# Every PR into the trunk carries a WRITTEN changelog entry.',
        '#',
        '# The runner is not in this file: it is a reusable workflow in DKJ-Solutions/dkj-marketplace,',
        '# which runs check-branch-entry.ps1 -- the same two functions open-pr calls locally. One definition',
        '# of the gate, and a change to it reaches this repo without re-adopting. Its reasoning is written there.',
        '#',
        '# WHICH BRANCHES OWE NOTHING: answer Get-EntryGateExemptPrefixes in scripts/repo-config.ps1. It',
        '# defaults to ''sync'' -- a mirror branch carries somebody else''s work, so it has nothing to declare.',
        '#',
        '# PINNED TO A RELEASE (#4237): a script moved on the source''s main would otherwise turn this gate red',
        '# before this repo adopts the release carrying the move. When you update the dkj-repo-workflow plugin,',
        '# move the tag in `uses:` AND in `scripts-ref:` together -- re-running adopt-workflow-folder says when.',
        'name: Branch entry',
        '',
        '# pull-requests: read AND edited HOLD THE DEPLOY LOCK: the runner reads the PR body to refuse a DEPLOY',
        '# section changed since the PR opened, and edited lets it look again after open-pr -RefreshBody.',
        'permissions:',
        '  contents: read',
        '  pull-requests: read',
        '',
        'on:',
        '  pull_request:',
        '    types: [opened, synchronize, reopened, edited]',
        '    branches: [main]',
        '',
        'jobs:',
        '  branch-entry:',
        ('    uses: DKJ-Solutions/dkj-marketplace/.github/workflows/reusable-branch-entry.yml@' + $gateRef),
        '    with:',
        ('      scripts-ref: ' + $gateRef)
    )

    # The live branch joins the caller's trigger, with the reason beside it (#4374). Inserted by position, so
    # a caller without a live branch stays byte-for-byte what it was.
    if ($liveBranch) {
        $entryGateWorkflow = @($entryGateWorkflow | ForEach-Object { $_ -replace '^    branches: \[main\]$', "    branches: [main, $liveBranch]" })
        $pinAt = [array]::IndexOf($entryGateWorkflow, ($entryGateWorkflow | Where-Object { $_ -like '# PINNED TO A RELEASE*' } | Select-Object -First 1))
        $liveComment = @(
            "# THE LIVE BRANCH IS LISTED TOO (#4374): this repo ships hotfix PRs straight to '$liveBranch'",
            '# (Get-ShopifyLiveDeployBranch in scripts/repo-config.ps1) and they flow back to the trunk only later.',
            '# Without it here the gate never ran on those PRs, and a malformed DEPLOY section reached the trunk',
            '# and turned the fold red on every later merge. Change the two together.',
            '#'
        )
        $entryGateWorkflow = @($entryGateWorkflow[0..($pinAt - 1)]) + $liveComment + @($entryGateWorkflow[$pinAt..($entryGateWorkflow.Count - 1)])
    }

    $alwaysOnGateWorkflow = @(
        '# The always-on budget: a PR may not grow what every session pays before a single assignment is',
        '# given -- CLAUDE.md plus everything it ''@''-imports.',
        '#',
        '# The runner is not in this file: it is a reusable workflow in DKJ-Solutions/dkj-marketplace,',
        '# which runs check-always-on-budget.ps1 -- the same verdict open-pr reads locally and the session',
        '# hook reports at start. Its reasoning is written there.',
        '#',
        '# WHAT THE CEILING IS: answer Get-AlwaysOnBudget in scripts/repo-config.ps1, in BYTES. Unanswered,',
        '# it is 100,000. A repo already over it is held at a recorded baseline rather than refused.',
        '#',
        '# PINNED TO A RELEASE, for the reason branch-entry.yml states (#4237). Move the tag in `uses:` AND',
        '# in `scripts-ref:` together.',
        'name: Always-on budget',
        '',
        'permissions:',
        '  contents: read',
        '',
        'on:',
        '  pull_request:',
        '    branches: [main]',
        '',
        'jobs:',
        '  always-on-budget:',
        ('    uses: DKJ-Solutions/dkj-marketplace/.github/workflows/reusable-always-on-budget.yml@' + $gateRef),
        '    with:',
        ('      scripts-ref: ' + $gateRef)
    )

    return @(
        @{ Rel = '.github/workflows/branch-entry.yml';     Content = (($entryGateWorkflow -join $nl) + $nl) },
        @{ Rel = '.github/workflows/always-on-budget.yml'; Content = (($alwaysOnGateWorkflow -join $nl) + $nl) }
    )
}

function ConvertTo-PinNeutralCallerText {
    <#
        A caller's text with the release pin taken out, LF-normalised, one trailing newline: the `@<ref>`
        ending a `uses: .../reusable-*.yml@<ref>` line and the `scripts-ref:` value. <ref> is a vX.Y.Z tag,
        main, or the placeholder the template is composed with; all three read as '<pin>'. A `uses:` of
        anybody else's workflow is not ours and is left as it stands.
    #>
    param([AllowEmptyString()][string]$Text)
    $t = ($Text -replace "`r`n", "`n").TrimEnd("`n") + "`n"
    $ref = '(?:@@GATE_REF@@|v\d+\.\d+\.\d+|main)'
    $t = $t -replace ('(?m)^([ \t]*uses:[ \t]*DKJ-Solutions/dkj-marketplace/\.github/workflows/reusable-[\w-]+\.yml)@' + $ref + '[ \t]*$'), '$1@<pin>'
    return ($t -replace ('(?m)^([ \t]*scripts-ref:)[ \t]*' + $ref + '[ \t]*$'), '$1 <pin>')
}

function Get-WorkflowFolderCallerDrift {
    <#
        One record per gate caller that is PLACED in -RepoRoot: Rel, Stale ($true when it differs from
        the template this plugin version composes, its pin aside) and Line (the first line that differs,
        0 when it is current). A caller that is absent is not reported -- check-script-contract's
        [UNADOPTED] line owns that -- and neither is one reached through a symlink or junction, which
        adopt-workflow-folder refuses to touch.

        The template is composed for THIS tree: the live branch is resolved from its own
        scripts/repo-config.ps1 exactly as adopt-workflow-folder resolves it, so a repo that declared a
        live branch after placing the caller reads behind. Nothing in the placed file is returned, only a
        line number, because its text is the consumer's and the caller prints into session context.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot)
    $live = Resolve-WorkflowFolderLiveBranch -RepoConfigPath (Join-Path $RepoRoot 'scripts\repo-config.ps1')
    $records = @()
    foreach ($t in @(Get-WorkflowFolderCallerTargets -GateRef $script:WorkflowFolderCallerPlaceholderRef -LiveBranch $live.Branch)) {
        $abs = Join-Path $RepoRoot ($t.Rel -replace '/', '\')
        if (Get-WriteTargetReparsePoint -Path $abs -Root $RepoRoot) { continue }
        if (-not (Test-Path -LiteralPath $abs -PathType Leaf)) { continue }
        $line = Get-FirstDifferingLine `
            -Placed (ConvertTo-PinNeutralCallerText -Text ([System.IO.File]::ReadAllText($abs))) `
            -Template (ConvertTo-PinNeutralCallerText -Text $t.Content)
        $records += [pscustomobject]@{ Rel = $t.Rel; Stale = ($line -gt 0); Line = $line }
    }
    return $records
}
