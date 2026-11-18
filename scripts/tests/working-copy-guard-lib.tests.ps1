<#
.SYNOPSIS
    Tests for scripts/lib/working-copy-guard-lib.ps1 -- the judgement behind the working-copy guard:
    which git commands mutate the dispatching session's tree, index or refs.

.DESCRIPTION
    IN-PROCESS, AND THAT IS THE POINT OF THE SPLIT. The judgement is a pure function, so a case costs
    a function call rather than a process and a payload. The hook's own suite
    (guard-working-copy.tests.ps1) covers the parts that need a real invocation: the agent_id gate,
    the exit codes and the refusal wording.

    SIX GROUPS.
      1. The class, as ONE class. #1665 measured `git stash` plus `git checkout HEAD -- <path>`, so a
         guard shaped like that pair reads as sufficient; #1669's comment records a later occurrence a
         pair-shaped guard would have passed. Every member of the class is asserted here, including
         the ones no incident has produced yet.
      2. The read-only siblings stay open BY NAME. `git stash list`, a `git branch` listing, a `git
         tag` listing, `git clean -n` and reading the reflog share a verb with a destructive form.
         Blocking a whole verb would have been shorter and would refuse a reviewer reading whether a
         stash exists.
      3. Describing the rule is not performing it -- the subcommand position, which is this guard's
         own answer to the lesson guard-live-theme.ps1 paid for. `git commit -m "never run git
         checkout HEAD -- <path>"` is the case no heredoc or text-tool exemption would have saved,
         because the segment IS led by git.
      4. Group 3 must not become a hole: wrappers, second segments, and text piped into a shell.
      5. THE MEASURED FALSE POSITIVE, and every shape that must not turn its exemption into a bypass.
         Run over the 995 real dispatched-subagent calls in this repo's transcripts, the judgement
         refused 12; eleven were real crossings and the twelfth was a test engineer working in its own
         fixture repo under /tmp. The exemption is scope rather than tolerance -- and a command that
         steps out and back IN is still judged, in all three ways it can step back.
      6. An agent with worktree isolation owns its own tree. The harness puts that worktree INSIDE the
         repo (.claude/worktrees/agent-<id>), so a plain "under the root" test would refuse such an
         agent every command in the one tree it is entitled to move. No incident produced this group:
         it is the feature whose whole purpose is to make this hazard impossible, and refusing it
         would be the guard breaking its own remedy.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $RepoRoot 'scripts\lib\working-copy-guard-lib.ps1')

# A stable, invented project root: the assertions are about path REASONING, and must not depend on
# where this checkout happens to live or on anything existing on disk.
$Proj = 'C:\work\myrepo'
$script:pass = 0
$script:fail = 0

function Assert-Violation {
    param([string]$Command, [string]$Name, [string]$Cwd = $Proj, [string]$ExpectSub = '')
    $v = Get-WorkingCopyViolation -Command $Command -ProjectRoot $Proj -Cwd $Cwd
    if ($null -eq $v) {
        $script:fail++; Write-Host "  [FAIL] $Name`n         expected a violation, got none" -ForegroundColor Red
        return
    }
    if ($ExpectSub -and $v.Sub -ne $ExpectSub) {
        $script:fail++; Write-Host "  [FAIL] $Name`n         expected sub '$ExpectSub', got '$($v.Sub)'" -ForegroundColor Red
        return
    }
    $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green
}

