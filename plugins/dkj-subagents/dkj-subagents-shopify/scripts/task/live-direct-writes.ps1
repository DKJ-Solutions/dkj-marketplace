<#
.SYNOPSIS
    Flag direct FILE writes to the live theme -- a CLI theme push or an admin code-editor save -- that
    reached the live deploy branch outside the promotion and the hotfix lane, and open one issue for them.

.DESCRIPTION
    WHY THIS EXISTS. Every control on the live theme is session-side (the CLI live guard, a guard hook on
    the trunk) or git-side (a deploy-branch ruleset). A `shopify theme push --allow-live` from a shell that
    never loaded this repo's harness -- an agent session started in the home directory, a plain terminal --
    reaches live with nothing in the way, and the only trace is the commit Shopify's GitHub integration
    writes onto the deploy branch afterwards. The owner of the store this was built for chose to read that
    trace on a schedule and turn it into an issue, instead of restricting staff permissions. Moved here
    from that store's repo (#4289), beside live-preflight.

    WHO RUNS IT. A scheduled GitHub workflow, .github/workflows/live-direct-writes.yml, that
    adopt-shopify-floor places in a store whose live theme is Git-connected (Get-ShopifyLiveDeployBranch is
    answered). A store whose live theme is pushed with the CLI has no deploy branch for the bot to write to,
    so there is nothing to read and no workflow. The workflow checks this script out of the plugin's source
    repo at the release it was placed from, and the history of the deploy branch out of the store's repo.
    You can also run it by hand against a clone: see the examples.

    THE SIGNAL is in the header of rules lib (scripts/lib/live-direct-writes-rules.ps1): a shopify[bot]
    commit whose body carries a 'Changed by:' line is a direct write; one that carries 'Theme last edited
    by:' is the sanctioned theme-editor route and never is.

    THE FLOOR. -Since says where the history starts that this run may report. Left out there is no floor:
    every bot commit on the ref counts, which on a store with a long history is one very large first issue.
    The workflow adopt-shopify-floor places carries the time it was placed as -Since, so a store starts from
    now; a store that wants older commits reported edits that one value in its workflow file.

    DEDUPE. Every reported commit leaves a marker `<!-- live-direct-write:<sha> -->` in the issue it was
    reported in. A run reads the markers of every issue carrying the label (open and closed) that the CI
    account wrote, and reports only commits no marker names yet, so a re-run is quiet and closing the issue
    does not re-open it.

    THE ONE WRITE. One `gh issue create` per run that found something new (plus `gh label create` once,
    when the label does not exist yet). It never writes to git, to Shopify, or to an existing issue.

    Needs git and an authenticated gh (GH_TOKEN, as the workflow sets it). It needs no seam: the store's
    facts reach it as parameters.

    Pure ASCII (repo convention for .ps1): Windows PowerShell 5.1 reads a BOM-less script as ANSI. It also
    runs under pwsh on ubuntu, which is where the workflow runs it.

.PARAMETER Ref
    The ref whose history is read. Default HEAD, so run it from a checkout of the deploy branch, or name
    the branch (for example origin/live).

.PARAMETER Since
    The floor: a UTC date (2026-11-18) or a UTC date and time (2026-11-18T00:00:00Z). Commits before it
    are not reported. Default: none.

.PARAMETER Repo
    owner/name, where the issues are read and opened. Default: GITHUB_REPOSITORY, which Actions sets.

.PARAMETER RepoPath
    The clone whose history is read. Default: the current directory.

.PARAMETER DryRun
    Read everything, open nothing: prints the issue it would open.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/live-direct-writes.ps1 -Repo owner/store -Ref origin/live -Since 2026-11-01 -DryRun
