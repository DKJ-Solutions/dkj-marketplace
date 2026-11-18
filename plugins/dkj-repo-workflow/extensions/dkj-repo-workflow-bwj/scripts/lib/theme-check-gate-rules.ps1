<#
.SYNOPSIS
    The shape rules for a store's theme-check gate: that the required CI check ENFORCES theme check's
    outcome instead of only reporting it, and that the checks named in .theme-check.yml are real.

.DESCRIPTION
    Dot-source this and hand it the text of the store's files:

        . (Join-Path $PSScriptRoot '..\lib\theme-check-gate-rules.ps1')
        $findings = @(Get-ThemeCheckGateFindings -WorkflowText $wf -ConfigText $cfg)

    A finding is a plain string; no findings means the gate has the right shape. THIS RUNS NO THEME CHECK
    (that needs the Shopify CLI and the network, and CI measures it) -- only the SHAPE of the gate is held.

    WHY THE SHAPE IS HELD (issue #4272; the two stores each carried this as a suite of their own).
    Shopify/theme-check-action@v2 has two mutually exclusive modes, chosen by its 'token' input. WITH a
    token it writes a separate check run with annotations and then exits 0 UNCONDITIONALLY; WITHOUT one it
    exits with theme check's real code. A workflow with only the token step can fail on a crash and never
    on a Liquid error, and the failure announces nothing: it keeps reporting, annotations and all, and
    simply never blocks a merge. So the workflow has two steps, and the one without a token IS the gate.

    ONE LAYER DOWN, THE SAME FAILURE: theme check ignores an unknown check name in .theme-check.yml
    WITHOUT A WORD, and under 'extends: nothing' nothing fills the gap. A config that enabled
    'JSONSyntaxError' -- which is not a check; the real one is 'ValidJSON' -- gated no invalid JSON at all.
    Measured: a template with a missing brace gave JSONSyntaxError 0 offenses / exit 0, ValidJSON 1 error /
    exit 1. So every check name in the config must be on an allowlist of names MEASURED to exist.

    THE ALLOWLIST: the two names every store's gate needs, ValidJSON and LiquidHTMLSyntaxError, are held
    here. A store that enables more extends the list through the optional seam Get-ThemeCheckExtraChecks in
    its scripts/repo-config.ps1 (names only; each must have been measured to exist before it is added --
    an unmeasured name is exactly the defect this catches). The caller passes the seam's answer in as
    -ExtraChecks; this file reads no config itself.

    Pure ASCII (repo convention for .ps1).
#>

# Names measured to exist in theme check, and which both stores' gates enable at severity error.
$script:ThemeCheckRequiredChecks = @('ValidJSON', 'LiquidHTMLSyntaxError')

# Top-level keys of .theme-check.yml that are not check names.
$script:ThemeCheckNonCheckKeys = @('extends', 'ignore', 'require', 'exclude', 'root')

function Get-ThemeCheckWorkflowFindings {
    <# Findings about .github/workflows/theme-check.yml, from its text. #>
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text)

    $f = New-Object System.Collections.ArrayList
    $lines = @($Text -split "`r?`n")
    $text  = $lines -join "`n"

    # The required check on the trunk is named after the JOB's 'name:', not a step's. Renaming it breaks
    # the ruleset and any stale-CI detector that reads this name as its certificate.
    if ($text -notmatch '(?m)^ {4}name:\s*Shopify theme check\s*$') {
        $null = $f.Add("the job is not named 'Shopify theme check' (the required check on the trunk is named after the job)")
    }

    # Cut the step list into blocks: a step starts on a line of exactly six spaces then '- '.
    $blocks = @()
    $current = $null
    foreach ($line in $lines) {
        if ($line -match '^ {6}-\s') {
            if ($null -ne $current) { $blocks += , $current }
            $current = @($line)
        } elseif ($null -ne $current) {
            $current += $line
        }
    }
    if ($null -ne $current) { $blocks += , $current }

    $action = @($blocks | Where-Object { ($_ -join "`n") -match 'uses:\s*Shopify/theme-check-action@v2' })
    if ($action.Count -ne 2) {
        $null = $f.Add("expected exactly two theme-check-action steps (annotations + gate), found $($action.Count)")
        return @($f)
    }

    $withToken    = @($action | Where-Object { ($_ -join "`n") -match    '(?m)^\s*token:\s*\S' })
    $withoutToken = @($action | Where-Object { ($_ -join "`n") -notmatch '(?m)^\s*token:\s*\S' })
    if ($withToken.Count -ne 1)    { $null = $f.Add("expected exactly one step WITH a token (the annotation step), found $($withToken.Count)") }
    if ($withoutToken.Count -ne 1) { $null = $f.Add("expected exactly one step WITHOUT a token (the gate that fails the job), found $($withoutToken.Count)") }

    # The annotation step tolerates its own failure and the gate does not: a failed step skips every
    # later step, so an annotation step that can fail would skip the gate and turn the required check red
    # on a clean tree (measured on a real PR: the check-run update failed with HttpError: Not Found).
    if ($withToken.Count -eq 1 -and (($withToken[0] -join "`n") -notmatch '(?m)^\s*continue-on-error:\s*true\s*$')) {
        $null = $f.Add('the annotation step does not carry continue-on-error: true, so its own failure would skip the gate')
    }
    if ($withoutToken.Count -eq 1) {
        $body = $withoutToken[0] -join "`n"
        if ($body -match '(?m)^\s*continue-on-error:') { $null = $f.Add('the gate step carries continue-on-error -- it is the step that must fail the job') }
        if ($body -match '(?m)^\s*if:')                { $null = $f.Add('the gate step carries an if: that could skip it') }
    }

    # Both steps measure the same thing, or the annotation list stops explaining the red check.
    $versions = @()
    foreach ($step in $action) {
        $body  = $step -join "`n"
        $label = if ($body -match '(?m)^\s*token:\s*\S') { 'the annotation step' } else { 'the gate step' }
        if ($body -notmatch "(?m)^\s*flags:\s*'--fail-level error'\s*$") { $null = $f.Add("$label does not run with --fail-level error") }
        if ($body -notmatch "(?m)^\s*theme_root:\s*'\.'\s*$")            { $null = $f.Add("$label does not run over the whole repo root (theme_root: '.')") }
        if ($body -match "(?m)^\s*version:\s*'(\d+\.\d+\.\d+)'\s*$") { $versions += $Matches[1] }
    }
    # Without 'version' the action installs the CLI's latest, and a bad release of it blocks every PR
    # (it happened: a major release crashed the annotation step). A pin in one step only would also run
    # two different theme checks side by side.
    if ($versions.Count -ne 2) { $null = $f.Add('both theme-check-action steps must pin an exact CLI version (x.y.z)') }
    elseif (@($versions | Select-Object -Unique).Count -ne 1) { $null = $f.Add('the two steps pin different CLI versions') }

    if ($text -notmatch '(?m)^\s*checks:\s*write\s*$') { $null = $f.Add('the workflow permissions lack checks: write, which the annotation step needs') }

    return @($f)
}

