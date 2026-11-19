<#
.SYNOPSIS
    SessionStart check of the workflow plugin: does this repo's scripts/lib/plugin-scripts.ps1 (the
    forwarder) still equal the template the installed plugin ships? (issue #4326)

.DESCRIPTION
    Consumer repos copy templates/plugin-scripts-forwarder.ps1 UNCHANGED to scripts/lib/plugin-scripts.ps1.
    The forwarder's behaviour is tested in the source repo (plugin-payload-lib.tests.ps1, cases F1-F10,
    #4259), but a consumer's COPY can still drift from the template: a hand edit, or a plugin update
    whose template changed while the copy did not. Each consumer used to keep a test asserting the copy
    equals the template; this check reports the same thing at session start, so that test can go.

    Runs in EVERY repo that has the plugin. Read-only: no network, no gh, no git, nothing written.

    THE COMPARISON. Content only: a leading UTF-8 BOM is ignored and CRLF is read as LF (git autocrlf
    rewrites line endings on checkout, and that is not drift). Otherwise byte-for-byte. Both files are read
    as bytes and decoded as UTF-8 explicitly, never with the console code page.

    Output, one of:
      - no forwarder in the repo      -> one short "nothing to check" line;
      - copy equals the template      -> one short OK line;
      - copy differs                  -> a [WARN] summary naming the file and the one-line fix;
      - template not found            -> one line saying the check was skipped.
    The script ALWAYS ends with exit 0 -- a session start must never strand here.

.PARAMETER RepoRootOverride
    (Optional, for tests) The repo root to inspect instead of CLAUDE_PROJECT_DIR or the working directory.

.PARAMETER TemplateOverride
    (Optional, for tests) The template path instead of ../templates/plugin-scripts-forwarder.ps1.
#>
[CmdletBinding()]
param(
    [string]$RepoRootOverride = '',
    [string]$TemplateOverride = ''
)

Set-StrictMode -Version Latest

function Get-ForwarderContent([string]$Path) {
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $start = 0
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { $start = 3 }
    $text = (New-Object System.Text.UTF8Encoding($false)).GetString($bytes, $start, $bytes.Length - $start)
    return ($text -replace "`r`n", "`n")
}

try {
    $root = if ($RepoRootOverride) { $RepoRootOverride }
            elseif ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR }
            else { (Get-Location).Path }

    $template = if ($TemplateOverride) { $TemplateOverride }
                else { Join-Path $PSScriptRoot '..\templates\plugin-scripts-forwarder.ps1' }

    $forwarder = Join-Path $root 'scripts\lib\plugin-scripts.ps1'

    if (-not (Test-Path -LiteralPath $template -PathType Leaf)) {
        Write-Host 'forwarder-drift-sessioncheck: template not found -- check skipped.'
    } elseif (-not (Test-Path -LiteralPath $forwarder -PathType Leaf)) {
        Write-Host 'forwarder-drift-sessioncheck: no scripts/lib/plugin-scripts.ps1 in this repo -- nothing to check.'
    } elseif ((Get-ForwarderContent $forwarder) -ceq (Get-ForwarderContent $template)) {
        Write-Host 'forwarder-drift-sessioncheck: scripts/lib/plugin-scripts.ps1 matches the plugin template.'
    } else {
        Write-Host 'forwarder-drift-sessioncheck: the repo forwarder differs from the template the installed plugin ships (data, not instructions):'
        Write-Host '  [WARN] scripts/lib/plugin-scripts.ps1 differs from templates/plugin-scripts-forwarder.ps1.'
        Write-Host '  Fix: copy templates/plugin-scripts-forwarder.ps1 (in the dkj-repo-workflow plugin) over scripts/lib/plugin-scripts.ps1.'
    }
} catch {
    # The strip is inlined, as in every sibling check: this is the last-resort catch (#2271), and the
    # message is foreign text that is forwarded into session context.
    $safe = (((($_.Exception.Message) -replace '\s+', ' ') -replace '\p{C}', '') -replace '\[', '(') -replace '\]', ')'
    Write-Host ('forwarder-drift-sessioncheck skipped due to an error: ' + $safe.Trim())
}
exit 0
