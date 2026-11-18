<#
.SYNOPSIS
    Regression tests for the shared BWJ theme-check gate shape rules that dkj-repo-workflow-bwj ships --
    scripts/lib/theme-check-gate-rules.ps1 and scripts/task/check-theme-gate.ps1 (issue #4272, step 2 of #4259).

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/bwj-theme-check-gate.tests.ps1

    WHY A SUITE HERE FOR A FILE NOBODY IN THIS REPO USES -- the answer bwj-market-urls.tests.ps1 gives.
    Both BWJ stores each carried a suite of their own that read the store's own workflow file; the shared
    rules are driven here by MADE-UP workflow and config texts, so what is held is the rule and not any
    store's file (this repo is public, and a store's file is the store's).

    THE FAILURE DIRECTION IS WHY EACH RULE HAS A BAD CASE. Remove the gate step, give it a token, or
    mistype a check name, and the gate turns decorative without announcing it. So for every rule there is
    a good text that passes and a mutation of it that must be flagged -- a rule that cannot fail proves
    nothing.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Ext      = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\extensions\dkj-repo-workflow-bwj'
$LibPath  = Join-Path $Ext 'scripts\lib\theme-check-gate-rules.ps1'
$Script   = Join-Path $Ext 'scripts\task\check-theme-gate.ps1'
$Suite    = Join-Path ([System.IO.Path]::GetTempPath()) "bwj-theme-gate-fixture-$PID-$([guid]::NewGuid().ToString('n'))"

$script:pass = 0
$script:fail = 0
function Assert-True {
    param([bool]$Condition, [string]$Label)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label" -ForegroundColor Red }
}
function Assert-Equal {
    param($Expected, $Actual, [string]$Label)
    if ("$Expected" -eq "$Actual") { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red }
}
function Write-Group { param([string]$Title) Write-Host ''; Write-Host $Title -ForegroundColor Cyan }
# A mutation must produce a finding that mentions the given fragment.
function Assert-Flagged {
    param([string[]]$Findings, [string]$Fragment, [string]$Label)
    Assert-True (@($Findings | Where-Object { $_ -like "*$Fragment*" }).Count -gt 0) $Label
}

Write-Host 'The shared BWJ theme-check gate shape rules -- where the plugin ships them (#4272)' -ForegroundColor Cyan
Assert-True (Test-Path -LiteralPath $LibPath) 'dkj-repo-workflow-bwj ships scripts/lib/theme-check-gate-rules.ps1'
Assert-True (Test-Path -LiteralPath $Script) 'dkj-repo-workflow-bwj ships scripts/task/check-theme-gate.ps1'
. $LibPath

$Workflow = @'
name: Theme check
permissions:
  contents: read
  checks: write
jobs:
  theme-check:
    name: Shopify theme check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: annotations
        uses: Shopify/theme-check-action@v2
        continue-on-error: true
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          flags: '--fail-level error'
          theme_root: '.'
          version: '3.94.3'
      - name: gate
        uses: Shopify/theme-check-action@v2
        with:
          flags: '--fail-level error'
          theme_root: '.'
          version: '3.94.3'
'@
$Config = @'
extends: nothing
ignore:
  - theme-archive/**

LiquidHTMLSyntaxError:
  enabled: true
  severity: error
  ignore:
    - assets/*.js.liquid

ValidJSON:
  enabled: true
  severity: error
'@

# Normalise: a checkout with CRLF line ends would otherwise break the LF-based edits below.
$Workflow = $Workflow.Replace("`r`n", "`n")
$Config   = $Config.Replace("`r`n", "`n")

function Edit-Text { param([string]$Text, [string]$From, [string]$To) if (-not $Text.Contains($From)) { throw "fixture edit: '$From' not found" }; return $Text.Replace($From, $To) }

try {
    Write-Group '1. the good texts pass'
    Assert-Equal 0 @(Get-ThemeCheckWorkflowFindings -Text $Workflow).Count 'a two-step workflow with a gate and an annotation step has no findings'
    Assert-Equal 0 @(Get-ThemeCheckConfigFindings -Text $Config).Count 'a config with both required checks at severity error has no findings'
    Assert-Equal 0 @(Get-ThemeCheckGateFindings -WorkflowText $Workflow -ConfigText $Config).Count 'and both together'
    $crlf = $Workflow.Replace("`n", "`r`n")
    Assert-Equal 0 @(Get-ThemeCheckWorkflowFindings -Text $crlf).Count 'CRLF line ends do not matter'

    Write-Group '2. the workflow: the gate is a step WITHOUT a token'
    $wf = Edit-Text $Workflow "      - name: gate`n        uses: Shopify/theme-check-action@v2`n        with:`n" "      - name: gate`n        uses: Shopify/theme-check-action@v2`n        with:`n          token: x`n"
    $f = @(Get-ThemeCheckWorkflowFindings -Text $wf)
    Assert-Flagged $f 'WITHOUT a token' 'a token on the gate step (it would exit 0 unconditionally) is flagged'
    $wf = Edit-Text $Workflow "      - name: gate`n        uses: Shopify/theme-check-action@v2`n        with:`n" "      - name: gate`n        uses: Shopify/theme-check-action@v2`n        continue-on-error: true`n        with:`n"
    Assert-Flagged @(Get-ThemeCheckWorkflowFindings -Text $wf) 'continue-on-error' 'continue-on-error on the gate is flagged'
    $wf = Edit-Text $Workflow "      - name: gate`n        uses: Shopify/theme-check-action@v2`n" "      - name: gate`n        if: github.event_name == 'push'`n        uses: Shopify/theme-check-action@v2`n"
    Assert-Flagged @(Get-ThemeCheckWorkflowFindings -Text $wf) 'if:' 'an if: on the gate (it could skip it) is flagged'

    Write-Group '3. the workflow: the annotation step cannot skip the gate'
    $wf = Edit-Text $Workflow "        continue-on-error: true`n" ''
    Assert-Flagged @(Get-ThemeCheckWorkflowFindings -Text $wf) 'continue-on-error: true' 'an annotation step without continue-on-error: true is flagged'

    Write-Group '4. the workflow: exactly two action steps'
    $one = $Workflow.Substring(0, $Workflow.IndexOf("      - name: gate"))
    $f = @(Get-ThemeCheckWorkflowFindings -Text $one)
    Assert-Flagged $f 'exactly two' 'dropping the gate step is flagged'
    Assert-Equal 1 $f.Count 'and is the only finding (the rest cannot be judged)'

    Write-Group '5. the workflow: both steps measure the same thing, on one pinned version'
    $wf = Edit-Text $Workflow "          flags: '--fail-level error'`n          theme_root: '.'`n          version: '3.94.3'`n" "          flags: '--fail-level crash'`n          theme_root: '.'`n          version: '3.94.3'`n"
    Assert-Flagged @(Get-ThemeCheckWorkflowFindings -Text $wf) '--fail-level error' 'a different fail level is flagged'
    $wf = Edit-Text $Workflow "          theme_root: '.'`n          version: '3.94.3'`n      - name: gate" "          theme_root: 'theme'`n          version: '3.94.3'`n      - name: gate"
    Assert-Flagged @(Get-ThemeCheckWorkflowFindings -Text $wf) 'whole repo root' 'a narrower theme_root is flagged'
    $wf = $Workflow.Replace("          version: '3.94.3'`n", '')
    Assert-Flagged @(Get-ThemeCheckWorkflowFindings -Text $wf) 'pin an exact CLI version' 'an unpinned CLI is flagged'
    $wf = Edit-Text $Workflow "          version: '3.94.3'`n      - name: gate" "          version: '3.90.0'`n      - name: gate"
    Assert-Flagged @(Get-ThemeCheckWorkflowFindings -Text $wf) 'different CLI versions' 'two different pins are flagged'

    Write-Group '6. the workflow: job name and permission'
    $wf = Edit-Text $Workflow 'name: Shopify theme check' 'name: Theme lint'
    Assert-Flagged @(Get-ThemeCheckWorkflowFindings -Text $wf) 'Shopify theme check' 'a renamed job (the required check name) is flagged'
    $wf = Edit-Text $Workflow "  checks: write`n" ''
    Assert-Flagged @(Get-ThemeCheckWorkflowFindings -Text $wf) 'checks: write' 'a missing checks: write is flagged'

    Write-Group '7. the config: only check names measured to exist'
    $cfg = $Config + "`nTotallyBogusCheck:`n  enabled: true`n"
    Assert-Flagged @(Get-ThemeCheckConfigFindings -Text $cfg) 'TotallyBogusCheck' 'an unknown check name is flagged (theme check ignores it silently)'
    Assert-Equal 0 @(Get-ThemeCheckConfigFindings -Text $cfg -ExtraChecks @('TotallyBogusCheck')).Count 'the same name passes once the store lists it through its seam'
    $cfg = $Config.Replace('ValidJSON:', 'JSONSyntaxError:')
    $f = @(Get-ThemeCheckConfigFindings -Text $cfg)
    Assert-Flagged $f 'JSONSyntaxError' 'the old, non-existent JSON check name is flagged'
    Assert-Flagged $f 'ValidJSON is not enabled' 'and the real one is then missing'
    Assert-Equal 0 @(Get-ThemeCheckConfigFindings -Text ($Config + "`nextends_note: x`n")).Count 'a key that is not a bare check header is not read as a check name'
    Assert-Flagged @(Get-ThemeCheckConfigFindings -Text "extends: nothing`n") 'names no check' 'a config with no check at all is flagged'

    Write-Group '8. the config: severity is read from the check''s own block'
    $cfg = Edit-Text $Config "LiquidHTMLSyntaxError:`n  enabled: true`n  severity: error`n" "LiquidHTMLSyntaxError:`n  enabled: true`n"
    Assert-Flagged @(Get-ThemeCheckConfigFindings -Text $cfg) 'LiquidHTMLSyntaxError is not at severity' 'a check with no severity is flagged EVEN THOUGH the next check below it has one (a run-on match would pass it)'
    $cfg = Edit-Text $Config "ValidJSON:`n  enabled: true`n  severity: error" "ValidJSON:`n  enabled: true`n  severity: warning"
    Assert-Flagged @(Get-ThemeCheckConfigFindings -Text $cfg) 'ValidJSON is not at severity' 'a check at severity warning is flagged'
    Assert-Flagged @(Get-ThemeCheckConfigFindings -Text ($Config.Replace("ValidJSON:`n  enabled: true`n  severity: error", ''))) 'ValidJSON is not enabled' 'a missing required check is flagged'

    Write-Group '9. the script: missing files, the optional seam, and the exit codes'
    New-Item -ItemType Directory -Force -Path (Join-Path $Suite 'repo\.github\workflows') | Out-Null
    $repo = Join-Path $Suite 'repo'
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    function Invoke-Gate {
        $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
        try { $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script -Path $repo 2>&1 } finally { $ErrorActionPreference = $prev }
        $code = $LASTEXITCODE
        return [pscustomobject]@{ Code = $code; Text = (@($out | ForEach-Object { "$_" }) -join "`n") }
    }
    $r = Invoke-Gate
    Assert-Equal 1 $r.Code 'a repo with neither file exits 1'
    [System.IO.File]::WriteAllText((Join-Path $repo '.github\workflows\theme-check.yml'), $Workflow, $utf8)
    [System.IO.File]::WriteAllText((Join-Path $repo '.theme-check.yml'), ($Config + "`nStoreExtraCheck:`n  enabled: true`n  severity: error`n"), $utf8)
    $r = Invoke-Gate
    Assert-Equal 1 $r.Code 'a check name no seam vouches for exits 1'
    Assert-True ($r.Text.Contains('StoreExtraCheck')) 'and is named'
    New-Item -ItemType Directory -Force -Path (Join-Path $repo 'scripts') | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $repo 'scripts\repo-config.ps1'), "function Get-ThemeCheckExtraChecks { return @('StoreExtraCheck') }", $utf8)
    $r = Invoke-Gate
    Assert-Equal 0 $r.Code 'the store''s Get-ThemeCheckExtraChecks seam makes it pass'
    Assert-True ($r.Text.Contains('PASS')) 'and says PASS'

    Write-Group '10. ASCII, and no store fact in the shipped files'
    foreach ($p in @($LibPath, $Script)) {
        $nonAscii = @([System.IO.File]::ReadAllBytes($p) | Where-Object { $_ -gt 127 }).Count
        Assert-Equal 0 $nonAscii ("{0} is pure ASCII" -f (Split-Path -Leaf $p))
    }
} finally {
    if (Test-Path -LiteralPath $Suite) { Remove-Item -LiteralPath $Suite -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host ''
Write-Host ("{0} passed, {1} failed" -f $script:pass, $script:fail) -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 }
exit 0