function Assert-Clean {
    param([string]$Command, [string]$Name, [string]$Cwd = $Proj)
    $v = Get-WorkingCopyViolation -Command $Command -ProjectRoot $Proj -Cwd $Cwd
    if ($null -eq $v) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Name`n         expected none, got a '$($v.Sub)' violation on: $($v.Segment)" -ForegroundColor Red }
}

Write-Host "== working-copy-guard-lib ==" -ForegroundColor Cyan

Write-Host ""
Write-Host "-- group 1: the class, and it is ONE class" -ForegroundColor Cyan

# The two commands #1665 actually measured.
Assert-Violation 'git stash' 'the bare stash #1665 measured -- a bare stash IS a push' -ExpectSub 'stash'
Assert-Violation 'git checkout HEAD -- scripts/lib/gate-lib.ps1' 'the checkout HEAD -- <path> #1665 measured' -ExpectSub 'checkout'
# The command #1669's comment measured, which a pair-shaped guard would have passed.
Assert-Violation 'git checkout fix/1682-porcelain-line-parse' 'the bare branch checkout #1669 measured' -ExpectSub 'checkout'

foreach ($sub in @('checkout main', 'switch -c feat/x', 'restore --staged .', 'reset --hard HEAD',
                   'rebase origin/main', 'merge origin/main', 'pull --ff-only',
                   'cherry-pick abc1234', 'revert HEAD', 'am /tmp/p.patch',
                   'update-ref refs/heads/x HEAD')) {
    Assert-Violation "git $sub" "git $sub"
}
Assert-Violation 'git stash pop'   'stash pop moves the tree too'          -ExpectSub 'stash'
Assert-Violation 'git stash -u'    'stash -u takes untracked files as well' -ExpectSub 'stash'
Assert-Violation 'git clean -fd'   'clean -fd deletes untracked files'      -ExpectSub 'clean'
Assert-Violation 'git branch -D old/thing' 'branch -D destroys a pointer'   -ExpectSub 'branch'
Assert-Violation 'git branch -f main HEAD' 'branch -f moves one'            -ExpectSub 'branch'
Assert-Violation 'git tag -d v4.0.0'       'tag -d removes a ref'           -ExpectSub 'tag'
Assert-Violation 'git tag -f v4.0.0 HEAD'  'tag -f moves one'               -ExpectSub 'tag'
Assert-Violation 'git reflog expire --expire=now --all' 'reflog expire destroys the last recovery path' -ExpectSub 'reflog'
# git's own global options sit before the subcommand and must not hide it.
Assert-Violation 'git -C . checkout main'                    'a -C global option does not hide the subcommand'
Assert-Violation 'git -c core.quotePath=true reset --hard'   'nor does a -c config override'
Assert-Violation 'git --no-pager checkout main'              'nor a valueless global flag'
Assert-Violation 'git.exe checkout main'                     'git.exe is git'
# BOTH -n AND --force IS A DRY RUN, AND THAT WAS VERIFIED AGAINST GIT RATHER THAN REASONED. This
# assertion was first written the other way round -- judged on the --force, on the assumption that the
# more dangerous flag wins -- and the suite caught it. Measured in a throwaway repo: `git clean -nd
# --force` prints "Would remove untracked.txt", exits 0, and the file is still there afterwards. So
# exempting it is not leniency, it is what the command does.
Assert-Clean 'git clean -nd --force' 'clean with BOTH -n and --force is a dry run, so nothing is discarded'

Write-Host ""
Write-Host "-- group 2: the read-only siblings stay open" -ForegroundColor Cyan

foreach ($c in @('git stash list', 'git stash show -p', 'git branch', 'git branch -av',
                 'git branch --show-current', 'git tag', 'git tag -l "v4*"', 'git clean -n',
                 'git clean --dry-run', 'git clean -nd', 'git reflog', 'git reflog -n 5',
                 'git status --short', 'git diff origin/main...HEAD', 'git diff main -- a.ps1',
                 'git show HEAD:a.ps1', 'git log --oneline -5', 'git ls-files', 'git rev-parse HEAD',
                 'git fetch origin -q', 'git worktree add /tmp/probe origin/main',
                 'git worktree list', 'git worktree remove /tmp/probe')) {
    Assert-Clean $c $c
}
Assert-Clean 'git commit -m "a change"' 'commit belongs to another block and does not discard'
Assert-Clean 'git add -A'               'and so does add'
Assert-Clean 'npm test'                 'an unrelated command is not git'
Assert-Clean ''                         'an empty command is not a violation'

Write-Host ""
Write-Host "-- group 3: describing the rule is not performing it" -ForegroundColor Cyan

Assert-Clean 'git commit -m "the reviewer must never run git checkout HEAD -- <path>"' `
    'THE CASE THE SUBCOMMAND POSITION EXISTS FOR: a commit message naming the rule'
Assert-Clean 'git commit -m "fix: git stash and git reset are now refused"' `
    'and one naming two members of the class'
Assert-Clean 'echo "never run git stash in a dispatched agent"' 'echoing the rule'
Assert-Clean 'grep -rn "git checkout HEAD --" plugins/'         'searching for the rule'
Assert-Clean "cat > doc.md <<'EOF'`nnever run git stash here`ngit checkout HEAD -- x is forbidden`nEOF" `
    'a heredoc writing the rule into a file'
Assert-Clean "`$doc = @'`ngit reset --hard is never yours to run`n'@`n`$doc | Out-File notes.md" `
    'a here-string writing the rule into a file'
Assert-Clean 'git log --oneline --grep="git stash"' 'searching history for the words'

Write-Host ""
Write-Host "-- group 4: the counter-cases that make group 3 safe" -ForegroundColor Cyan

Assert-Violation 'bash -c "git reset --hard origin/main"'    'a bash -c wrapper is re-scanned'
Assert-Violation 'powershell -Command "git checkout main"'   'a powershell -Command wrapper too'
Assert-Violation 'echo hi && git checkout main'              'a real command after a harmless one'
Assert-Violation "echo hi`ngit stash"                        'a real command on the next line'
Assert-Violation 'echo "git stash" | bash'                   'text piped into a shell really runs'
Assert-Violation 'eval "git reset --hard"'                   'and so does eval'

Write-Host ""
Write-Host "-- group 5: the measured false positive, and its bypasses" -ForegroundColor Cyan

# The twelfth refusal in the corpus measurement, verbatim in shape: a fixture repo under /tmp.
Assert-Clean 'cd /tmp/grtest2 && git log --oneline && git checkout $(git rev-parse HEAD)' `
    'THE MEASURED FALSE POSITIVE: a fixture repo outside the project is out of scope'
Assert-Clean 'cd C:\work\other && git reset --hard'      'so is another checkout entirely'
Assert-Clean 'git -C C:\work\other reset --hard'         'and a -C into one'
Assert-Clean 'cd C:\work\myrepo-lanes\fix--x && git checkout main' `
    'a lane worktree is a SIBLING of the repo, so the ordinary rule already covers it'

Assert-Violation 'cd /tmp/grtest2 && cd C:\work\myrepo && git reset --hard' `
    'stepping out and back IN is judged -- the exemption is not a bypass'
Assert-Violation 'cd /tmp/grtest2 && git -C C:\work\myrepo checkout main' `
    'a -C back in outranks the cd out'
Assert-Violation 'cd /tmp/grtest2 && git --work-tree=C:\work\myrepo checkout main' `
    'and so does a --work-tree back in'
Assert-Violation 'cd /tmp/grtest2 && git --git-dir=C:\work\myrepo\.git checkout main' `
    'and a --git-dir back in'
Assert-Violation 'cd scripts && git checkout HEAD -- lib/gate-lib.ps1' `
    'a RELATIVE cd stays inside the project'
Assert-Violation 'cd "C:\work\myrepo" && git stash' `
    'a quoted cd to the project itself is inside'
Assert-Violation 'cd $SOMEWHERE && git reset --hard' `
    'a cd this file cannot resolve is treated as inside -- never exempt what cannot be read'

# With no project root there is no question to answer, so everything is judged.
$v = Get-WorkingCopyViolation -Command 'cd /tmp/grtest2 && git reset --hard'
if ($null -ne $v) { $script:pass++; Write-Host "  [PASS] with NO project root the directory rule is skipped and everything is judged" -ForegroundColor Green }
else { $script:fail++; Write-Host "  [FAIL] with NO project root the directory rule is skipped and everything is judged" -ForegroundColor Red }

Write-Host ""
Write-Host "-- group 6: an isolated agent owns its own worktree" -ForegroundColor Cyan

$wt = 'C:\work\myrepo\.claude\worktrees\agent-a1'
Assert-Clean 'git checkout main' 'an agent standing in its OWN worktree may move it' -Cwd $wt
Assert-Clean 'git reset --hard'  'and reset it'                                      -Cwd $wt
Assert-Clean 'cd C:\work\myrepo\.claude\worktrees\agent-a1 && git stash' 'reached by an explicit cd, too'
Assert-Violation 'cd C:\work\myrepo && git reset --hard' `
    'but a cd back to the dispatching checkout is judged' -Cwd $wt
Assert-Violation 'git -C C:\work\myrepo reset --hard' `
    'and so is a -C back to it' -Cwd $wt

Write-Host ""
Write-Host "-- the pieces, directly" -ForegroundColor Cyan

$inv = Get-GitInvocation 'git -C . checkout HEAD -- a.ps1'
Assert-Violation 'git checkout main' 'sanity: the judgement is reachable'
if ($inv.Sub -eq 'checkout') { $script:pass++; Write-Host "  [PASS] Get-GitInvocation reads past global options to the subcommand" -ForegroundColor Green }
else { $script:fail++; Write-Host "  [FAIL] Get-GitInvocation reads past global options to the subcommand (got '$($inv.Sub)')" -ForegroundColor Red }

$inv = Get-GitInvocation 'git stash'
if ($inv.Args.Count -eq 0) { $script:pass++; Write-Host "  [PASS] a subcommand with no arguments yields an EMPTY argument list, not a reversed one" -ForegroundColor Green }
else { $script:fail++; Write-Host "  [FAIL] a subcommand with no arguments yields an empty argument list (got $($inv.Args.Count): $($inv.Args -join ','))" -ForegroundColor Red }

if ($null -eq (Get-GitInvocation 'npm run build')) { $script:pass++; Write-Host "  [PASS] a non-git segment is not an invocation" -ForegroundColor Green }
else { $script:fail++; Write-Host "  [FAIL] a non-git segment is not an invocation" -ForegroundColor Red }

# Case sensitivity is a real property here: -d and -D are different flags, as are -m/-M and -c/-C.
if (Test-HasFlag -Arguments @('-D') -Flags @('-D')) { $script:pass++; Write-Host "  [PASS] Test-HasFlag matches -D" -ForegroundColor Green }
else { $script:fail++; Write-Host "  [FAIL] Test-HasFlag matches -D" -ForegroundColor Red }
if (-not (Test-HasFlag -Arguments @('-a') -Flags @('-D'))) { $script:pass++; Write-Host "  [PASS] and does not match an unrelated short flag" -ForegroundColor Green }
else { $script:fail++; Write-Host "  [FAIL] and does not match an unrelated short flag" -ForegroundColor Red }
if (Test-HasFlag -Arguments @('-nd') -Flags @('-n')) { $script:pass++; Write-Host "  [PASS] and finds a flag inside a BUNDLE (-nd carries -n)" -ForegroundColor Green }
else { $script:fail++; Write-Host "  [FAIL] and finds a flag inside a bundle (-nd carries -n)" -ForegroundColor Red }
if (-not (Test-HasFlag -Arguments @('--contains') -Flags @('-c'))) { $script:pass++; Write-Host "  [PASS] and does not read a long flag as a bundle of short ones" -ForegroundColor Green }
else { $script:fail++; Write-Host "  [FAIL] and does not read a long flag as a bundle of short ones" -ForegroundColor Red }

Write-Host ""
Write-Host "-- group: Get-SafetyRuleViolation, the force push and hard reset rule (#3901)" -ForegroundColor Cyan

function Assert-Safety {
    param([string]$Command, [string]$Name, [string]$ExpectSub = '')
    $v = Get-SafetyRuleViolation -Command $Command
    $ok = if ($ExpectSub) { $null -ne $v -and $v.Sub -eq $ExpectSub } else { $null -eq $v }
    if ($ok) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Name`n         expected '$ExpectSub', got '$(if ($v) { $v.Sub } else { 'none' })'" -ForegroundColor Red }
}

