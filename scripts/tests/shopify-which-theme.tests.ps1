<#
.SYNOPSIS
    Tests for dkj-subagents-shopify's which-theme: the pure rules in scripts/lib/which-theme-rules.ps1 and
    the evidence extraction in scripts/lib/fetch-failure.ps1 (issue #4289).

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell. Exit code 0 if everything passes, 1 on a failure.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/shopify-which-theme.tests.ps1

    No network: the script itself fetches pages and is not driven. Everything that can be wrong without
    one is a function here -- URL building, the market rows, the served theme read out of the HTML,
    bot-protection detection, fingerprints -- and the failure evidence is built from mocked exceptions.
    Made-up fixtures only (this repo is public): no real store name, domain or theme id.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Plugin   = Join-Path $RepoRoot 'plugins\dkj-subagents\dkj-subagents-shopify'
$RulesLib = Join-Path $Plugin 'scripts\lib\which-theme-rules.ps1'
$FetchLib = Join-Path $Plugin 'scripts\lib\fetch-failure.ps1'
$Script   = Join-Path $Plugin 'scripts\task\which-theme.ps1'

. $RulesLib
. $FetchLib

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
function Write-Group { param([string]$Title) Write-Host ""; Write-Host "== $Title" -ForegroundColor Cyan }
function Get-Threw { param([scriptblock]$Block) try { & $Block | Out-Null; return $null } catch { return $_.Exception.Message } }

Write-Group '1. Add-Query picks ? or & by whether the URL already has a query'
Assert-Equal 'https://x.example/a?b=1' (Add-Query -Target 'https://x.example/a' -Query 'b=1') 'no query yet: ?'
Assert-Equal 'https://x.example/a?c=2&b=1' (Add-Query -Target 'https://x.example/a?c=2' -Query 'b=1') 'has a query: &'
Assert-Equal 'https://x.example/a' (Add-Query -Target 'https://x.example/a' -Query '') 'empty query: unchanged'

Write-Group '2. Get-ProbeUrl: preview parameters and cache buster'
$u = Get-ProbeUrl -Target 'https://x.example/p' -ThemeId '123'
Assert-Equal 'https://x.example/p?preview_theme_id=123&_ab=0&_fd=0&_sc=1' $u 'ThemeId adds preview_theme_id and the three admin parameters'
$u = Get-ProbeUrl -Target 'https://x.example/p' -NoCache -CacheBuster 'abc'
Assert-Equal 'https://x.example/p?cachebust=abc' $u 'NoCache adds the buster'
$u = Get-ProbeUrl -Target 'https://x.example/p' -ThemeId '123' -NoCache -CacheBuster 'abc'
Assert-Equal 'https://x.example/p?preview_theme_id=123&_ab=0&_fd=0&_sc=1&cachebust=abc' $u 'both: the buster joins with &'
Assert-True ((Get-ProbeUrl -Target 'https://x.example/p' -NoCache) -match 'cachebust=[0-9a-f]{12}$') 'a generated buster is 12 hex characters'
Assert-Equal 'https://x.example/p' (Get-ProbeUrl -Target 'https://x.example/p') 'neither: unchanged'

Write-Group '3. Get-ProbeTargets from -Url'
$t = @(Get-ProbeTargets -Url @('https://a.example/', 'https://b.example/'))
Assert-Equal 2 $t.Count 'one row per URL'
Assert-Equal 'https://a.example/' $t[0].Target 'the URL is the target'
$t = @(Get-ProbeTargets -Url @('https://a.example/'))
Assert-Equal 1 $t.Count 'a single URL still counts as 1 (the @() wrap)'

Write-Group '4. Get-ProbeTargets from market rows (hashtables and objects)'
$markets = @(
    @{ Market = 'de'; Domain = 'shop.example.de'; PathPrefix = '' },
    [pscustomobject]@{ Market = 'NL'; Domain = 'www.example.com'; PathPrefix = '/nl' }
)
$t = @(Get-ProbeTargets -Path @('/products/foo') -Markets $markets)
Assert-Equal 2 $t.Count 'one row per market'
Assert-Equal 'https://shop.example.de/products/foo' $t[0].Target 'domain market: no prefix'
Assert-Equal 'https://www.example.com/nl/products/foo' $t[1].Target 'prefixed market: prefix then path'
Assert-Equal 'DE  /products/foo' $t[0].Label 'label: upper-case market and path'
$t = @(Get-ProbeTargets -Path @('/') -Markets $markets)
Assert-Equal 'https://www.example.com/nl' $t[1].Target 'root path on a prefixed market has no trailing slash'
Assert-Equal 'https://shop.example.de/' $t[0].Target 'root path on a domain market keeps the slash'
$t = @(Get-ProbeTargets -Path @('products/foo') -Markets $markets)
Assert-Equal 'https://shop.example.de/products/foo' $t[0].Target 'a path without a leading slash gets one'
$t = @(Get-ProbeTargets -Path @('/a', '/b') -Markets $markets)
Assert-Equal 4 $t.Count 'paths cross markets'

Write-Group '5. Get-ProbeTargets refusals'
$m = Get-Threw { Get-ProbeTargets -Path @('/') -Markets @() }
Assert-True ($m -match 'Get-StorefrontMarkets' -and $m -match '-Url') 'an unanswered seam names the seam and -Url'
$m = Get-Threw { Get-ProbeTargets -Path @('/') -Markets @(@{ Market = 'DE'; Domain = 'https://x.example' }) }
Assert-True ($m -match 'scheme') 'a scheme in Domain is refused'
$m = Get-Threw { Get-ProbeTargets -Path @('/') -Markets @(@{ Market = 'DE'; Domain = 'x.example/' }) }
Assert-True ($m -match 'trailing slash') 'a trailing slash in Domain is refused'
$m = Get-Threw { Get-ProbeTargets -Path @('/') -Markets @(@{ Domain = 'x.example' }) }
Assert-True ($m -match 'Market label') 'a row without Market is refused'
$m = Get-Threw { Get-ProbeTargets -Path @('/') -Markets @(@{ Market = 'DE' }) }
Assert-True ($m -match 'no Domain') 'a row without Domain is refused'

Write-Group '6. Get-ServedTheme reads id and name'
$html = '<script>var Shopify = {}; Shopify.theme = {"name":"x"}; window.x = {"theme":{"id":123456,"name":"my-preview","role":"unpublished"}};</script>'
$s = Get-ServedTheme -Html $html
Assert-Equal '123456' $s.Id 'id'
Assert-Equal 'my-preview' $s.Name 'name'
$s = Get-ServedTheme -Html '{"theme" : { "id" : 42 , "name":"a b"}}'
Assert-Equal '42' $s.Id 'whitespace tolerant: id'
$s = Get-ServedTheme -Html '<html>no marker here</html>'
Assert-Equal '' $s.Id 'absent: empty id'
Assert-Equal '' $s.Name 'absent: empty name'

Write-Group '7. Test-BotProtection'
Assert-True (Test-BotProtection -Html '<title>Verifying your connection</title>') 'challenge text'
Assert-True (Test-BotProtection -Html 'window._cf_chl_opt = {}') 'challenge script'
Assert-True (-not (Test-BotProtection -Html '<html>a normal page</html>')) 'a normal page is not flagged'

Write-Group '8. Test-Fingerprint, both directions'
$page = '<div class="new-markup">x</div>'
Assert-True (Test-Fingerprint -Html $page -Needle 'new-markup' -Kind Contain).Ok 'Contain: present is ok'
Assert-True (-not (Test-Fingerprint -Html $page -Needle 'old-markup' -Kind Contain).Ok) 'Contain: missing fails'
Assert-True (Test-Fingerprint -Html $page -Needle 'old-markup' -Kind NotContain).Ok 'NotContain: absent is ok'
Assert-True (-not (Test-Fingerprint -Html $page -Needle 'new-markup' -Kind NotContain).Ok) 'NotContain: present fails'
Assert-True (Test-Fingerprint -Html 'a?b*c' -Needle '?' -Kind Contain).Ok 'a needle is literal, never a wildcard'

Write-Group '9. Get-FetchFailureEvidenceFromParts'
$e = Get-FetchFailureEvidenceFromParts -StatusCode 500 -Headers @{ 'X-Request-Id' = 'abc-123' } -Url 'https://x.example/p'
Assert-Equal 500 $e.StatusCode 'status'
Assert-Equal 'abc-123' $e.RequestId 'header name is case-insensitive'
Assert-Equal 'https://x.example/p' $e.Url 'url'
Assert-True ($e.TimeUtc -match '^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ$') 'time is UTC ISO'
$e = Get-FetchFailureEvidenceFromParts -StatusCode ([System.Net.HttpStatusCode]::BadGateway) -Headers @{} -Url 'u'
Assert-Equal 502 $e.StatusCode 'an enum status becomes its number'
Assert-True ($null -eq $e.RequestId) 'no header: no id'
$e = Get-FetchFailureEvidenceFromParts -StatusCode 500 -Headers @{ 'x-request-id' = ('ab' + [char]13 + [char]10 + 'c' + [char]0x200B + 'd') } -Url 'u'
Assert-True ($e.RequestId -notmatch '\p{C}') 'control and format characters are stripped'
$e = Get-FetchFailureEvidenceFromParts -StatusCode 500 -Headers @{ 'x-request-id' = ('z' * 300) } -Url 'u'
Assert-Equal 128 $e.RequestId.Length 'the id is capped at 128'
$e = Get-FetchFailureEvidenceFromParts -StatusCode 500 -Headers @{ 'x-request-id' = @('a', 'b') } -Url 'u'
Assert-Equal 'a,b' $e.RequestId 'multiple values are joined'
$whc = New-Object System.Net.WebHeaderCollection
$whc.Add('x-request-id', 'web-1')
$e = Get-FetchFailureEvidenceFromParts -StatusCode 500 -Headers $whc -Url 'u'
Assert-Equal 'web-1' $e.RequestId 'a WebHeaderCollection works'

Write-Group '10. Get-FetchFailureEvidence from mocked errors'
$resp = [pscustomobject]@{ StatusCode = 503; Headers = @{ 'x-request-id' = 'rid-9' } }
$ex = New-Object psobject -Property @{ Response = $resp; Message = 'boom' }
$e = Get-FetchFailureEvidence -ErrorRecord $ex -Url 'https://x.example/q'
Assert-Equal 503 $e.StatusCode 'a bare exception with a Response'
Assert-Equal 'rid-9' $e.RequestId 'its request id'
$caught = $null
try { throw [System.Net.WebException]::new('no response') } catch { $caught = $_ }
$e = Get-FetchFailureEvidence -ErrorRecord $caught -Url 'https://x.example/q'
Assert-True ($null -eq $e.StatusCode) 'a real ErrorRecord with no response: status is null'
Assert-Equal 'https://x.example/q' $e.Url 'the url is kept'
$e = Get-FetchFailureEvidence -ErrorRecord $null -Url 'u'
Assert-True ($null -eq $e.StatusCode) '$null input never throws'

Write-Group '11. the files are English, ASCII and read the seam themselves'
foreach ($p in @($RulesLib, $FetchLib, $Script)) {
    $bytes = [System.IO.File]::ReadAllBytes($p)
    $nonAscii = @($bytes | Where-Object { $_ -gt 127 }).Count
    Assert-Equal 0 $nonAscii ("{0} is pure ASCII" -f (Split-Path -Leaf $p))
}
$src = Get-Content -LiteralPath $Script -Raw
Assert-True ($src -match 'Get-StorefrontMarkets') 'the script reads the store''s own market seam'
Assert-True (-not ($src -match 'market-domains|market-urls')) 'the script depends on no bwj lib'
Assert-True (-not ($src -match 'shopify theme push')) 'read-only: no push anywhere'

Write-Host ''
Write-Host ("{0} passed, {1} failed" -f $script:pass, $script:fail) -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 }
exit 0
