<#
.SYNOPSIS
    Release day in one command, from the owner's go-live word to a verified, cut release, for a store whose
    live theme deploys from a Git-connected branch: preflight, promotion PR opened, required checks waited
    on, PR merged, live theme verified by content hash, app deployed or held, release cut, tasks told.

.DESCRIPTION
    WHAT IT REPLACES (inbound #4402, measured on a release day in BWJ-Development/smartwatchbanden). From the
    owner's "approve" to "live and verified", a session walked six steps and handed most of them back: the
    promotion PR it printed was opened by hand (three attempts before the guards accepted it), the merge
    needed the admin bypass, the live theme was verified ad hoc, the app deploy was printed and never run,
    and the live-push record had to be hand-edited to 'hold' when it was skipped. Each step printed rather
    than ran, so every one of them came back to a person as a separate confirmation -- the rubber stamp the
    constitution warns about.

    ONE WORD COVERS THE CHAIN FOR ONE RELEASE (the owner's decision on #4402, November 23, 2026):

      1. THE WORD IS THE LIVE-PUSH MARKER ON THIS COMMAND LINE. guard-live-theme (dkj-subagents-shopify)
         refuses any line that runs this script without it (its rule 6), because every act below happens
         inside a script that guard cannot read. So this script never checks for the marker itself, and
         never prints it: the line a person authorises is theirs to write.
      2. THE APP DEPLOY RIDES INSIDE THE SAME WORD, as a required switch on the same line: -AppDeploy or
         -SkipAppDeploy wherever Get-ShopifyAppRoot is answered. Skipping writes 'hold' into the record.

    THE STEPS, AND IT STOPS AT THE FIRST REFUSAL:

      1 preflight  live-preflight (dkj-subagents-shopify), unchanged, with -ResultPath; refused = stop.
      2 promote    the promotion PR, trunk into the deploy branch -- an open one is reused.
      3 checks     the PR's required checks, polled until they settle; a failure or the timeout stops.
                   The merge below bypasses the deploy ruleset, so THIS wait is the gate it would have been.
      4 merge      'gh pr merge --merge --admin' -- a merge commit, and the trunk is never deleted as its head.
      5 verify     the live theme pulled, file by file, until each promoted file's 'git hash-object'
                   equals the promoted commit's blob (or is absent where the range deletes it).
      6 app        'shopify app deploy --path <root> --allow-updates', or the record's app lines to 'hold'.
      7 cut        cut-release (dkj-repo-workflow) with -LivePushRecord.
      8 notify     notify-live -Post with the same record.

    A STOP AFTER THE MERGE IS RESUMED, NOT RE-RUN. The promotion cannot be made twice (the preflight
    refuses two equal trees), so every stop past step 4 prints the line to run again with -ResumeFrom and
    the record -- without the marker, which the person adds.

    WHAT IT DOES NOT COVER: a store that goes live by a CLI 'shopify theme push' (Get-ShopifyLiveDeployBranch
    unanswered). It refuses there; live-preflight still prints that push for a person to make.

.PARAMETER Version
    The release, X.Y.Z (a leading 'v' is accepted). Handed to the cut and to notify-live. Required.

.PARAMETER Title
    The release title, handed to cut-release's -Title.

.PARAMETER AppDeploy
    Run the app deploy. Required beside -SkipAppDeploy's absence wherever Get-ShopifyAppRoot is answered.

.PARAMETER SkipAppDeploy
    Do not run the app deploy: its files go into the record as 'hold'.

.PARAMETER ResumeFrom
    verify | app | cut | notify -- carry on after a stop past the merge. Needs -LivePushRecord.

.PARAMETER LivePushRecord
    The record the first run's preflight wrote, for -ResumeFrom.

.PARAMETER CheckTimeoutMinutes
    How long step 3 waits for the required checks. Default 30.

.PARAMETER VerifyTimeoutMinutes
    How long step 5 polls the live theme. Default 15: Shopify had not finished syncing a minute after the
    merge on the measured release day.

.PARAMETER AcceptUnverified
    Turn a step-5 timeout into a note, after a person has looked at the paths it names (a JSON template the
    theme editor reformats, for example) and judged them live. Never a default.

.PARAMETER SinceTag
    Passed to live-preflight.

.PARAMETER BackupTimeoutMinutes
    Passed to live-preflight.

.PARAMETER BackupVerifyExisting
    Passed to live-preflight.

.PARAMETER AcceptRejectedWriteBacks
    Passed to live-preflight.

.PARAMETER AcceptOwedReconciliation
    Passed to live-preflight.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File "<plugin>/scripts/task/go-live.ps1" -Version 3.2.0 -AppDeploy  # <STORE>-LIVE-PUSH-AUTHORIZED

.NOTES
    The decisions are in ../lib/go-live-rules.ps1 and pinned by scripts/tests/bwj-go-live.tests.ps1; the
    guard rule by scripts/tests/guard-live-theme.tests.ps1. THIS SCRIPT IS NOT DRIVEN, for live-preflight's
    reason: every step reaches gh, git or a real store. Pure ASCII (repo convention for .ps1).
#>
[CmdletBinding()]
param(
    [string]$Version = '',
    [string]$Title = '',
    [switch]$AppDeploy,
    [switch]$SkipAppDeploy,
    [ValidateSet('', 'verify', 'app', 'cut', 'notify')]
    [string]$ResumeFrom = '',
    [string]$LivePushRecord = '',
    [ValidateRange(1, 240)][int]$CheckTimeoutMinutes = 30,
    [ValidateRange(1, 240)][int]$VerifyTimeoutMinutes = 15,
    [switch]$AcceptUnverified,
    [string]$SinceTag = '',
    [ValidateRange(1, 600)][int]$BackupTimeoutMinutes = 20,
    [string]$BackupVerifyExisting = '',
    [switch]$AcceptRejectedWriteBacks,
    [switch]$AcceptOwedReconciliation
)

$ErrorActionPreference = 'Stop'

# Captured before the repo's own config is dot-sourced: repo-config.ps1 may bind any name (notify-live's guard).
$A = @{
    Version = $Version; Title = $Title; AppDeploy = [bool]$AppDeploy; SkipAppDeploy = [bool]$SkipAppDeploy
    ResumeFrom = $ResumeFrom; Record = $LivePushRecord; CheckMin = $CheckTimeoutMinutes; VerifyMin = $VerifyTimeoutMinutes
    AcceptUnverified = [bool]$AcceptUnverified; SinceTag = $SinceTag; BackupMin = $BackupTimeoutMinutes
    BackupExisting = $BackupVerifyExisting; AcceptWriteBacks = [bool]$AcceptRejectedWriteBacks; AcceptOwed = [bool]$AcceptOwedReconciliation
}

. (Join-Path $PSScriptRoot '..\lib\repo-root-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\native-command-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\shopify-cli-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\live-record-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\plugin-payload-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\go-live-rules.ps1')

$repoRoot = Resolve-BwjRepoRoot -Override ''
Set-Location -LiteralPath $repoRoot
$script:PluginPayloadRepoRoot = $repoRoot

function Stop-GoLive {
    param([string]$Step, [string]$Message, [string]$ResumeFrom = '')
    Write-Host ''
    Write-Host "REFUSED at $Step -- $Message" -ForegroundColor Red
    if ($ResumeFrom -and $script:recordPath) {
        Write-Host 'Everything up to the merge is done. Fix what refused, then run the rest with this line, adding the' -ForegroundColor Yellow
        Write-Host 'marker your repo states for a live push (go-live prints no marker; the word is yours):' -ForegroundColor Yellow
        Write-Host "  $(Format-GoLiveResumeLine -From $ResumeFrom -RecordPath $script:recordPath -Version $script:version -AppSwitch $script:appSwitch)"
    }
    exit 1
}

function Write-Step([string]$Name, [string]$Text) {
    Write-Host ''
    Write-Host "[$Name] $Text" -ForegroundColor Cyan
}

if (Test-Path -LiteralPath (Join-Path $repoRoot '.claude-plugin\marketplace.json') -PathType Leaf) {
    Write-Host 'REFUSED: this repo publishes plugins, so it is this script''s source rather than a store. Nothing was done.' -ForegroundColor Red
    exit 1
}

# --- the seams --------------------------------------------------------------------------------------
$seam = @{ Deploy = ''; LiveId = ''; AppRoot = ''; Trunk = ''; Store = '' }
$configPath = Join-Path $repoRoot 'scripts\repo-config.ps1'
if (Test-Path -LiteralPath $configPath -PathType Leaf) {
    $keep = $repoRoot
    try { . $configPath } catch { Write-Warning "scripts/repo-config.ps1 threw $($_.Exception.GetType().Name) while being read." }
    $repoRoot = $keep
    foreach ($pair in @(@('Deploy', 'Get-ShopifyLiveDeployBranch'), @('LiveId', 'Get-ShopifyLiveThemeId'), @('AppRoot', 'Get-ShopifyAppRoot'), @('Trunk', 'Get-TrunkBranchName'), @('Store', 'Get-ShopifyThemeEstateStore'))) {
        if (@($ExecutionContext.InvokeCommand.GetCommands($pair[1], 'Function', $false)).Count -gt 0) {
            try { $seam[$pair[0]] = ([string](& $pair[1])).Trim() } catch { $seam[$pair[0]] = '' }
        }
    }
}
foreach ($k in @('Deploy', 'AppRoot')) { if ($seam[$k] -match 'VUL-IN') { $seam[$k] = '' } }
$deploy = $seam.Deploy -replace '^refs/heads/', ''
$trunk = if ($seam.Trunk) { $seam.Trunk } else { 'main' }
$liveId = if ($seam.LiveId -match '^\d+$') { $seam.LiveId } else { '' }
$appRoot = $seam.AppRoot
$store = $seam.Store
$script:version = ([string]$A.Version).Trim().TrimStart('v')
$script:appSwitch = if ($A.AppDeploy) { '-AppDeploy' } elseif ($A.SkipAppDeploy) { '-SkipAppDeploy' } else { '' }
$script:recordPath = ([string]$A.Record).Trim()

Write-Host "== go-live -- v$($script:version) ==" -ForegroundColor Cyan

# --- what refuses before anything runs --------------------------------------------------------------
if (-not (Test-GoLiveVersion $A.Version)) { Stop-GoLive 'start' "-Version is required as X.Y.Z; got '$($A.Version)'." }
if (-not ($deploy -cmatch '\A[A-Za-z0-9][A-Za-z0-9._/-]*\z')) {
    Stop-GoLive 'start' 'this repo answers no Get-ShopifyLiveDeployBranch, so its live theme is not Git-connected and goes live by a CLI push. go-live covers the promotion only; run live-preflight and make its printed push.'
}
if (-not ($trunk -cmatch '\A[A-Za-z0-9][A-Za-z0-9._/-]*\z')) { Stop-GoLive 'start' 'Get-TrunkBranchName is not a branch name.' }
if (-not $liveId) { Stop-GoLive 'start' 'Get-ShopifyLiveThemeId is unanswered, so the live theme cannot be verified.' }
$appPrecheck = Get-GoLiveAppDecision -AppRoot $appRoot -AppDeploy:$A.AppDeploy -SkipAppDeploy:$A.SkipAppDeploy
if (-not $appPrecheck.Ok) { Stop-GoLive 'start' $appPrecheck.Message }
if ($A.ResumeFrom -and -not ($script:recordPath -and (Test-Path -LiteralPath $script:recordPath -PathType Leaf))) {
    Stop-GoLive 'start' '-ResumeFrom needs -LivePushRecord naming the record the first run wrote.'
}

$steps = @(Get-GoLiveSteps)
$startAt = if ($A.ResumeFrom) { [array]::IndexOf($steps, $A.ResumeFrom) } else { 0 }
function Test-Runs([string]$Name) { return ([array]::IndexOf($steps, $Name) -ge $startAt) }

$promotedSha = ''
$appChanged = $true

# === 1 preflight =====================================================================================
if (Test-Runs 'preflight') {
    Write-Step 'preflight' 'live-preflight, unchanged -- every gate, the drift and write-back reads, the backup.'
    try { $preflight = Resolve-PluginScript -Plugin 'dkj-subagents-shopify' -RelativePath 'scripts\task\live-preflight.ps1' }
    catch { Stop-GoLive 'preflight' $_.Exception.Message }
    $resultPath = Join-Path ([System.IO.Path]::GetTempPath()) ("go-live-preflight-{0}.json" -f [guid]::NewGuid().ToString('N').Substring(0, 8))
    $pfArgs = @('-ResultPath', $resultPath, '-BackupTimeoutMinutes', [string]$A.BackupMin)
    if ($A.SinceTag) { $pfArgs += @('-SinceTag', $A.SinceTag) }
    if ($A.BackupExisting) { $pfArgs += @('-BackupVerifyExisting', $A.BackupExisting) }
    if ($A.AcceptWriteBacks) { $pfArgs += '-AcceptRejectedWriteBacks' }
    if ($A.AcceptOwed) { $pfArgs += '-AcceptOwedReconciliation' }
    & powershell -NoProfile -ExecutionPolicy Bypass -File $preflight @pfArgs | Out-Host
    $pfCode = $LASTEXITCODE
    $pf = $null
    if (Test-Path -LiteralPath $resultPath -PathType Leaf) {
        try { $pf = Get-Content -LiteralPath $resultPath -Raw | ConvertFrom-Json } catch { $pf = $null }
    }
    if ($pfCode -ne 0 -or -not $pf -or -not $pf.Allowed) { Stop-GoLive 'preflight' 'live-preflight did not allow the release (its verdict is above). Nothing was promoted.' }
    if (-not $pf.Connected -or -not $pf.Promotion) { Stop-GoLive 'preflight' 'live-preflight composed no promotion, so there is nothing for go-live to take live.' }
    if (-not $pf.RecordPath -or -not $pf.PromotedSha) { Stop-GoLive 'preflight' 'live-preflight wrote no live-push record, so the cut would have no input. Nothing was promoted.' }
    $script:recordPath = [string]$pf.RecordPath
    $promotedSha = [string]$pf.PromotedSha
    $appChanged = [bool]$pf.AppDeploy
    if ($pf.Store) { $store = [string]$pf.Store }
} else {
    try { $promotion = Get-LivePushRecordPromotion -Text (Get-Content -LiteralPath $script:recordPath -Raw) }
    catch { Stop-GoLive 'start' $_.Exception.Message }
    if (-not $promotion) { Stop-GoLive 'start' 'the record names no promotion, so it is not a go-live record.' }
    $promotedSha = $promotion.Sha
    $parsed = ConvertFrom-LivePushRecord -Text (Get-Content -LiteralPath $script:recordPath -Raw)
    $appChanged = @(@($parsed.Live) + @($parsed.Hold) | Where-Object { Test-GoLiveUnderAppRoot -Path $_ -AppRoot $appRoot }).Count -gt 0
    # A resume has to stand on a promotion that DID merge.
    [void](Invoke-Native { git -C $repoRoot fetch -q origin $deploy })
    $anc = Invoke-Native { git -C $repoRoot merge-base --is-ancestor $promotedSha "origin/$deploy" }
    if ($anc.Code -ne 0) { Stop-GoLive 'start' "the record's promoted commit $promotedSha is not on origin/$deploy -- the promotion never merged, so there is nothing to resume." }
}
if (-not ($store -cmatch '\A[A-Za-z0-9][A-Za-z0-9.-]*\z')) { Stop-GoLive 'start' 'Get-ShopifyThemeEstateStore is not a store domain, so the live theme cannot be read.' }
$app = Get-GoLiveAppDecision -AppRoot $appRoot -AppDeploy:$A.AppDeploy -SkipAppDeploy:$A.SkipAppDeploy -AppChanged $appChanged

# === 2-4 promote, checks, merge ======================================================================
if (Test-Runs 'promote') {
    Write-Step 'promote' "the promotion PR, $trunk into $deploy."
    $existing = Invoke-Native { gh pr list --base $deploy --head $trunk --state open --json number -q '.[0].number' } -Compact
    $pr = [string](@($existing.Lines) | Select-Object -First 1)
    if ($pr -notmatch '^\d+$') {
        $title = "promote: $trunk to $deploy for v$($script:version)"
        $body = "Promotes $trunk ($promotedSha) to the live theme's deploy branch -- go-live, for v$($script:version)."
        $created = Invoke-Native { gh pr create --base $deploy --head $trunk --title $title --body $body } -Compact
        $m = [regex]::Match((@($created.Lines) -join ' '), '/pull/(\d+)')
        if ($created.Code -ne 0 -or -not $m.Success) { Stop-GoLive 'promote' 'gh pr create did not open the promotion PR. Nothing was merged.' }
        $pr = $m.Groups[1].Value
        Write-Host "  opened #$pr"
    } else {
        Write-Host "  reusing the open promotion PR #$pr"
    }

    Write-Step 'checks' "the required checks on #$pr, up to $($A.CheckMin) minute(s). The merge bypasses the deploy ruleset, so this wait is that gate."
    $deadline = (Get-Date).AddMinutes($A.CheckMin)
    $graceUntil = (Get-Date).AddSeconds(90)
    $state = 'pending'
    while ($true) {
        $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
        try { $raw = @(& gh pr checks $pr --required --json name,bucket 2>&1 | ForEach-Object { "$_" }) } catch { $raw = @() } finally { $ErrorActionPreference = $prev }
        $text = ($raw -join "`n")
        $checks = $null
        $jsonStart = $text.IndexOf('[')
        if ($jsonStart -ge 0) { try { $checks = @($text.Substring($jsonStart) | ConvertFrom-Json) } catch { $checks = $null } }
        if ($null -ne $checks) { $state = Get-GoLiveCheckState -Checks $checks }
        elseif ($text -match '(?i)no (required )?checks reported') { $state = 'none' }
        else { $state = 'pending' }   # an unreadable answer is waited on, never merged over
        if ($state -eq 'none' -and (Get-Date) -lt $graceUntil) { $state = 'pending' }
        if ($state -ne 'pending') { break }
        if ((Get-Date) -ge $deadline) { Stop-GoLive 'checks' "the required checks on #$pr did not settle within $($A.CheckMin) minute(s). The PR is open and unmerged; run go-live again once they have." }
        Start-Sleep -Seconds 20
    }
    if ($state -eq 'fail') { Stop-GoLive 'checks' "a required check on #$pr failed. The PR is open and unmerged; fix the trunk and run go-live again." }
    Write-Host $(if ($state -eq 'none') { '  NOTE: the deploy branch requires no check on this PR.' } else { '  every required check passed.' })

    Write-Step 'merge' "#$pr into $deploy -- a merge commit, the admin bypass, the branch kept. This is what goes live."
    $merged = Invoke-Native { gh pr merge $pr --merge --admin }
    $view = Invoke-Native { gh pr view $pr --json state -q .state } -Compact
    if ((@($view.Lines) | Select-Object -First 1) -ne 'MERGED') { Stop-GoLive 'merge' "#$pr is not merged (gh pr merge exited $($merged.Code)). Nothing went live." }
    Write-Host "  merged. Shopify now syncs '$deploy' to the live theme."
}

# === 5 verify ========================================================================================
if (Test-Runs 'verify') {
    $parsed = ConvertFrom-LivePushRecord -Text (Get-Content -LiteralPath $script:recordPath -Raw)
    $paths = @(Get-GoLiveVerifyPaths -Live @($parsed.Live) -AppRoot $appRoot)
    Write-Step 'verify' "$($paths.Count) promoted file(s) on live theme $liveId, by content hash, up to $($A.VerifyMin) minute(s)."
    if ($paths.Count -gt 0) {
        $expected = @{}
        foreach ($p in $paths) {
            $r = Invoke-Native { git -C $repoRoot rev-parse --verify -q "$($promotedSha):$p" } -Compact
            $expected[$p] = if ($r.Code -eq 0) { [string](@($r.Lines) | Select-Object -First 1) } else { '' }
        }
        $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("go-live-verify-{0}" -f [guid]::NewGuid().ToString('N').Substring(0, 8))
        $deadline = (Get-Date).AddMinutes($A.VerifyMin)
        $mismatch = @($paths)
        try {
            while ($true) {
                if (Test-Path -LiteralPath $dir) { Remove-Item -LiteralPath $dir -Recurse -Force }
                New-Item -ItemType Directory -Force -Path $dir | Out-Null
                $cli = @('theme', 'pull', '--store', $store, '--theme', $liveId, '--path', $dir)
                foreach ($p in $paths) { $cli += @('--only', $p) }
                $pull = Invoke-ShopifyCli -Arguments $cli -Quiet
                if ($pull.ExitCode -eq 0) {
                    $actual = @{}
                    foreach ($p in $paths) {
                        $f = Join-Path $dir ($p -replace '/', '\')
                        if (Test-Path -LiteralPath $f -PathType Leaf) {
                            $h = Invoke-Native { git -C $repoRoot hash-object "--path=$p" -- $f } -Compact
                            $actual[$p] = if ($h.Code -eq 0) { [string](@($h.Lines) | Select-Object -First 1) } else { 'unreadable' }
                        }
                    }
                    $mismatch = @(Compare-GoLiveTheme -Expected $expected -Actual $actual)
                    if ($mismatch.Count -eq 0) { break }
                    Write-Host "  $($mismatch.Count) of $($paths.Count) not live yet; polling again."
                } else {
                    Write-Host "  theme pull exited $($pull.ExitCode); polling again."
                }
                if ((Get-Date) -ge $deadline) { break }
                Start-Sleep -Seconds 30
            }
        } finally {
            Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue
        }
        if ($mismatch.Count -gt 0) {
            $shown = (@($mismatch | Select-Object -First 10) -join ', ') + $(if ($mismatch.Count -gt 10) { " ... and $($mismatch.Count - 10) more" } else { '' })
            if (-not $A.AcceptUnverified) {
                Stop-GoLive 'verify' "after $($A.VerifyMin) minute(s) the live theme does not hold the promoted content of: $shown. Read those on live; where they are live in a form Shopify rewrote, resume with -AcceptUnverified." -ResumeFrom 'verify'
            }
            Write-Host "  NOTE (-AcceptUnverified): not matched by hash, accepted by a person: $shown" -ForegroundColor Yellow
        } else {
            Write-Host '  every promoted file is on the live theme.'
        }
    }
}

# === 6 app ===========================================================================================
if (Test-Runs 'app') {
    Write-Step 'app' $app.Message
    if ($app.Mode -eq 'deploy') {
        $deployRun = Invoke-ShopifyCli -Arguments @('app', 'deploy', '--path', $appRoot, '--allow-updates')
        if ($deployRun.ExitCode -ne 0) { Stop-GoLive 'app' "shopify app deploy exited $($deployRun.ExitCode). The theme is live; the app is not, and nothing has been cut." -ResumeFrom 'app' }
    } elseif ($app.Mode -eq 'hold') {
        try {
            $text = Get-Content -LiteralPath $script:recordPath -Raw
            $held = Set-GoLiveRecordAppHold -Text $text -AppRoot $appRoot
            [void](ConvertFrom-LivePushRecord -Text $held)
            [System.IO.File]::WriteAllText($script:recordPath, $held, (New-Object System.Text.UTF8Encoding($false)))
        } catch { Stop-GoLive 'app' "the record could not be marked 'hold' for the app: $($_.Exception.Message)" -ResumeFrom 'app' }
    }
}

# === 7 cut ===========================================================================================
if (Test-Runs 'cut') {
    Write-Step 'cut' "cut-release v$($script:version), with the live-push record."
    try { $cut = Resolve-PluginScript -Plugin 'dkj-repo-workflow' -RelativePath 'scripts\release\cut-release.ps1' }
    catch { Stop-GoLive 'cut' $_.Exception.Message -ResumeFrom 'cut' }
    $cutArgs = @('-Version', $script:version, '-LivePushRecord', $script:recordPath)
    if ($A.Title) { $cutArgs += @('-Title', $A.Title) }
    & powershell -NoProfile -ExecutionPolicy Bypass -File $cut @cutArgs | Out-Host
    if ($LASTEXITCODE -ne 0) { Stop-GoLive 'cut' "cut-release exited $LASTEXITCODE (its reason is above). The release is live and not cut." -ResumeFrom 'cut' }
}

# === 8 notify ========================================================================================
if (Test-Runs 'notify') {
    Write-Step 'notify' "notify-live -Post for v$($script:version), with the same record."
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'notify-live.ps1') -Version "v$($script:version)" -LivePushRecord $script:recordPath -Post | Out-Host
    if ($LASTEXITCODE -ne 0) { Stop-GoLive 'notify' "notify-live exited $LASTEXITCODE (its reason is above). The release is live and cut." -ResumeFrom 'notify' }
}

Write-Host ''
Write-Host "v$($script:version) is live, verified and cut. Record: $($script:recordPath)" -ForegroundColor Green
exit 0
