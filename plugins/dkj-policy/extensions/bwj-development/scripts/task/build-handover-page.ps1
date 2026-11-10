<#
.SYNOPSIS
    Build a preview handover as an Admin page (#3925) and print the ONE link to it: a card per market with a QR code to
    the preview and the preview and control links (Get-MarketHandoverPairs), and the other three blocks
    PREVIEW-portable.md names -- how to see the change, what is proven and what is asked, and the go-live block as
    build-golive-block.ps1 -OutFile wrote it.

.DESCRIPTION
    WHY IT EXISTS. PREVIEW-portable.md says the handover is one link to a published page, and since #3772 a result
    someone must judge is an Admin page, never a claude.ai Artifact. Until this script nothing built that page, so a
    handover went into an issue comment without the QR codes (smartwatchbanden#1059, November 6, 2026).

    WHAT IT WRITES. One model file outside the checkout, beside this repo's Stopwatch store (dkj-policy's
    apps/admin/lib/handover-page-lib.ps1, Get-HandoverDir), so the branch parked for the owner's eye stays clean.
    Admin draws the page from it at /dev/handover/<name>, the QR codes included, on this machine. Building the same
    -Name again replaces the page, so the link the reviewer already holds shows the new version.

    THE TERMINAL GETS THE LINK, NEVER THE URLS. The cards' URLs are on the page; this prints one line, the page's
    address, read from this checkout's Admin state file, as a markdown link (Format-HandoverLink) because a bare URL
    relayed verbatim could not be clicked (#3954). Where Admin is not running it names the path to open once it is.

      -ThemeId <id>            the preview theme (required), as push-preview printed it.
      -Path <path,...>         the changed page(s), as Get-MarketUrls takes them (default '/').
      -LiveThemeId <id>        the control's theme; default the repo's Get-ShopifyLiveThemeId.
      -Title <text>            the page's title (required): what is being handed over.
      -HowToSee <text>         block one: the page, the condition, the device, the steps. Or -HowToSeeFile <path>.
      -Proven <text>           block three: which gates ran and what they verified. Or -ProvenFile <path>.
      -Asked <text>            block three's last line: the one question the reviewer is asked.
      -GoliveFile <path>       block four: build-golive-block.ps1's -OutFile; the text between its two '---' rules.
      -GoliveTask <text>       the Asana task the go-live block goes to, named above it.
      -CopyFile <path>         JSON { "<market>": "<expected copy>" } for a change with copy in it.
      -Prerequisite <text,...> open store-admin prerequisites, shown above the cards.
      -Issue <ref>             the issue the handover is for, in the footer. -Name <slug>: default the branch name.
      -RootOverride <path>     the repo root, when the run does not start inside the checkout.

    Exits 0 with the link, 1 on a refusal. Pure ASCII (repo convention for .ps1).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ThemeId,
    [string[]]$Path = @('/'),
    [string]$LiveThemeId = '',
    [Parameter(Mandatory = $true)][string]$Title,
    [string]$HowToSee = '',
    [string]$HowToSeeFile = '',
    [string]$Proven = '',
    [string]$ProvenFile = '',
    [string]$Asked = '',
    [string]$GoliveFile = '',
    [string]$GoliveTask = '',
    [string]$CopyFile = '',
    [string[]]$Prerequisite = @(),
    [string]$Issue = '',
    [string]$Name = '',
    [string]$RootOverride = ''
)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$dkjPolicy = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..\..\..')).Path

function Stop-Handover {
    param([string]$Message)
    Write-Host "[REFUSED] $(($Message -replace '[\x00-\x1F\x7F]', ' '))" -ForegroundColor Red
    exit 1
}
function Read-TextArg {
    <# A block's text from its parameter or its file; a file that does not exist is a refusal. #>
    param([string]$Text, [string]$File, [string]$What)
    if ($File) {
        if (-not (Test-Path -LiteralPath $File -PathType Leaf)) { Stop-Handover "$What file '$File' does not exist." }
        return [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $File).Path, $utf8)
    }
    return $Text
}

$RootArg = $RootOverride
. (Join-Path $PSScriptRoot '..\lib\repo-root-lib.ps1')
$repoRoot = Resolve-BwjRepoRoot -Override $RootArg
. (Join-Path $PSScriptRoot '..\lib\market-urls.ps1')
. (Join-Path $dkjPolicy 'apps\admin\lib\handover-page-lib.ps1')
. (Join-Path $dkjPolicy 'apps\admin\lib\dev-preview-rules.ps1')

