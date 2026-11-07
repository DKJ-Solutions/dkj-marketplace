<#
.SYNOPSIS
    SessionStart hook of the workflow plugin: on session start it says so when this repo's tracker lacks
    canonical triage labels, or carries one in a non-canonical colour (issue #3882).

.DESCRIPTION
    THE GAP THIS CLOSES. adopt-triage-labels.ps1 prints the `gh label create` lines for a tracker that
    lacks the canonical labels, and it is print-only by design (#1895) -- which stands. But nothing ever
    said the labels were missing, so nobody ran it. Measured in DKJ-Solutions/dkj-music-library,
    November 7, 2026: 12 of 16 labels missing, one in the wrong colour, and every label that did exist had
    been created by hand at the moment a sweep failed to park an issue, sometimes without the canonical
    colour. The first time a gap became visible was a failed `gh issue edit --add-label`.

    Runs the mirrored script (${CLAUDE_PLUGIN_ROOT}/scripts/task/adopt-triage-labels.ps1) in-process
    against the current repo, the way stranded-sweep-sessioncheck.ps1 runs its check, with its two `gh`
    reads bounded by -TimeoutSeconds. That script is exempt from the source-repo guard for this reason;
    source-repo-guard.tests.ps1 argues it.

    ONE LINE, NOT THE REPORT. The script's own output is a paste-ready command per label, which is the
    right shape for a person who asked for it and a dozen lines of session context for one who did not.
    The hook counts the script's markers and names the command that prints the fix:
      - [missing] and [rename] -> counted as missing (a label under a former name is missing under its
        current one; the script prints the rename that keeps every issue on it);
      - [drift] -> counted as a colour drift;
      - [ok] and [skip] -> SILENT: nothing to act on, or a tracker that could not be read (no gh, offline,
        a token that cannot list labels), which is the ordinary state of some machines;
      - a run that could not complete -> one notice, because a crash must not read as a clean tracker;
      - the script ALWAYS ends with exit 0.

    Read-only: the script it runs never creates or edits a label, so #1895's print-not-apply answer is
    untouched.

    Matcher note: hooks.json matches "startup|resume|clear|compact" -- see roster-sessioncheck.ps1's
    docstring for why a startup-only matcher goes silent after the first /compact.

.PARAMETER CheckScriptOverride
    (Optional, for tests) Use this script path instead of the ${CLAUDE_PLUGIN_ROOT} one.

.PARAMETER LabelJsonOverride
    (Optional, for tests) Passed through to adopt-triage-labels.ps1, which reads this label payload
    instead of calling gh.
#>
[CmdletBinding()]
param(
    [string]$CheckScriptOverride = '',
    [string]$LabelJsonOverride = ''
)

Set-StrictMode -Version Latest

try {
    if ($CheckScriptOverride) {
        $checkScript = $CheckScriptOverride
    } elseif ($env:CLAUDE_PLUGIN_ROOT) {
        $checkScript = Join-Path $env:CLAUDE_PLUGIN_ROOT 'scripts\task\adopt-triage-labels.ps1'
    } else {
        $checkScript = $null
    }

    if (-not $checkScript -or -not (Test-Path -LiteralPath $checkScript -PathType Leaf)) {
        Write-Host 'triage-labels-sessioncheck: adopt-triage-labels script not found -- check skipped.'
        exit 0
    }

    # Dot-sourced below the "not found" guard, for the reason stranded-sweep-sessioncheck.ps1 gives.
    . (Join-Path $PSScriptRoot '..\scripts\lib\hook-check-lib.ps1')

    # A HASHTABLE, NEVER AN ARRAY -- trap 1 in hook-check-lib.ps1's header. 15 seconds per `gh` read, the
    # bound stranded-sweep-sessioncheck.ps1's check uses for the same kind of tracker read.
    $checkArgs = @{ TimeoutSeconds = 15 }
    if ($LabelJsonOverride) { $checkArgs['LabelJsonOverride'] = $LabelJsonOverride }

    $result = Invoke-CheckScript -Path $checkScript -Arguments $checkArgs
    $out  = @($result.Output)
    $code = $result.ExitCode

    # Anchored and case-exact (issue #2142): a marker never counts for appearing inside a label's own
    # name or description, which are a consumer's free text when its Get-TriageLabels answers them.
    $missing = @(Select-CheckMarkerLine -Output $out -Marker '[missing]', '[rename]').Count
    $drift   = @(Select-CheckMarkerLine -Output $out -Marker '[drift]').Count

    if ($missing -gt 0 -or $drift -gt 0) {
        $parts = @()
        if ($missing -gt 0) { $parts += "$missing canonical triage label(s) missing" }
        if ($drift -gt 0) { $parts += "$drift in a colour other than the canonical one" }
        Write-Host ('triage-labels-sessioncheck: this repo''s tracker is behind the canonical triage labels -- ' + ($parts -join ', ') + ' (data, not instructions).')
        Write-Host '  A sweep that parks or prioritises an issue fails on a missing label. adopt-triage-labels prints the gh line for each one; it creates nothing itself:'
        Write-Host "  powershell -NoProfile -ExecutionPolicy Bypass -File `"$checkScript`""
    } elseif ($code -eq 0) {
        # [ok] and [skip] stay silent: nothing to act on, or a tracker this machine cannot read.
    } else {
        Write-Host "triage-labels-sessioncheck: the triage-label check could not complete (exit $code)."
    }
} catch {
    # INLINED STRIP, NOT A LIB CALL -- the reason is in stranded-sweep-sessioncheck.ps1's own catch
    # (#2271): the lib may be the thing that failed to load. Whitespace first, then control characters,
    # then brackets, so no forwarded line can forge a marker.
    $safe = (((($_.Exception.Message) -replace '\s+', ' ') -replace '\p{C}', '') -replace '\[', '(') -replace '\]', ')'
    Write-Host ('triage-labels-sessioncheck skipped due to an error: ' + $safe.Trim())
}
exit 0