Assert-Safety 'git push --force'                       'push --force'                                  -ExpectSub 'push'
Assert-Safety 'git push -f origin main'                'push -f'                                       -ExpectSub 'push'
Assert-Safety 'git push -uf origin feat/x'             'a bundled -f (-uf carries -f)'                 -ExpectSub 'push'
Assert-Safety 'git push --force-with-lease'            'a lease is still a force push'                 -ExpectSub 'push'
Assert-Safety 'git push --force-with-lease=main:abc'   'and so is a lease with a value'                -ExpectSub 'push'
Assert-Safety 'git push origin +main'                  'a + refspec is a force push'                   -ExpectSub 'push'
Assert-Safety 'git push origin "+HEAD:main"'           'and so is a quoted one'                        -ExpectSub 'push'
Assert-Safety 'git -C ../other push --force'           'another repo is not exempt: "on any branch"'   -ExpectSub 'push'
Assert-Safety 'cd /tmp/fixture && git reset --hard'    'nor is a cd elsewhere'                         -ExpectSub 'reset'
Assert-Safety 'git reset --hard HEAD'                  'reset --hard'                                  -ExpectSub 'reset'
Assert-Safety 'git status && git reset --hard origin/main' 'a later segment is still judged'           -ExpectSub 'reset'
Assert-Safety 'echo "git push --force" | bash'         'text piped into an interpreter runs'           -ExpectSub 'push'
# The review of #3901 found these four open.
Assert-Safety 'git push origin HEAD:+main'             'a + on the destination is a force refspec too' -ExpectSub 'push'
Assert-Safety 'git push --mirror'                      'a mirror push forces every ref'                -ExpectSub 'push'
Assert-Safety '& git push -f'                          'the PowerShell call operator is git-led'       -ExpectSub 'push'
Assert-Safety '"git" reset --hard'                     'and so is a quoted executable'                 -ExpectSub 'reset'
Assert-Safety "echo a`ngit reset --hard"               'a hard reset on a second line'                 -ExpectSub 'reset'
# git accepts a unique prefix of a long option; the security review saw `--force-w` force a push.
Assert-Safety 'git push --force-w origin HEAD'         'an abbreviated --force-with-lease'             -ExpectSub 'push'
Assert-Safety 'git push --force-with origin HEAD'      'and a longer abbreviation'                     -ExpectSub 'push'
Assert-Safety 'git reset --ha HEAD~1'                  'an abbreviated --hard'                         -ExpectSub 'reset'
Assert-Safety 'git reset --har'                        'and --har'                                     -ExpectSub 'reset'
Assert-Safety 'echo "git reset --har" | bash'          'and through the interpreter branch'            -ExpectSub 'reset'
Assert-Safety 'git push --forc'                        '--forc is ambiguous to git and errors, so it is no force'
Assert-Safety 'git reset --hash'                       'a longer word is not a prefix of --hard'

