<#
.SYNOPSIS
    How many open issues did THIS gh account open in this repo -- so the person at the keyboard learns
    that sessions of theirs have been filing findings, and how to sweep exactly those (issue #4338).

.DESCRIPTION
    THE GAP THIS CLOSES. The filing rule makes a session file a finding as an issue and close out with
    a one-line receipt. Someone who does not know the workflow never notices that receipt, so the
    issues pile up unseen and another person ends up clearing them (measured November 19, 2026, in a
    shared consumer: 13 open issues opened by one account, unknown to its owner). The sweep can only
    help once the person knows there is something to sweep, and `claim-issue.ps1 -Candidates -Author
    @me` (#4337) lets that person sweep only their own.

    ONE NETWORK CALL. The login comes from the keyring (Get-ActiveGhAccount reads `gh auth status`),
    and the count from one `gh issue list --author @me --json number`. The repo is the checkout's own
    remote, which gh resolves from the working directory, so no repo name has to be configured.

    FAILS QUIET, ALWAYS, BECAUSE IT MUST NEVER BLOCK A SESSION START: gh absent, no active account, a
    list read that fails to start, times out or exits non-zero (offline, a rate limit, not a GitHub
    remote), or output that does not parse -- each prints one [SKIP] line and exits 0. Zero open
    issues prints one [OK] line. Only a count above zero prints [OPEN].

    THE LIST IS CAPPED AT -Limit (default 100); at the cap the count prints as '100+', never as a
    number it did not establish.

    The login is scrubbed to [A-Za-z0-9_-] before it is printed: it is foreign data, and this output
    is forwarded into session context.

    READ-ONLY: one `gh issue list`. Nothing is created, labelled, commented on or closed.

    RUN IT from the command line whenever you want the answer directly:

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/lint/check-open-issues.ps1

    Its one automatic caller is the SessionStart hook open-issues-sessioncheck.ps1 (workflow plugin).

    Pure ASCII, per this repo's script-layer convention.

.PARAMETER RootOverride
    Repo root to run gh in, for the test suite and the SessionStart hook. A consumer never types this.

.PARAMETER TimeoutSeconds
    (Optional) how long the `gh` call gets before this check gives up on it. Default 15.

.PARAMETER Limit
    (Optional) how many issues the list read asks for. Default 100.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/lint/check-open-issues.ps1
#>
[CmdletBinding()]
param(
    [string]$RootOverride = '',
    [int]$TimeoutSeconds = 15,
    [int]$Limit = 100
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\command-probe-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\repo-root-lib.ps1')
$checkLib = Join-Path $PSScriptRoot '..\lib\consumer-check-lib.ps1'
if (Test-Path -LiteralPath $checkLib -PathType Leaf) { . $checkLib }

$repoRoot = ''
if (Test-FunctionDefined 'Resolve-CheckRepoRoot') {
    $repoRoot = Resolve-CheckRepoRoot -RootOverride $RootOverride
} elseif ($RootOverride) {
    $repoRoot = $RootOverride
} elseif ($env:CLAUDE_PROJECT_DIR) {
    $repoRoot = $env:CLAUDE_PROJECT_DIR
} else {
    $repoRoot = (Get-GitTopLevelPath).Path
    if (-not $repoRoot) { $repoRoot = '' }
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host '[SKIP] gh is not installed -- nothing here can be read.'
    exit 0
}

. (Join-Path $PSScriptRoot '..\lib\native-capture-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\git-identity-lib.ps1')

# The login, from the KEYRING: no network call (see Get-ActiveGhAccount). Absent or logged out is the
# ordinary state of a machine that never touches the tracker.
$login = Get-ActiveGhAccount
if (-not $login) {
    Write-Host '[SKIP] gh names no active account (absent, or logged out) -- nothing here can be read.'
    exit 0
}
$safeLogin = ([string]$login) -replace '[^A-Za-z0-9_-]', ''
if (-not $safeLogin) {
    Write-Host '[SKIP] the active gh account name is not printable -- nothing here can be read.'
    exit 0
}

# gh resolves the repo from the working directory's remote; there is no -C for it, so the call runs from
# the repo root, and the location is restored whatever happens.
$read = $null
$pushed = $false
try {
    if ($repoRoot -and (Test-Path -LiteralPath $repoRoot -PathType Container)) {
        Push-Location -LiteralPath $repoRoot
        $pushed = $true
    }
    $read = Invoke-NativeCapture -FilePath 'gh' -DiscardStderr -TimeoutSeconds $TimeoutSeconds -Arguments @(
        'issue', 'list', '--state', 'open', '--author', '@me', '--limit', "$Limit", '--json', 'number')
} finally {
    if ($pushed) { Pop-Location }
}

if (-not ((Test-NativeCommandStarted -Capture $read) -and (Test-NativeExitMeasured -Capture $read) `
        -and -not $read.TimedOut -and $read.ExitCode -eq 0)) {
    Write-Host '[SKIP] the list of your open issues could not be read -- offline, or a transient gh/API problem.'
    exit 0
}

$count = 0
try {
    $parsed = ($read.Output -join "`n") | ConvertFrom-Json
    $count = @($parsed | Where-Object { $_ }).Count
} catch {
    Write-Host '[SKIP] the list of your open issues could not be parsed.'
    exit 0
}

if ($count -eq 0) {
    Write-Host "[OK] no open issue was opened by $safeLogin in this repo."
    exit 0
}

$shown = if ($count -ge $Limit) { "$Limit+" } else { "$count" }
Write-Host "[OPEN] $shown open issue(s) were opened by $safeLogin -- sweep only your own with /dkj-repo-workflow:issues-sweep -Author @me (#4337)."
exit 0
