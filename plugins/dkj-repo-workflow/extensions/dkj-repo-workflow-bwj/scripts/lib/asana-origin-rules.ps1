<#
.SYNOPSIS
    The pure half of hooks/guard-asana-origin.ps1: whether a new issue's body says it came from a colleague
    (it names a requester, or quotes a task) and, if so, whether it links that colleague's Asana task or
    states that none exists (Get-AsanaOriginVerdict).

.DESCRIPTION
    INBOUND #4477 (BWJ-Development/smartwatchbanden, November 25, 2026). A colleague's request, passed on in
    chat, was filed as smartwatchbanden#1567 with a plain create. Its body said "Requested by <colleague>
    (task "<task name>"), passed on by <colleague>", yet it carried no '<!-- asana-task: -->' marker, no
    reach label, and the colleague's task -- created 13 minutes earlier, and the first hit of one Asana
    search on a phrase from the request -- stayed in its inbox with no link and no comment. The requester
    would have heard nothing at the close. asana-link-pickupcheck (#2919, #2928) only WARNS, and only
    after claim-issue or new-branch, when the issue is already filed and the work has started. This guard
    asks #2928's question at the create, where the answer can still change what is filed.

    THE SIGNAL is a phrase in the body, English or Dutch: a requester named ('requested by', 'reported by',
    'on behalf of', 'passed on by', 'aangevraagd door', 'op verzoek van', 'namens', ...) or a task quoted
    ('task "..."', 'taak "..."', 'Asana task', 'Asana-ticket', ...). A body with neither is not judged.

    LINKED is whatever Resolve-AsanaTaskRef resolves -- the marker, the header row, a sole task URL -- or
    several task URLs at once, which asana-closed-message reports on its own. The same reader every
    consumer of the link uses, so 'linked' cannot mean something different here than at the close.

    THE OPT-OUT is the line '<!-- no-asana-task -->' in the body: the session searched the board and
    found no task, and says so where a later reader can see it. Resolve-AsanaTaskRef never reads it as a
    link, because it carries no number.

    WHICH REPOS. The admitted repos (asana-mirror-gate.ps1's list) minus this plugin's source repo under
    both its names: an inbound issue there quotes a store's requester as evidence, and has no task on
    this repo's board to link.

    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/guard-asana-origin.tests.ps1 in the
    source repo -- change one, run the other.
#>

. (Join-Path $PSScriptRoot 'reach-reason-rules.ps1')
. (Join-Path $PSScriptRoot 'asana-task-lib.ps1')
. (Join-Path $PSScriptRoot 'asana-mirror-gate.ps1')

$script:AsanaOriginRepos = @($script:AsanaMirrorAdmittedRepos | Where-Object { @('dkj-marketplace', 'dkj-claude-plugins') -notcontains $_ })

# Opening quotes a task title may start with: straight, and the typographic ones written as escapes so
# this file stays ASCII.
$script:AsanaOriginQuote = '[' + '"' + "'" + [char]0x201C + [char]0x2018 + [char]0x201E + ']'

$script:AsanaOriginRequesterPattern = '(?i)\b(?:requested|reported|asked)\s+by\b|\bon\s+behalf\s+of\b|\bpassed\s+on\s+by\b|\b(?:aangevraagd|gevraagd|gemeld|doorgegeven|ingediend)\s+door\b|\bop\s+verzoek\s+van\b|\bnamens\b'
$script:AsanaOriginTaskPattern = '(?i)\b(?:task|taak|ticket)\s*[:(]?\s*' + $script:AsanaOriginQuote + '|\basana[\s-]?(?:task|taak|ticket|card|kaart)\b'
$script:AsanaOriginOptOutPattern = '<!--\s*no-asana-task\s*-->'

function Get-AsanaOriginSignal {
    <#
        Pure: what in -Body says the issue came from a colleague, as a list of 'names a requester' and
        'quotes a task' -- fixed text, never the matched words. Empty where neither is found.
    #>
    param([AllowEmptyString()][AllowNull()][string]$Body = '')

    $text = [string]$Body
    $signals = @()
    if ($text -match $script:AsanaOriginRequesterPattern) { $signals += 'names a requester' }
    if ($text -match $script:AsanaOriginTaskPattern) { $signals += 'quotes a task' }
    return $signals
}

function Test-AsanaOriginSettled {
    <#
        Pure: $true where -Body links an Asana task (Resolve-AsanaTaskRef finds one, or several) or carries
        the '<!-- no-asana-task -->' opt-out.
    #>
    param([AllowEmptyString()][AllowNull()][string]$Body = '')

    $text = [string]$Body
    if ($text -match $script:AsanaOriginOptOutPattern) { return $true }
    $ref = Resolve-AsanaTaskRef -IssueBody $text
    return ([bool]$ref.Gid -or $ref.Source -eq 'ambiguous')
}

function Get-AsanaOriginVerdict {
    <#
        Pure: the verdict on one body, as Verdict ('pass' | 'refuse') and Signals (Get-AsanaOriginSignal's
        list). A body with no signal passes, and so does one that is settled (Test-AsanaOriginSettled).
    #>
    param([AllowEmptyString()][AllowNull()][string]$Body = '')

    $signals = @(Get-AsanaOriginSignal -Body $Body)
    $verdict = 'pass'
    if ($signals.Count -gt 0 -and -not (Test-AsanaOriginSettled -Body $Body)) { $verdict = 'refuse' }
    return [pscustomobject]@{ Verdict = $verdict; Signals = $signals }
}
