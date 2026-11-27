<#
.SYNOPSIS
    PreToolUse hook on the shell tools: refuses `gh pr create --base <live>` while the head branch's
    changelog entry is not written, judged by the same check-branch-entry.ps1 the CI gate runs (#4532).

.DESCRIPTION
    THE GAP. A hotfix PR to the declared live deploy branch (Get-ShopifyLiveDeployBranch in
    scripts/repo-config.ps1) is opened by hand: open-pr.ps1 and ship-pr.ps1 open PRs to the trunk only.
    So the only branch-entry check such a PR met was the `pull_request` workflow the LIVE branch itself
    carries -- and a live branch whose copy of that caller lags the trunk's judged nothing. Measured in a
    consumer (#4526, November 27, 2026): five hotfix PRs ran no branch-entry check, a DEPLOY section with
    `**Score:** N/A` under the tier-0 heading landed unjudged, and the fold stranded once the back-flow
    reached the trunk. entry-gate-live-sessioncheck reports the lagging copy; it does not stop the PR.

    WHY A HOOK AND NOT A -Base ROUTE IN open-pr. The leak is the hand-typed `gh pr create`. A route in the
    ship scripts only helps a session that chooses to use it; a PreToolUse hook meets the command that
    actually opens the PR, and it needs no workflow file to be current.

    WHAT IT JUDGES. A segment of the command that RUNS `gh pr create` (command-guard-lib's segment
    pipeline, so a heredoc, a here-string or a grep that mentions it is not a run) with a base of
    `--base X`, `--base=X` or `-B X` equal to the declared live branch, case-sensitively as git compares
    branch names. The head is `--head`/`-H` (an `owner:` prefix dropped), else the checkout's current
    branch. It then runs check-branch-entry.ps1 -Branch <head> -- THE REPO'S OWN COPY where one exists
    (the source repo, whose released copy refuses itself there), otherwise the copy in this plugin -- and
    refuses (exit 2) on its exit 1, printing its findings. It adds no rule of its own: "written" has one
    definition, and it is that script's.

    SILENT where nothing applies: no `gh pr create`, no --base (gh then targets the default branch), a base
    that is not the live branch, or a repo that declares no usable live branch (the validity test
    entry-gate-live-sessioncheck applies: a plain name, no VUL-IN, no refs/, no '..', not 'main').

    IT FAILS OPEN, AND SAYS SO TO THE SESSION. A base it cannot read (a variable, a subshell), a head it
    cannot resolve, a missing check script, a check that timed out or crashed: the PR goes through with a
    PreToolUse additionalContext naming what was not checked and the command that checks it by hand. The
    CI caller is still the backstop where the live branch carries a current one, and a wrong refusal here
    would block every hotfix in every consumer. PowerShell failing to start is the same case, so
    hooks.json carries no fail-closed wrapper -- the same choice guard-stale-paste-block made.

    AN ACCIDENT GUARD, NOT AN ADVERSARIAL ONE: an alias, `gh api` POSTing a pull request, or a PR opened
    in the GitHub UI are not seen, the residuals every command guard in this tree states.

    WHAT IT PRINTS is its own text, the live branch name after the validity test, the head name after a
    branch-name test, and check-branch-entry's own output -- a script of this plugin.

    Exit codes (PreToolUse contract): 2 = block and send stderr to Claude; 0 = allow, with JSON on stdout
    whenever something was not checked.

    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/guard-live-pr-entry.tests.ps1 in the
    source repo -- change one, run the other.
#>
[CmdletBinding()]
param(
    # A fixture root, for the test suite. In a session the root is CLAUDE_PROJECT_DIR.
    [string]$RepoRootOverride = ''
)
$ErrorActionPreference = 'Stop'

# READ STDIN ONLY WHERE THERE IS A HANDLE, the guard every hook in this tree carries (#2264).
$raw = ''
if ([Console]::IsInputRedirected) { $raw = [Console]::In.ReadToEnd() }

# THE CHEAP PRE-GATE: no `pr create` named, nothing to judge and no lib load spent. hooks.json makes the
# same test in shell first; this repeats it for a run that reaches the file another way.
if ($raw -notmatch '(?i)gh(\.exe)?["'']?\s+pr\s+create') { exit 0 }

$script:notChecked = New-Object System.Collections.Generic.List[string]
function Add-NotChecked([string]$Message) {
    [Console]::Error.WriteLine($Message)
    $script:notChecked.Add($Message)
}
function Exit-Allow {
    <# exit 0; where something was not checked the allow says so to the session (#3058's lesson:
       stderr from an exit-0 hook reaches nobody). #>
    if ($script:notChecked.Count -gt 0) {
        $out = @{ hookEventName = 'PreToolUse'; additionalContext = ($script:notChecked -join "`n") }
        [Console]::Out.WriteLine((@{ hookSpecificOutput = $out } | ConvertTo-Json -Compress))
    }
    exit 0
}

function Get-SafeText([string]$Value, [int]$Max = 80) {
    $s = (($Value -replace '\s+', ' ') -replace '\p{C}', '').Trim()
    if ($s.Length -gt $Max) { $s = $s.Substring(0, $Max) + '...' }
    return $s
}

$libPath = Join-Path $PSScriptRoot '..\scripts\lib\command-guard-lib.ps1'
if (-not (Test-Path -LiteralPath $libPath -PathType Leaf)) {
    Add-NotChecked 'guard-live-pr-entry: command-guard-lib.ps1 not found beside this hook -- a PR to the live branch was NOT checked for a written changelog entry. Reinstall or update the dkj-repo-workflow plugin.'
    Exit-Allow
}
. $libPath

# ANY UNEXPECTED THROW FROM HERE ON IS THE DELIBERATE FAIL-OPEN, NOT A CRASH.
trap {
    Add-NotChecked 'guard-live-pr-entry: an unexpected error stopped the check -- the changelog entry of this PR to the live branch was NOT checked. Run the check-branch-entry skill on the head branch before the PR is opened.'
    Exit-Allow
}

function Get-GhPrCreateInvocations {
    <# Every segment that RUNS `gh pr create`, as @{ Base; Head; HasBase }. Base/Head are the raw values
       (quotes removed), '' where absent. #>
    param([string]$Command)

    $textTools = @(
        'grep', 'egrep', 'fgrep', 'rg', 'sed', 'awk', 'cat', 'echo', 'printf', 'head', 'tail', 'less', 'more',
        'jq', 'findstr', 'tee', 'diff', 'wc', 'sort', 'uniq', 'tr', 'cut', 'out-file', 'set-content',
        'add-content', 'get-content', 'select-string', 'tee-object', 'write-output', 'write-host', 'out-string'
    )
    $found = New-Object System.Collections.Generic.List[object]
    foreach ($segment in @(Get-GuardSegments -Command $Command -TextTools $textTools -QuoteAware)) {
        $s = ([string]$segment).Trim()
        while ($s -match '^\(?\{?\s*[A-Za-z_][A-Za-z0-9_]*=[^\s]*\s+(.*)$') { $s = $Matches[1].Trim() }
        $s = ($s -replace '^[\(\{\s]+', '') -replace '^&\s+', ''
        $tokens = @([regex]::Matches($s, '"[^"]*"|''[^'']*''|\S+') | ForEach-Object {
            $t = $_.Value
            if ($t.Length -ge 2 -and ($t[0] -eq '"' -or $t[0] -eq "'") -and $t[$t.Length - 1] -eq $t[0]) { $t = $t.Substring(1, $t.Length - 2) }
            $t
        })
        if ($tokens.Count -lt 3) { continue }
        $lead = ($tokens[0] -replace '.*[\\/]', '').ToLower()
        if ($lead -ne 'gh' -and $lead -ne 'gh.exe') { continue }
        if ($tokens[1].ToLower() -ne 'pr' -or $tokens[2].ToLower() -ne 'create') { continue }

        $inv = @{ Base = ''; Head = ''; HasBase = $false }
        for ($i = 3; $i -lt $tokens.Count; $i++) {
            $t = $tokens[$i]
            $next = if ($i + 1 -lt $tokens.Count) { $tokens[$i + 1] } else { '' }
            if ($t -ceq '--base' -or $t -ceq '-B') { $inv.Base = $next; $inv.HasBase = $true; $i++ }
            elseif ($t -cmatch '^--base=(.*)$') { $inv.Base = $Matches[1]; $inv.HasBase = $true }
            elseif ($t -cmatch '^-B(.+)$') { $inv.Base = $Matches[1]; $inv.HasBase = $true }
            elseif ($t -ceq '--head' -or $t -ceq '-H') { $inv.Head = $next; $i++ }
            elseif ($t -cmatch '^--head=(.*)$') { $inv.Head = $Matches[1] }
            elseif ($t -cmatch '^-H(.+)$') { $inv.Head = $Matches[1] }
        }
        $found.Add($inv)
    }
    return $found.ToArray()
}

# A BYTE-ORDER MARK IS NOT PART OF THE PAYLOAD. A writer whose console input code page is UTF-8 prefixes
# one, ConvertFrom-Json then fails, and the fallback judges the raw JSON text -- whose first token is no
# `gh`, so the guard went silent. Measured in this hook's own suite (the guard-stale-paste-block case):
# whatever precedes the first '{' is dropped.
$jsonText = [string]$raw
$brace = $jsonText.IndexOf('{')
if ($brace -gt 0) { $jsonText = $jsonText.Substring($brace) }
$payload = Get-HookCommandPayload $jsonText
$invocations = @(Get-GhPrCreateInvocations -Command $payload.Command | Where-Object { $_.HasBase })
if ($invocations.Count -eq 0) { exit 0 }

$root = if ($RepoRootOverride) { $RepoRootOverride }
        elseif ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR }
        elseif ($payload.Cwd) { $payload.Cwd }
        else { (Get-Location).Path }

