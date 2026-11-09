<#
.SYNOPSIS
    Which issues one merged pull request CARRIED -- the ones it closed and the ones it only names. Pure:
    no network, no filesystem, no git, no gh.

.DESCRIPTION
    Dot-sourced by two readers that must agree on that set:

      - dkj-policy's cut-release.ps1, whose audience note links every solved task (#2586);
      - bwj-development's notify-live.ps1 (through live-message-rules.ps1), which tells those same
        tasks that the release is live (#3070, #3498).

    ONE FILE, MIRRORED INTO BOTH PLUGINS (#3941, November 9, 2026). Each reader used to decide the set
    on its own: notify-live took the named issues too, while cut-release read the closing references
    alone. Measured at BWJ-Development/smartwatchbanden's v2.51.0 cut: five storefront entries whose PR
    named its issue without closing it were left out of the audience note as "no issue it closed is
    linked to a task", and notify-live told three of those same tasks the release was live minutes
    later. So the rule is one file, held byte-identical by the lint gate's mirror check, for the reason
    live-record-lib.ps1 is: separately versioned plugins, and a cross-plugin path breaks silently on a
    version mismatch.

    Pure ASCII (repo convention for .ps1). No Set-StrictMode: dot-sourcing would change the caller's.
#>

function Get-PullIssueCandidates {
    <#
        Pure: the issue numbers one merged PR carried, as @{ Closing; Named }. -Closing is gh's
        closingIssuesReferences, which GitHub has already confirmed are issues. -Named is every OTHER
        number the PR points at -- the issue its head branch is named after ('<prefix>/<n>-<name>') and
        each bare '#<n>' in its body -- which the caller still has to ask GitHub about, because from the
        text alone a '#<n>' may be a pull request.

        WHY NOT CLOSING REFERENCES ALONE (inbound #3498). A repo that answers Get-ResolvesExemptMatchers
        ships every Asana-linked issue with -NoResolves and closes it by hand, because its go-live block
        has to go on while the issue is still open. So none of those issues is ever in
        closingIssuesReferences -- and they are exactly the issues the live message and the audience
        note exist for. Measured on BWJ-Development/smartwatchbanden: PR #1015 (branch liquid/1011-...,
        body naming #1011) had an empty closingIssuesReferences, and #1011 was never found. A surplus
        candidate costs nothing as long as each caller still demands a closed-as-completed issue before
        it counts a named one.

        Not read as mentions: the PR's own number, anything inside a code span or fence, 'PR #<n>' /
        'pull request #<n>', and 'owner/repo#<n>' (another repo's issue -- the lookbehind refuses a word
        character before the '#').
    #>
    param(
        [int]$PullNumber = 0,
        [AllowNull()][AllowEmptyCollection()][int[]]$ClosingNumbers,
        [AllowNull()][string]$HeadRefName = '',
        [AllowNull()][string]$Body = ''
    )
    $closing = New-Object 'System.Collections.Generic.List[int]'
    foreach ($n in @($ClosingNumbers)) { if ($null -ne $n -and $n -gt 0 -and -not $closing.Contains([int]$n)) { $closing.Add([int]$n) } }

    $named = New-Object 'System.Collections.Generic.List[int]'
    $add = { param($n) if ($n -gt 0 -and $n -ne $PullNumber -and -not $closing.Contains($n) -and -not $named.Contains($n)) { $named.Add($n) } }

    if ($HeadRefName -and ([string]$HeadRefName) -match '^[^/]+/(\d{1,9})-') { & $add ([int]$Matches[1]) }

    if ($Body) {
        $text = [regex]::Replace([string]$Body, '(?s)```.*?```', ' ')
        $text = [regex]::Replace($text, '`[^`]*`', ' ')
        $text = [regex]::Replace($text, '(?i)\b(pull\s*requests?|PRs?)\s*#\s*\d+', ' ')
        foreach ($m in [regex]::Matches($text, '(?<![\w/])#(\d{1,9})\b')) { & $add ([int]$m.Groups[1].Value) }
    }
    return @{ Closing = @($closing); Named = @($named) }
}

function Test-NamedIssueSolved {
    <#
        Pure: whether a NAMED issue (one the PR mentions but did not close) counts as solved by it --
        closed, as completed. A closing reference needs no such test: the merge closed it. A mention
        does, because "follows #12" names work that may still be open, and an audience note or a live
        message about it would claim a task solved that is not. -State and -StateReason are GitHub's,
        in either spelling (REST 'closed'/'completed', GraphQL 'CLOSED'/'COMPLETED').
    #>
    param([AllowNull()][string]$State = '', [AllowNull()][string]$StateReason = '')
    return ([string]$State -ieq 'closed') -and ([string]$StateReason -ieq 'completed')
}
