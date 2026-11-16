<#
.SYNOPSIS
    The pure half of hooks/guard-kind-label.ps1: the three kind labels, the repos whose tracker runs
    them, and the verdict on one 'gh issue create' call (Get-KindLabelVerdict).

.DESCRIPTION
    INBOUND #4197 (November 16, 2026): WORKFLOW-portable.md says every issue carries exactly one of
    'bug', 'feature' or 'research', set on the 'gh issue create' itself (#2783, #3006). Nothing held it.
    Measured in smartwatchbanden: 11 consecutive issues filed by sessions on 2026-11-13 and 2026-11-14
    carried no kind label, and none was ever added afterwards, while the procedure that states the rule
    was loaded and unchanged. The gap was enforcement, not wording.

    THE CALLS are read by reach-reason-rules.ps1's Get-GhIssueLabelCall, the parser guard-reach-reason
    uses, so the two guards cannot disagree about what a command does.

    WHICH REPOS. The kind scheme is the BWJ stores' tracker scheme, so the guard judges the repos
    report-issue admits (asana-mirror-gate.ps1's list) MINUS this plugin's source repo under both its
    names: a store session files inbound issues there under 'feature-inbound' or 'bug-inbound', which
    carry no kind of the three, and refusing those would block the inbound route itself.

    ONLY A CREATE IS JUDGED. The rule is that the label goes on at creation; an edit that adds a kind to
    an old issue is the repair the workflow asks for, and judging it would need the issue's current
    labels from the network.

    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/guard-kind-label.tests.ps1 in the
    source repo -- change one, run the other.
#>

. (Join-Path $PSScriptRoot 'reach-reason-rules.ps1')
. (Join-Path $PSScriptRoot 'asana-mirror-gate.ps1')

$script:KindLabels = @('bug', 'feature', 'research')
$script:KindLabelRepos = @($script:AsanaMirrorAdmittedRepos | Where-Object { @('dkj-marketplace', 'dkj-claude-plugins') -notcontains $_ })

function Get-KindLabelVerdict {
    <#
        Pure: the verdict on one call from Get-GhIssueLabelCall, as Verdict ('pass' | 'refuse' |
        'unchecked') and Kinds (the kind labels it names, lower case, without repeats). An edit always
        passes. A create naming exactly one kind passes; two or more is refused; none is refused unless
        the labels are built at run time or set outside the command (a template, the browser, an editor,
        --recover), which leaves it unchecked.
    #>
    param([Parameter(Mandatory = $true)]$Call)

    $kinds = @(@($Call.Labels) | ForEach-Object { ([string]$_).ToLowerInvariant() } | Where-Object { $script:KindLabels -contains $_ } | Select-Object -Unique)
    $verdict = 'pass'
    if ($Call.Kind -ceq 'create') {
        if ($kinds.Count -gt 1) { $verdict = 'refuse' }
        elseif ($kinds.Count -eq 0) {
            $verdict = if ($Call.LabelsDynamic -or $Call.BodySource -eq 'elsewhere') { 'unchecked' } else { 'refuse' }
        }
    }
    return [pscustomobject]@{ Verdict = $verdict; Kinds = $kinds }
}