Assert-Safety 'git push'                               'a plain push is fine'
Assert-Safety 'git push -u origin feat/x'              'and so is setting an upstream'
Assert-Safety 'git push --force-if-includes'           'force-if-includes alone forces nothing'
Assert-Safety 'git reset --soft HEAD~1'                'a soft reset is not a hard one'
Assert-Safety 'git reset HEAD -- a.txt'                'nor is unstaging a path'
Assert-Safety 'git rebase origin/main'                 'rebase is out of scope: "shared" is not in the string'
Assert-Safety 'git commit -m "never git push --force"' 'a commit message naming the rule is not the rule'
Assert-Safety 'grep -rn "reset --hard" plugins/'       'nor is a grep for it'
Assert-Safety ''                                       'an empty command is no violation'

# ---------------------------------------------------------------------------------------------------
Write-Host ""
Write-Host "-- group 8: never directly on the trunk, except the three bounded commits (#4286)" -ForegroundColor Cyan

# Pure judgement: the repo facts are injected, so no case needs a repo. A fixed fake table keyed by the
# directory a commit targets; anything not in it is 'unknown' (fail open).
$script:TrunkFacts = {
    param($Dir)
    switch -Wildcard ($Dir) {
        'C:\work\onmain'   { return @{ Branch = 'main'; Trunk = 'main' } }
        'C:\work\onbranch' { return @{ Branch = 'feat/x'; Trunk = 'main' } }
        'C:\work\detached' { return $null }
        'C:\work\master'   { return @{ Branch = 'master'; Trunk = 'master' } }
        default            { return $null }
    }
}
function Assert-TrunkCommit {
    param([string]$Command, [string]$Name, [string]$Cwd = 'C:\work\onmain', [switch]$Refused)
    $v = Get-TrunkCommitViolation -Command $Command -Cwd $Cwd -ResolveFacts $script:TrunkFacts
    $got = $null -ne $v
    if ($got -eq [bool]$Refused) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    elseif ($got) { $script:fail++; Write-Host "  [FAIL] $Name`n         expected allow, refused: $($v.Reason)" -ForegroundColor Red }
    else { $script:fail++; Write-Host "  [FAIL] $Name`n         expected a refusal, got none" -ForegroundColor Red }
}

