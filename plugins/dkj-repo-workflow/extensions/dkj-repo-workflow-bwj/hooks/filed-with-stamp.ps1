<#
.SYNOPSIS
    PostToolUse hook on the shell tools: after a 'gh issue create' on a store repo, appends the plugin
    versions this session ran to the new issue's body as a hidden comment (inbound #4220).

.DESCRIPTION
    WHY A HOOK AND NOT A STEP OF report-issue. A bare 'gh issue create' is exactly the case that slips
    past the procedure, so a stamp only report-issue wrote would miss the issues where the version
    matters most. The stamp, the version reading and the repo list are in
    scripts/lib/filed-with-rules.ps1; this file reads the payload, asks the tracker, and edits.

    IT FAILS OPEN. PostToolUse runs after the create, so the issue already stands whatever happens
    here. Where a version cannot be read it is stamped 'unknown'; where the body cannot be read or
    edited, the session is told which issue went unstamped, and nothing else changes. Two gh calls at
    most per issue, bounded under hooks.json's 30s ceiling.

    hooks.json greps the payload for 'gh issue create' before PowerShell starts, so every other shell
    call costs no PowerShell start; the same test is repeated below for a run that reaches this file
    another way.

    WHAT IT PRINTS is fixed text plus repo refs and issue numbers -- never a title or a body.

    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/filed-with-stamp.tests.ps1 in the
    source repo -- change one, run the other.
#>
$ErrorActionPreference = 'Stop'

# READ STDIN ONLY WHERE THERE IS A HANDLE, the guard every hook in this tree carries (#2264).
$raw = ''
if ([Console]::IsInputRedirected) { $raw = [Console]::In.ReadToEnd() }

# THE CHEAP PRE-GATE, the same test hooks.json makes in shell first.
if ($raw -notmatch 'gh(\.exe)?\s+issue\s+create') { exit 0 }

foreach ($lib in @('asana-task-lib.ps1', 'filed-with-rules.ps1')) {
    $libPath = Join-Path $PSScriptRoot "..\scripts\lib\$lib"
    if (-not (Test-Path -LiteralPath $libPath -PathType Leaf)) {
        [Console]::Error.WriteLine("filed-with-stamp: $lib not found beside this hook -- the new issue was NOT stamped with its plugin versions. Reinstall or update the dkj-repo-workflow-bwj plugin.")
        exit 0
    }
    . $libPath
}

trap {
    [Console]::Error.WriteLine('filed-with-stamp: an unexpected error stopped the stamp -- the new issue may carry no plugin versions.')
    exit 0
}

# A BYTE-ORDER MARK IS NOT PART OF THE PAYLOAD (see guard-stale-paste-block.ps1).
$jsonText = [string]$raw
$brace = $jsonText.IndexOf('{')
if ($brace -gt 0) { $jsonText = $jsonText.Substring($brace) }
$payload = $null
try { $payload = $jsonText | ConvertFrom-Json } catch { exit 0 }
if ([string]$payload.tool_input.command -notmatch 'gh(\.exe)?\s+issue\s+create') { exit 0 }

$refs = @(Get-CreatedIssueRef -Text @(Get-FiledWithResponseText -Value $payload.tool_response) |
    Where-Object { $script:KindLabelRepos -contains ($_.Repo -split '/')[1].ToLowerInvariant() })
if ($refs.Count -eq 0) { exit 0 }

# --- The versions this session ran ----------------------------------------------------------------
$projectDir = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }
$userHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
$admin = $null
try {
    $adminPath = Join-Path $userHome '.claude\plugins\installed_plugins.json'
    if (Test-Path -LiteralPath $adminPath -PathType Leaf) { $admin = Get-Content -LiteralPath $adminPath -Raw -Encoding UTF8 | ConvertFrom-Json }
} catch { $admin = $null }
$versions = [ordered]@{}
foreach ($name in $script:FiledWithPlugins) { $versions[$name] = Get-FiledWithVersion -Admin $admin -Name $name -ProjectDir $projectDir }
if (-not $versions['dkj-repo-workflow-bwj']) {
    try { $versions['dkj-repo-workflow-bwj'] = [string]((Get-Content -LiteralPath (Join-Path $PSScriptRoot '..\.claude-plugin\plugin.json') -Raw | ConvertFrom-Json).version) } catch { }
}
$stamp = Get-FiledWithStamp -Versions $versions

# --- Stamp each new issue -------------------------------------------------------------------------
$missed = @()
foreach ($r in $refs) {
    $ref = "$($r.Repo)#$($r.Number)"
    $read = Invoke-AsanaGhBounded -Arguments "issue view $($r.Number) --repo $($r.Repo) --json body -q .body" -TimeoutMs 10000 -WorkingDirectory $projectDir
    if (-not $read.Started -or $read.TimedOut -or $read.ExitCode -ne 0) { $missed += $ref; continue }
    $newBody = Add-FiledWithStamp -Body ([string]$read.Out) -Stamp $stamp
    if ($null -eq $newBody) { continue }
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("filed-with-{0}.md" -f [guid]::NewGuid().ToString('N'))
    try {
        [System.IO.File]::WriteAllText($tmp, $newBody, (New-Object System.Text.UTF8Encoding($false)))
        $edit = Invoke-AsanaGhBounded -Arguments "issue edit $($r.Number) --repo $($r.Repo) --body-file `"$tmp`"" -TimeoutMs 12000 -WorkingDirectory $projectDir
        if (-not $edit.Started -or $edit.TimedOut -or $edit.ExitCode -ne 0) { $missed += $ref }
    } finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}
if ($missed.Count -eq 0) { exit 0 }

$text = "filed-with-stamp: $($missed -join ', ') could not be stamped with the plugin versions this session ran (#4220). The issue stands as created; nothing else is needed."
@{ hookSpecificOutput = @{ hookEventName = 'PostToolUse'; additionalContext = $text } } | ConvertTo-Json -Compress
exit 0