#>
[CmdletBinding()]
param(
    [string]$Ref = 'HEAD',
    [string]$Since = '',
    [string]$Repo = $env:GITHUB_REPOSITORY,
    [string]$RepoPath = '.',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\command-probe-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\check-report-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\native-capture-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\sync-rules.ps1')
. (Join-Path $PSScriptRoot '..\lib\live-direct-writes-rules.ps1')

function Invoke-GhChecked {
    # One gh call, judged: it must have started, finished in time and exited 0, else the run stops. Guessing
    # 'nothing reported' from a failed read would re-report every commit since the floor.
    param([string[]]$GhArgs, [string]$What)
    $r = Invoke-NativeCapture -FilePath 'gh' -Arguments $GhArgs -DiscardStderr -TimeoutSeconds $script:NativeCaptureNetworkTimeoutSeconds
    if (-not (Test-NativeCommandStarted $r)) { throw "gh is not available, so $What could not run." }
    if ($r.TimedOut) { throw "$What timed out." }
    if ($r.ShortRead) { throw "$What was read short." }
    if (-not (Test-NativeExitMeasured -Capture $r) -or $r.ExitCode -ne 0) { throw "$What failed ($(Get-NativeExitLabel -Capture $r))." }
    return (@($r.Output) -join "`n")
}

try {
    if (-not (Test-DirectWriteRef $Ref)) { throw "-Ref '$Ref' is not a plain revision." }
    if ($Since -and -not (Test-DirectWriteSince $Since)) { throw "-Since '$Since' is not a UTC date (2026-11-18) or date and time (2026-11-18T00:00:00Z)." }
    if (-not $Repo) { throw 'No repository: pass -Repo owner/name or set GITHUB_REPOSITORY.' }
    if (-not (Test-DirectWriteRepo $Repo)) { throw "-Repo '$Repo' is not owner/name." }
    $label = Get-DirectWriteLabel

    $logArgs = @('-C', $RepoPath, 'log', $Ref)
    if ($Since) { $logArgs += "--since=$Since" }
    # The author filter is a regex: the brackets of the bot's name are escaped.
    $logArgs += @("--author=$([regex]::Escape((Get-DirectWriteBotAuthor)))", '--format=%H%x1f%an%x1f%aI%x1f%s%x1f%b%x1e')
    $raw = (@(Invoke-SyncGitQuiet @logArgs)) -join "`n"
    if ($LASTEXITCODE -ne 0) { throw "git log $Ref failed (exit $LASTEXITCODE)." }
    $commits = ConvertFrom-DirectWriteGitLog -Raw $raw

    # A label that does not exist yet means nothing was ever reported.
    $labels = Invoke-GhChecked -GhArgs @('label', 'list', '--repo', $Repo, '--limit', '500', '--json', 'name') -What 'gh label list'
    $labelExists = $false
    if ($labels.Trim()) { $labelExists = @(($labels | ConvertFrom-Json) | Where-Object { $_.name -eq $label }).Count -gt 0 }
    $issuesJson = '[]'
    if ($labelExists) {
        $issuesJson = Invoke-GhChecked -GhArgs @('issue', 'list', '--repo', $Repo, '--label', $label, '--state', 'all', '--limit', '1000', '--json', 'number,body,author') -What 'gh issue list'
        if (-not $issuesJson.Trim()) { $issuesJson = '[]' }
    }
    # Only markers this workflow wrote count, so a hand-written marker cannot silence a report.
    $authors = Get-DirectWriteIssueAuthors
    $bodies = @(($issuesJson | ConvertFrom-Json) | Where-Object { $_.author.login -in $authors } | ForEach-Object { $_.body })
    $reported = @(Get-ReportedShas -Bodies $bodies)

    $hits = @(Select-DirectWrites -Commits $commits -Reported $reported)
    $floor = if ($Since) { $Since } else { 'the start of the history' }
    Write-Host "Scanned $(@($commits).Count) shopify[bot] commit(s) on $Ref since $floor; $($reported.Count) already reported; $($hits.Count) new direct write(s)."
    if ($hits.Count -eq 0) { exit 0 }

    $text = New-DirectWriteIssueText -Hits $hits -Repo $Repo
    if ($DryRun) {
        Write-Host "[dry-run] would open: $($text.Title)"
        Write-Host $text.Body
        exit 0
    }

    if (-not $labelExists) {
        $null = Invoke-GhChecked -GhArgs @('label', 'create', $label, '--repo', $Repo, '--color', 'B60205', '--description', 'A file write reached the live theme outside the branch flow') -What 'gh label create'
    }
    # The body travels in a file, never on a command line.
    $bodyFile = [System.IO.Path]::GetTempFileName()
    try {
        [System.IO.File]::WriteAllText($bodyFile, $text.Body, (New-Object System.Text.UTF8Encoding($false)))
        $created = Invoke-GhChecked -GhArgs @('issue', 'create', '--repo', $Repo, '--title', $text.Title, '--label', $label, '--body-file', $bodyFile) -What 'gh issue create'
        Write-Host $created
        Write-Host "::warning::Direct write(s) to the live theme reported: $($text.Title)"
    } finally {
        Remove-Item -LiteralPath $bodyFile -ErrorAction SilentlyContinue
    }
    exit 0
} catch {
    Write-Host "FAILED: $(Format-SafeProseToken -Value $_.Exception.Message)" -ForegroundColor Red
    exit 1
}