# The repo's seams (Get-StorefrontMarkets, Get-ShopifyLiveThemeId), at script scope so the market lookups see them --
# the reason build-golive-block.ps1 gives for loading them the same way (#2339).
$configPath = Join-Path $repoRoot 'scripts\repo-config.ps1'
if (Test-Path -LiteralPath $configPath -PathType Leaf) {
    Set-StrictMode -Off
    $resolvedRoot = $repoRoot
    . $configPath
    $repoRoot = $resolvedRoot
}

$how = Read-TextArg -Text $HowToSee -File $HowToSeeFile -What '-HowToSee'
$proof = Read-TextArg -Text $Proven -File $ProvenFile -What '-Proven'
if (-not $how.Trim()) { Stop-Handover 'no -HowToSee: the steps a reviewer takes before the change is visible are the block no URL can carry.' }
if (-not $proof.Trim()) { Stop-Handover 'no -Proven: say which gates ran and what they verified, so the link stands on its own.' }
if (-not $Asked.Trim()) { Stop-Handover 'no -Asked: name the one question the reviewer is being asked.' }

if (-not $Name) {
    $branch = ''
    try { $branch = [string](git -C $repoRoot rev-parse --abbrev-ref HEAD 2>$null) } catch { $branch = '' }
    $Name = ConvertTo-HandoverName $branch.Trim()
}
if (-not (Test-HandoverName $Name)) { Stop-Handover "-Name '$Name' is not a handover name: lowercase letters, digits and dashes, at most 80." }

try { $pairs = @(Get-MarketHandoverPairs -ThemeId $ThemeId -Path $Path -LiveThemeId $LiveThemeId) }
catch { Stop-Handover ([string]$_.Exception.Message) }

$copy = @{}
if ($CopyFile) {
    if (-not (Test-Path -LiteralPath $CopyFile -PathType Leaf)) { Stop-Handover "-CopyFile '$CopyFile' does not exist." }
    try { $cj = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $CopyFile).Path, $utf8) | ConvertFrom-Json } catch { Stop-Handover "-CopyFile '$CopyFile' is not valid JSON." }
    foreach ($p in $cj.PSObject.Properties) { $copy[[string]$p.Name] = [string]$p.Value }
}

$golive = $null
if ($GoliveFile) {
    if (-not (Test-Path -LiteralPath $GoliveFile -PathType Leaf)) { Stop-Handover "-GoliveFile '$GoliveFile' does not exist." }
    $lines = @([System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $GoliveFile).Path, $utf8) -split "`r?`n")
    $rules = @(for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i].Trim() -eq '---') { $i } })
    # The block as build-golive-block writes it: between its two '---' rules, or the whole file where it has none.
    $block = if ($rules.Count -ge 2) { ($lines[($rules[0] + 1)..($rules[1] - 1)] -join "`n").Trim() } else { ($lines -join "`n").Trim() }
    if ($block) { $golive = [pscustomobject]@{ task = $GoliveTask; block = $block } }
}

$model = [pscustomobject]@{
    name = $Name; title = $Title.Trim(); createdAt = (Get-Date).ToString('yyyy-MM-dd HH:mm'); issue = $Issue
    branch = $(try { ([string](git -C $repoRoot rev-parse --abbrev-ref HEAD 2>$null)).Trim() } catch { '' })
    howToSee = $how; prerequisites = @($Prerequisite | ForEach-Object { $_ -split "`n" } | Where-Object { $_.Trim() })
    cards = @($pairs | ForEach-Object { [pscustomobject]@{ market = $_.Market; path = $_.Path; previewUrl = $_.PreviewUrl; controlUrl = $_.LiveUrl; copy = [string]$copy[[string]$_.Market] } })
    proven = $proof; asked = $Asked.Trim(); golive = $golive
}
try { $file = Save-HandoverModel -Dir (Get-HandoverDir -RepoRoot $repoRoot) -Model $model } catch { Stop-Handover ([string]$_.Exception.Message) }

$route = '/dev/handover/' + $Name
$state = @{ Pages = '' }
$statePath = Get-RepoAdminStatePath -Root $repoRoot
if (Test-Path -LiteralPath $statePath -PathType Leaf) { $state = ConvertFrom-RepoAdminState -Text ([System.IO.File]::ReadAllText($statePath, $utf8)) -Root $repoRoot }
Write-Host "[OK] the handover is built: $(@($model.cards).Count) market card(s), each with a QR code to its preview."
if ($state.Pages) {
    Write-Host 'The handover, the one link to report -- relay this line as it stands, a markdown link, so it can be clicked (#3954):'
    Write-Host (Format-HandoverLink -Name $Name -Url ($state.Pages + $route))
} else {
    Write-Host "Admin is not running for this checkout, so there is no address yet. Once it is (the next session start starts it), the page is at $route on Admin."
}
exit 0
