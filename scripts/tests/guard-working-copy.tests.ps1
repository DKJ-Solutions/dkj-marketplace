<#
.SYNOPSIS
    Tests for plugins/dkj-repo-workflow/hooks/guard-working-copy.ps1 -- the PreToolUse hook that refuses a
    dispatched subagent the git commands which discard the dispatching session's working copy.

.DESCRIPTION
    THE JUDGEMENT IS NOT TESTED HERE. It is a pure function with a suite of its own
    (working-copy-guard-lib.tests.ps1, 92 cases in-process). What needs a real invocation is
    everything this file adds on top: the gate, the exit codes, the refusal text, and the two ways it
    deliberately fails OPEN.

    FIVE GROUPS.
      1. THE GATE, which is the whole design. #1669 raised the objection against itself -- a hook
         cannot tell the repository engineer's legitimate `git checkout` from a dispatched reviewer's
         illegitimate one. It can: agent_id is present only inside a subagent. Both directions are
         asserted on the SAME command, because that is the claim: identical text, opposite verdicts.
      2. agent_type IS NOT THE GATE. Claude Code's schema says it is present on the main thread of an
         --agent session, without agent_id. A payload shaped like that must pass, or the guard would
         refuse the main thread of every such session. No incident produced this case; the vendor's
         own field documentation did, which is why it is asserted rather than trusted.
      3. The two deliberate fail-OPEN paths: a payload that cannot be read, and a missing lib. Both
         mean "cannot tell", and answering that with a block would refuse the orchestrator's own git
         commands the moment the contract moves or an install breaks. The prose block still stands
         under both.
      4. The refusal TEXT, because a sentence nothing asserts is a sentence the next edit removes --
         the reason guard-live-theme.tests.ps1 gives for asserting its own. Three things have to be in
         it: the read-only alternatives, that a need for another state is a sentence in a deliverable
         rather than a command, and that authoring the rule is already exempt.
      5. THE FAST PATH'S COUNTER-CASE. The hook string-tests the raw payload for "agent_id" before
         loading any lib, because it fires on every Bash call and 8089 of the 9084 in this repo's
         transcripts are the main thread's (675 ms -> 437 ms). A command whose own TEXT contains that
         string must still be judged as the main thread -- the fast path may only ever cause more
         work, never a different verdict.

    Pure ASCII (repo convention for .ps1).
#>
# 'Continue', not 'Stop': the guard writes its refusal to stderr, and PowerShell 5.1 turns native
# stderr from a child process into a terminating NativeCommandError when the preference is 'Stop'.
# That stderr IS the expected output of a blocking case, so it must not end the run.
$ErrorActionPreference = 'Continue'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $PSScriptRoot '..\lib\fixture-git-lib.ps1')
$Guard    = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\hooks\guard-working-copy.ps1'
# Fixture paths carry $PID: the test gate is a throttled PARALLEL scheduler, so two runs at one fixed
# temp path tear down each other's tree mid-assert.
$Fixture  = Join-Path ([System.IO.Path]::GetTempPath()) "guard-working-copy-$PID-$([guid]::NewGuid().ToString('n'))"

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
    else { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}

function New-Payload {
    <# The shape the harness sends, built rather than typed. #>
    param([string]$Command, [string]$AgentId = '', [string]$AgentType = '', [string]$Cwd = 'C:\work\myrepo')
    $p = @{
        hook_event_name = 'PreToolUse'; session_id = 's1'; cwd = $Cwd
        tool_name = 'Bash'; tool_use_id = 'tu1'; tool_input = @{ command = $Command }
    }
    if ($AgentId)   { $p.agent_id   = $AgentId }
    if ($AgentType) { $p.agent_type = $AgentType }
    return ($p | ConvertTo-Json -Compress -Depth 5)
}

function Invoke-Guard {
    <# Returns @{ Code; Out }. CLAUDE_PROJECT_DIR is set per call, because the guard reads it to know
       which tree it is protecting. #>
    param([string]$Payload, [string]$Root = 'C:\work\myrepo', [string]$GuardPath = $null)
    if (-not $GuardPath) { $GuardPath = $Guard }
    $prev = $env:CLAUDE_PROJECT_DIR
    $env:CLAUDE_PROJECT_DIR = $Root
    try {
        $out = $Payload | & powershell -NoProfile -ExecutionPolicy Bypass -File $GuardPath 2>&1
        return [pscustomobject]@{ Code = $LASTEXITCODE; Out = (($out | ForEach-Object { "$_" }) -join "`n") }
    } finally {
        if ($null -eq $prev) { Remove-Item Env:\CLAUDE_PROJECT_DIR -ErrorAction SilentlyContinue }
        else { $env:CLAUDE_PROJECT_DIR = $prev }
    }
}

