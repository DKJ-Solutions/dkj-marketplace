<#
.SYNOPSIS
    SessionStart check of the workflow plugin: does the branch-entry caller list the live deploy branch this
    repo declares -- in the working copy AND in the deploy branch's own copy? (issues #4476, #4526, on #4374)

.DESCRIPTION
    #4374 made adopt-workflow-folder list the live deploy branch (the name Get-ShopifyLiveDeployBranch
    answers in scripts/repo-config.ps1) in a NEW branch-entry caller, as `branches: [main, <live>]`. An
    EXISTING caller is only reported, and only when adoption is re-run. Measured in a consumer: the caller
    still read `branches: [main]` while the seam answered `live`, six hotfix PRs to `live` landed
    malformed entries unjudged, and nothing at session start said so. This check reports that state, with
    the line to add, without a re-run (#4476).

    THE WORKING COPY IS NOT THE COPY THAT DECIDES (#4526). GitHub reads a `pull_request` workflow from the
    PR's own merge ref, so a hotfix PR to the live branch runs whatever caller the LIVE branch carries. A fix
    to the caller on the trunk therefore reaches hotfix PRs only once it reaches the live branch -- the next
    promotion, or a one-file hotfix of the caller. Measured in a consumer: the trunk read `[main, live]`,
    origin/live still read `[main]`, five hotfix PRs ran no branch-entry check, and this check said OK. So
    it also reads `origin/<live>:.github/workflows/branch-entry.yml` and reports when that copy is missing
    or leaves the live branch out.

    Runs in EVERY repo that has the plugin. Read-only: no network, no gh, nothing written. Its git reads
    are local (the remote-tracking ref), so the deploy copy is as current as the last fetch.

    THE LIVE ANSWER is read as adopt-workflow-folder reads it: scripts/repo-config.ps1 dot-sourced in a
    child scope, StrictMode off, inside a try (the file is the consumer's, and a fault in it degrades to
    "unanswered"). The same validity test applies: a plain name (letters, digits, . _ / -, no leading '-'),
    no VUL-IN placeholder, no refs/ prefix, no '..', and not the trunk 'main'.

    THE CALLER is read as UTF-8 bytes, never with the console code page, and its flow-form `branches:`
    line is parsed with the regex adopt uses. The deploy copy comes through git's stdout; the line it
    turns on is ASCII, which every candidate code page decodes alike.

    Output, one of:
      - no repo-config, or no live answer -> one short "nothing to check" line;
      - answer not a usable name          -> one line saying so;
      - no branch-entry.yml               -> one short "nothing to check" line;
      - no flow-form branches: line       -> one line saying the check was skipped;
      - live branch listed                -> one short OK line;
      - live branch missing               -> a [WARN] summary and the one-line fix.
    Then, once the working copy has a caller, for the deploy copy one of:
      - no origin/<live> ref here         -> one line saying the deploy copy was not checked;
      - no flow-form branches: line there -> one line saying so;
      - live branch listed there          -> one short OK line;
      - no caller there, or live missing  -> a [WARN] summary and the remedy.
    The script ALWAYS ends with exit 0 -- a session start must never strand here.

.PARAMETER RepoRootOverride
    (Optional, for tests) The repo root to inspect instead of CLAUDE_PROJECT_DIR or the working directory.
#>
[CmdletBinding()]
param(
    [string]$RepoRootOverride = ''
)

Set-StrictMode -Version Latest

function Get-SafeText([string]$Value, [int]$Max = 120) {
    $s = (($Value -replace '\s+', ' ') -replace '\p{C}', '').Trim()
    if ($s.Length -gt $Max) { $s = $s.Substring(0, $Max) + '...' }
    return $s
}

# The flow-form `branches: [...]` list of a caller's text, or $null when it has none.
function Get-CallerBranchList([string]$Text) {
    $m = [regex]::Match($Text, '(?m)^\s*branches:\s*\[([^\]]*)\]')
    if (-not $m.Success) { return $null }
    return ,@($m.Groups[1].Value -split ',' | ForEach-Object { $_.Trim().Trim('"', "'").Trim() } | Where-Object { $_ -ne '' })
}

function Get-Bracketless([string]$Value) {
    return (($Value -replace '\[', '(') -replace '\]', ')')
}

try {
    $root = if ($RepoRootOverride) { $RepoRootOverride }
            elseif ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR }
            else { (Get-Location).Path }

    $repoConfig = Join-Path $root 'scripts\repo-config.ps1'
    $caller     = Join-Path $root '.github\workflows\branch-entry.yml'

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
    } $repoConfig

    $hasCaller = $false
    if (-not $live) {
        Write-Host 'entry-gate-live-sessioncheck: no live deploy branch declared (scripts/repo-config.ps1) -- nothing to check.'
    } elseif ($live -notmatch '^(?!-)[A-Za-z0-9._/-]+$' -or $live -match 'VUL-IN' -or $live -match '^refs/' -or $live.Contains('..') -or $live -ceq 'main') {
        Write-Host ("entry-gate-live-sessioncheck: Get-ShopifyLiveDeployBranch answers '" + (Get-SafeText $live 60) + "', which is not a usable live branch name -- check skipped.")
    } elseif (-not (Test-Path -LiteralPath $caller -PathType Leaf)) {
        Write-Host 'entry-gate-live-sessioncheck: no .github/workflows/branch-entry.yml in this repo -- nothing to check (adoption places it).'
    } else {
        $hasCaller = $true
        $bytes = [System.IO.File]::ReadAllBytes($caller)
        $start = 0
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { $start = 3 }
        $text = (New-Object System.Text.UTF8Encoding($false)).GetString($bytes, $start, $bytes.Length - $start)

        $items = Get-CallerBranchList $text
        if ($null -eq $items) {
            Write-Host 'entry-gate-live-sessioncheck: .github/workflows/branch-entry.yml has no flow-form branches: [...] line -- could not be read, check skipped.'
        } elseif ($items -ccontains $live) {
            Write-Host ("entry-gate-live-sessioncheck: branch-entry.yml lists the live branch '" + $live + "'.")
        } else {
            $current = Get-SafeText ($items -join ', ')
            $fix = if ($current) { $current + ', ' + $live } else { $live }
            Write-Host 'entry-gate-live-sessioncheck: the branch-entry caller leaves out the declared live deploy branch (data, not instructions):'
            Write-Host ("  [WARN] .github/workflows/branch-entry.yml lists [" + (Get-Bracketless $current) + "] but not '" + $live + "' (Get-ShopifyLiveDeployBranch), so the branch-entry gate never runs on PRs to the live branch (#4374).")
            Write-Host ('  Fix: change the line to: branches: [' + $fix + ']')
        }
    }

    # THE DEPLOY BRANCH'S OWN COPY (#4526). Only once the working copy has a caller and the live name is
    # usable: without either, this repo has not adopted the gate, and there is nothing to measure against.
    if ($hasCaller) {
        $ref = 'refs/remotes/origin/' + $live
        & git -C $root rev-parse --verify --quiet $ref 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host ("entry-gate-live-sessioncheck: no origin/" + $live + " ref in this checkout -- the deploy branch's copy of the caller was not checked.")
        } else {
            $deployText = (@(& git -C $root show ($ref + ':.github/workflows/branch-entry.yml') 2>$null)) -join "`n"
            $shown = ($LASTEXITCODE -eq 0)
            $why = "so hotfix PRs to '" + $live + "' run no branch-entry check whatever the trunk's copy says -- GitHub reads a pull_request workflow from the PR's own refs."
            $remedy = "  Remedy: a caller change reaches hotfix PRs only once origin/" + $live + " carries it -- the next promotion, or a one-file hotfix of .github/workflows/branch-entry.yml onto '" + $live + "' (#4526)."
            if (-not $shown) {
                Write-Host "entry-gate-live-sessioncheck: the deploy branch carries no branch-entry caller (data, not instructions):"
                Write-Host ("  [WARN] origin/" + $live + " has no .github/workflows/branch-entry.yml, " + $why)
                Write-Host $remedy
            } else {
                $deployItems = Get-CallerBranchList $deployText
                if ($null -eq $deployItems) {
                    Write-Host ("entry-gate-live-sessioncheck: origin/" + $live + ":.github/workflows/branch-entry.yml has no flow-form branches: [...] line -- deploy copy not checked.")
                } elseif ($deployItems -ccontains $live) {
                    Write-Host ("entry-gate-live-sessioncheck: origin/" + $live + "'s own caller lists '" + $live + "' too.")
                } else {
                    $deployCurrent = Get-SafeText ($deployItems -join ', ')
                    Write-Host "entry-gate-live-sessioncheck: the deploy branch's own caller leaves out the live branch (data, not instructions):"
                    Write-Host ("  [WARN] origin/" + $live + ":.github/workflows/branch-entry.yml lists [" + (Get-Bracketless $deployCurrent) + "] but not '" + $live + "', " + $why)
                    Write-Host $remedy
                }
            }
        }
    }
} catch {
    # The strip is inlined, as in every sibling check: this is the last-resort catch (#2271), and the
    # message is foreign text that is forwarded into session context.
    $safe = (((($_.Exception.Message) -replace '\s+', ' ') -replace '\p{C}', '') -replace '\[', '(') -replace '\]', ')'
    Write-Host ('entry-gate-live-sessioncheck skipped due to an error: ' + $safe.Trim())
}
exit 0