# The four subjects the bounded exceptions write pass on the trunk.
Assert-TrunkCommit 'git commit -m "fold: feat/x changelog (#12)"'      'fold: passes'
Assert-TrunkCommit 'git commit -m "release: v7.1.0"'                   'release: passes'
Assert-TrunkCommit 'git commit -m "release-prep: open the 7.x section"' 'release-prep: passes'
Assert-TrunkCommit 'git commit -m "release-notes: v6.1.0"'             'the historical release-notes: passes'
Assert-TrunkCommit "git commit -m 'fold: x'"                           'single quotes pass'
Assert-TrunkCommit 'git commit --message="fold: x"'                    '--message= passes'
Assert-TrunkCommit 'git commit --message "fold: x"'                    '--message <value> passes'
Assert-TrunkCommit 'git commit -nm "fold: x"'                          'a bundled -nm passes'
Assert-TrunkCommit 'git commit -m"fold: x"'                            'an attached -m"..." passes'
Assert-TrunkCommit 'git commit -m "fold: x" -m "body; with & chars"'   'a later -m is a paragraph, not the subject'
Assert-TrunkCommit 'git add -A && git commit -m "fold: x" 2>&1'        'a chain with a redirect passes'

# Everything else is refused on the trunk.
Assert-TrunkCommit 'git commit -m "fix: cart totals"'      'a fix: subject is refused'          -Refused
Assert-TrunkCommit 'git commit -am "wip"'                  '-am is refused'                     -Refused
Assert-TrunkCommit 'git commit -m "park: feat/x"'          'park: belongs on a branch'          -Refused
Assert-TrunkCommit 'git commit -m "Fold: x"'               'the prefix is case-sensitive'       -Refused
Assert-TrunkCommit 'git commit -m "folder: x"'             'a prefix of another word is no match' -Refused
Assert-TrunkCommit 'git commit -m "x fold: y"'             'the prefix must START the subject'  -Refused
Assert-TrunkCommit 'git add . ; git commit -m "docs: x"'   'a later segment is judged'          -Refused
Assert-TrunkCommit 'echo done && git commit -m "fix: x"'   'and so is one after a harmless command' -Refused
Assert-TrunkCommit 'git commit -m "fold: x" && git commit -m "fix: y"' 'one allowed commit does not cover the next' -Refused
Assert-TrunkCommit '& git commit -m "fix: x"'              'the PowerShell call operator is git-led' -Refused
Assert-TrunkCommit 'git commit --amend -m "fix: x"'        'an amend with a bad new subject'    -Refused
Assert-TrunkCommit 'git commit --amend -m "fold: x"'       'an amend with an allowed new subject passes' -Refused:$false
Assert-TrunkCommit 'git commit --amend --no-edit'          'an amend that keeps the old message has no readable subject' -Refused
Assert-TrunkCommit 'git commit --amend'                    'an amend through the editor'        -Refused

