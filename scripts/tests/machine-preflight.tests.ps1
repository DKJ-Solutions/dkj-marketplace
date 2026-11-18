<#
.SYNOPSIS
    Contract tests for the machine-preflight lib that dkj-repo-workflow-bwj ships -- the Shopify CLI
    presence test and the repair text a refusal prints.

.DESCRIPTION
    Run:
        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/machine-preflight.tests.ps1

    WHAT THIS GUARDS. A store's start-task, pre-task sync and release cut all have to answer "is the
    Shopify CLI reachable from this profile?" and print the SAME repair, because the repair is the whole
    value of the refusal. The lib is where that lives; these cases hold its two functions.

    THE PATH HALF OF THE REPAIR is why it is two steps and not one: 'npm i -g @shopify/cli' succeeds and
    'shopify' still does not resolve on a profile that has never had a global npm package, because npm's
    global bin is not on the user PATH at all. A repair naming only the install sends the reader back to
    the same refusal with nothing changed.

    A RESOLUTION IS NOT AN INVOCATION: an interrupted install leaves npm's extensionless 'shopify' sh shim
    in place with the .cmd and .ps1 shims still under staging names. Get-Command resolves the first as an
    Application PowerShell cannot run. The staged-folder cases below rebuild that state and then the whole
    one, so the filter is shown not to have become a refusal of everything.

    THE STORE IS A SEAM, NEVER A LITERAL: the repair names the store from Get-ShopifyStoreDomain when the
    caller has it, and a placeholder otherwise, so the lib that ships to every store names no store's
    domain. WHAT IS NOT HERE: the machine-state assert (is the CLI on THIS box) and the git credential
    case. Those describe a store's machine, not this lib, and stay in the stores.

    Exit 0 = green. Dependency-free; no Pester. Pure ASCII.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$BwjRoot  = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\extensions\dkj-repo-workflow-bwj'
. (Join-Path $BwjRoot 'scripts\tests\test-lib.ps1')
trap { Add-SuiteFault $_ ; continue }

$libPath = Join-Path $BwjRoot 'scripts\lib\machine-preflight.ps1'
Write-SuiteHeader 'machine-preflight.ps1 (dkj-repo-workflow-bwj)'

Write-Case 'the lib exists and defines both functions'
Assert-True (Test-Path -LiteralPath $libPath) 'machine-preflight.ps1 ships in the extension'
$libText = Get-Content -LiteralPath $libPath -Raw
Assert-Match $libText 'function Test-ShopifyCliPresent'    'it defines the presence test'
Assert-Match $libText 'function Get-ShopifyCliRepairLines' 'and the repair text, as its single owner'
. $libPath

Write-Case 'the repair is two steps plus the interactive auth leg, and names the store from the seam'
$repair = ((Get-ShopifyCliRepairLines) -join "`n")
Assert-Match $repair 'npm i -g @shopify/cli' 'the repair names the install'
Assert-Match $repair 'PATH'                  'and the PATH step, which the install does not do'
Assert-Match $repair 'RESTART'               'and that a running shell will not see the new PATH'
Assert-Match $repair 'shopify theme list'    'and the auth leg, which is interactive'
Assert-Match $repair '<your-store>.myshopify.com' 'with no seam in scope the store is a placeholder'
Assert-NoMatch $repair 'xoxo' 'and never a real store'
$explicit = ((Get-ShopifyCliRepairLines -Store 'example-shop.myshopify.com') -join "`n")
Assert-Match $explicit '--store example-shop.myshopify.com' '-Store names the store the caller gave'
function Get-ShopifyStoreDomain { 'seam-shop.myshopify.com' }
$viaSeam = ((Get-ShopifyCliRepairLines) -join "`n")
Assert-Match $viaSeam '--store seam-shop.myshopify.com' 'and a Get-ShopifyStoreDomain in scope is read, not a second literal'
Remove-Item Function:\Get-ShopifyStoreDomain

Write-Case 'no market domain or store name is spelled out in the lib'
# Every myshopify.com in the file must be the placeholder.
$domains = @([regex]::Matches($libText, '[A-Za-z0-9<>-]+\.myshopify\.com') | ForEach-Object { $_.Value } | Sort-Object -Unique)
Assert-Equal 1 $domains.Count 'exactly one domain-shaped string'
Assert-Equal '<your-store>.myshopify.com' $domains[0] 'and it is the placeholder'

Write-Case 'a half-installed CLI is NOT present: only the extensionless sh shim resolves'
$stubDir = Join-Path ([System.IO.Path]::GetTempPath()) ("bwj-cli-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stubDir | Out-Null
try {
    Set-Content -LiteralPath (Join-Path $stubDir 'shopify') -Value '#!/bin/sh'
    Set-Content -LiteralPath (Join-Path $stubDir '.shopify.cmd-pFQdlKWQ') -Value '@echo off'
    Set-Content -LiteralPath (Join-Path $stubDir '.shopify.ps1-pFQdlKWQ') -Value 'exit 0'
    $probe = @"
`$env:Path = '$stubDir;' + `$env:SystemRoot + '\system32'
. '$libPath'
if (Test-ShopifyCliPresent) { 'PRESENT' } else { 'ABSENT' }
"@
    $half = (& powershell -NoProfile -ExecutionPolicy Bypass -Command $probe 2>&1 | Out-String).Trim()
    Assert-Equal 'ABSENT' $half 'the staging-named install reads as absent, not present'

    Set-Content -LiteralPath (Join-Path $stubDir 'shopify.cmd') -Value '@echo off'
    $whole = (& powershell -NoProfile -ExecutionPolicy Bypass -Command $probe 2>&1 | Out-String).Trim()
    Assert-Equal 'PRESENT' $whole 'and with shopify.cmd in place it reads as present again'
} finally {
    Remove-Item -LiteralPath $stubDir -Recurse -Force -ErrorAction SilentlyContinue
}

Complete-Suite
