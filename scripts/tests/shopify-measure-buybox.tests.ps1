<#
.SYNOPSIS
    Tests for dkj-subagents-shopify's measure-buybox: the pure rules in scripts/lib/measure-buybox-rules.ps1,
    the seam read, and the driver end to end against a stand-in node (issue #4290).

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell. Exit code 0 if everything passes, 1 on a failure.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/shopify-measure-buybox.tests.ps1

    No network and no Chrome. The driver runs against a stand-in node.cmd placed first on PATH (the way
    shopify-live-direct-writes.tests.ps1 stands in for gh): it logs what it was asked and answers canned
    harness JSON, so the whole script -- seam, address, harness call, verdict, exit code -- is driven
    without a browser. That part runs on Windows only, because the stand-in is a .cmd.

    Why this script deserves tests: measure-buybox is a MEASUREMENT, and a wrong one reads as a met
    requirement. Four things can go wrong silently:

      1. THE WRONG WIDTH. A viewport that did not take reads as the requested one. The report names
         requested and measured width, and a verdict meant for one width is never printed for another.
      2. A VERDICT WITHOUT AN EXPECTATION, or a hard-coded one. The limit is the store's (the seam); with
         none given the run measures only and says so.
      3. THE THEME LEAKING BACK INTO THE MECHANISM. The harness must hold no selector of any theme: they
         arrive as input. A static check guards that.
      4. A SKIPPED RUN READ AS GREEN. node absent is a refusal, a failed or hung node is a failure.

    Made-up fixtures only (this repo is public): no real store name, domain, selector or id.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot   = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Plugin     = Join-Path $RepoRoot 'plugins\dkj-subagents\dkj-subagents-shopify'
$Lib        = Join-Path $Plugin 'scripts\lib'
$Script     = Join-Path $Plugin 'scripts\task\measure-buybox.ps1'
$Harness    = Join-Path $Plugin 'scripts\task\measure-buybox.harness.js'
$RulesLib   = Join-Path $Lib 'measure-buybox-rules.ps1'
$PsExe      = (Get-Command powershell -CommandType Application | Select-Object -First 1).Source

. (Join-Path $Lib 'command-probe-lib.ps1')
. (Join-Path $Lib 'check-report-lib.ps1')
. (Join-Path $Lib 'which-theme-rules.ps1')
. (Join-Path $Lib 'storefront-markets-lib.ps1')
. $RulesLib

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

$fullSeam = @{
    BoxSelector    = 'div.buy-box'
    AtcSelector    = '.buy-box__atc'
    BlockSelectors = @('.buy-box__title', '.buy-box__price')
    StickySelector = '.sticky-atc'
    AtcMaxTop      = 260
    AtWidth        = 390
}

# A measurement as the harness prints it, made up.
function New-Measurement {
    param([int]$InnerWidth = 390, $AtcTop = 250, $Sticky = $null, [string]$Title = 'A product')
    $m = [ordered]@{
        innerWidth = $InnerWidth; viewportHeight = 900; mobileMQ = ($InnerWidth -le 749); title = $Title
        page   = [ordered]@{ buyBoxTop = 651; atcFromPageTop = if ($null -eq $AtcTop) { $null } else { 651 + $AtcTop } }
        sticky = $Sticky
        order  = @([ordered]@{ cls = 'buy-box__title'; top = 0; h = 40 }, [ordered]@{ cls = 'buy-box__atc'; top = $AtcTop; h = 48 })
        blocks = [ordered]@{ '.buy-box__atc' = $(if ($null -eq $AtcTop) { $null } else { [ordered]@{ top = $AtcTop; h = 48 } }); '.buy-box__title' = [ordered]@{ top = 0; h = 40 }; '.buy-box__gone' = $null }
        atc    = $(if ($null -eq $AtcTop) { $null } else { [ordered]@{ top = $AtcTop; h = 48 } })
    }
    return (($m | ConvertTo-Json -Depth 6 -Compress) | ConvertFrom-Json)
}

$fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("measure-buybox-fixture-" + [guid]::NewGuid().ToString('N'))
$bareFixture = Join-Path ([System.IO.Path]::GetTempPath()) ("measure-buybox-bare-" + [guid]::NewGuid().ToString('N'))
$brokenFixture = Join-Path ([System.IO.Path]::GetTempPath()) ("measure-buybox-broken-" + [guid]::NewGuid().ToString('N'))
$noExpFixture = Join-Path ([System.IO.Path]::GetTempPath()) ("measure-buybox-noexp-" + [guid]::NewGuid().ToString('N'))
$prevPath = $env:PATH
try {
    foreach ($d in @($fixture, $bareFixture, $brokenFixture, $noExpFixture)) { New-Item -ItemType Directory -Path (Join-Path $d 'scripts') -Force | Out-Null }
    Set-Content -LiteralPath (Join-Path $fixture 'scripts\repo-config.ps1') -Encoding ASCII -Value @'
function Get-StorefrontMarkets {
    @(
        @{ Market = 'nl'; Domain = 'shop.example.nl'; PathPrefix = '' },
        [pscustomobject]@{ Market = 'de'; Domain = 'www.example.com'; PathPrefix = '/de' }
    )
}
function Get-ShopifyBuyBox {
    @{
        BoxSelector    = 'div.buy-box'
        AtcSelector    = '.buy-box__atc'
        BlockSelectors = @('.buy-box__title', '.buy-box__price')
        StickySelector = '.sticky-atc'
        AtcMaxTop      = 260
        AtWidth        = 390
    }
}
'@
    Set-Content -LiteralPath (Join-Path $noExpFixture 'scripts\repo-config.ps1') -Encoding ASCII -Value @'
function Get-ShopifyBuyBox { @{ BoxSelector = 'div.buy-box'; AtcSelector = '.buy-box__atc' } }
'@
    Set-Content -LiteralPath (Join-Path $brokenFixture 'scripts\repo-config.ps1') -Encoding ASCII -Value 'function Get-ShopifyBuyBox { throw "typo in the store config" }'

    Write-Group '1. the seam read'
    $ans = Get-BuyBoxSeamAnswer -RepoRoot $fixture
    Assert-True ($ans -is [System.Collections.IDictionary] -and $ans.BoxSelector -eq 'div.buy-box') 'an answered seam comes back as the hashtable the store wrote'
    Assert-True ($null -eq (Get-BuyBoxSeamAnswer -RepoRoot $bareFixture)) 'no repo-config.ps1: unanswered ($null)'
    Assert-True ($null -eq (Get-BuyBoxSeamAnswer -RepoRoot $brokenFixture)) 'a seam that throws degrades to unanswered instead of taking the script down'

    Write-Group '2. the seam answer made into one config'
    $c = Resolve-BuyBoxConfig -Seam $fullSeam
    Assert-Equal 'div.buy-box' $c.BoxSelector 'box selector'
    Assert-Equal '.buy-box__atc' $c.AtcSelector 'ATC selector'
    Assert-Equal '.sticky-atc' $c.StickySelector 'sticky selector'
    Assert-Equal 260 $c.AtcMaxTop 'expectation'
    Assert-Equal 390 $c.AtWidth 'width the expectation applies to'
    Assert-Equal 749 $c.MobileMaxWidth 'mobile breakpoint defaults to 749'
    Assert-Equal '.buy-box__atc' $c.BlockSelectors[0] 'the ATC button is always among the measured blocks, first'
    Assert-Equal 3 @($c.BlockSelectors).Count 'ATC plus the two listed blocks'
    $c2 = Resolve-BuyBoxConfig -Seam ([pscustomobject]@{ BoxSelector = 'b'; AtcSelector = 'a'; BlockSelectors = 'a' })
    Assert-Equal 1 @($c2.BlockSelectors).Count 'a block list that already holds the ATC selector does not repeat it, and a lone string is a list of one'
    Assert-True ($null -eq $c2.AtcMaxTop -and $null -eq $c2.AtWidth -and $c2.StickySelector -eq '') 'an object answer works, and the optional keys default to nothing'

    $e = Get-Threw { Resolve-BuyBoxConfig -Seam $null }
    Assert-True ($e -match 'Get-ShopifyBuyBox' -and $e -match 'BoxSelector' -and $e -match 'AtcSelector' -and $e -match 'AtcMaxTop') 'unanswered and no overrides: the message names the seam and its row shape'
    $e = Get-Threw { Resolve-BuyBoxConfig -Seam $null -BoxSelector 'b' }
    Assert-True ($e -match 'AtcSelector') 'one override is not enough: the missing half is named'
    $o = Resolve-BuyBoxConfig -Seam $null -BoxSelector 'b' -AtcSelector 'a'
    Assert-True ($o.BoxSelector -eq 'b' -and $o.AtcSelector -eq 'a' -and $null -eq $o.AtcMaxTop) 'both overrides: no seam needed, and no expectation'
    $o = Resolve-BuyBoxConfig -Seam $fullSeam -BoxSelector 'override-box'
    Assert-True ($o.BoxSelector -eq 'override-box' -and $o.AtcSelector -eq '.buy-box__atc' -and $o.AtcMaxTop -eq 260) 'an override wins over the seam for that one key; the rest stays the seam'
    Assert-True ($null -ne (Get-Threw { Resolve-BuyBoxConfig -Seam @{ BoxSelector = 'b'; AtcSelector = 'a'; AtcMaxTop = 200 } })) 'AtcMaxTop without AtWidth is refused'
    Assert-True ($null -ne (Get-Threw { Resolve-BuyBoxConfig -Seam @{ BoxSelector = 'b'; AtcSelector = 'a'; AtWidth = 390 } })) 'AtWidth without AtcMaxTop is refused'
    Assert-True ($null -ne (Get-Threw { Resolve-BuyBoxConfig -Seam @{ BoxSelector = 'b'; AtcSelector = 'a'; AtcMaxTop = 'tall'; AtWidth = 390 } })) 'a non-numeric AtcMaxTop is refused'
    Assert-True ($null -ne (Get-Threw { Resolve-BuyBoxConfig -Seam @{ BoxSelector = "b`nc"; AtcSelector = 'a' } })) 'a multi-line selector is refused'
    Assert-True ($null -ne (Get-Threw { Resolve-BuyBoxConfig -Seam @(1, 2) })) 'a seam that answers a list instead of one hashtable is refused'
    Assert-Equal 600 (Resolve-BuyBoxConfig -Seam @{ BoxSelector = 'b'; AtcSelector = 'a'; MobileMaxWidth = 600 }).MobileMaxWidth 'MobileMaxWidth is read from the seam'

    Write-Group '3. the address'
    $rows = @(Get-StorefrontMarketRows -RepoRoot $fixture)
    Assert-Equal 'https://x.example/p' (Get-MeasureUrl -Url 'https://x.example/p') '-Url passes through'
    Assert-Equal 'https://shop.example.nl/products/a' (Get-MeasureUrl -Market 'NL' -Path '/products/a' -MarketRows $rows) '-Market is case-insensitive and builds https://<Domain><path>'
    Assert-Equal 'https://www.example.com/de/products/a' (Get-MeasureUrl -Market 'de' -Path '/products/a' -MarketRows $rows) 'a market with a path prefix puts the prefix in'
    $pu = Get-MeasureUrl -Market 'nl' -Path '/products/a' -PreviewThemeId '123' -MarketRows $rows
    Assert-True ($pu -match '\?preview_theme_id=123&_ab=0&_fd=0&_sc=1$') 'a preview theme carries the full preview parameters, not the id alone'
    Assert-True ((Get-Threw { Get-MeasureUrl -Market 'BE' -Path '/p' -MarketRows $rows }) -match "Unknown market 'BE'") 'an unknown market is refused with the known ones named'
    Assert-True ($null -ne (Get-Threw { Get-MeasureUrl -Url 'ftp://x' })) 'a non-http address is refused'
    Assert-True ($null -ne (Get-Threw { Get-MeasureUrl -Market 'nl' -Path 'products/a' -MarketRows $rows })) 'a path without a leading slash is refused'
    Assert-True ($null -ne (Get-Threw { Get-MeasureUrl })) 'nothing to build from is refused'

    Write-Group '4. harness input and output'
    $b64 = ConvertTo-BuyBoxInput -Config $c
    $back = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64)) | ConvertFrom-Json
    Assert-Equal 'div.buy-box' $back.boxSelector 'the input carries the box selector'
    Assert-Equal '.buy-box__atc' $back.atcSelector 'the input carries the ATC selector'
    Assert-Equal 3 @($back.blockSelectors).Count 'the input carries the block list'
    Assert-Equal '.sticky-atc' $back.stickySelector 'the input carries the sticky selector'
    Assert-True ($b64 -match '^[A-Za-z0-9+/=]+$') 'it is one base64 token: no shell or Start-Process quoting rule can touch it'
    $cq = Resolve-BuyBoxConfig -Seam @{ BoxSelector = "a[data-x=""y z""]"; AtcSelector = "b'c" }
    $bq = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((ConvertTo-BuyBoxInput -Config $cq))) | ConvertFrom-Json
    Assert-True ($bq.boxSelector -eq 'a[data-x="y z"]' -and $bq.atcSelector -eq "b'c") 'quotes and brackets in a selector survive the round trip'
    Assert-Equal '{"a":2}' (Get-BuyBoxJsonLine -Lines @('diag', '{"a":1}', '  {"a":2}', 'trailing noise')) 'the LAST line that is a JSON object is the measurement'
    Assert-True ($null -eq (Get-BuyBoxJsonLine -Lines @('only diagnostics'))) 'no JSON line: $null'
    Assert-True ($null -eq (Get-BuyBoxJsonLine -Lines $null)) 'no output at all: $null'

    Write-Group '5. the verdict'
    $v = Get-BuyBoxVerdict -Measurement (New-Measurement -AtcTop 250) -Config $c
    Assert-True ($v.State -eq 'Pass' -and $v.Text -match '^PASS') 'under the limit at the right width: PASS'
    $v = Get-BuyBoxVerdict -Measurement (New-Measurement -AtcTop 260) -Config $c
    Assert-Equal 'Pass' $v.State 'exactly at the limit passes (the expectation is "at most")'
    $v = Get-BuyBoxVerdict -Measurement (New-Measurement -AtcTop 261) -Config $c
    Assert-True ($v.State -eq 'Fail' -and $v.Text -match '^FAIL') 'one px over: FAIL'
    $v = Get-BuyBoxVerdict -Measurement (New-Measurement -InnerWidth 1920 -AtcTop 700) -Config $c
    Assert-True ($v.State -eq 'NotJudged' -and $v.Text -match '390px' -and $v.Text -match '1920px') 'measured at another width than the expectation applies to: not judged, both widths named'
    $v = Get-BuyBoxVerdict -Measurement (New-Measurement -InnerWidth 1920 -AtcTop 100) -Config $c
    Assert-Equal 'NotJudged' $v.State 'and a good number at the wrong width does not pass either'
    $v = Get-BuyBoxVerdict -Measurement (New-Measurement -AtcTop 999) -Config (Resolve-BuyBoxConfig -Seam @{ BoxSelector = 'b'; AtcSelector = 'a' })
    Assert-True ($v.State -eq 'NoExpectation' -and $v.Text -match 'No expectation') 'no AtcMaxTop: measure only, and it says so'
    $v = Get-BuyBoxVerdict -Measurement (New-Measurement -AtcTop $null) -Config $c
    Assert-Equal 'NoAtc' $v.State 'no ATC element on the page'

    Write-Group '6. the report'
    $sticky = [ordered]@{ position = 'fixed'; top = 820; height = 80; onScreen = $true }
    $r = @(Get-BuyBoxReport -Measurement (New-Measurement -Sticky $sticky) -Config $c -RequestedWidth 390)
    $txt = ($r | ForEach-Object { $_.Text }) -join "`n"
    Assert-True ($txt -match 'viewport : 390px \(mobile media query: True\)') 'the measured viewport is always printed'
    Assert-True ($txt -match 'does NOT say' -and $txt -match 'buy box itself starts at\s+651px' -and $txt -match 'so the ATC button is at\s+901px') 'the "what the offset does not say" block carries the box top and the ATC from the page top'
    Assert-True ($txt -match 'sticky ATC bar \(fixed\s*\)\s+ON SCREEN at 820px, 80px high' -and $txt -match 'pinned on screen') 'a sticky bar on screen is named, with the conclusion it prevents'
    Assert-True ($txt -match 'PASS' -and $txt -match '\.buy-box__gone\s+\(not on this page\)') 'verdict line and a block missing from the page both show'
    $rm = @(Get-BuyBoxReport -Measurement (New-Measurement -InnerWidth 1920 -AtcTop 100) -Config $c -RequestedWidth 390)
    $mm = $rm | Where-Object { $_.Text -match 'MEASURED AT 1920px, REQUESTED 390px' }
    Assert-True ($null -ne $mm -and $mm.Color -eq 'Red') 'a viewport that is not the requested one is a LOUD red line naming both widths'
    $rn = (@(Get-BuyBoxReport -Measurement (New-Measurement) -Config $c -RequestedWidth 390) | ForEach-Object { $_.Text }) -join "`n"
    Assert-True ($rn -match 'sticky ATC bar\s+NONE on this page') 'no sticky bar found where a selector was named: said so'
    $rn2 = (@(Get-BuyBoxReport -Measurement (New-Measurement) -Config (Resolve-BuyBoxConfig -Seam @{ BoxSelector = 'b'; AtcSelector = 'a' }) -RequestedWidth 390) | ForEach-Object { $_.Text }) -join "`n"
    Assert-True ($rn2 -match 'not measured \(the store named no StickySelector\)') 'no sticky selector named: "not measured", never "none on the page"'
    $evil = @(Get-BuyBoxReport -Measurement (New-Measurement -Title "x [ERROR] y`nforged line") -Config $c -RequestedWidth 390)
    $evilText = ($evil | ForEach-Object { $_.Text }) -join "`n"
    Assert-True ($evilText -notmatch '\[ERROR\]' -and $evilText -notmatch 'x \(ERROR\) y\s*\r?\nforged') 'a page title cannot plant a marker or forge a line'
    $err = [pscustomobject]@{ innerWidth = 390; viewportHeight = 900; mobileMQ = $true; title = 't'; error = 'no element matches the box selector on this page' }
    $re = (@(Get-BuyBoxReport -Measurement $err -Config $c -RequestedWidth 390) | ForEach-Object { $_.Text }) -join "`n"
    Assert-True ($re -match 'No buy box found' -and $re -notmatch 'ATC button is') 'no buy box: reported, and no ATC claim made'

    Write-Group '7. the script through powershell -File, -PlanOnly'
    function Invoke-Target {
        param([string[]]$Arguments, [string]$Root = $fixture)
        $out = & $PsExe -NoProfile -ExecutionPolicy Bypass -File $Script @Arguments -RootOverride $Root 2>&1
        return [pscustomobject]@{ Text = (@($out | ForEach-Object { "$_" }) -join "`n"); Code = $LASTEXITCODE }
    }
    $r = Invoke-Target -Arguments @('-Market', 'nl', '-Path', '/products/a', '-PlanOnly')
    Assert-True ($r.Code -eq 0 -and $r.Text -match 'Would measure: https://shop\.example\.nl/products/a' -and $r.Text -match 'box selector : div\.buy-box' -and $r.Text -match 'ATC <= 260px' -and $r.Text -match 'at 390px wide') '-PlanOnly shows the address and the store''s selectors and expectation'
    Assert-True ($r.Text -match 'nothing measured') '-PlanOnly measures nothing'
    $r = Invoke-Target -Arguments @('-Url', 'https://x.example/p', '-PlanOnly', '-AtcSelector', '.other-atc')
    Assert-True ($r.Code -eq 0 -and $r.Text -match 'ATC selector : \.other-atc' -and $r.Text -match 'box selector : div\.buy-box') '-AtcSelector overrides the seam for that key only'
    $r = Invoke-Target -Arguments @('-Url', 'https://x.example/p', '-PlanOnly') -Root $bareFixture
    Assert-True ($r.Code -eq 1 -and $r.Text -match 'REFUSED:' -and $r.Text -match 'Get-ShopifyBuyBox' -and $r.Text -match 'BoxSelector') 'unanswered seam, no overrides: REFUSED, naming the seam and its row shape'
    $r = Invoke-Target -Arguments @('-Url', 'https://x.example/p', '-PlanOnly', '-BoxSelector', 'b', '-AtcSelector', 'a') -Root $bareFixture
    Assert-True ($r.Code -eq 0 -and $r.Text -match 'expectation\s*: \(none given\)') 'both overrides: no seam needed, no expectation'
    $r = Invoke-Target -Arguments @('-Url', 'https://x.example/p', '-PlanOnly') -Root $brokenFixture
    Assert-True ($r.Code -eq 1 -and $r.Text -match 'REFUSED:') 'a seam that throws is an unanswered seam: REFUSED'
    $r = Invoke-Target -Arguments @('-Market', 'nl', '-Path', '/p', '-PlanOnly') -Root $bareFixture
    Assert-True ($r.Code -eq 1 -and $r.Text -match 'REFUSED:' -and $r.Text -notmatch 'Would measure') 'no seam at all: refused before any address is built'
    $r = Invoke-Target -Arguments @('-Market', 'BE', '-Path', '/p', '-PlanOnly')
    Assert-True ($r.Code -eq 1 -and $r.Text -match "REFUSED: Unknown market 'BE'") 'an unknown market is refused'
    $r = Invoke-Target -Arguments @('-Market', 'nl', '-Path', '/p', '-PlanOnly') -Root $noExpFixture
    Assert-True ($r.Code -eq 1 -and $r.Text -match 'market table' -and $r.Text -match 'Get-StorefrontMarkets') 'no market table: refuses and names that seam and -Url'
    $r = Invoke-Target -Arguments @('-Url', 'https://x.example/p', '-PlanOnly')
    Assert-True ($r.Code -eq 0) '-Url needs no market table'

    Write-Group '8. the script end to end against a stand-in node'
    $isWin = ($env:OS -eq 'Windows_NT')
    if (-not $isWin) {
        Write-Host '  [skip] the stand-in node is a .cmd; this group runs on Windows only' -ForegroundColor DarkGray
    } else {
        $bin = Join-Path $fixture 'bin'
        $emptyBin = Join-Path $fixture 'nonode'
        New-Item -ItemType Directory -Path $bin, $emptyBin -Force | Out-Null
        [System.IO.File]::WriteAllText((Join-Path $bin 'node.cmd'), (@(
            '@echo off',
            'echo %*>>"%~dp0node.log"',
            'echo diagnostic line on stderr 1>&2',
            'type "%~dp0answer.txt"',
            'if "%FAKE_NODE_EXIT%"=="" (exit /b 0)',
            'exit /b %FAKE_NODE_EXIT%'
        ) -join "`r`n") + "`r`n", (New-Object System.Text.ASCIIEncoding))
        $log = Join-Path $bin 'node.log'
        $answerFile = Join-Path $bin 'answer.txt'
        function Set-Answer { param($Measurement) [System.IO.File]::WriteAllText($answerFile, (($Measurement | ConvertTo-Json -Depth 6 -Compress) + "`r`n"), (New-Object System.Text.ASCIIEncoding)) }
        function Invoke-WithNode {
            param([string[]]$Arguments, [string]$Root = $fixture)
            if (Test-Path -LiteralPath $log) { Remove-Item -LiteralPath $log }
            $env:PATH = "$bin;$prevPath"
            try { return (Invoke-Target -Arguments $Arguments -Root $Root) } finally { $env:PATH = $prevPath }
        }

        Set-Answer (New-Measurement -AtcTop 250)
        $r = Invoke-WithNode -Arguments @('-Market', 'nl', '-Path', '/products/a')
        Assert-True ($r.Code -eq 0 -and $r.Text -match 'PASS' -and $r.Text -match 'viewport : 390px') 'a measurement under the store''s limit: PASS, exit 0'
        Assert-True ($r.Text -match 'does NOT say') 'the report carries the "what the offset does not say" block'
        $logged = if (Test-Path -LiteralPath $log) { (Get-Content -LiteralPath $log -Raw).Trim() } else { '' }
        $parts = @($logged -split '\s+')
        # %* is logged whole: cmd's own %6 would cut the base64 at its '=' padding, which node does not.
        Assert-True ($parts.Count -eq 6 -and $parts[2] -eq '390' -and $parts[3] -eq '900' -and $parts[4] -eq '5000') 'the harness was called with the requested width, height and settle'
        $sent = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String(($parts[5] -replace '"', ''))) | ConvertFrom-Json
        Assert-True ($sent.boxSelector -eq 'div.buy-box' -and $sent.stickySelector -eq '.sticky-atc' -and @($sent.blockSelectors).Count -eq 3) 'and with the store''s selectors from the seam, as input'

        Set-Answer (New-Measurement -AtcTop 300)
        $r = Invoke-WithNode -Arguments @('-Url', 'https://x.example/p')
        Assert-True ($r.Code -eq 1 -and $r.Text -match 'FAIL') 'over the limit at the right width: FAIL, exit 1'

        Set-Answer (New-Measurement -InnerWidth 1920 -AtcTop 700)
        $r = Invoke-WithNode -Arguments @('-Url', 'https://x.example/p')
        Assert-True ($r.Code -eq 0 -and $r.Text -match 'MEASURED AT 1920px, REQUESTED 390px' -and $r.Text -match 'not judged' -and $r.Text -notmatch 'FAIL: ' -and $r.Text -notmatch 'PASS: ') 'a viewport that did not take: loud warning, no verdict, exit 0'

        Set-Answer (New-Measurement -InnerWidth 1920 -AtcTop 300)
        $r = Invoke-WithNode -Arguments @('-Url', 'https://x.example/p', '-Width', '1920')
        Assert-True ($r.Code -eq 0 -and $r.Text -notmatch 'FAIL: ' -and $r.Text -match 'applies at 390px' -and $r.Text -cnotmatch 'MEASURED AT') 'asked and measured at another width than the expectation applies to: not judged, no width warning'
        Set-Answer (New-Measurement -InnerWidth 390 -AtcTop 300)
        $r = Invoke-WithNode -Arguments @('-Url', 'https://x.example/p', '-Width', '1920')
        Assert-True ($r.Code -eq 1 -and $r.Text -match 'MEASURED AT 390px, REQUESTED 1920px' -and $r.Text -match 'FAIL: ') 'the width compared is the MEASURED one: a viewport stuck at 390 is judged as 390 and warned about'

        $r = Invoke-WithNode -Arguments @('-Url', 'https://x.example/p') -Root $noExpFixture
        Assert-True ($r.Code -eq 0 -and $r.Text -match 'No expectation was given') 'a store with no expectation: measures only, exit 0, says so'

        Set-Answer (New-Measurement -AtcTop $null)
        $r = Invoke-WithNode -Arguments @('-Url', 'https://x.example/p')
        Assert-True ($r.Code -eq 1 -and $r.Text -match 'NOT found') 'no ATC element: exit 1'

        Set-Answer ([pscustomobject]@{ innerWidth = 390; viewportHeight = 900; mobileMQ = $true; title = 't'; error = 'no element matches the box selector on this page' })
        $r = Invoke-WithNode -Arguments @('-Url', 'https://x.example/p')
        Assert-True ($r.Code -eq 1 -and $r.Text -match 'No buy box found') 'no buy box: exit 1'

        Set-Answer (New-Measurement -AtcTop 250)
        $r = Invoke-WithNode -Arguments @('-Url', 'https://x.example/p', '-Json')
        Assert-True ($r.Code -eq 0 -and $r.Text -match '"innerWidth":390' -and $r.Text -notmatch 'PASS') '-Json prints the raw measurement line, no report'

        $env:FAKE_NODE_EXIT = '1'
        try { $r = Invoke-WithNode -Arguments @('-Url', 'https://x.example/p') } finally { Remove-Item Env:\FAKE_NODE_EXIT -ErrorAction SilentlyContinue }
        Assert-True ($r.Code -eq 1 -and $r.Text -match 'did NOT succeed' -and $r.Text -match 'diagnostic line on stderr') 'a node that fails: exit 1, "do not read this as met", and the harness''s own words shown'

        [System.IO.File]::WriteAllText($answerFile, "only diagnostics, no json`r`n", (New-Object System.Text.ASCIIEncoding))
        $r = Invoke-WithNode -Arguments @('-Url', 'https://x.example/p')
        Assert-True ($r.Code -eq 1 -and $r.Text -match 'did NOT succeed') 'exit 0 but no JSON line: still a failure, never a green nothing'

        $env:PATH = "$emptyBin;$env:SystemRoot\System32;$env:SystemRoot\System32\WindowsPowerShell\v1.0"
        try { $r = Invoke-Target -Arguments @('-Url', 'https://x.example/p') } finally { $env:PATH = $prevPath }
        Assert-True ($r.Code -eq 1 -and $r.Text -match 'REFUSED:' -and $r.Text -match 'node is not installed') 'node absent: a hard REFUSED, never a silent skip'
    }

    Write-Group '9. static guards'
    $harnessSrc = Get-Content -LiteralPath $Harness -Raw
    $harnessCode = (($harnessSrc -split "`n") | Where-Object { $_ -notmatch '^\s*//' }) -join "`n"
    Assert-True ($harnessCode -notmatch '(?i)safe-sticky|product-info|buy-buttons|quick-add|variant-picker|__wrap|upsell') 'the harness names no selector of any theme'
    Assert-True ($harnessCode -notmatch 'querySelector(All)?\(\s*[''"`]') 'every querySelector in the harness takes its selector from the input, never a literal'
    Assert-True ($harnessCode -match 'setDeviceMetricsOverride') 'the harness still emulates the viewport through the DevTools Protocol'
    Assert-True ($harnessSrc -notmatch '[^\x00-\x7F]') 'the harness is pure ASCII'
    $src = Get-Content -LiteralPath $Script -Raw
    $code = [regex]::Replace($src, '(?s)<#.*?#>', '')
    $codeLines = @($code -split "`n" | Where-Object { $_ -notmatch '^\s*#' })
    Assert-True (@($codeLines | Where-Object { $_ -match "(?i)#466|safe-sticky|product-info" }).Count -eq 0) 'the driver hard-codes no store selector or store issue number'
    Assert-True (@($codeLines | Where-Object { $_ -match 'Invoke-NativeCapture' -and $_ -match '-TimeoutSeconds' }).Count -ge 1) 'the node call is bounded'
    Assert-True (@($codeLines | Where-Object { $_ -match '^\s*&\s*node\b|^\s*node\s' -or $_ -match '2>&1' }).Count -eq 0) 'no bare native call and no 2>&1 in the driver'
    $msgLines = @($codeLines | Where-Object { $_ -match '\.Exception\.Message' })
    Assert-True ($msgLines.Count -gt 0 -and @($msgLines | Where-Object { $_ -notmatch 'Format-SafeProseToken|Stop-Refused' }).Count -eq 0) 'every exception message the driver prints goes through the prose guard'
    Assert-True ($src -notmatch '[^\x00-\x7F]' -and (Get-Content -LiteralPath $RulesLib -Raw) -notmatch '[^\x00-\x7F]') 'driver and rules lib are pure ASCII'
    $ver = (Get-Command node -ErrorAction SilentlyContinue)
    if ($ver) {
        $chk = & node --check $Harness 2>&1
        Assert-True ($LASTEXITCODE -eq 0) 'the harness passes node --check'
    } else {
        Write-Host '  [skip] node is not installed here: the harness syntax check is skipped (the driver''s own refusal is tested above)' -ForegroundColor DarkGray
    }
}
finally {
    $env:PATH = $prevPath
    foreach ($d in @($fixture, $bareFixture, $brokenFixture, $noExpFixture)) {
        if (Test-Path -LiteralPath $d) { Remove-Item -LiteralPath $d -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

Write-Host ""
Write-Host ("{0} passed, {1} failed" -f $script:pass, $script:fail) -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 }
exit 0