# The first -m is the subject, and the foreign message sources are not the subject.
Assert-TrunkCommit 'git commit -m wip -m "fold: x"'        'a wip subject with a fold: paragraph is a wip commit' -Refused
Assert-TrunkCommit 'git commit -m wip --message="release: v9"' 'and the long form too'          -Refused
Assert-TrunkCommit 'git commit -mwip -m "fold: x"'         'an attached first -m'               -Refused
Assert-TrunkCommit 'git commit --mess wip -m "fold: x"'    'an abbreviated --message'           -Refused
Assert-TrunkCommit 'git commit "-m" wip -m "fold: x"'      'a quoted -m'                        -Refused
Assert-TrunkCommit 'git commit -Fm "fold: x"'              '-Fm is a message FILE named m'      -Refused
Assert-TrunkCommit 'git commit -cm "fold: x"'              '-cm reuses a commit'                -Refused
Assert-TrunkCommit 'git commit -umm "fold: x"'             '-umm carries a mode, not a message' -Refused
Assert-TrunkCommit 'git commit -m=fold:x'                  '-m=v is the value =v'               -Refused
Assert-TrunkCommit 'git commit -C HEAD -m "fold: x"'       '-C reuses a message'                -Refused
Assert-TrunkCommit 'git commit --fixup=HEAD -m "fold: x"'  '--fixup writes its own subject'     -Refused
Assert-TrunkCommit 'git commit --reuse-message=HEAD'       '--reuse-message'                    -Refused
Assert-TrunkCommit 'git commit -F msg.txt -m "fold: x"'    '-F beside -m is not guessed at'     -Refused
Assert-TrunkCommit 'git commit -m "$msg"'                  'a variable message is unreadable'   -Refused
Assert-TrunkCommit 'git commit -m "$(date)"'               'a command substitution is unreadable' -Refused
Assert-TrunkCommit 'git commit'                            'no message at all (the editor)'     -Refused
Assert-TrunkCommit 'git commit -a'                         'a commit with only flags'           -Refused
Assert-TrunkCommit 'git commit -m'                         'a -m with no value'                 -Refused
Assert-TrunkCommit 'git commit -- -m "fold: x"'            'after -- nothing is an option'      -Refused

