<#
.SYNOPSIS
    Tests for plugins/dkj-policy/extensions/bwj-development/hooks/guard-reach-reason.ps1 and its lib,
    scripts/lib/reach-reason-rules.ps1 -- the PreToolUse hook that refuses the reach label on an issue
    whose body does not say why (inbound #4057).

.DESCRIPTION
    THREE GROUPS.
      1. THE LIB, in-process: which gh calls add the reach label, where their body comes from, and what
         counts as a written reason.
      2. THE HOOK, as a process, on every path that makes no network call: every call names its repo
         with --repo, and every body is inline, in a file, or on stdin.
      3. THE REGISTRATION: hooks.json runs the file on the shell tools behind a gh issue create/edit
         pre-filter.

    THE TEST GAP, NAMED. An edit that passes no body is judged on the issue's current body, which needs
    gh to answer about a real issue, so that path is not run here -- this suite runs in CI without
    tracker credentials. The judgement it takes is group 1's Test-ReachReasonSection.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Continue'
$RepoRoot   = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$PluginRoot = Join-Path $RepoRoot 'plugins\dkj-policy\extensions\bwj-development'
$Hook       = Join-Path $PluginRoot 'hooks\guard-reach-reason.ps1'
$HooksJson  = Join-Path $PluginRoot 'hooks\hooks.json'
$Fixture    = Join-Path ([System.IO.Path]::GetTempPath()) ('guard-reach-reason-' + [guid]::NewGuid().ToString('n'))

. (Join-Path $PluginRoot 'scripts\lib\reach-reason-rules.ps1')

$script:pass = 0
$script:fail = 0
function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    if ($Expected -eq $Actual) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Name`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red }
}
function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else            { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}

$why = "Broken.`n`n## Why minor`nThe commissioner sees the Belgian pop-up on every page."

Write-Host '== 1. the lib =='
$c = @(Get-ReachLabelInvocation -Command "gh issue create --repo BWJ-Development/smartwatchbanden --title 'x' --label bug,minor --body 'no reason'" -ReachLabel 'minor')
Assert-Equal 1 $c.Count 'a create with the reach label in a comma list is found'
Assert-Equal 'create' $c[0].Kind 'as a create'
Assert-Equal 'BWJ-Development/smartwatchbanden' $c[0].Repo 'with its --repo'
Assert-Equal 'inline' $c[0].BodySource 'and its inline body'
Assert-Equal 0 @(Get-ReachLabelInvocation -Command "gh issue create --label bug --body 'x'" -ReachLabel 'minor').Count 'a create without the reach label is not a finding'
Assert-Equal 0 @(Get-ReachLabelInvocation -Command "git commit -m 'gh issue create --label minor'" -ReachLabel 'minor').Count 'a mention inside a commit message is not a call'
Assert-Equal 0 @(Get-ReachLabelInvocation -Command "gh issue edit 12 --remove-label minor" -ReachLabel 'minor').Count 'removing the label is not adding it'
Assert-Equal 1 @(Get-ReachLabelInvocation -Command "gh issue create -lMinor -b x" -ReachLabel 'minor').Count 'an attached short flag, any case, is read'
$e = @(Get-ReachLabelInvocation -Command "gh issue edit 1283 --milestone 3 --add-label minor" -ReachLabel 'minor')
Assert-Equal '1283' (@($e[0].Numbers) -join ',') 'an edit names its issue, and --milestone 3 does not read as issue 3'
Assert-Equal 'none' $e[0].BodySource 'an edit passing no body says so'
$u = @(Get-ReachLabelInvocation -Command "gh issue edit https://github.com/BWJ-Development/xoxowildhearts/issues/401 --add-label minor" -ReachLabel 'minor')
Assert-Equal 'BWJ-Development/xoxowildhearts' $u[0].Repo 'an issue URL gives its repo'
$f = @(Get-ReachLabelInvocation -Command "gh issue create --label minor --body-file body.md" -ReachLabel 'minor')
Assert-Equal 'file' $f[0].BodySource 'a --body-file is a file'
Assert-Equal 'body.md' $f[0].BodyFile 'with its path'
Assert-Equal 'stdin' @(Get-ReachLabelInvocation -Command "gh issue create --label minor -F -" -ReachLabel 'minor')[0].BodySource "'-F -' is stdin"
Assert-Equal 2 @(Get-ReachLabelInvocation -Command "gh issue create --label minor -b x; gh issue edit 5 --add-label minor" -ReachLabel 'minor').Count 'two calls in one command are both found'
$ps = @(Get-ReachLabelInvocation -Command ('gh issue create --label minor --body "x`n`n## Why minor`nThe owner sees it."') -ReachLabel 'minor')
Assert-True (Test-ReachReasonSection -Body $ps[0].Body -ReachLabel 'minor') 'a PowerShell backtick-n body is read with its line breaks'

Assert-True (Test-ReachReasonSection -Body $why -ReachLabel 'minor') 'a Why section with text under it passes'
Assert-True (Test-ReachReasonSection -Body "### why MINOR?`r`nThe commissioner." -ReachLabel 'minor') 'level 3, any case, a question mark and CRLF pass'
Assert-True (-not (Test-ReachReasonSection -Body "## Why minor`n`n## Next`ntext" -ReachLabel 'minor')) 'a heading with nothing under it before the next heading is no reason'
Assert-True (-not (Test-ReachReasonSection -Body "## Why minor" -ReachLabel 'minor')) 'nor is a heading at the end'
Assert-True (-not (Test-ReachReasonSection -Body "Why minor: the commissioner" -ReachLabel 'minor')) 'prose without the heading is not the section'
Assert-True (-not (Test-ReachReasonSection -Body "# Why minor`ntext" -ReachLabel 'minor')) 'a level-1 heading is not the section'
Assert-True (Test-ReachReasonSection -Body "## Why tier-1`ntext" -ReachLabel 'tier-1') "the heading follows the repo's own label name"
Assert-True (-not (Test-ReachReasonSection -Body '' -ReachLabel 'minor')) 'an empty body has no reason'

Write-Host '== 2. the hook =='
New-Item -ItemType Directory -Force -Path $Fixture | Out-Null
[System.IO.File]::WriteAllText((Join-Path $Fixture 'good.md'), $why)
[System.IO.File]::WriteAllText((Join-Path $Fixture 'bad.md'), 'No reason here.')
function Invoke-Hook {
    param([string]$Command)
    $payload = @{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress
    $saved = $env:CLAUDE_PROJECT_DIR
    try {
        $env:CLAUDE_PROJECT_DIR = $Fixture
        $out = $payload | & powershell -NoProfile -ExecutionPolicy Bypass -File $Hook 2>&1 | ForEach-Object { "$_" }
    } finally { $env:CLAUDE_PROJECT_DIR = $saved }
    return [pscustomobject]@{ Text = ($out -join "`n"); Code = $LASTEXITCODE }
}
$store = '--repo BWJ-Development/smartwatchbanden'

$r = Invoke-Hook "gh issue create $store --title 'Belgium pop-up' --label bug --label minor --body 'It shows twice.'"
Assert-Equal 2 $r.Code 'the measured case (#4057): the reach label with no reason in the body is refused'
Assert-True ($r.Text -match "BLOCKED \(guard-reach-reason\): a new issue on BWJ-Development/smartwatchbanden would carry the reach label 'minor'") 'and the refusal names the repo and the label'
Assert-True ($r.Text -match '## Why minor') 'and shows the section to write'
Assert-True ($r.Text -notmatch 'It shows twice') 'and prints no body'

$r = Invoke-Hook ("gh issue create $store --label minor --body '" + $why + "'")
Assert-Equal 0 $r.Code 'a body with the Why section passes'
Assert-True ($r.Text.Trim() -eq '') 'silently'

$r = Invoke-Hook "gh issue create $store --label minor"
Assert-Equal 2 $r.Code 'a create with no body at all is refused'

$r = Invoke-Hook "gh issue create $store --label minor --body-file good.md"
Assert-Equal 0 $r.Code 'a body file with the section passes, read relative to the project'
$r = Invoke-Hook "gh issue create $store --label minor --body-file bad.md"
Assert-Equal 2 $r.Code 'a body file without it is refused'
$r = Invoke-Hook "gh issue create $store --label minor --body-file missing.md"
Assert-Equal 0 $r.Code 'a body file that is not there passes'
Assert-True ($r.Text -match 'body file not found') 'with a warning naming what was not checked'
$r = Invoke-Hook "gh issue create $store --label minor -F -"
Assert-Equal 0 $r.Code 'a body on stdin passes'
Assert-True ($r.Text -match 'body on stdin') 'with a warning'

$r = Invoke-Hook "gh issue edit 1283 $store --body 'still no reason' --add-label minor"
Assert-Equal 2 $r.Code 'an edit that adds the label and rewrites the body without the section is refused'
Assert-True ($r.Text -match 'BWJ-Development/smartwatchbanden#1283') 'and names the issue'
$r = Invoke-Hook ("gh issue edit 1283 $store --add-label minor --body '" + $why + "'")
Assert-Equal 0 $r.Code 'an edit writing the section in the same move passes'

# A BODY THE CALL DOES NOT SPELL OUT IS NOT REFUSED (Victor's review, #4057): built at run time, or written
# in a template, the browser or an editor, the text gh receives is not on the command line.
foreach ($cmd in @(
        ('gh issue create ' + $store + ' --label minor --body $body'),
        ('gh issue create ' + $store + ' --label minor --body "$body"'),
        ('gh issue create ' + $store + ' --label minor --body "$(cat /tmp/b.md)"'),
        ('gh issue create ' + $store + ' --label minor --body (Get-Content b.md -Raw)'),
        ('gh issue create ' + $store + ' --label minor --template bug'),
        ('gh issue create ' + $store + ' --label minor --web'),
        ('gh issue create ' + $store + ' -e --label minor'))) {
    $r = Invoke-Hook $cmd
    Assert-True (($r.Code -eq 0) -and ($r.Text -match 'did NOT judge it')) "passes with a warning: $cmd"
}
$r = Invoke-Hook ('gh issue create ' + $store + " --label minor --body `"`$(cat <<'EOF'`n" + $why + "`nEOF`n)`"")
Assert-Equal 0 $r.Code 'a heredoc whose text shows the section passes'
Assert-True ($r.Text.Trim() -eq '') 'silently'

$r = Invoke-Hook "gh issue create --repo DaveKJohn/some-other-repo --label minor --body 'x'"
Assert-Equal 0 $r.Code 'a repo report-issue does not admit is none of this guard''s business'
$r = Invoke-Hook "gh issue create $store --label bug --body 'x'"
Assert-Equal 0 $r.Code 'a create without the reach label passes'
$r = Invoke-Hook "gh issue list --label minor"
Assert-Equal 0 $r.Code 'a list is not a create or an edit'
$r = Invoke-Hook "echo 'gh issue create --label minor' > notes.txt"
Assert-Equal 0 $r.Code 'a mention passes'

[System.IO.Directory]::CreateDirectory((Join-Path $Fixture 'scripts')) | Out-Null
[System.IO.File]::WriteAllText((Join-Path $Fixture 'scripts\repo-config.ps1'), "function Get-ReachLabel { 'tier-1' }`n")
$r = Invoke-Hook "gh issue create $store --label minor --body 'x'"
Assert-Equal 0 $r.Code "with Get-ReachLabel answered 'tier-1', 'minor' is not the reach label"
$r = Invoke-Hook "gh issue create $store --label tier-1 --body '## Why minor`nold heading'"
Assert-Equal 2 $r.Code 'and the section must carry the repo''s own label name'
Remove-Item -LiteralPath (Join-Path $Fixture 'scripts') -Recurse -Force

Write-Host '== 3. the registration =='
$hooks = Get-Content -Raw -LiteralPath $HooksJson | ConvertFrom-Json
$entry = @($hooks.hooks.PreToolUse | Where-Object { @($_.hooks | Where-Object { $_.command -match 'guard-reach-reason\.ps1' }).Count -gt 0 })
Assert-Equal 1 $entry.Count 'hooks.json registers the hook once'
Assert-Equal 'Bash|PowerShell' $entry[0].matcher 'on the shell tools'
Assert-True ($entry[0].hooks[0].command -match 'issue\[\[:space:\]\]\+\(create\|edit\)') 'behind a gh issue create/edit pre-filter'

if (Test-Path -LiteralPath $Fixture) { Remove-Item -Recurse -Force -LiteralPath $Fixture -ErrorAction SilentlyContinue }
Write-Host ''
Write-Host "guard-reach-reason: $script:pass passed, $script:fail failed"
if ($script:fail -gt 0) { exit 1 }
exit 0
