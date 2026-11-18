<#
.SYNOPSIS
    Validate the JSON-LD (structured data) of storefront pages, per market and optionally on a
    preview theme.

.DESCRIPTION
    Fetches every given page, pulls out all <script type="application/ld+json"> blocks, parses them and
    reports per block the @type, whether the JSON is valid, and a summary of the fields that tend to go
    wrong (breadcrumb @ids, url, priceCurrency, aggregateRating, FAQ answer text, protocol-relative
    image URLs).

    Why this script exists: preview URLs are publicly reachable, but Google's Rich Results Test does not
    follow the preview cookie reliably. Parsing the HTML mechanically is the reliable route.

    Exit code 1 as soon as one block holds invalid JSON, a page could not be fetched, or a page did not
    serve the requested preview theme. Read-only: it pushes and publishes nothing.

    -Path builds its URLs from the store's own market table: the optional Get-StorefrontMarkets seam in
    the repo's scripts/repo-config.ps1 (rows with Market, Domain and PathPrefix), read by the same
    reader which-theme uses. Nothing is shipped here, because the market table is per store. Unanswered,
    -Path refuses and names -Url.

    MIND THE INVOCATION FORM. `powershell -File <script> -Path '/a','/b'` binds the WHOLE list as ONE
    string: with -File every argument is a bare string and PowerShell does not split on commas. This
    script therefore splits itself (Expand-CommaList from scripts/lib/comma-list.ps1) and then refuses
    every target of the wrong shape; the split and the shape check are a pair.

    Mind the rate limit: after a few dozen automated requests Shopify serves a bot-protection page
    (HTTP 429, "Verifying your connection..."). The script recognises it and reports a fetch failure
    instead of "no JSON-LD" -- measure fewer pages per run or wait a few minutes.

    Moved here from a store repo (#4290).

.PARAMETER ThemeId
    Preview theme id; added to every -Path URL as preview_theme_id plus the three parameters the admin
    sends (_ab=0&_fd=0&_sc=1). Leave out to measure the live storefront.

.PARAMETER Path
    One or more storefront paths, e.g. '/', '/pages/reviews'. Default: '/'. Collection and article
    handles can differ per market (301); shared paths such as '/pages/reviews' are safe.
    Each path must start with '/'; a comma separates paths, even inside a single argument.

.PARAMETER Market
    Markets to measure (the Market labels of the store's Get-StorefrontMarkets rows, case-insensitive).
    Default: all.

.PARAMETER Url
    Full URLs instead of -Path/-Market. No preview suffix is added: put it in yourself.
    Each URL must start with http:// or https://; a comma separates URLs.

.PARAMETER PlanOnly
    Print the target URLs this script would fetch, then stop. Touches no network. Meant for checking
    the invocation form before measuring.

.PARAMETER Full
    Print the raw JSON per block (to paste into validator.schema.org) instead of the summary.

.PARAMETER SaveTo
    Folder to keep the fetched HTML in, for closer inspection.

.PARAMETER RootOverride
    A fixture root for the seam read; a consumer never types it.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/check-jsonld.ps1 -ThemeId 123456789012 -Path '/','/pages/reviews'

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/check-jsonld.ps1 -Url 'https://your-store.example/pages/reviews' -Full

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/check-jsonld.ps1 -Path '/','/pages/reviews' -Market UK -PlanOnly

.NOTES
    Pure ASCII (repo convention for .ps1): Windows PowerShell 5.1 reads a BOM-less script as ANSI.

    No native exe here, so no stderr trap -- everything goes through Invoke-WebRequest.
#>
[CmdletBinding(DefaultParameterSetName = 'Market')]
param(
    [Parameter(ParameterSetName = 'Market')][string]$ThemeId,
    [Parameter(ParameterSetName = 'Market')][string[]]$Path = @('/'),
    [Parameter(ParameterSetName = 'Market')][string[]]$Market,
    [Parameter(ParameterSetName = 'Url', Mandatory = $true)][string[]]$Url,
    [switch]$Full,
    [string]$SaveTo,
    [switch]$PlanOnly,
    [string]$RootOverride = ''
)
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\command-probe-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\check-report-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\fetch-failure.ps1')
. (Join-Path $PSScriptRoot '..\lib\which-theme-rules.ps1')
. (Join-Path $PSScriptRoot '..\lib\storefront-markets-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\comma-list.ps1')
. (Join-Path $PSScriptRoot '..\lib\check-jsonld-rules.ps1')

function Write-ShapeRefusal {
    param([string[]]$Bad, [string]$Kind)
    $need = if ($Kind -eq 'Path') { "must start with '/'" } else { 'must start with http:// or https://' }
    Write-Host ("Invalid -{0} argument(s) -- each {1}:" -f $Kind, $need) -ForegroundColor Red
    foreach ($b in $Bad) { Write-Host ("  '{0}'" -f (Format-SafeProseToken -Value $b)) -ForegroundColor Red }
    Write-Host ""
    Write-Host "Does this come from a comma list? That was already split on commas above; a fragment left" -ForegroundColor Yellow
    Write-Host "over here most likely belonged to a query string. Pass such a target as a separate" -ForegroundColor Yellow
    Write-Host "argument in a direct call (not through 'powershell -File')." -ForegroundColor Yellow
}

# -- Build the target URLs ---------------------------------------------------------------------------
$targets = [System.Collections.Generic.List[object]]::new()
if ($PSCmdlet.ParameterSetName -eq 'Url') {
    $Url = Expand-CommaList -Value $Url
    $bad = @(Get-TargetShapeErrors -Value $Url -Kind 'Url')
    if ($bad.Count -gt 0) { Write-ShapeRefusal -Bad $bad -Kind 'Url'; exit 1 }
    foreach ($u in $Url) { $targets.Add([pscustomobject]@{ Label = $u; Url = $u }) }
}
else {
    $Path = Expand-CommaList -Value $Path
    $bad = @(Get-TargetShapeErrors -Value $Path -Kind 'Path')
    if ($bad.Count -gt 0) { Write-ShapeRefusal -Bad $bad -Kind 'Path'; exit 1 }
    $repoRoot = Resolve-RepoRootOrFail -Override $RootOverride -ScriptName 'check-jsonld.ps1' -OverrideName '-RootOverride'
    $allMarkets = @(Get-StorefrontMarketRows -RepoRoot ([string]$repoRoot))
    try {
        # -Market carries the same comma trap, so it is split here too.
        $wanted = if ($Market) { @(Expand-CommaList -Value $Market) } else { @() }
        $rows = @(Select-MarketRows -Markets $allMarkets -Market $wanted)
        $built = @(Get-ProbeTargets -Path $Path -Markets $rows)
    }
    catch {
        Write-Host "REFUSED: $(Format-SafeProseToken -Value $_.Exception.Message -MaxLength 500)" -ForegroundColor Red
        exit 1
    }
    foreach ($b in $built) {
        $targets.Add([pscustomobject]@{ Label = $b.Label; Url = (Get-ProbeUrl -Target $b.Target -ThemeId $ThemeId) })
    }
}

# -PlanOnly shows WHICH targets this script would fetch without touching the network: the only way to
# check the invocation form before measuring, and it makes the comma trap testable without a request.
if ($PlanOnly) {
    Write-Host ("{0} target(s):" -f $targets.Count) -ForegroundColor Cyan
    foreach ($t in $targets) { Write-Host ("  {0}  ->  {1}" -f $t.Label, $t.Url) }
    Write-Host ""
    Write-Host "-PlanOnly: nothing fetched." -ForegroundColor DarkGray
    exit 0
}

if ($SaveTo -and -not (Test-Path -LiteralPath $SaveTo)) { New-Item -ItemType Directory -Path $SaveTo | Out-Null }

$levelColor = @{ Warn = 'Yellow'; Ok = 'Green'; Dim = 'DarkGray' }
function Write-Findings {
    param($Findings)
    foreach ($f in $Findings) {
        if ($levelColor.ContainsKey($f.Level)) { Write-Host $f.Text -ForegroundColor $levelColor[$f.Level] }
        else { Write-Host $f.Text }
    }
}

# -- Main loop -----------------------------------------------------------------------------------------
$blocks = 0; $invalid = 0; $themeFaults = 0
foreach ($t in $targets) {
    Write-Host ""
    Write-Host ("===== {0}" -f $t.Label) -ForegroundColor Cyan
    Write-Host ("      {0}" -f $t.Url) -ForegroundColor DarkGray

    $html = $null
    try {
        # A web session keeps the preview cookie across the redirect Shopify sends. A 429 throws here,
        # so the status always reaches the failure evidence rather than passing as an empty page.
        $html = (Invoke-WebRequest -Uri $t.Url -UseBasicParsing -TimeoutSec 60 -SessionVariable sess).Content
    }
    catch {
        $evidence = Get-FetchFailureEvidence -ErrorRecord $_ -Url $t.Url
        $statusText = if ($null -ne $evidence.StatusCode) { "HTTP $($evidence.StatusCode)" } else { 'no HTTP response' }
        Write-Host ("  FETCH FAILED: {0} -- {1}" -f $statusText, (Format-SafeProseToken -Value $_.Exception.Message)) -ForegroundColor Red
        if ($evidence.StatusCode -eq 429) {
            Write-Host "      Shopify bot protection / rate limit: wait a few minutes and measure again, or measure fewer pages per run." -ForegroundColor Yellow
        }
        $invalid++
        continue
    }
    # The bot-protection page is valid HTML too, and would otherwise pass as "no JSON-LD found".
    if (Test-BotProtection -Html $html) {
        Write-Host "  FETCH FAILED: bot protection (429-like), not a real page. Wait a few minutes and measure fewer pages per run." -ForegroundColor Red
        $invalid++
        continue
    }

    if ($SaveTo) {
        $safe = ($t.Label -replace '[^\w\-]', '_')
        Set-Content -LiteralPath (Join-Path $SaveTo "$safe.html") -Value $html -Encoding UTF8
    }

    # Did the page really serve the requested preview theme?
    if ($ThemeId) {
        $served = (Get-ServedTheme -Html $html).Id
        if ($served -ne "$ThemeId") {
            Write-Host ("  !! page served theme '{0}', not '{1}' -- measurement unreliable" -f $served, $ThemeId) -ForegroundColor Red
            $themeFaults++
        }
    }

    $raws = @(Get-JsonLdBlocks -Html $html)
    if ($raws.Count -eq 0) { Write-Host "  no JSON-LD found" -ForegroundColor Yellow; continue }

    $i = 0
    foreach ($raw in $raws) {
        $i++; $blocks++
        $type = Get-JsonLdType -Raw $raw
        $obj = $null
        try { $obj = $raw | ConvertFrom-Json -ErrorAction Stop }
        catch {
            $invalid++
            Write-Host ("  [{0}] {1}  JSON INVALID: {2}" -f $i, $type, (Format-SafeProseToken -Value $_.Exception.Message)) -ForegroundColor Red
            Write-Host ("      raw: {0}" -f (Format-SafeProseToken -Value $raw.Substring(0, [Math]::Min(400, $raw.Length))))
            continue
        }
        Write-Host ("  [{0}] {1}  JSON OK" -f $i, $type) -ForegroundColor Green
        if ($Full) { $raw; continue }
        Write-Findings (Get-BlockFindings -Type $type -Obj $obj)
    }

    $rel = Get-ProtocolRelativeImageCount -Raw $raws
    if ($rel -gt 0) { Write-Host ("  -> {0}x protocol-relative image URL in schema" -f $rel) -ForegroundColor Yellow }
}

Write-Host ""
if ($invalid -eq 0 -and $themeFaults -eq 0) {
    Write-Host ("{0} block(s) tested over {1} page(s), all valid." -f $blocks, $targets.Count) -ForegroundColor Green
    exit 0
}
Write-Host ("{0} block(s) tested, {1} invalid or unfetched, {2} page(s) with the wrong theme." -f $blocks, $invalid, $themeFaults) -ForegroundColor Red
exit 1