# -F: the file's first line is the subject, read when the file exists.
$msgDir = Join-Path ([System.IO.Path]::GetTempPath()) "wcg-msg-$PID"
New-Item -ItemType Directory -Force -Path $msgDir | Out-Null
try {
    Set-Content -LiteralPath (Join-Path $msgDir 'ok.txt') -Value @('', 'fold: feat/x changelog (#1)', '', 'body') -Encoding Ascii
    Set-Content -LiteralPath (Join-Path $msgDir 'bad.txt') -Value @('fix: something', 'body') -Encoding Ascii
    Set-Content -LiteralPath (Join-Path $msgDir 'blank.txt') -Value @('', '  ') -Encoding Ascii
    $facts = { param($d) @{ Branch = 'main'; Trunk = 'main' } }
    function Assert-TrunkCommitIn {
        param([string]$Command, [string]$Name, [switch]$Refused)
        $v = Get-TrunkCommitViolation -Command $Command -Cwd $msgDir -ResolveFacts $facts
        if (($null -ne $v) -eq [bool]$Refused) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
        else { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
    }
    Assert-TrunkCommitIn 'git commit -F ok.txt'                          '-F reads the first non-empty line: allowed'
    Assert-TrunkCommitIn "git commit --file=ok.txt"                      '--file= too'
    Assert-TrunkCommitIn ('git commit -F "' + (Join-Path $msgDir 'ok.txt') + '"') 'an absolute quoted path'
    Assert-TrunkCommitIn 'git commit -F bad.txt'                         '-F with a bad subject'              -Refused
    Assert-TrunkCommitIn 'git commit -F missing.txt'                     '-F with a file that is not there'   -Refused
    Assert-TrunkCommitIn 'git commit -F blank.txt'                       '-F with an empty file'              -Refused
    Assert-TrunkCommitIn 'git commit -F -'                               '-F - (stdin) is unreadable'         -Refused
} finally {
    Remove-Item -Recurse -Force -LiteralPath $msgDir -ErrorAction SilentlyContinue
}

# A heredoc or here-string that only OPENS in the segment: the subject is the first line after it.
$nl = "`n"
Assert-TrunkCommit ('git commit -m "$(cat <<' + "'EOF'" + $nl + 'fold: feat/x changelog (#9)' + $nl + $nl + 'body' + $nl + 'EOF' + $nl + ')"') `
    'a heredoc subject that is allowed passes'
Assert-TrunkCommit ('git commit -m "$(cat <<' + "'EOF'" + $nl + 'fix: something' + $nl + 'EOF' + $nl + ')"') `
    'a heredoc subject that is not is refused' -Refused
Assert-TrunkCommit ('git commit -m "$(cat <<EOF' + $nl + 'fold: x' + $nl + 'EOF' + $nl + ')"') `
    'an unquoted heredoc opener reads the same way'
Assert-TrunkCommit ('git add -A' + $nl + 'git commit -m "$(cat <<' + "'EOF'" + $nl + 'release: v1.2.3' + $nl + 'EOF' + $nl + ')"') `
    'a heredoc after another line'
Assert-TrunkCommit ("git commit -m @'" + $nl + 'fold: x' + $nl + "'@") 'a PowerShell here-string subject that is allowed'
Assert-TrunkCommit ("git commit -m @'" + $nl + 'wip' + $nl + "'@") 'and one that is not'  -Refused
Assert-TrunkCommit ('git commit -m "$(cat <<' + "'EOF'" + $nl + 'EOF' + $nl + ')"') 'an empty heredoc has no subject' -Refused

# On a branch, and wherever the rule cannot be sure, any commit passes.
Assert-TrunkCommit 'git commit -m "fix: anything"'  'any subject on a branch'                       -Cwd 'C:\work\onbranch'
Assert-TrunkCommit 'git commit'                     'even the editor on a branch'                  -Cwd 'C:\work\onbranch'
Assert-TrunkCommit 'git commit -m "fix: x"'         'a detached HEAD or non-repo (facts unknown)'  -Cwd 'C:\work\detached'
Assert-TrunkCommit 'git commit -m "fix: x"'         'a directory the facts do not know'            -Cwd 'C:\work\nowhere'
Assert-TrunkCommit 'git commit -m "fix: x"'         'no cwd at all and unknown facts' -Cwd ''
Assert-TrunkCommit 'git commit -m "fix: x"'         'a trunk that is not main (master) is judged as the trunk' -Cwd 'C:\work\master' -Refused

# Which repo: -C and cd, in either direction.
Assert-TrunkCommit 'git -C C:\work\onbranch commit -m "fix: x"'  '-C to a branch checkout overrides a trunk cwd'
Assert-TrunkCommit 'git -C C:\work\onmain commit -m "fix: x"'    '-C to a trunk checkout overrides a branch cwd'  -Cwd 'C:\work\onbranch' -Refused
Assert-TrunkCommit 'git -C "C:\work\onmain" commit -m "fix: x"'  'a quoted -C'                                      -Cwd 'C:\work\onbranch' -Refused
Assert-TrunkCommit 'git -C ..\onmain commit -m "fix: x"'         'a relative -C resolves against the cwd'            -Cwd 'C:\work\onbranch' -Refused
Assert-TrunkCommit 'git -C C:\work\onbranch commit -m "fold: x"' 'an allowed subject passes either way'
Assert-TrunkCommit 'cd C:\work\onbranch && git commit -m "fix: x"' 'a cd to a branch checkout'
Assert-TrunkCommit 'cd C:\work\onmain && git commit -m "fix: x"'   'a cd to a trunk checkout'  -Cwd 'C:\work\onbranch' -Refused
Assert-TrunkCommit 'Set-Location C:\work\onmain; git commit -m "fix: x"' 'Set-Location is a cd'   -Cwd 'C:\work\onbranch' -Refused
Assert-TrunkCommit 'git --git-dir=C:\other\.git commit -m "fix: x"' '--git-dir names a repo the rule does not read'
Assert-TrunkCommit 'git commit -C HEAD'                           'a -C AFTER commit is a commit option, not a directory' -Refused

# Not a commit, or not a git command: untouched.
Assert-TrunkCommit 'git status --short'                           'status is not a commit'
Assert-TrunkCommit 'git log --grep=commit'                        'a log that names commit'
Assert-TrunkCommit 'git commit-tree HEAD^{tree}'                  'commit-tree is another subcommand'
Assert-TrunkCommit 'git commit --dry-run'                         '--dry-run commits nothing'
Assert-TrunkCommit 'echo "git commit -m x"'                       'an echo that names a commit'
Assert-TrunkCommit 'grep -rn "git commit" plugins/'               'a grep for it'
Assert-TrunkCommit 'git push origin feat/x'                       'a push is another rule'
Assert-TrunkCommit 'gh pr create --title "fix: commit"'           'a non-git command naming commit'
Assert-TrunkCommit ''                                              'an empty command'
Assert-TrunkCommit ('cat > note.md <<' + "'EOF'" + $nl + 'git commit -m "fix: x"' + $nl + 'EOF') 'a heredoc body that writes the rule is data'

# The wording a refusal carries.
$r = Get-TrunkCommitViolation -Command 'git commit -m "fix: x"' -Cwd 'C:\work\onmain' -ResolveFacts $script:TrunkFacts
foreach ($needle in @('never directly on the trunk', 'fold:', 'release:', 'release-prep:', 'release-notes:', 'new-branch', "'main'", "subject 'fix: x'")) {
    if ($r.Reason.Contains($needle)) { $script:pass++; Write-Host "  [PASS] the refusal names: $needle" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] the refusal does not name: $needle`n         $($r.Reason)" -ForegroundColor Red }
}

Write-Host ""
Write-Host "Summary: $script:pass passed, $script:fail failed" -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 }
exit 0
