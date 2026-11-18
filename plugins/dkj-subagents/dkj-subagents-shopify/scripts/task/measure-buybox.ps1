<#
.SYNOPSIS
    Measure where the add-to-cart button sits in a product page's buy box, on a really emulated viewport.

.DESCRIPTION
    No gate in a repo proves that something LOOKS right -- but a HEIGHT is not taste, it is a number. This
    script makes that number reproducible: per block in the buy box it reports the distance from the top
    of the box, and apart from that the distance of the add-to-cart button, the buy box's own place on the
    page and the sticky add-to-cart bar.

    WHICH ELEMENTS those are is the store's fact, not this plugin's: the selectors (and an optional
    expectation) come from the store's Get-ShopifyBuyBox seam in scripts/repo-config.ps1, read through
    scripts/lib/measure-buybox-rules.ps1. The mechanism -- Chrome discovery, viewport emulation, the
    settle wait, the probe and the report -- lives here and in measure-buybox.harness.js.

    TWO ROUTES THAT LOOK RIGHT AND SILENTLY MEASURE THE WRONG WIDTH, which is why this script starts a
    headless Chrome instead of using the browser you already have open:

      1. Shrinking the window (a resize call, window.resizeTo) REPORTS SUCCESS and leaves
         window.innerWidth at the old value once the window is maximised. Measured on a first manual
         attempt: 'Successfully resized to 390x900' with innerWidth 1920 afterwards.
      2. Putting the page in an iframe or a 390px container. A storefront may refuse framing, and a
         container does not help anyway: media queries look at the VIEWPORT, not at the width of the
         parent, so the mobile rules stay off.

    Only Emulation.setDeviceMetricsOverride of the DevTools Protocol really changes the CSS viewport. That
    is why the node harness exists beside this script.

    THE FAILURE DIRECTION IS ASYMMETRIC, so the measured width is ALWAYS in the output: a too-high
    measurement stands out and costs a round, while a measurement silently taken at desktop width reads as
    a requirement met on mobile. Read the 'viewport' line before believing the rest. When the measured
    width differs from the requested one the line says so loudly.

    THE VERDICT. Only when the store answered AtcMaxTop (and AtWidth) AND the measured innerWidth equals
    AtWidth does the script print PASS or FAIL, and exit 1 on FAIL. Otherwise it measures and says so.

    node is a HARD requirement, not a skip: a silent skip measures nothing and is still green, the exact
    failure direction a gate must refuse. A call to node is bounded: a Chrome that hangs must not hang the
    run.

    Exit 1 on: a refusal, a failed measurement, no buy box, no ATC button, or a FAIL verdict. Otherwise 0.

    Moved here from a store repo (#4290).

.PARAMETER Url
    The full address to measure. Excludes -Market/-Path.

.PARAMETER Market
    The Market label of one of the store's Get-StorefrontMarkets rows. With -Path, and optionally
    -PreviewThemeId, it builds the address.

.PARAMETER Path
    The path on the storefront, starting with '/'.

.PARAMETER PreviewThemeId
    Measure the preview theme instead of the published one (with the full preview parameters).

.PARAMETER Width
    Viewport width. Default 390.

.PARAMETER Height
    Viewport height. Default 900.

.PARAMETER SettleMs
    Wait after load before measuring. Late-filled blocks are rendered after load, so waiting too briefly
    measures an incomplete row and so a too-high button. Default 5000.

.PARAMETER BoxSelector
    Override the seam's BoxSelector for a one-off run.

.PARAMETER AtcSelector
    Override the seam's AtcSelector for a one-off run.

.PARAMETER Json
    Print the harness's raw JSON line instead of the report (exit 0 on a measurement).

.PARAMETER PlanOnly
    Print the address and the selectors this run would use, then stop. Runs no node and no browser and
    touches no network; meant for checking the seam and the address before measuring.

.PARAMETER RootOverride
    A fixture root for the seam read; a consumer never types it.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/measure-buybox.ps1 -Market NL -Path /products/some-product

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/measure-buybox.ps1 -Market NL -Path /products/some-product -PreviewThemeId 123456789

.NOTES
    Pure ASCII (repo convention for .ps1): Windows PowerShell 5.1 reads a BOM-less script as ANSI.

    The node call goes through Invoke-NativeCapture and never as a bare call with 2>&1: under
    $ErrorActionPreference = 'Stop' Windows PowerShell 5.1 turns every stderr line of a native exe into an
    ErrorRecord and sets $? to false even on exit code 0, and the harness writes its diagnostics to stderr.
#>
[CmdletBinding(DefaultParameterSetName = 'Market')]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Url')][string]$Url,
    [Parameter(Mandatory = $true, ParameterSetName = 'Market')][string]$Market,
    [Parameter(Mandatory = $true, ParameterSetName = 'Market')][string]$Path,
    [Parameter(ParameterSetName = 'Market')][string]$PreviewThemeId,
    [int]$Width = 390,
    [int]$Height = 900,
    [int]$SettleMs = 5000,
    [string]$BoxSelector = '',
    [string]$AtcSelector = '',
    [switch]$Json,
    [switch]$PlanOnly,
    [string]$RootOverride = ''
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\command-probe-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\check-report-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\native-capture-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\which-theme-rules.ps1')
. (Join-Path $PSScriptRoot '..\lib\storefront-markets-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\measure-buybox-rules.ps1')

function Show {
    <# A console line whose text may carry page or store-config text: it goes through the prose guard. #>
    param([string]$Text, [string]$Color = '')
    $t = Format-SafeProseToken -Value $Text -MaxLength 1000
    if ($Color) { Write-Host $t -ForegroundColor $Color } else { Write-Host $t }
}

function Stop-Refused {
    param([string]$Message)
    Write-Host "REFUSED: $(Format-SafeProseToken -Value $Message -MaxLength 900)" -ForegroundColor Red
    exit 1
}

if ($Width -lt 1 -or $Height -lt 1 -or $SettleMs -lt 0) { Stop-Refused '-Width and -Height must be positive and -SettleMs not negative.' }

# -- The store's facts: the seam, with the one-off overrides on top ---------------------------------------
$repoRoot = Resolve-RepoRootOrFail -Override $RootOverride -ScriptName 'measure-buybox.ps1' -OverrideName '-RootOverride'
try {
    $seam = if ($BoxSelector -and $AtcSelector) { $null } else { Get-BuyBoxSeamAnswer -RepoRoot ([string]$repoRoot) }
    $config = Resolve-BuyBoxConfig -Seam $seam -BoxSelector $BoxSelector -AtcSelector $AtcSelector
}
catch { Stop-Refused $_.Exception.Message }

# -- The address ------------------------------------------------------------------------------------------
try {
    $rows = @(if ($PSCmdlet.ParameterSetName -eq 'Market') { Get-StorefrontMarketRows -RepoRoot ([string]$repoRoot) })
    if ($PSCmdlet.ParameterSetName -eq 'Market' -and $rows.Count -eq 0) {
        Stop-Refused ("-Market/-Path need the store's market table, and this repo has not answered it. Add Get-StorefrontMarkets " +
            "to scripts/repo-config.ps1 (rows with Market, Domain and PathPrefix), or pass the full address with -Url.")
    }
    $target = if ($PSCmdlet.ParameterSetName -eq 'Url') {
        Get-MeasureUrl -Url $Url
    } else {
        Get-MeasureUrl -Market $Market -Path $Path -PreviewThemeId $PreviewThemeId -MarketRows $rows
    }
}
catch { Stop-Refused $_.Exception.Message }

$harness = Join-Path $PSScriptRoot 'measure-buybox.harness.js'
if (-not (Test-Path -LiteralPath $harness -PathType Leaf)) { Stop-Refused "the node harness is missing: $harness" }

if ($PlanOnly) {
    Show "Would measure: $target" 'Cyan'
    Show ("  box selector : {0}" -f $config.BoxSelector)
    Show ("  ATC selector : {0}" -f $config.AtcSelector)
    Show ("  sticky bar   : {0}" -f $(if ($config.StickySelector) { $config.StickySelector } else { '(none named)' }))
    Show ("  listed blocks: {0}" -f (@($config.BlockSelectors) -join ' | '))
    Show ("  expectation  : {0}" -f $(if ($null -ne $config.AtcMaxTop) { "ATC <= $($config.AtcMaxTop)px from the top of the box at $($config.AtWidth)px wide" } else { '(none given)' }))
    Write-Host ''
    Write-Host '-PlanOnly: nothing measured.' -ForegroundColor DarkGray
    exit 0
}

Show "Measuring: $target" 'Cyan'
Write-Host ("requested viewport : {0}x{1} (settle {2} ms)" -f $Width, $Height, $SettleMs)

# THE BOUND. The harness waits up to ~20 s for Chrome's endpoint, ~30 s for the load event and then the
# settle; a Chrome that hangs past all of that is hung. 120 s of slack on top of the settle is far above
# any honest run and still ends a hang inside one attention span.
$bound = [int][Math]::Ceiling($SettleMs / 1000.0) + 120

$run = Invoke-NativeCapture -FilePath 'node' -TimeoutSeconds $bound -Utf8 `
    -Arguments @($harness, $target, "$Width", "$Height", "$SettleMs", (ConvertTo-BuyBoxInput -Config $config))

# node absent is a refusal, never a skip: nothing was measured, and a green nothing is the failure.
if (-not (Test-NativeCommandStarted -Capture $run)) {
    Stop-Refused 'node is not installed or not on PATH, and the measurement cannot run without it (node 22 or newer: the harness uses its built-in WebSocket). Install node and run again; this is never skipped.'
}

$lines = @($run.Output)
$jsonLine = Get-BuyBoxJsonLine -Lines $lines
if ($run.TimedOut) {
    Write-Host ''
    Write-Host ("The measurement did not finish within {0}s and was stopped -- do not read this as a met requirement." -f $bound) -ForegroundColor Red
    foreach ($l in $lines) { Show "  $l" }
    exit 1
}
# Judged only after Test-NativeExitMeasured: an exit code that could not be measured is not a verdict.
$failed = $true
if (Test-NativeExitMeasured -Capture $run) { $failed = ($run.ExitCode -ne 0) }
if ($failed -or -not $jsonLine) {
    Write-Host ''
    Write-Host 'The measurement did NOT succeed -- do not read this as a met requirement.' -ForegroundColor Red
    if (-not (Test-NativeExitMeasured -Capture $run)) { Write-Host ("  node's exit code could not be measured: {0}" -f (Get-NativeExitLabel -Capture $run)) -ForegroundColor Red }
    foreach ($l in $lines) { Show "  $l" }
    exit 1
}

if ($Json) { $jsonLine; exit 0 }

try { $m = $jsonLine | ConvertFrom-Json }
catch {
    Write-Host ''
    Write-Host ("The harness answered a line that is not valid JSON: {0}" -f (Format-SafeProseToken -Value $_.Exception.Message -MaxLength 300)) -ForegroundColor Red
    exit 1
}

foreach ($l in (Get-BuyBoxReport -Measurement $m -Config $config -RequestedWidth $Width)) {
    if ($l.Color) { Write-Host $l.Text -ForegroundColor $l.Color } else { Write-Host $l.Text }
}

if ($m.PSObject.Properties.Name -contains 'error') { exit 1 }
$verdict = Get-BuyBoxVerdict -Measurement $m -Config $config
if ($verdict.State -in @('NoAtc', 'Fail')) { exit 1 }
exit 0
