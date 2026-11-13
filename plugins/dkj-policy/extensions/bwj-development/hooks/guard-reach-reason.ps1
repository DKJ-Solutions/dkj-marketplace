<#
.SYNOPSIS
    PreToolUse hook on the shell tools: refuses a 'gh issue create' or 'gh issue edit' that puts the reach
    label on an issue of an admitted repo whose body has no written 'Why <reach label>' section (#4057).

.DESCRIPTION
    THE RULE IS report-issue's STEP 1 (inbound #4057, the owner, November 13, 2026): the reach label is
    given only with its reason written into the issue -- who notices the defect, and what they notice --
    so the call is made with thought and can be checked afterwards. Measured in smartwatchbanden: 35
    issues filed with 'minor' since November 1, and not one said why. The parsing and the section test
    are in scripts/lib/reach-reason-rules.ps1; this file reads the payload, finds the body, and answers.

    WHICH CALLS. A create whose --label/-l names the reach label, and an edit whose --add-label does, on a
    repo report-issue admits (asana-mirror-gate.ps1's list, matched on the repo NAME). The body judged is
    the one the call will leave on the issue: its --body or --body-file where it passes one, else, for an
    edit, the issue's current body, read through gh. A create with no body at all is refused, since it
    carries no reason either.

    THE REACH LABEL'S NAME is the project's Get-ReachLabel (Get-ProjectReachLabel, the definition the
    other two reach-label hooks use), defaulting to 'minor'.

    IT FAILS OPEN, with a warning, the direction guard-asana-mirror chose for the same reason (#2482):
    a body it cannot read (gh absent, slow or logged out, a body file that is not there, a body on stdin,
    a body built at run time from a variable or a subexpression, a create's --template, --recover, --web
    or --editor) passes with a line on stderr naming what was not checked, and so does a repo it cannot
    name. A run-time body whose literal text already shows the section passes silently. A label
    added without its reason is cheap to repair; a guard that stops every issue edit while the tracker is
    unreachable is not.

    WHAT IT PRINTS is its own text, refs built from GitHub's owner/name character classes, and the label
    name from this repo's own config -- never a title or a body.

    Exit codes (PreToolUse contract): 2 = block and send stderr to Claude; 0 = allow.

    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/guard-reach-reason.tests.ps1 in the
    source repo -- change one, run the other.
#>
$ErrorActionPreference = 'Stop'

# READ STDIN ONLY WHERE THERE IS A HANDLE, the guard every hook in this tree carries (#2264).
$raw = ''
if ([Console]::IsInputRedirected) { $raw = [Console]::In.ReadToEnd() }

# THE CHEAP PRE-GATE, the same test hooks.json makes in shell first.
if ($raw -notmatch 'gh(\.exe)?\s+issue\s+(create|edit)') { exit 0 }

foreach ($lib in @('asana-task-lib.ps1', 'asana-mirror-gate.ps1', 'reach-reason-rules.ps1')) {
    $libPath = Join-Path $PSScriptRoot "..\scripts\lib\$lib"
    if (-not (Test-Path -LiteralPath $libPath -PathType Leaf)) {
        [Console]::Error.WriteLine("guard-reach-reason: $lib not found beside this hook -- the reach-label reason check is OFF for this call. Reinstall or update the bwj-development plugin.")
        exit 0
    }
    . $libPath
}

trap {
    [Console]::Error.WriteLine('guard-reach-reason: an unexpected error stopped the check -- it did NOT judge this call. Confirm by hand that an issue given the reach label says why in its body.')
    exit 0
}

# A BYTE-ORDER MARK IS NOT PART OF THE PAYLOAD (see guard-stale-paste-block.ps1).
$jsonText = [string]$raw
$brace = $jsonText.IndexOf('{')
if ($brace -gt 0) { $jsonText = $jsonText.Substring($brace) }
$command = ''
try { $command = [string](($jsonText | ConvertFrom-Json).tool_input.command) } catch { exit 0 }

$projectDir = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }
$reach = Get-ProjectReachLabel -ProjectDir $projectDir
$label = $reach.Label
if ($reach.ReadFailed) {
    [Console]::Error.WriteLine("guard-reach-reason: scripts\repo-config.ps1 could not be read -- judging against the default reach label '$label'.")
}

$calls = @(Get-ReachLabelInvocation -Command $command -ReachLabel $label)
if ($calls.Count -eq 0) { exit 0 }

$deadline = [DateTime]::UtcNow.AddSeconds(25)
$currentRepo = $null
$refused = @()
$unchecked = @()
foreach ($c in $calls) {
    $nwo = [string]$c.Repo
    if (-not $nwo) {
        if ($null -eq $currentRepo) {
            $currentRepo = ''
            $leftMs = [int]($deadline - [DateTime]::UtcNow).TotalMilliseconds
            if ($leftMs -gt 1000) {
                $run = Invoke-AsanaGhBounded -Arguments 'repo view --json nameWithOwner -q .nameWithOwner' -TimeoutMs ([Math]::Min(8000, $leftMs)) -WorkingDirectory $projectDir
                if ($run.Started -and -not $run.TimedOut -and $run.ExitCode -eq 0) { $currentRepo = ([string]$run.Out).Trim() }
            }
        }
        $nwo = $currentRepo
    }
    $what = if ($c.Kind -eq 'create') { 'the new issue' } else { (@($c.Numbers) | ForEach-Object { "#$_" }) -join ', ' }
    if ($nwo -notmatch '\A([A-Za-z0-9][A-Za-z0-9-]*)/([A-Za-z0-9._-]+)\z') { $unchecked += "$what (repo unknown)"; continue }
    $owner = $Matches[1]
    $name = $Matches[2]
    if ($script:AsanaMirrorAdmittedRepos -notcontains $name.ToLowerInvariant()) { continue }
    if ($c.Kind -eq 'create') { $what = "a new issue on $nwo" } else { $what = (@($c.Numbers) | ForEach-Object { "$nwo#$_" }) -join ', ' }

    switch ($c.BodySource) {
        'inline' {
            if (Test-ReachReasonSection -Body $c.Body -ReachLabel $label) { break }
            if ($c.BodyDynamic) { $unchecked += "$what (body built at run time)" } else { $refused += $what }
        }
        'elsewhere' { $unchecked += "$what (body from a template, the browser or an editor)" }
        'file' {
            $path = if ([System.IO.Path]::IsPathRooted($c.BodyFile)) { $c.BodyFile } else { Join-Path $projectDir $c.BodyFile }
            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { $unchecked += "$what (body file not found)"; break }
            if (-not (Test-ReachReasonSection -Body ([System.IO.File]::ReadAllText($path)) -ReachLabel $label)) { $refused += $what }
        }
        'stdin' { $unchecked += "$what (body on stdin)" }
        default {
            if ($c.Kind -eq 'create') { $refused += $what; break }
            foreach ($n in @($c.Numbers)) {
                $ref = "$nwo#$n"
                $leftMs = [int]($deadline - [DateTime]::UtcNow).TotalMilliseconds
                if ($leftMs -le 1000) { $unchecked += $ref; continue }
                $state = Read-AsanaIssueBlockState -Owner $owner -Repo $name -Number $n -TimeoutMs ([Math]::Min(20000, $leftMs)) -WorkingDirectory $projectDir
                if (-not $state.Ok) { $unchecked += $ref; continue }
                if (-not (Test-ReachReasonSection -Body ([string]$state.Body) -ReachLabel $label)) { $refused += $ref }
            }
        }
    }
}

if ($unchecked.Count -gt 0) {
    [Console]::Error.WriteLine("guard-reach-reason: could not read the body of $($unchecked -join ', ') -- the reason check did NOT judge it. Confirm by hand that the body carries a '## Why $label' section saying who notices the defect.")
}
if ($refused.Count -eq 0) { exit 0 }

[Console]::Error.WriteLine("BLOCKED (guard-reach-reason): $($refused -join ', ') would carry the reach label '$label' with no '## Why $label' section in its body.")
[Console]::Error.WriteLine(@(
    "  The label puts an issue on the colleague-facing board and the management worklist, so it is given",
    '  only with its reason written into the issue (report-issue step 1, #4057). Add, in the body:',
    '',
    "    ## Why $label",
    '    <who notices it -- management, the commissioner, or a customer they answer for -- and what they',
    '    notice; one or two sentences>',
    '',
    "  On an existing issue, write the section in the same move as the label (gh issue edit <n> --body",
    "  <body with the section> --add-label '$label'). 'Visible on the storefront' alone does not answer it:",
    '  the test is whether that reader notices the DEFECT. If you cannot say who, leave the label off.'
) -join "`n")
exit 2
