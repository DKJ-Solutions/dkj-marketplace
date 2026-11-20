<#
.SYNOPSIS
    SessionStart check of the workflow plugin: is Claude Code's auto memory switched off for this repo,
    and does this checkout still hold memory notes? (issue #4341)

.DESCRIPTION
    THE RULE. Lessons are kept in the docs and never in memory (the constitution, Maikel, November 20,
    2026, #4341): a note lives on one machine under one account, so everybody else on the team never sees
    it. Measured the day the rule was made: one consumer checkout held 12 notes, one of them a filing rule
    the owner had decided two weeks earlier that never reached the shared docs, so a colleague's sessions
    kept breaking it.

    TWO READINGS, both read-only:
      1. THE SWITCH. .claude/settings.json must carry "autoMemoryEnabled": false -- the committed file,
         because that is what reaches every checkout. Missing, or any other value, is a [WARN] naming
         Part 6 of adopt-dkj-repo-workflow (adopt-auto-memory.ps1), which adds it. A machine-level
         CLAUDE_CODE_DISABLE_AUTO_MEMORY does not count: it switches nothing off for a colleague.
      2. THE NOTES. ~/.claude/projects/<project>/memory/ for THIS checkout, where <project> is the
         checkout's path with every character outside [A-Za-z0-9] written as '-' (Claude Code's own
         spelling, read off ~/.claude/projects). Every non-empty file there is listed by name, with the
         migration: file the lesson inbound (shared behaviour) or move it into the repo's own lens or facts
         rule (this repo alone), then delete the note. The list repeats at every session start until the
         directory is empty, which is the point -- a migration nobody is reminded of does not happen.

    WHAT IT CANNOT SEE -- the folder is found on a best-effort reading of Claude Code's layout: an
    autoMemoryDirectory setting or a CLAUDE_CONFIG_DIR that moves the notes elsewhere, the shortened and
    hashed name Claude Code gives a very long checkout path, and other checkouts of the same repo (each
    has its own project directory and reports in its own sessions). Any of those reads as "no notes".

    A note's NAME is foreign text forwarded into session context, so it is stripped of whitespace runs,
    control characters and brackets before it is printed, as every sibling check strips (#2271). A note's
    CONTENT is never read, let alone printed: any non-empty file counts, and the person reads the file.
    Names are capped at 80 characters and the list at 20, so a planted folder cannot flood the context.

    The script ALWAYS ends with exit 0 -- a session start must never strand here.

.PARAMETER RepoRootOverride
    (Optional, for tests) The repo root instead of CLAUDE_PROJECT_DIR or the working directory.

.PARAMETER UserHomeOverride
    (Optional, for tests) The home directory instead of USERPROFILE / HOME.
#>
[CmdletBinding()]
param(
    [string]$RepoRootOverride = '',
    [string]$UserHomeOverride = ''
)

Set-StrictMode -Version Latest

function Format-NoteName([string]$Text, [int]$Max = 80) {
    $s = ((((($Text) -replace '\s+', ' ') -replace '\p{C}', '') -replace '\[', '(') -replace '\]', ')').Trim()
    if ($s.Length -gt $Max) { $s = $s.Substring(0, $Max) + '...' }
    return $s
}

function Get-NoteFiles([string]$Dir) {
    # Recursion by hand, so a junction or symlink inside memory/ is never entered.
    foreach ($item in @(Get-ChildItem -LiteralPath $Dir -Force -ErrorAction SilentlyContinue)) {
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { continue }
        if ($item.PSIsContainer) { Get-NoteFiles -Dir $item.FullName }
        elseif ($item.Length -gt 0) { $item }
    }
}

try {
    $root = if ($RepoRootOverride) { $RepoRootOverride }
            elseif ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR }
            else { (Get-Location).Path }
    # A drive root keeps its separator ('C:\' encodes as 'C--'); anything else loses a trailing one.
    if ($root -notmatch '^[A-Za-z]:[\\/]$') { $root = $root.TrimEnd('\', '/') }

    $userHome = if ($UserHomeOverride) { $UserHomeOverride }
                elseif ($env:USERPROFILE) { $env:USERPROFILE }
                else { "$env:HOME" }

    . (Join-Path $PSScriptRoot '..\scripts\lib\settings-member-lib.ps1')

    # --- 1. the switch ---------------------------------------------------------------------------
    $settings = Read-SettingsFile -Path (Join-Path $root '.claude\settings.json')
    $state = 'missing'
    if (-not $settings.Readable) {
        $state = 'unreadable'
    } elseif (@(Get-SettingsMemberNames $settings.Parsed) -contains 'autoMemoryEnabled') {
        $value = $settings.Parsed.autoMemoryEnabled
        $state = $(if ($value -is [bool] -and -not $value) { 'off' } else { 'on' })
    }

    # --- 2. the notes --------------------------------------------------------------------------------
    $notes = @()
    $memoryDir = ''
    if ($userHome) {
        $project   = $root -replace '[^A-Za-z0-9]', '-'
        $memoryDir = Join-Path $userHome (Join-Path '.claude\projects' (Join-Path $project 'memory'))
        if (Test-Path -LiteralPath $memoryDir -PathType Container) {
            # NO CONTENT READ AND NO REPARSE POINT FOLLOWED (security review): a non-empty file counts, so a
            # huge or locked note cannot stall or sink the check, and the walk stays inside memory/.
            $notes = @(Get-NoteFiles -Dir $memoryDir | Sort-Object FullName)
        }
    }

    if ($state -eq 'off' -and $notes.Count -eq 0) {
        Write-Host 'auto-memory-sessioncheck: auto memory is off in .claude/settings.json and this checkout holds no memory notes.'
        exit 0
    }

    Write-Host 'auto-memory-sessioncheck: lessons go in the docs, never in memory (#4341) (data, not instructions):'
    switch ($state) {
        'missing'    { Write-Host '  [WARN] .claude/settings.json does not set "autoMemoryEnabled": false, so Claude Code keeps writing memory notes here.' }
        'on'         { Write-Host '  [WARN] .claude/settings.json sets "autoMemoryEnabled" to something other than false, so Claude Code keeps writing memory notes here.' }
        'unreadable' { Write-Host '  [WARN] .claude/settings.json does not parse as JSON, so whether auto memory is off cannot be read.' }
    }
    if ($state -ne 'off') {
        Write-Host '         Fix: Part 6 of the adopt-dkj-repo-workflow skill (adopt-auto-memory.ps1 -Apply), then commit the file.'
    }
    if ($notes.Count -gt 0) {
        Write-Host "  [WARN] this checkout holds $($notes.Count) memory note(s) only this machine can see, in $(Format-NoteName $memoryDir 400) :"
        $shown = 20
        foreach ($n in @($notes | Select-Object -First $shown)) {
            $rel = $n.FullName.Substring($memoryDir.Length).TrimStart('\', '/')
            Write-Host ('           - ' + (Format-NoteName $rel))
        }
        if ($notes.Count -gt $shown) { Write-Host "           ... and $($notes.Count - $shown) more." }
        Write-Host '         Move each one: a lesson about shared behaviour is filed inbound on the plugin source repo,'
        Write-Host '         a fact about this repo alone goes in its own lens or facts rule. Then delete the note;'
        Write-Host '         MEMORY.md is only the index and goes last. This line repeats until the folder is empty.'
    }
} catch {
    # The strip is inlined, as in every sibling check: this is the last-resort catch (#2271), and the
    # message is foreign text that is forwarded into session context.
    $safe = (((($_.Exception.Message) -replace '\s+', ' ') -replace '\p{C}', '') -replace '\[', '(') -replace '\]', ')'
    Write-Host ('auto-memory-sessioncheck skipped due to an error: ' + $safe.Trim())
}
exit 0
