<#
.SYNOPSIS
    The judgement behind hooks/guard-asana-mirror.ps1: which GitHub issues an Asana create-task call
    mirrors, and whether each one carries the reach label that admits it to the board.

.DESCRIPTION
    WHY THIS EXISTS (inbound #2482). report-issue's step 2 opens with "Only for an issue carrying the
    reach label" since #2360, and that sentence was the whole of the gate: report-issue has no script,
    and the Asana create-task tool is available to a session whatever step 1 decided. Measured
    September 25, 2026, on the fixed plugin version: BWJ-Development/smartwatchbanden#770 was filed
    with only `documentation` -- a developer-only lint fix -- and still got a card, whose marker then
    made the PR that fixed it unable to close it on merge. The second measured miss of one rule, so
    the rule moves from memory to a hook.

    Split from the hook so the decision is testable without a payload on stdin and a process per case,
    the same split guard-working-copy.ps1 makes with working-copy-guard-lib.ps1.

    WHAT COUNTS AS A MIRROR is a GitHub issue URL anywhere in the call's tool_input, on a repo this
    procedure is admitted in. report-issue writes that URL into the `Tracked on GitHub:` line (the
    first line of the notes) and the optional `Github Issue` custom field -- so a mirror carries it by
    construction, and a task that cites no issue of an admitted repo is not a mirror and is none of this gate's business. The repo
    list is report-issue's own "Before you start" list, matched on the NAME for the reason stated there:
    the two stores are no longer in one organisation.

    Pure ASCII (repo convention for .ps1).
#>

# The repos report-issue admits, by NAME -- see "Before you start" in skills/report-issue/SKILL.md.
$script:AsanaMirrorAdmittedRepos = @('smartwatchbanden', 'xoxowildhearts', 'dkj-marketplace', 'dkj-claude-plugins', 'phone-factory')

function Get-MirroredIssueRefs {
    <#
        Every distinct GitHub issue on an admitted repo that $Text cites as a URL, as objects with
        Owner, Repo, Number and Ref ('owner/repo#n'). The character classes are GitHub's own for an
        owner and a repo name, so nothing outside them reaches a gh argument or a printed line.
    #>
    param([string]$Text)
    $refs = [ordered]@{}
    if (-not $Text) { return @() }
    $pattern = 'github\.com/([A-Za-z0-9-]+)/([A-Za-z0-9._-]+)/issues/([0-9]+)'
    foreach ($m in [regex]::Matches($Text, $pattern)) {
        $owner = $m.Groups[1].Value
        $repo  = $m.Groups[2].Value
        if ($script:AsanaMirrorAdmittedRepos -notcontains $repo.ToLowerInvariant()) { continue }
        # A digit run past Int32 is no GitHub issue, and a bare [int] cast on it THROWS -- which crashed
        # the hook out of its own fail-open path (Sebastian's review, #2482). Skipped, not cast.
        $number = 0
        if (-not [int]::TryParse($m.Groups[3].Value, [ref]$number) -or $number -lt 1) { continue }
        $ref = "$owner/$repo#$number"
        if (-not $refs.Contains($ref.ToLowerInvariant())) {
            $refs[$ref.ToLowerInvariant()] = [pscustomobject]@{
                Owner = $owner; Repo = $repo; Number = $number; Ref = $ref
            }
        }
    }
    return @($refs.Values)
}

function Get-AsanaMirrorToolInputText {
    <#
        The tool_input of a PreToolUse payload as one string to search, or '' when the payload does not
        parse. Re-serialised rather than searched raw, so the URL is matched in its decoded form
        whichever way the harness escaped it.
    #>
    param([string]$Raw)
    if (-not $Raw) { return '' }
    # A leading BOM makes ConvertFrom-Json throw, and the gate then passes the call silently. A .NET
    # StreamWriter on a child's stdin writes one (measured, #4054: the suite's hook runs never parsed),
    # and the child decodes its three bytes under the console code page -- one U+FEFF, or three
    # characters of mojibake -- so whatever stands before the opening brace in that span is dropped.
    $brace = $Raw.IndexOf('{')
    if ($brace -gt 0 -and $brace -le 3) { $Raw = $Raw.Substring($brace) }
    try { $payload = $Raw | ConvertFrom-Json } catch { return '' }
    if ($null -eq $payload -or $null -eq $payload.tool_input) { return '' }
    return ($payload.tool_input | ConvertTo-Json -Depth 20 -Compress)
}

function Get-AsanaMirrorVerdict {
    <#
        One issue's verdict from its labels. $Labels is $null when they could not be read -- which is
        'unknown', never 'missing': a failed read is not evidence that the label is absent.

        Returns 'admit' (the reach label is on it), 'refuse' (read, and not on it) or 'unknown'.
        The comparison is case-insensitive, as GitHub's own label matching is.
    #>
    param([AllowNull()][string[]]$Labels, [Parameter(Mandatory = $true)][string]$ReachLabel)
    if ($null -eq $Labels) { return 'unknown' }
    foreach ($l in $Labels) { if ($l -and $l.Trim() -ieq $ReachLabel) { return 'admit' } }
    return 'refuse'
}

function Get-ProjectReachLabel {
    <#
        The reach label's name for the project at -ProjectDir: its scripts\repo-config.ps1's
        Get-ReachLabel, else the prescribed default 'minor'. Returns @{ Label; ReadFailed }, and each
        caller words its own note for ReadFailed -- the file was there and could not be read.

        Read in a child scope with StrictMode off, the way build-backlog-page.ps1 reads the same seam: the
        file is the consumer's own and is written on the assumption that StrictMode is off. One definition
        for both hooks that judge the reach label -- guard-asana-mirror (issue -> card) and
        asana-link-pickupcheck (card -> issue, #2940) -- so the two directions cannot read two names.
    #>
    param([Parameter(Mandatory = $true)][string]$ProjectDir)
    $seam = Read-ProjectConfigSeam -ProjectDir $ProjectDir -Name 'Get-ReachLabel'
    $label = if ($seam.Value) { $seam.Value } else { 'minor' }
    return @{ Label = $label; ReadFailed = $seam.ReadFailed }
}

function Get-ProjectAsanaPrioFieldGid {
    <#
        The GID of the board's Prio-Score custom field for the project at -ProjectDir: its
        scripts\repo-config.ps1's Get-AsanaPrioFieldGid, else '' -- the board carries no such field and
        nothing is required (#4054). Returns @{ Gid; ReadFailed }.
    #>
    param([Parameter(Mandatory = $true)][string]$ProjectDir)
    $seam = Read-ProjectConfigSeam -ProjectDir $ProjectDir -Name 'Get-AsanaPrioFieldGid'
    return @{ Gid = $seam.Value; ReadFailed = $seam.ReadFailed }
}

function Read-ProjectConfigSeam {
    <#
        One seam's answer from the project's scripts\repo-config.ps1, trimmed, as @{ Value; ReadFailed }.
        Value is '' when the file or the function is absent or answers nothing; ReadFailed is set when
        the file was there and could not be read. Read in a child scope with StrictMode off, the way
        build-backlog-page.ps1 reads the same file: it is the consumer's own and is written on the
        assumption that StrictMode is off. One reader for every seam the two hooks judge, so they
        cannot read the file two ways.
    #>
    param([Parameter(Mandatory = $true)][string]$ProjectDir, [Parameter(Mandatory = $true)][string]$Name)
    $result = @{ Value = ''; ReadFailed = $false }
    $configPath = Join-Path $ProjectDir 'scripts\repo-config.ps1'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) { return $result }
    try {
        $answer = & {
            Set-StrictMode -Off
            # Captured before the dot-source: the consumer's file runs in this scope and may reset $args.
            $__seamName = $args[1]
            . $args[0]
            if (@($ExecutionContext.InvokeCommand.GetCommands($__seamName, 'Function', $false)).Count) { & $__seamName }
        } $configPath $Name
        if ($answer -and ([string]@($answer)[-1]).Trim()) { $result.Value = ([string]@($answer)[-1]).Trim() }
    } catch {
        $result.ReadFailed = $true
    }
    return $result
}

function Get-AsanaMirrorFieldState {
    <#
        Whether a create-task call's tool_input sets the custom field -FieldGid (#4054): 'set' (a value
        that is not null and not an empty string), 'missing' (custom_fields absent, or present without
        that key or with an empty value) or 'unknown' (custom_fields is a string that does not parse).
        The Asana tools take custom_fields as an object or as one JSON string holding the same map, so
        both are read. -ToolInputJson is Get-AsanaMirrorToolInputText's output.
        A batch tool (tool_input.tasks, one object per task) is judged per task, and only a task that
        itself cites an issue on an admitted repo must carry the field: 'missing' if any such task lacks
        it, else 'unknown' if any could not be read, else 'set'.
    #>
    param([AllowEmptyString()][string]$ToolInputJson, [Parameter(Mandatory = $true)][string]$FieldGid)
    if (-not $ToolInputJson) { return 'unknown' }
    try { $ti = $ToolInputJson | ConvertFrom-Json } catch { return 'unknown' }
    if ($null -eq $ti) { return 'unknown' }
    $tasks = @($ti)
    if ($ti.PSObject.Properties.Name -contains 'tasks' -and @($ti.tasks | Where-Object { $_ }).Count) {
        # The tasks that cite an issue themselves; where none does, the URL sits outside them and every
        # task is the mirror (Victor's review, #4054: judging the wrapper then refused a scored batch).
        $all = @($ti.tasks | Where-Object { $_ })
        $mirrors = @($all | Where-Object { @(Get-MirroredIssueRefs -Text ($_ | ConvertTo-Json -Depth 20 -Compress)).Count -gt 0 })
        $tasks = if ($mirrors.Count) { $mirrors } else { $all }
    }
    $states = @($tasks | ForEach-Object { Get-AsanaTaskFieldState -Task $_ -FieldGid $FieldGid })
    if ($states -contains 'missing') { return 'missing' }
    if ($states -contains 'unknown') { return 'unknown' }
    return 'set'
}

function Get-AsanaTaskFieldState {
    <# One task object's state for -FieldGid: 'set', 'missing' or 'unknown'; see Get-AsanaMirrorFieldState. #>
    param($Task, [Parameter(Mandatory = $true)][string]$FieldGid)
    # Every property read sits in the try: a number or a boolean where an object belongs makes a read
    # throw under StrictMode, and a throw would reach the hook's trap, which passes the call unjudged --
    # reach label included (Sebastian's review, #4054). Such a shape is no score, so it is 'missing'.
    try {
        if ($null -eq $Task -or $Task -is [ValueType] -or $Task -is [string] -or
            -not ($Task.PSObject.Properties.Name -contains 'custom_fields')) { return 'missing' }
        $cf = $Task.custom_fields
        if ($cf -is [string]) {
            if (-not $cf.Trim()) { return 'missing' }
            try { $cf = $cf | ConvertFrom-Json } catch { return 'unknown' }
        }
        if ($null -eq $cf -or $cf -is [ValueType] -or $cf -is [string] -or $cf -is [array] -or
            -not ($cf.PSObject.Properties.Name -contains $FieldGid)) { return 'missing' }
        $v = $cf.$FieldGid
        if ($null -eq $v -or ($v -is [string] -and -not $v.Trim())) { return 'missing' }
        # An empty array or object is no score either (Victor's and Sebastian's reviews).
        if ($v -is [array] -and @($v).Count -eq 0) { return 'missing' }
        if ($v -is [pscustomobject] -and @($v.PSObject.Properties).Count -eq 0) { return 'missing' }
        return 'set'
    } catch {
        return 'missing'
    }
}

function ConvertFrom-GhIssueLabels {
    <#
        The label names out of `gh issue view --json labels` output, or $null when it is not that
        shape. An issue with no labels is an EMPTY array, which is a real answer, not $null.
    #>
    param([string]$Json)
    if (-not $Json) { return $null }
    try { $obj = $Json | ConvertFrom-Json } catch { return $null }
    if ($null -eq $obj -or -not ($obj.PSObject.Properties.Name -contains 'labels')) { return $null }
    # A JSON null is not an empty list: piped, $null runs the block once and yields @(''), which would
    # read as 'refuse' (Victor's review, #2482).
    if ($null -eq $obj.labels) { return $null }
    return ,([string[]]@($obj.labels | ForEach-Object { [string]$_.name }))
}
