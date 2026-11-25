<#
.SYNOPSIS
    PreToolUse hook on the shell tools: refuses a 'gh issue create' on a store repo whose body names a
    requester or quotes a task but links no Asana task and does not state that none exists (#4477).

.DESCRIPTION
    THE RULE IS report-issue's STEP 1 (#4477): a request a colleague filed in Asana and passed on in chat
    is filed as the issue for THAT task, so the board is searched for it before the create, and the task
    is linked in the body. Measured in smartwatchbanden#1567: the body named the requester and quoted the
    task, the task was the first hit of one Asana search, and the issue was filed with no link -- so the
    card never moved, got no 'created:' comment, and the requester would have heard nothing at the close.
    asana-link-pickupcheck (#2919, #2928) only warns, after the work has started. The signal and the
    verdict are in scripts/lib/asana-origin-rules.ps1; this file reads the payload, finds the body, and
    answers.

    THE WAY THROUGH is the task's link in the body ('<!-- asana-task: <gid> -->', a '| **Asana** |' row or
    the task URL), or the line '<!-- no-asana-task -->' where the search found none.

    IT FAILS OPEN, with a warning, the direction guard-reach-reason and guard-kind-label chose: a body it
    cannot read (on stdin, built at run time, a body file that is not there, a template, the browser or an
    editor) or a repo it cannot name passes with a line on stderr -- but only where the literal text it
    could see names a requester or a task, or there is no text to see. A missed link is repaired by hand
    and caught again at pickup; a guard that stops every issue create while the tracker is unreachable is
    not cheap.

    WHAT IT PRINTS is its own text and refs built from GitHub's owner/name character classes -- never a
    title or a body, and never the words that matched.

    Exit codes (PreToolUse contract): 2 = block and send stderr to Claude; 0 = allow.

    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/guard-asana-origin.tests.ps1 in the
    source repo -- change one, run the other.
#>
$ErrorActionPreference = 'Stop'

# READ STDIN ONLY WHERE THERE IS A HANDLE, the guard every hook in this tree carries (#2264).
$raw = ''
if ([Console]::IsInputRedirected) { $raw = [Console]::In.ReadToEnd() }

# THE CHEAP PRE-GATE, the same test hooks.json makes in shell first.
if ($raw -notmatch 'gh(\.exe)?\s+issue\s+create') { exit 0 }

$libPath = Join-Path $PSScriptRoot '..\scripts\lib\asana-origin-rules.ps1'
if (-not (Test-Path -LiteralPath $libPath -PathType Leaf)) {
    [Console]::Error.WriteLine('guard-asana-origin: asana-origin-rules.ps1 not found beside this hook -- the Asana-origin check is OFF for this call. Reinstall or update the dkj-repo-workflow-bwj plugin.')
    exit 0
}
. $libPath

trap {
    [Console]::Error.WriteLine('guard-asana-origin: an unexpected error stopped the check -- it did NOT judge this call. If the request came from a colleague, confirm by hand that the issue links their Asana task.')
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
    # Which body this call leaves, as text, or $null where it cannot be read.
    $body = $null
    $why = ''
    switch ($c.BodySource) {
        'inline' { $body = [string]$c.Body; if ($c.BodyDynamic) { $why = 'body built at run time' } }
        'file' {
            $path = if ([System.IO.Path]::IsPathRooted($c.BodyFile)) { $c.BodyFile } else { Join-Path $projectDir $c.BodyFile }
            if (Test-Path -LiteralPath $path -PathType Leaf) { $body = [System.IO.File]::ReadAllText($path) } else { $why = 'body file not found' }
        }
        'stdin' { $why = 'body on stdin' }
        'elsewhere' { $why = 'body from a template, the browser or an editor' }
        default { $body = '' }
    }
    # Nothing in the text we can see names a colleague: not this guard's business, and no warning either.
    $verdict = if ($null -ne $body) { Get-AsanaOriginVerdict -Body $body } else { $null }
    if ($null -ne $verdict -and $verdict.Verdict -eq 'pass') { continue }

    $nwo = [string]$c.Repo
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
    if ($script:AsanaOriginRepos -notcontains $Matches[1].ToLowerInvariant()) { continue }

    if ($null -eq $verdict) { $unchecked += "a new issue on $nwo ($why)"; continue }
    if ($why) { $unchecked += "a new issue on $nwo ($why)"; continue }
    $refused += "a new issue on $nwo $(@($verdict.Signals) -join ' and ')"
}

if ($unchecked.Count -gt 0) {
    [Console]::Error.WriteLine("guard-asana-origin: could not read the body of $($unchecked -join ', ') -- the Asana-origin check did NOT judge it. If the request came from a colleague, confirm by hand that the issue links their Asana task.")
}
if ($refused.Count -eq 0) { exit 0 }

[Console]::Error.WriteLine("BLOCKED (guard-asana-origin): $($refused -join '; '), but links no Asana task.")
[Console]::Error.WriteLine(@(
    '  A request a colleague filed in Asana is filed as the issue for THAT task (report-issue step 1, #4477).',
    '  Search the board for it first (Asana search_tasks on a phrase from the request), then put in the body:',
    '',
    '    Asana: <task URL>',
    '    <!-- asana-task: <numeric task GID> -->',
    '',
    "  and take report-issue's 'On a ticket that came the other way': the reach label on this create, the",
    "  card moved to Filed, the link on top of the task and the created: comment.",
    '  Searched, and no task exists? Say so in the body with the line',
    '',
    '    <!-- no-asana-task -->',
    '',
    '  and create again.'
) -join "`n")
exit 2
