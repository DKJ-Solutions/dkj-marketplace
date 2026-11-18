<#
.SYNOPSIS
    Establish WHICH theme and WHICH version a storefront page actually serves.

.DESCRIPTION
    When reviewing a preview the question is not "am I in a preview session" but "am I getting the
    content I think I am getting". Those are different things, and the difference produced three wrong
    conclusions in one day:

      1. A homepage still showed the old markup after a live push -- edge cache, not a bug.
      2. A product page showed the old version although the preview parameter was in the URL -- the
         cookie had dropped on an internal link, so it was live.
      3. The same page showed old content while the admin indicator named the right theme -- the
         indicator says something about the SESSION, not about the version of the content.

    This script fetches the page and reports the theme id and theme name Shopify actually sent
    (Shopify embeds them in the HTML). On top of that, -MustContain / -MustNotContain use a piece of
    content as a fingerprint -- the only way to tell a CACHED copy of the right theme from a fresh one.

    When a page fails (an HTTP 500, say) the script also prints the status code, the x-request-id, the
    UTC time and the requested URL. Why: a 500 without its x-request-id cannot be traced by Shopify,
    and a 500 carries no Shopify.theme marker, so the URL with preview_theme_id is the only trace of
    which theme was requested. Put those values on the issue.

    Read-only: it fetches, it never pushes or publishes anything. Exit 0 when there are no deviations,
    1 on any deviation or failure.

    -Path builds its URLs from the store's own market table: the optional Get-StorefrontMarkets seam in
    the repo's scripts/repo-config.ps1 (rows with Market, Domain and PathPrefix). Nothing is shipped
    here, because the market table is per store. Unanswered, -Path refuses and names -Url.

    Moved here from a store repo (#4289), together with fetch-failure.ps1.

.PARAMETER Url
    Full URL(s). Preview parameters are added when you also pass -ThemeId.

.PARAMETER Path
    Path(s) such as '/' or '/products/foo', across every market the store's Get-StorefrontMarkets
    seam lists.

.PARAMETER ThemeId
    Theme id whose preview you want to see. Added to the URL together with the three extra parameters
    the admin sends itself (_ab=0&_fd=0&_sc=1). They are not decoration: with preview_theme_id alone
    the preview drops as soon as you click through, and you silently get live.

.PARAMETER ExpectThemeId
    Fail (exit 1) when a page serves a different theme than this id. Without it the script is purely
    informative.

.PARAMETER MustContain
    Text that must appear in the HTML. Use something that ONLY exists in the new version and it
    unmasks a cached copy. Fails (exit 1) when missing.

.PARAMETER MustNotContain
    Text that must NOT appear, for example markup you just removed.

.PARAMETER NoCache
    Append a unique parameter to the URL to bypass caches. Useful to establish WHETHER you are looking
    at a cache: fetch the same page once with and once without.

.PARAMETER RootOverride
    A fixture root for the seam read; a consumer never types it.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/which-theme.ps1 -Path '/products/foo' -ThemeId 123456789012 -ExpectThemeId 123456789012

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/which-theme.ps1 -Url 'https://your-store.example/products/foo' -MustNotContain 'old-markup-class'

.NOTES
    Pure ASCII (repo convention for .ps1): Windows PowerShell 5.1 reads a BOM-less script as ANSI.

    No native exe here, so no stderr trap -- everything goes through Invoke-WebRequest.
#>
[CmdletBinding(DefaultParameterSetName = 'Path')]
param(
    [Parameter(ParameterSetName = 'Url', Mandatory = $true)][string[]]$Url,
    [Parameter(ParameterSetName = 'Path')][string[]]$Path = @('/'),
    [string]$ThemeId,
    [string]$ExpectThemeId,
    [string[]]$MustContain,
    [string[]]$MustNotContain,
    [switch]$NoCache,
    [string]$RootOverride = ''
)
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\command-probe-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\check-report-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\fetch-failure.ps1')
. (Join-Path $PSScriptRoot '..\lib\which-theme-rules.ps1')

$markets = @()
if ($PSCmdlet.ParameterSetName -ne 'Url') {
    # The seam is read in a child scope with StrictMode off and inside a try, as this plugin's other
    # scripts read repo-config.ps1: the file belongs to the consumer, so a fault in it must degrade to
    # "unanswered" rather than take this script down.
    $repoRoot = Resolve-RepoRootOrFail -Override $RootOverride -ScriptName 'which-theme.ps1' -OverrideName '-RootOverride'
    $repoRoot = ([string]$repoRoot).Trim() -replace '/', '\'
    $markets = @(& {
        Set-StrictMode -Off
        $configPath = Join-Path $args[0] 'scripts\repo-config.ps1'
        if (Test-Path -LiteralPath $configPath -PathType Leaf) {
            try { . $configPath } catch { }
        }
        if (Test-FunctionDefined 'Get-StorefrontMarkets') { return @(Get-StorefrontMarkets) }
    } $repoRoot)
}

try {
    # @() keeps .Count valid for a single page in Windows PowerShell 5.1, where an unrolled single
    # object has no .Count and the summary count would print empty.
    $rows = @(Get-ProbeTargets -Url $Url -Path $Path -Markets $markets)
}
catch {
    Write-Host "REFUSED: $(Format-SafeProseToken -Value $_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$failures = 0
foreach ($row in $rows) {
    $target = Get-ProbeUrl -Target $row.Target -ThemeId $ThemeId -NoCache:$NoCache

    Write-Host ""
    Write-Host "===== $($row.Label)"
    Write-Host "      $target"

    $html = $null
    try {
        $html = (Invoke-WebRequest -Uri $target -UseBasicParsing -TimeoutSec 60).Content
    }
    catch {
        # Exception messages can carry strange text: strip control and format characters before printing.
        $safeMessage = [regex]::Replace([string]$_.Exception.Message, '\p{C}', ' ')
        Write-Host "  FETCH FAILED: $safeMessage" -ForegroundColor Red
        $evidence = Get-FetchFailureEvidence -ErrorRecord $_ -Url $target
        $statusText = if ($null -ne $evidence.StatusCode) { $evidence.StatusCode } else { '(no HTTP response)' }
        $idText = if ($evidence.RequestId) { $evidence.RequestId } else { '(not sent)' }
        Write-Host "      status code  : $statusText"
        Write-Host "      x-request-id : $idText"
        Write-Host "      time (UTC)   : $($evidence.TimeUtc)"
        Write-Host "      url          : $($evidence.Url)"
        if ($evidence.StatusCode -ge 500 -and $evidence.StatusCode -le 599) {
            Write-Host "      Put these values on the issue; without the x-request-id Shopify cannot trace the error." -ForegroundColor Yellow
        }
        $failures++
        continue
    }

    # Shopify's bot protection is itself valid HTML, so without this check the page would look as if it
    # simply held nothing.
    if (Test-BotProtection -Html $html) {
        Write-Host "  BOT PROTECTION (429-like): not a real page. Wait a while and fetch fewer pages per run." -ForegroundColor Yellow
        $failures++
        continue
    }

    $served = Get-ServedTheme -Html $html
    if ($served.Id) {
        $nameText = if ($served.Name) { " ('$($served.Name)')" } else { '' }
        Write-Host ("  theme served    : {0}{1}" -f $served.Id, $nameText)
    }
    else {
        # The live theme does not always send this field; that is information, not an error.
        Write-Host "  theme served    : (not found in the HTML -- usual on the live theme)"
    }

    if ($ExpectThemeId) {
        if ($served.Id -eq $ExpectThemeId) {
            Write-Host "  expected theme  : OK"
        }
        else {
            Write-Host "  expected theme  : FAIL -- expected $ExpectThemeId, got '$($served.Id)'" -ForegroundColor Red
            $failures++
        }
    }

    foreach ($needle in $MustContain) {
        if ((Test-Fingerprint -Html $html -Needle $needle -Kind Contain).Ok) {
            Write-Host "  contains        : OK   '$needle'"
        }
        else {
            Write-Host "  contains        : FAIL '$needle' is missing -- old or cached content?" -ForegroundColor Red
            $failures++
        }
    }
    foreach ($needle in $MustNotContain) {
        if ((Test-Fingerprint -Html $html -Needle $needle -Kind NotContain).Ok) {
            Write-Host "  contains NOT    : OK   '$needle'"
        }
        else {
            Write-Host "  contains NOT    : FAIL '$needle' is present -- old or cached content?" -ForegroundColor Red
            $failures++
        }
    }
}

Write-Host ""
if ($failures -eq 0) {
    Write-Host "$($rows.Count) page(s) checked, no deviations." -ForegroundColor Green
    exit 0
}
Write-Host "$($rows.Count) page(s) checked, $failures deviation(s)." -ForegroundColor Red
exit 1