function Get-ThemeCheckConfigFindings {
    <# Findings about .theme-check.yml, from its text. -ExtraChecks is the store's seam answer. #>
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text,
        [string[]]$ExtraChecks = @()
    )

    $f = New-Object System.Collections.ArrayList
    $lines = @($Text -split "`r?`n")
    $known = @($script:ThemeCheckRequiredChecks) + @($ExtraChecks | Where-Object { $_ })

    # Top-level keys in check-name shape, with the lines of each one's block (up to the next top-level key).
    $keys   = New-Object System.Collections.ArrayList
    $blocks = @{}
    $name   = $null
    foreach ($l in $lines) {
        if ($l -match '^([A-Za-z][A-Za-z0-9_]*):') {
            $name = $Matches[1]
            if ($script:ThemeCheckNonCheckKeys -notcontains $name -and $l -match '^[A-Za-z][A-Za-z0-9_]*:\s*$') {
                $null = $keys.Add($name); $blocks[$name] = New-Object System.Collections.ArrayList
            } else { $name = $null }
        } elseif ($name -and $blocks.ContainsKey($name)) {
            $null = $blocks[$name].Add($l)
        }
    }

    if ($keys.Count -eq 0) { $null = $f.Add('.theme-check.yml names no check at all') }

    foreach ($k in $keys) {
        if ($known -notcontains $k) {
            $null = $f.Add("check name '$k' is not on the allowlist of names measured to exist -- theme check ignores an unknown name SILENTLY (a store adds a measured one through Get-ThemeCheckExtraChecks)")
        }
    }

    if ($keys -contains 'JSONSyntaxError') { $null = $f.Add("'JSONSyntaxError' is not a check and fails silently; the check is 'ValidJSON'") }

    foreach ($k in $script:ThemeCheckRequiredChecks) {
        if ($keys -notcontains $k) { $null = $f.Add("$k is not enabled in .theme-check.yml"); continue }
        # The severity is read from the check's OWN block: a pattern that runs on from the key could take
        # the next check's severity and pass a check that has none.
        if (-not (@($blocks[$k]) -match '^\s+severity:\s*error\s*$')) { $null = $f.Add("$k is not at severity: error") }
    }
    return @($f)
}

function Get-ThemeCheckGateFindings {
    <# Both files at once; every finding carries the file it belongs to. #>
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$WorkflowText,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$ConfigText,
        [string[]]$ExtraChecks = @()
    )
    $out = New-Object System.Collections.ArrayList
    foreach ($x in @(Get-ThemeCheckWorkflowFindings -Text $WorkflowText)) { $null = $out.Add(".github/workflows/theme-check.yml: $x") }
    foreach ($x in @(Get-ThemeCheckConfigFindings -Text $ConfigText -ExtraChecks $ExtraChecks)) { $null = $out.Add(".theme-check.yml: $x") }
    return @($out)
}
