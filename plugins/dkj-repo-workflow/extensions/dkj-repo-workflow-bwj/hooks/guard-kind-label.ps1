<#
.SYNOPSIS
    PreToolUse hook on the shell tools: refuses a 'gh issue create' on a store repo whose labels hold
    none, or more than one, of the kind labels 'bug', 'feature' and 'research' (#4197).

.DESCRIPTION
    THE RULE IS report-issue's STEP 1 and WORKFLOW-portable.md's classification table (#2783, #3006):
    every issue carries exactly one kind, set on the create itself. Measured in smartwatchbanden: 11
    consecutive issues filed by sessions on 2026-11-13 and 2026-11-14 carried none, with the rule loaded.
    The verdict and the repo list are in scripts/lib/kind-label-rules.ps1; this file reads the payload,
    names the repo, and answers.

    IT FAILS OPEN, with a warning, the direction guard-reach-reason chose for the same reason: labels
    built at run time or set outside the command (a template, the browser, an editor, --recover), and a
    repo it cannot name, pass with a line on stderr naming what was not checked. A missing kind is cheap
    to repair; a guard that stops every issue create while the tracker is unreachable is not.

    WHAT IT PRINTS is its own text and refs built from GitHub's owner/name character classes -- never a
    title or a body.

    Exit codes (PreToolUse contract): 2 = block and send stderr to Claude; 0 = allow.

    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/guard-kind-label.tests.ps1 in the
    source repo -- change one, run the other.
#>
$ErrorActionPreference = 'Stop'

# READ STDIN ONLY WHERE THERE IS A HANDLE, the guard every hook in this tree carries (#2264).
$raw = ''
if ([Console]::IsInputRedirected) { $raw = [Console]::In.ReadToEnd() }

# THE CHEAP PRE-GATE, the same test hooks.json makes in shell first.
if ($raw -notmatch 'gh(\.exe)?\s+issue\s+create') { exit 0 }

foreach ($lib in @('asana-task-lib.ps1', 'kind-label-rules.ps1')) {
    $libPath = Join-Path $PSScriptRoot "..\scripts\lib\$lib"
    if (-not (Test-Path -LiteralPath $libPath -PathType Leaf)) {
        [Console]::Error.WriteLine("guard-kind-label: $lib not found beside this hook -- the kind-label check is OFF for this call. Reinstall or update the dkj-repo-workflow-bwj plugin.")
        exit 0
    }
    . $libPath
}

trap {
    [Console]::Error.WriteLine('guard-kind-label: an unexpected error stopped the check -- it did NOT judge this call. Confirm by hand that the new issue carries exactly one of bug, feature or research.')
    exit 0
}

# A BYTE-ORDER MARK IS NOT PART OF THE PAYLOAD (see guard-stale-paste-block.ps1).
$jsonText = [string]$raw
$brace = $jsonText.IndexOf('{')
if ($brace -gt 0) { $jsonText = $jsonText.Substring($brace) }
$command = ''
try { $command = [string](($jsonText | ConvertFrom-Json).tool_input.command) } catch { exit 0 }

$calls = @(Get-GhIssueLabelCall -Command $command | Where-Object { $_.Kind -ceq 'create' })
if ($calls.Count -eq 0) { exit 0 }

$projectDir = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }
$currentRepo = $null
$refused = @()
$unchecked = @()
foreach ($c in $calls) {
    $nwo = [string]$c.Repo
    # A --repo given as a variable names a repo this hook cannot read: unknown, never the checkout's (#4293).
    if ($c.RepoUnknown) { $unchecked += 'a new issue (repo given as a variable)'; continue }
    if (-not $nwo) {
        if ($null -eq $currentRepo) {
            $currentRepo = ''
            $run = Invoke-AsanaGhBounded -Arguments 'repo view --json nameWithOwner -q .nameWithOwner' -TimeoutMs 8000 -WorkingDirectory $projectDir
            if ($run.Started -and -not $run.TimedOut -and $run.ExitCode -eq 0) { $currentRepo = ([string]$run.Out).Trim() }
        }
        $nwo = $currentRepo
    }
    if ($nwo -notmatch '\A[A-Za-z0-9][A-Za-z0-9-]*/([A-Za-z0-9._-]+)\z') { $unchecked += 'a new issue (repo unknown)'; continue }
    if ($script:KindLabelRepos -notcontains $Matches[1].ToLowerInvariant()) { continue }

    $v = Get-KindLabelVerdict -Call $c
    switch ($v.Verdict) {
        'refuse' {
            $has = if (@($v.Kinds).Count -gt 0) { "carries $(@($v.Kinds) -join ' and ')" } else { 'carries none of them' }
            $refused += "a new issue on $nwo $has"
        }
        'unchecked' { $unchecked += "a new issue on $nwo (labels built at run time, or set in a template, the browser or an editor)" }
    }
}

if ($unchecked.Count -gt 0) {
    [Console]::Error.WriteLine("guard-kind-label: could not read the labels of $($unchecked -join ', ') -- the kind check did NOT judge it. Confirm by hand that the issue carries exactly one of bug, feature or research.")
}
if ($refused.Count -eq 0) { exit 0 }

[Console]::Error.WriteLine("BLOCKED (guard-kind-label): every issue carries exactly one of the kind labels bug, feature or research, set on the create itself -- $($refused -join '; ').")
[Console]::Error.WriteLine(@(
    '  Pick one (report-issue step 1, #2783, #3006):',
    '    --label feature   something new being added',
    '    --label bug       something that exists and has to change',
    '    --label research  a research, test or decision ticket that changes nothing on the store',
    '  A doc finding is a bug or a feature: a missing page is a feature, a wrong one a bug.'
) -join "`n")
exit 2
