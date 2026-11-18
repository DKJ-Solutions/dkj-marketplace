<#
.SYNOPSIS
    Early-warning Stop hook: run lint-brain.ps1 only when there are *.md changes since the last commit,
    and surface a count of every ERROR category it exits 1 on.

.DESCRIPTION
    One shared copy of what both BWJ store repos carried: one counted two of the error categories in one
    run, the other re-ran the lint a second time to count and only named dead links. This one counts
    every error category from a SINGLE run, by reading the summary line lint-brain prints.

    This is NOT the gate: the real enforcement is the PR gate (open-pr). This is a cheap, early signal
    DURING the work, so a finding is caught in the turn that made it rather than at the PR.

    How it works:
      1. Cheap check first: 'git status --porcelain' -- are there any *.md paths in there (changed,
         added or untracked since the last commit)? If not: silent, no output, exit 0. That is what stops
         a full repo scan running on every single turn.
      2. If there are: run the lint-brain.ps1 that sits NEXT TO THIS FILE, with -Quiet, over the repo
         root. It is found through $PSScriptRoot, not through the repo root: the lint is the plugin's,
         the repo is only what it scans.
      3. Exit code 1 -> print a Stop-hook JSON object with a short systemMessage carrying the count and
         the categories, e.g. '3 error(s) (A: 1, F: 2)'. 'continue' stays true: this NEVER blocks Claude
         finishing, it is informational.
      4. Fail-soft: everything sits in try/catch. An unexpected fault in this script itself (git not
         found, not a repository, lint-brain moved) is a silent exit 0 -- a hook that crashes is worse
         than no hook, because it turns every turn into noise and then gets switched off.

    A COUNT AND NOT THE FINDINGS: a hook that prints its whole report competes with the work for the
    reader's attention every turn. A count plus the command for the detail is read; a wall of paths is not.

.NOTES
    NOT registered in this plugin's hooks/hooks.json: a store that still registers its own copy in its
    .claude/settings.json would run it twice. A store registers this one (or the plugin registers it)
    once its own copy is gone.
    Pure ASCII (repo convention for .ps1).
#>

$ErrorActionPreference = "Stop"

try {
    . (Join-Path $PSScriptRoot '..\lib\repo-root-lib.ps1')
    $repoRoot = Resolve-BwjRepoRoot

    Push-Location -LiteralPath $repoRoot
    try {
        $statusLines = git status --porcelain 2>$null
        if (-not $statusLines) { exit 0 }

        $mdChanges = $statusLines | Where-Object { $_ -match '\.md("|\s|$)' }
        if (-not $mdChanges) { exit 0 }

        $lintScript = Join-Path $PSScriptRoot 'lint-brain.ps1'
        if (-not (Test-Path -LiteralPath $lintScript)) { exit 0 }

        # *>&1 captures ALL streams (including Write-Host, which normally writes straight to the console
        # outside the pipeline), so nothing from the lint's own reporting leaks into the session.
        $output = & $lintScript -Path $repoRoot -Quiet *>&1 | ForEach-Object { $_.ToString() }
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 1) {
            # The summary line: 'FAIL: <n> error(s) (A: 1, F: 2), <m> warning(s).' Warnings never reach
            # here (the hook does not pass -WarningsAsErrors), so exit 1 means errors.
            $count = ''
            $where = ''
            foreach ($line in $output) {
                if ($line -match '^(PASS|FAIL):\s*(\d+) error\(s\)(?:\s*\(([^)]*)\))?') {
                    $count = $Matches[2]
                    if ($Matches[3]) { $where = " ($($Matches[3]))" }
                }
            }
            $what = if ($count) { "$count error(s)$where" } else { 'errors' }
            $msg = "lint-brain early warning: $what in the documentation (dead link or anchor, mojibake, " +
                   "missing -ExecutionPolicy flag, stale version claim, tests/ table, or a paragraph pulled " +
                   "into a blockquote). Run lint-brain.ps1 for the detail -- the real gate is open-pr."
            $payload = [ordered]@{ systemMessage = $msg; continue = $true }
            Write-Output ($payload | ConvertTo-Json -Compress)
        }
        exit 0
    } finally {
        Pop-Location
    }
} catch {
    exit 0
}