# THE LIVE ANSWER, read exactly as entry-gate-live-sessioncheck reads it: repo-config dot-sourced in a
# child scope, a throw or a missing function both meaning "unanswered".
$live = & {
    Set-StrictMode -Off
    $answer = ''
    if (Test-Path -LiteralPath $args[0] -PathType Leaf) {
        try {
            . $args[0]
            if (Get-Command -Name Get-ShopifyLiveDeployBranch -CommandType Function -ErrorAction SilentlyContinue) {
                $answer = ([string](Get-ShopifyLiveDeployBranch)).Trim()
            }
        } catch { $answer = '' }
    }
    return $answer
} (Join-Path $root 'scripts\repo-config.ps1')

$branchShape = '^(?!-)[A-Za-z0-9._/-]+$'
if (-not $live -or $live -notmatch $branchShape -or $live -match 'VUL-IN' -or $live -match '^refs/' -or $live.Contains('..') -or $live -ceq 'main') { exit 0 }

foreach ($inv in $invocations) {
    $base = [string]$inv.Base
    if ($base -notmatch $branchShape) {
        Add-NotChecked ("guard-live-pr-entry: could not read the --base of a 'gh pr create' (a variable or an expression) -- if it is the live branch '$live', its changelog entry was NOT checked. Run the check-branch-entry skill on the head branch first.")
        continue
    }
    if ($base -cne $live) { continue }

    $head = ([string]$inv.Head) -replace '^[^:]*:', ''
    if (-not $head) {
        try {
            $head = ([string](& git -C $root rev-parse --abbrev-ref HEAD 2>$null)).Trim()
            if ($LASTEXITCODE -ne 0) { $head = '' }
        } catch { $head = '' }
    }
    if (-not $head -or $head -eq 'HEAD' -or $head -notmatch $branchShape) {
        Add-NotChecked "guard-live-pr-entry: could not tell which branch this PR to the live branch '$live' comes from -- its changelog entry was NOT checked. Run the check-branch-entry skill on the head branch first."
        continue
    }

    # THE REPO'S OWN COPY FIRST: in the source repo the released copy refuses to run (Assert-OwnCopy).
    $check = Join-Path $root 'scripts\lint\check-branch-entry.ps1'
    if (-not (Test-Path -LiteralPath $check -PathType Leaf)) { $check = Join-Path $PSScriptRoot '..\scripts\lint\check-branch-entry.ps1' }
    if (-not (Test-Path -LiteralPath $check -PathType Leaf)) {
        Add-NotChecked "guard-live-pr-entry: check-branch-entry.ps1 not found -- the changelog entry of '$head' (PR to the live branch '$live') was NOT checked. Reinstall or update the dkj-repo-workflow plugin."
        continue
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'powershell.exe'
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$check`" -Branch `"$head`" -RootOverride `"$root`""
    $psi.WorkingDirectory = $root
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.RedirectStandardInput = $true
    $psi.CreateNoWindow = $true
    $proc = [System.Diagnostics.Process]::Start($psi)
    $proc.StandardInput.Close()
    $outTask = $proc.StandardOutput.ReadToEndAsync()
    $errTask = $proc.StandardError.ReadToEndAsync()
    if (-not $proc.WaitForExit(25000)) {
        try { $proc.Kill() } catch { }
        Add-NotChecked "guard-live-pr-entry: check-branch-entry did not answer within 25s -- the changelog entry of '$head' (PR to the live branch '$live') was NOT checked. Run the check-branch-entry skill on it by hand."
        continue
    }
    $proc.WaitForExit()
    $text = (([string]$outTask.Result) + ([string]$errTask.Result)).TrimEnd()

    if ($proc.ExitCode -eq 0) { continue }
    if ($proc.ExitCode -ne 1) {
        Add-NotChecked "guard-live-pr-entry: check-branch-entry exited $($proc.ExitCode) on '$head' -- a crash, not a verdict, so this PR to the live branch '$live' was NOT checked. Run the check-branch-entry skill on it by hand."
        continue
    }

    [Console]::Error.WriteLine("BLOCKED (guard-live-pr-entry): '$head' does not carry a written changelog entry, and this PR targets the live branch '$live' (Get-ShopifyLiveDeployBranch).")
    [Console]::Error.WriteLine(@(
        '  No plugin script opens a hotfix PR, so this is the one local check it meets; the live branch''s own CI',
        '  copy may lag the trunk''s and judge nothing (#4526, #4532). A malformed DEPLOY section that lands here',
        '  strands the fold once the back-flow reaches the trunk.',
        '',
        '  check-branch-entry said:'
    ) -join "`n")
    foreach ($line in ($text -split "`r?`n")) { [Console]::Error.WriteLine("    $line") }
    [Console]::Error.WriteLine('  TO FIX: write the DEPLOY section in the branch''s development document, commit and push it, then open the PR again.')
    exit 2
}

Exit-Allow