try {
    Write-Host "== guard-working-copy ==" -ForegroundColor Cyan

    Write-Host ""
    Write-Host "-- group 1: the gate -- identical text, opposite verdicts" -ForegroundColor Cyan

    # 'git reset --soft', not '--hard': since #3901 a hard reset is refused on the main thread too (group 6).
    foreach ($cmd in @('git checkout main', 'git stash', 'git reset --soft HEAD~1',
                       'git checkout HEAD -- scripts/lib/gate-lib.ps1', 'git clean -fd')) {
        Assert-Equal 0 (Invoke-Guard (New-Payload -Command $cmd)).Code                    "main thread may run: $cmd"
        Assert-Equal 2 (Invoke-Guard (New-Payload -Command $cmd -AgentId 'a1')).Code      "a dispatched subagent may not: $cmd"
    }

    foreach ($cmd in @('git status --short', 'git diff main...HEAD', 'git stash list', 'git log --oneline')) {
        Assert-Equal 0 (Invoke-Guard (New-Payload -Command $cmd -AgentId 'a1')).Code      "a subagent may still read: $cmd"
    }

    Write-Host ""
    Write-Host "-- group 2: agent_type is NOT the gate" -ForegroundColor Cyan

    # An --agent session's main thread: agent_type present, agent_id absent. It must pass.
    Assert-Equal 0 (Invoke-Guard (New-Payload -Command 'git checkout main' -AgentType 'my-custom-agent')).Code `
        'an --agent session main thread (agent_type, no agent_id) is NOT a subagent'
    # And with both, it is a subagent.
    Assert-Equal 2 (Invoke-Guard (New-Payload -Command 'git checkout main' -AgentId 'a1' -AgentType 'my-custom-agent')).Code `
        'with agent_id beside it, the same payload IS a subagent'

    Write-Host ""
    Write-Host "-- group 3: the two deliberate fail-OPEN paths" -ForegroundColor Cyan

    Assert-Equal 0 (Invoke-Guard 'git checkout main').Code `
        'a payload that is not JSON at all is treated as the main thread'
    Assert-Equal 0 (Invoke-Guard '{"hook_event_name":"PreToolUse"').Code `
        'and so is a truncated one'
    Assert-Equal 0 (Invoke-Guard (New-Payload -Command '')).Code `
        'an empty command is allowed rather than erroring'

    # A copy of the hook with no lib beside it: a broken install must not brick every shell command.
    New-Item -ItemType Directory -Force -Path (Join-Path $Fixture 'hooks') | Out-Null
    $orphan = Join-Path $Fixture 'hooks\guard-working-copy.ps1'
    Copy-Item -LiteralPath $Guard -Destination $orphan
    $r = Invoke-Guard (New-Payload -Command 'git checkout main' -AgentId 'a1') -GuardPath $orphan
    Assert-Equal 0 $r.Code 'a MISSING lib fails open rather than blocking every command'
    Assert-True ($r.Out -match 'the working-copy guard is OFF for this call') `
        'and says so on stderr, so the hole is visible rather than silent'

    Write-Host ""
    Write-Host "-- group 4: the refusal text" -ForegroundColor Cyan

    $r = Invoke-Guard (New-Payload -Command 'git stash' -AgentId 'a1' -AgentType 'dkj-subagents-developers:victor')
    Assert-Equal 2 $r.Code 'the refusal blocks'
    Assert-True ($r.Out -match 'BLOCKED \(guard-working-copy\)') 'and names itself'
    Assert-True ($r.Out -match 'dkj-subagents-developers:victor')          'and names WHICH specialist was stopped'
    Assert-True ($r.Out -match 'git diff <ref>\.\.\.HEAD')       'and offers the read-only alternative'
    Assert-True ($r.Out -match 'git worktree add')               'and says a second checkout is not blocked'
    Assert-True ($r.Out -match 'a sentence in your') `
        'and says a genuine need for another state is a sentence in the deliverable, not a command'
    Assert-True ($r.Out -match 'no marker or flag that') `
        'and says plainly that nothing authorises it -- unlike guard-live-theme, this has no escape'
    Assert-True ($r.Out -match 'WRITING THIS RULE INTO A FILE') `
        'and tells an AUTHOR that writing the rule is already exempt'

    # Without agent_type there is still a refusal, and it still reads as a sentence.
    $r = Invoke-Guard (New-Payload -Command 'git stash' -AgentId 'a1')
    Assert-True ($r.Out -match 'a dispatched subagent') 'with no agent_type the refusal still names the caller generically'

    Write-Host ""
    Write-Host "-- group 5: the fast path may cause more work, never a different verdict" -ForegroundColor Cyan

    # The pre-gate is a string test on the raw payload. A command whose own text contains the key must
    # still be judged by the real parse -- which says main thread.
    Assert-Equal 0 (Invoke-Guard (New-Payload -Command 'grep -rn ''"agent_id":'' plugins/ && git checkout main')).Code `
        'a main-thread command whose TEXT contains the agent_id key is still the main thread'
    Assert-Equal 2 (Invoke-Guard (New-Payload -Command 'grep -rn ''"agent_id":'' plugins/ && git checkout main' -AgentId 'a1')).Code `
        'and the same command from a subagent is still refused'

    Write-Host ""
    Write-Host "-- group 6: the constitution's force push and hard reset, refused on EVERY thread (#3901)" -ForegroundColor Cyan

    foreach ($cmd in @('git push --force', 'git push -f origin main', 'git push --force-with-lease',
                       'git push origin +main', 'git reset --hard HEAD', 'git reset --hard origin/main')) {
        Assert-Equal 2 (Invoke-Guard (New-Payload -Command $cmd)).Code                    "the main thread may not: $cmd"
        Assert-Equal 2 (Invoke-Guard (New-Payload -Command $cmd -AgentId 'a1')).Code      "nor a subagent: $cmd"
    }
    foreach ($cmd in @('git push', 'git push -u origin feat/x', 'git reset --soft HEAD~1', 'git reset HEAD -- a.txt',
                       'git commit -m "never run git push --force or git reset --hard"')) {
        Assert-Equal 0 (Invoke-Guard (New-Payload -Command $cmd)).Code                    "the main thread may still run: $cmd"
    }

    # THE PRE-GATE READS JSON, where a newline or a tab before `git` is the two characters `\n` or `\t` --
    # which hid it from a `\bgit` test until the review of #3901 caught it. Through the real hook, so the
    # pre-gate is what is being tested.
    foreach ($cmd in @("cd x`ngit push -f", "echo a`ngit reset --hard", "cd x;`tgit reset --hard", "echo a`r`ngit push --force")) {
        Assert-Equal 2 (Invoke-Guard (New-Payload -Command $cmd)).Code "a multi-line command is still judged: $($cmd -replace '\s', ' ')"
    }

    $r = Invoke-Guard (New-Payload -Command 'git push --force')
    Assert-True ($r.Out -match 'BLOCKED \(guard-working-copy\)')  'the refusal is marked as this guard'
    Assert-True ($r.Out -match "owner's explicit permission")      'and names the constitution rule it enforces'
    Assert-True ($r.Out -match 'run it\s+themselves')              'and says the owner runs it themselves'
    Assert-True ($r.Out -notmatch 'This checkout belongs to')      'and is not the subagent working-copy text'

    Write-Host ""
    Write-Host "-- group 7: never directly on the trunk, refused on EVERY thread (#4286)" -ForegroundColor Cyan

    # Throwaway repos, built outside the project so no other session's `git add -A` can sweep them up. One
    # on its trunk, one on a branch, one detached. 'main' is named explicitly: the machine's default may be
    # 'master', which the rule (correctly) does not know as a trunk without origin/HEAD.
    $trunkRepo  = Join-Path $Fixture 'on-trunk'
    $branchRepo = Join-Path $Fixture 'on-branch'
    $detachRepo = Join-Path $Fixture 'detached'
    foreach ($repo in @($trunkRepo, $branchRepo, $detachRepo)) {
        New-Item -ItemType Directory -Force -Path $repo | Out-Null
        Invoke-FixtureGitIn $repo init -q -b main
        Invoke-FixtureGitIn $repo -c user.name=t -c user.email=t@example.invalid commit -q --allow-empty -m 'init'
    }
    Invoke-FixtureGitIn $branchRepo checkout -q -b feat/x
    Invoke-FixtureGitIn $detachRepo checkout -q --detach
    Assert-Equal 'main'   (("$(& git -C $trunkRepo branch --show-current)").Trim()) 'the trunk fixture is on main'
    Assert-Equal 'feat/x' (("$(& git -C $branchRepo branch --show-current)").Trim()) 'the branch fixture is on a branch'

    # The payload's cwd is where the command starts, so the hook reads that repo's HEAD itself.
    $bad = 'git commit -m "fix: cart totals"'
    Assert-Equal 2 (Invoke-Guard (New-Payload -Command $bad -Cwd $trunkRepo)).Code                    'the main thread may not commit on the trunk'
    Assert-Equal 2 (Invoke-Guard (New-Payload -Command $bad -Cwd $trunkRepo -AgentId 'a1')).Code      'nor a subagent'
    Assert-Equal 2 (Invoke-Guard (New-Payload -Command 'git commit -am "wip"' -Cwd $trunkRepo)).Code  'a -am commit'
    Assert-Equal 2 (Invoke-Guard (New-Payload -Command 'git commit' -Cwd $trunkRepo)).Code            'a commit with no message (the editor)'
    foreach ($subject in @('fold: feat/x changelog (#1)', 'release: v1.0.0', 'release-prep: open the 1.x section', 'release-notes: v1.0.0')) {
        Assert-Equal 0 (Invoke-Guard (New-Payload -Command "git commit -m `"$subject`"" -Cwd $trunkRepo)).Code "the trunk allows: $subject"
    }
    Assert-Equal 0 (Invoke-Guard (New-Payload -Command $bad -Cwd $branchRepo)).Code                   'any commit passes on a branch'
    Assert-Equal 0 (Invoke-Guard (New-Payload -Command $bad -Cwd $detachRepo)).Code                   'and on a detached HEAD (fails open)'
    Assert-Equal 0 (Invoke-Guard (New-Payload -Command $bad -Cwd (Join-Path $Fixture 'not-there'))).Code 'and where the directory is not there'
    Assert-Equal 0 (Invoke-Guard (New-Payload -Command $bad -Cwd $Fixture)).Code                       'and where the cwd is not a repo'

    # Which repo: -C and cd outrank the cwd, in both directions.
    Assert-Equal 2 (Invoke-Guard (New-Payload -Command "git -C `"$trunkRepo`" commit -m `"fix: x`"" -Cwd $branchRepo)).Code `
        '-C to the trunk checkout is refused from a branch cwd'
    Assert-Equal 0 (Invoke-Guard (New-Payload -Command "git -C `"$branchRepo`" commit -m `"fix: x`"" -Cwd $trunkRepo)).Code `
        '-C to a branch checkout passes from a trunk cwd'
    Assert-Equal 2 (Invoke-Guard (New-Payload -Command "cd `"$trunkRepo`" && git commit -m `"fix: x`"" -Cwd $branchRepo)).Code `
        'a cd to the trunk checkout is refused'

    # A trunk that origin/HEAD names, which is not 'main'.
    $masterRepo = Join-Path $Fixture 'on-master'
    New-Item -ItemType Directory -Force -Path $masterRepo | Out-Null
    Invoke-FixtureGitIn $masterRepo init -q -b trunk2
    Invoke-FixtureGitIn $masterRepo -c user.name=t -c user.email=t@example.invalid commit -q --allow-empty -m 'init'
    Assert-Equal 0 (Invoke-Guard (New-Payload -Command $bad -Cwd $masterRepo)).Code 'a branch that is neither main nor origin/HEAD is not read as the trunk'
    Invoke-FixtureGitIn $masterRepo update-ref refs/remotes/origin/trunk2 HEAD
    Invoke-FixtureGitIn $masterRepo symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/trunk2
    Assert-Equal 2 (Invoke-Guard (New-Payload -Command $bad -Cwd $masterRepo)).Code 'but one origin/HEAD names is'

    # Commands that are not a commit are not read.
    foreach ($cmd in @('git status --short', 'git log --grep=commit', 'git commit --dry-run', 'echo "git commit -m x"')) {
        Assert-Equal 0 (Invoke-Guard (New-Payload -Command $cmd -Cwd $trunkRepo)).Code "not a trunk commit: $cmd"
    }

    $r = Invoke-Guard (New-Payload -Command $bad -Cwd $trunkRepo)
    Assert-True ($r.Out -match 'BLOCKED \(guard-working-copy\)')   'the refusal is marked as this guard'
    Assert-True ($r.Out -match 'never directly on the trunk')       'and names the constitution rule'
    Assert-True ($r.Out -match 'fold:')                             'and the allowed prefixes'
    Assert-True ($r.Out -match 'new-branch')                        'and the way forward'
    Assert-True ($r.Out -notmatch 'This checkout belongs to')       'and is not the subagent working-copy text'
} finally {
    Remove-Item -Recurse -Force -LiteralPath $Fixture -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Summary: $script:pass passed, $script:fail failed" -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
$fixtureBroken = Write-FixtureGitSummary -Subject 'the working-copy guard hook'
if ($fixtureBroken) { Write-Host "FAILED: every assert passed, but $(Get-FixtureGitFailureCount) fixture git command(s) did not." -ForegroundColor Red }
if ($script:fail -gt 0 -or $fixtureBroken) { exit 1 }
exit 0
