<#
.SYNOPSIS
    The judgement behind the working-copy guard: does this command string mutate the working tree, the
    index or a ref -- and which part of it does.

.DESCRIPTION
    Dot-source this file from a hook or a script:

        . (Join-Path $PSScriptRoot '..\lib\working-copy-guard-lib.ps1')

    Supplies Get-WorkingCopyViolation (the whole judgement, pure) and the pieces under it --
    Get-GitInvocation, Test-HasFlag, Remove-TokenQuotes -- and Get-SafetyRuleViolation, the
    constitution's force-push and hard-reset rule for every thread, built on the same pieces (#3901), and
    Get-TrunkCommitViolation, the constitution's "never directly on the trunk" for every thread (#4286): a
    `git commit` while the targeted repo's HEAD is on its trunk is refused unless its subject starts with
    fold:, release:, release-prep: or release-notes:, the subjects of the three bounded trunk exceptions.
    It fails open on every doubt (not a repo, detached HEAD, trunk unknown). It dot-sources
    command-guard-lib.ps1 from its own directory for the false-positive machinery.

    WHY THE JUDGEMENT IS SPLIT OFF FROM THE HOOK (issue #1669). Same reason fanout-lib.ps1 states for
    its own split: the judgement can then be tested, and MEASURED, without a payload and a process per
    case. #1669 does not merely ask for a guard, it asks for the guard to arrive with a measured
    false-positive rate -- the standard guard-live-theme.ps1 set for this repo. That measurement runs a
    real corpus of thousands of commands through the decision, and it has to be the SAME decision the
    hook makes rather than a second copy of it in a measuring script.

    IT KNOWS ABOUT GIT, AND command-guard-lib DELIBERATELY DOES NOT. The machinery there is generic --
    heredocs, here-strings, segments, wrappers -- and is meant to serve any command guard, including
    dkj-subagents-shopify's, which is about a completely different CLI. Git belongs on this side of that
    line.

    THE CLASS IS ONE CLASS, which is #1669's own correction to #1665. #1665 measured `git stash`
    followed by `git checkout HEAD -- <path>`, so a guard written against that pair reads as
    sufficient. #1669's comment records a later occurrence that a pair-shaped guard would have passed:
    a bare `git checkout <branch>` discards nothing by itself and is the same violation, because it
    carries uncommitted work onto another branch or refuses in the middle of somebody else's work. So
    checkout, switch, restore, reset, stash, clean and the ref mutations are judged together.

    THE READ-ONLY SIBLINGS ARE NAMED, not left to a whole-verb rule: `git stash list`, `git stash
    show`, `git branch` as a listing, `git tag` as a listing, `git clean -n` and reading the reflog all
    share a verb with a destructive form and destroy nothing.

    WHAT IT JUDGES A VIOLATION:

      always                 checkout, switch, restore, reset, rebase, merge, pull, cherry-pick,
                             revert, am, update-ref
      unless read-only       stash (list/show open), clean (-n/--dry-run open),
                             branch (only -d/-D/-f/--force/-m/-M/-c/-C), tag (only -d/-f/--force),
                             reflog (only expire/delete)

    AND WHAT IT DELIBERATELY DOES NOT: `git worktree add` and `git worktree remove`, because the
    working-copy-boundary block explicitly permits a second checkout outside the repo; every
    diff/show/log/status/ls-files/rev-parse read, which is how a reviewer does its job; and
    commit/add/push, which belong to a different block (no-commit-push-pr) and do not discard.

    RESIDUAL LIMITS, STATED RATHER THAN HIDDEN:
      - a script FILE ('bash ./do.sh') is not read, so a git command inside it is not seen;
      - '-EncodedCommand' is not decoded;
      - a text tool asked to execute ('perl -e' with a system() call) is not caught;
      - `git gc --prune=now` and `git prune` can destroy objects a bad reset left unreachable, and are
        NOT judged: the boundary block does not name them, and this enforces that block rather than
        inventing rules beside it;
      - `git fetch` mutates remote-tracking refs and is not judged either, for the same reason and
        because it is how a reviewer reads the remote at all.
    Each is a deliberate trade in the same direction as guard-live-theme's own residual: the vector
    needs somebody to go out of their way, while the false positives the alternative causes happen in
    ordinary work every time a repo documents its own safety rules.

    No Set-StrictMode here: dot-sourcing would change the strict mode of the calling script.
    Pure ASCII (repo convention for .ps1).
    Tested by scripts/tests/working-copy-guard-lib.tests.ps1 -- change one, run the other.
#>

# Unconditional and unguarded, like fanout-lib's own sibling loads: this file is never reached except
# through a dot-source from a caller that already resolved a root, and the sibling travels with it in
# the same mirror.
. (Join-Path $PSScriptRoot 'command-guard-lib.ps1')

# Text and file-write commands that cannot themselves invoke git. NOTE WHAT IS ABSENT: `git` is in
# guard-live-theme's equivalent list, because there a segment led by git is handling text -- here git
# is the subject, and exempting it would exempt everything this guard exists for. `perl` is absent
# too: it is an interpreter, and `perl -e` with a system() call is a stated residual limit rather than
# an exemption.
$script:WcTextTools = @(
    'grep', 'egrep', 'fgrep', 'rg', 'sed', 'awk', 'cat', 'echo', 'printf', 'head', 'tail',
    'less', 'more', 'jq', 'findstr', 'tee', 'diff', 'wc', 'sort', 'uniq', 'tr', 'cut',
    'out-file', 'set-content', 'add-content', 'get-content', 'select-string', 'tee-object',
    'write-output', 'write-host', 'out-string'
)

# Subcommands that mutate the tree, the index or HEAD in every form they have.
$script:WcAlways = @{
    'checkout'    = 'moves this working copy or its HEAD'
    'switch'      = 'moves this working copy to another branch'
    'restore'     = 'overwrites files in this working copy from another state'
    'reset'       = 'moves HEAD or the index, discarding what was staged'
    'rebase'      = 'rewrites this branch and moves the tree with it'
    'merge'       = 'moves HEAD and writes into this working copy'
    'pull'        = 'is a fetch plus a merge, so it moves HEAD and the tree'
    'cherry-pick' = 'writes somebody else''s commit into this working copy'
    'revert'      = 'writes an inverse commit into this working copy'
    'am'          = 'applies a patch series into this working copy'
    'update-ref'  = 'moves a ref directly, destroying whatever was only reachable through it'
}

# git's own global options, which sit BEFORE the subcommand. These take a separate value, so the token
# after them is not the subcommand either.
$script:WcGlobalWithValue = @('-c', '-C', '--git-dir', '--work-tree', '--namespace', '--exec-path', '--super-prefix', '--config-env')

function Remove-TokenQuotes {
    <# A token keeps its quotes through tokenisation, because a quoted run has to stay one token. They
       come off before a token is COMPARED, so a quoted '-d' is still a delete flag. #>
    param([string]$Token)
    $t = [string]$Token
    if ($t.Length -ge 2) {
        $q = $t[0]
        if (($q -eq '"' -or $q -eq "'") -and $t[$t.Length - 1] -eq $q) { return $t.Substring(1, $t.Length - 2) }
    }
    return $t
}

function Get-GitInvocation {
    <# Split a segment led by git into its subcommand and the arguments after it, skipping git's own
       global options. Returns $null when the segment is not a git invocation at all. #>
    param([string]$Segment)

    $s = ([string]$Segment).Trim()
    while ($s -match '^\(?\{?\s*[A-Za-z_][A-Za-z0-9_]*=[^\s]*\s+(.*)$') { $s = $Matches[1].Trim() }
    $s = $s -replace '^[\(\{\s]+', ''
    # PowerShell's call operator, `& git push -f`, is git-led too -- and is how this repo's own docs spell a
    # native call (review of #3901). Stripped here so both rules see it.
    $s = $s -replace '^&\s+', ''

    # Tokenise on whitespace, keeping quoted runs together so a quoted pathspec cannot look like a flag.
    $tokens = @([regex]::Matches($s, '"[^"]*"|''[^'']*''|\S+') | ForEach-Object { $_.Value })
    if ($tokens.Count -eq 0) { return $null }

    # Unquoted before it is compared, so a quoted executable (`"git" push -f`) is still git.
    $lead = ((Remove-TokenQuotes $tokens[0]) -replace '.*[\\/]', '').ToLower()
    if ($lead -ne 'git' -and $lead -ne 'git.exe') { return $null }

    $i = 1
    while ($i -lt $tokens.Count) {
        $t = $tokens[$i]
        if ($t -notmatch '^-') { break }
        $bare = ($t -split '=')[0].ToLower()
        if ($script:WcGlobalWithValue -contains $bare -and $t -notmatch '=') { $i += 2 } else { $i += 1 }
    }
    if ($i -ge $tokens.Count) { return $null }

    # THE RANGE IS GUARDED rather than written as $tokens[($i+1)..($tokens.Count-1)]. With no arguments
    # after the subcommand that range counts DOWN -- 2..1 -- and hands the tokens back reversed with a
    # $null in front. `git stash` and `git clean` both take that path, and both happened to reach the
    # right verdict through it, which is the kind of luck a later edit spends.
    $rest = @()
    if ($i + 1 -le $tokens.Count - 1) { $rest = @($tokens[($i + 1)..($tokens.Count - 1)]) }

    return @{
        Sub  = (Remove-TokenQuotes $tokens[$i]).ToLower()
        Args = @($rest | ForEach-Object { Remove-TokenQuotes $_ })
    }
}

function Test-HasFlag {
    <# Case-SENSITIVE on purpose: -d and -D are different flags, and so are -m/-M and -c/-C. #>
    param([string[]]$Arguments, [string[]]$Flags)

    foreach ($a in $Arguments) {
        $bare = ($a -split '=')[0]
        foreach ($f in $Flags) { if ($bare -ceq $f) { return $true } }
        # Bundled short flags: `git clean -nd` carries -n, and `git branch -Dr` carries -D.
        if ($bare -cmatch '^-[A-Za-z]{2,}$') {
            foreach ($f in $Flags) {
                if ($f -cmatch '^-[A-Za-z]$' -and $bare.Substring(1).Contains($f.Substring(1))) { return $true }
            }
        }
    }
    return $false
}

function Resolve-GuardPath {
    <# Full path without touching the filesystem: the path may not exist, and a guard must not stat
       anything a caller handed it. Returns '' when it cannot be resolved at all. #>
    param([string]$Path, [string]$Base)

    $p = (Remove-TokenQuotes ([string]$Path)).Trim()
    if (-not $p) { return '' }
    try {
        if (-not [System.IO.Path]::IsPathRooted($p) -and $Base) { $p = Join-Path $Base $p }
        return ([System.IO.Path]::GetFullPath($p)).TrimEnd('\', '/')
    } catch { return '' }
}

function Test-PathUnder {
    <# Is $Path the same as, or under, $Root? Case-insensitive and separator-insensitive, because a
       Windows command line spells the same directory four ways. #>
    param([string]$Path, [string]$Root)

    if (-not $Path -or -not $Root) { return $false }
    $a = $Path.Replace('/', '\').TrimEnd('\')
    $b = $Root.Replace('/', '\').TrimEnd('\')
    if ($a -ieq $b) { return $true }
    return $a.StartsWith($b + '\', [System.StringComparison]::OrdinalIgnoreCase)
}

function Test-PathInside {
    <#
    .SYNOPSIS
        Is this path part of the DISPATCHING SESSION'S checkout -- the thing this guard protects?

    .DESCRIPTION
        Under the project root, with one carve-out.

        A DISPATCHED AGENT'S OWN WORKTREE IS NOT THE DISPATCHING SESSION'S CHECKOUT, even though the
        harness puts it inside the repo. `.claude/worktrees/agent-<id>` is where an agent granted
        worktree isolation works, and this repo's own .gitignore records that the location is the
        harness's choice rather than anything the repo picked -- there is no seam that would move it
        outside the tree the way worktree-lane.ps1 places a lane in a sibling '<repo>-lanes/'
        directory.

        So a plain "under the root" test would refuse an isolated agent every command inside its own
        tree, which is the one place it is entitled to run all of them. That is not a rate to accept:
        it would break the harness feature whose entire purpose is to make this hazard impossible.

        THE LANE DIRECTORY NEEDS NO CARVE-OUT for the mirror-image reason: a lane worktree is a
        SIBLING of the repo, so it is already outside the root and the ordinary rule covers it.
    #>
    param([string]$Path, [string]$Root)

    if (-not (Test-PathUnder -Path $Path -Root $Root)) { return $false }
    if (Test-PathUnder -Path $Path -Root (Join-Path $Root '.claude\worktrees')) { return $false }
    return $true
}

function Get-SegmentCdTarget {
    <# The directory a segment changes into (`cd`, `chdir`, `Set-Location`, `sl`, `pushd`), still quoted as
       written, or '' when the segment is not a directory change. Shared by the project-scope rule and the
       trunk-commit rule (#4286), so the two cannot disagree about what a `cd` is. #>
    param([string]$Segment)

    $m = [regex]::Match([string]$Segment, '(?i)^\s*(?:cd|chdir|set-location|sl|pushd)\s+(?:-LiteralPath\s+|-Path\s+)?("[^"]*"|''[^'']*''|[^\s;|&]+)')
    if ($m.Success) { return $m.Groups[1].Value }
    return ''
}

function Test-CommandLeavesProject {
    <#
    .SYNOPSIS
        Does this whole command work in a repo that is NOT the dispatching session's checkout?

    .DESCRIPTION
        THE MEASURED FALSE POSITIVE THIS ANSWERS (issue #1669, September 9, 2026). Run over the 995
        Bash/PowerShell calls this repo's dispatched subagents have actually made, the judgement
        refused 12. Eleven were real crossings of the boundary -- including both commands #1665
        measured and the `git checkout` #1669's own comment records. The twelfth was

            cd /tmp/grtest2 && git log --oneline
            git checkout $(git rev-parse HEAD)

        a test engineer working in its own throwaway FIXTURE repo, which cannot discard anybody's
        work. That is not a concession to a rate, it is the guard's actual scope: the subject is the
        dispatching session's checkout, and a git command aimed at another repo is out of scope by
        construction. This repo makes the class recurrent rather than incidental -- it ships
        scripts/lib/fixture-git-lib.ps1, so building a fixture repo is routine work here.

        IT CANNOT BE USED AS A BYPASS, and that is what the second half of the rule is for. A command
        that steps out and then steps BACK IN is not exempt: every `cd` target is resolved, and one
        landing inside the project (or a path that cannot be resolved at all) settles it as inside. So
        `cd /tmp && cd <project> && git reset --hard` is judged, and so is anything whose directory
        this file cannot work out -- failing towards checking, the same direction as everything else
        in this pair of libs.

        A git invocation's OWN `-C` / `--work-tree` / `--git-dir` is stronger than any of this and is
        read per invocation by the caller, so `cd /tmp && git -C <project> checkout main` is judged
        too.
    #>
    param([string]$Command, [string]$ProjectRoot, [string]$Cwd = '')

    if (-not $ProjectRoot) { return $false }

    $root = Resolve-GuardPath -Path $ProjectRoot -Base ''
    if (-not $root) { return $false }

    # WHERE THE COMMAND STARTS, which is the tool's own working directory rather than the project
    # root. The two differ in exactly the case that matters: an agent granted worktree isolation runs
    # with its cwd already inside .claude/worktrees/agent-<id>, and a command there carries no `cd` to
    # give the game away. Starting from the root instead would refuse that agent every command in the
    # one tree it owns outright.
    $start = if ($Cwd) { Resolve-GuardPath -Path $Cwd -Base '' } else { $root }
    if (-not $start) { $start = $root }

    $targets = New-Object System.Collections.Generic.List[string]
    foreach ($segment in (Split-CommandSegments $Command)) {
        $s = $segment.Trim()
        if (-not $s) { continue }
        $cdTarget = Get-SegmentCdTarget $s
        if ($cdTarget) { $targets.Add($cdTarget) }
    }

    # No `cd` at all: the answer is wherever the tool was already standing.
    if ($targets.Count -eq 0) { return (-not (Test-PathInside -Path $start -Root $root)) }

    foreach ($t in $targets) {
        $full = Resolve-GuardPath -Path $t -Base $start
        # An unresolvable target is treated as inside: a guard must not exempt what it cannot read.
        if (-not $full) { return $false }
        if (Test-PathInside -Path $full -Root $root) { return $false }
    }
    return $true
}

function Get-InvocationTargetDirection {
    <# Where does THIS git invocation point, if it says so itself? Returns 'inside', 'outside' or ''
       (it did not say). Read from -C / --work-tree / --git-dir, which override any `cd`. #>
    param([hashtable]$Invocation, [string]$Segment, [string]$ProjectRoot, [string]$Cwd = '')

    if (-not $ProjectRoot) { return '' }
    $root = Resolve-GuardPath -Path $ProjectRoot -Base ''
    if (-not $root) { return '' }

    $m = [regex]::Match($Segment, '(?:^|\s)(?:-C\s+|--work-tree(?:=|\s+)|--git-dir(?:=|\s+))("[^"]*"|''[^'']*''|[^\s;|&]+)')
    if (-not $m.Success) { return '' }

    $full = Resolve-GuardPath -Path $m.Groups[1].Value -Base $root
    if (-not $full) { return 'inside' }
    # A --git-dir of '<project>\.git' is the project; Test-PathInside answers that without a special case.
    if (Test-PathInside -Path $full -Root $root) { return 'inside' }
    return 'outside'
}

function Get-WorkingCopyViolation {
    <#
    .SYNOPSIS
        The judgement. Returns $null when nothing in this command mutates the working copy, or
        @{ Sub; Reason; Segment } for the first thing that does.

    .DESCRIPTION
        Pure: it reads a string and returns a verdict. It does NOT decide whether the caller is
        allowed to run it -- that gate is agent_id, and it belongs to the hook.

        IT MATCHES THE SUBCOMMAND POSITION, WHICH IS THE STRONGER ANSWER to the false-positive lesson
        guard-live-theme.ps1 records. Where that guard matches its patterns anywhere in a segment, this
        reads the segment's leading command and then git's own subcommand. That is what lets

            git commit -m "the reviewer must never run git checkout HEAD -- <path>"

        through, and no heredoc or text-tool exemption would have saved it: the segment IS led by git.
        A guard that cannot describe its own rule in a commit message is one somebody switches off.

        -ProjectRoot IS OPTIONAL AND OMITTING IT JUDGES EVERYTHING. It is what makes "this command
        works in a fixture repo somewhere else" answerable, and with no root there is no question to
        answer -- so the whole directory rule is skipped and every git invocation is judged, which is
        the failing-towards-checking direction. See Test-CommandLeavesProject.
    #>
    param([string]$Command, [string]$ProjectRoot = '', [string]$Cwd = '')

    if (-not $Command) { return $null }

    $leavesProject = Test-CommandLeavesProject -Command $Command -ProjectRoot $ProjectRoot -Cwd $Cwd

    # THE ONE PLACE THIS MATCHES ANYWHERE RATHER THAN IN SUBCOMMAND POSITION, and the narrow condition
    # is what makes it affordable. `echo "git stash" | bash` really does run git stash, and no segment
    # of it is LED by git -- so the subcommand rule, which is what keeps this guard quiet, cannot see
    # it. Test-CommandExecutesText is already computed by the machinery for its own reasons (it is what
    # switches the heredoc and text-tool exemptions off), so when it is true the guard has been told,
    # by the command itself, that text somewhere in here is about to be executed. Only then does the
    # whole string become fair game.
    #
    # MEASURED BEFORE IT WAS KEPT, and the number is zero: across all 9084 Bash/PowerShell calls in
    # this repo's transcripts -- 8089 from the main thread and 995 from dispatched subagents -- there
    # is not ONE command this rule refuses that the subcommand rule did not already refuse. So it
    # closes a real hole at no measured cost. It stays narrow anyway, gated on that flag rather than
    # applied generally, because a match-anywhere rule is exactly what guard-live-theme's first
    # version was and its header records what that cost.
    if ((Test-CommandExecutesText $Command) -and (-not $leavesProject)) {
        $verbs = (@($script:WcAlways.Keys) + @('stash', 'clean')) -join '|'
        $m = [regex]::Match($Command, "(?i)\bgit\s+($verbs)\b")
        if ($m.Success) {
            $sub = $m.Groups[1].Value.ToLower()
            return @{
                Sub = $sub; Segment = $m.Value
                Reason = "``git $sub`` sits inside text this command pipes into an interpreter, so it runs -- and this checkout is not a dispatched subagent's to move."
            }
        }
    }

    foreach ($segment in (Get-GuardSegments -Command $Command -TextTools $script:WcTextTools)) {
        $git = Get-GitInvocation $segment
        if ($null -eq $git) { continue }

        # The invocation's own -C / --work-tree / --git-dir outranks any `cd`, in both directions.
        $direction = Get-InvocationTargetDirection -Invocation $git -Segment $segment -ProjectRoot $ProjectRoot -Cwd $Cwd
        if ($direction -eq 'outside') { continue }
        if ($direction -ne 'inside' -and $leavesProject) { continue }

        if ($script:WcAlways.ContainsKey($git.Sub)) {
            return @{ Sub = $git.Sub; Segment = $segment; Reason = "``git $($git.Sub)`` $($script:WcAlways[$git.Sub]), and is never a dispatched subagent's to run." }
        }

        $first = if ($git.Args.Count -gt 0) { ([string]$git.Args[0]).ToLower() } else { '' }

        switch ($git.Sub) {
            'stash' {
                # A bare `git stash` IS `git stash push`, which is why the empty case is a violation and
                # not an exemption: that is the exact command #1665 measured.
                if ($first -ne 'list' -and $first -ne 'show') {
                    return @{ Sub = 'stash'; Segment = $segment; Reason = "``git stash`` puts the dispatching session's uncommitted work away, where a clean ``git status`` then hides it. ``git stash list`` and ``git stash show`` are not blocked." }
                }
            }
            'clean' {
                if (-not (Test-HasFlag -Arguments $git.Args -Flags @('-n', '--dry-run'))) {
                    return @{ Sub = 'clean'; Segment = $segment; Reason = "``git clean`` deletes untracked files outright, and there is no reflog for those. ``git clean -n`` is not blocked." }
                }
            }
            'branch' {
                if (Test-HasFlag -Arguments $git.Args -Flags @('-d', '-D', '--delete', '-f', '--force', '-m', '-M', '--move', '-c', '-C', '--copy')) {
                    return @{ Sub = 'branch'; Segment = $segment; Reason = "``git branch`` with a delete, force or move flag destroys work that may be reachable only through that pointer. Listing branches is not blocked." }
                }
            }
            'tag' {
                if (Test-HasFlag -Arguments $git.Args -Flags @('-d', '--delete', '-f', '--force')) {
                    return @{ Sub = 'tag'; Segment = $segment; Reason = "``git tag`` with a delete or force flag moves or removes a ref somebody's work hangs from. Listing tags is not blocked." }
                }
            }
            'reflog' {
                # The reflog is the ONLY recovery path left after a bad checkout or reset, which is why
                # expiring it counts here even though it leaves the tree alone.
                if ($first -eq 'expire' -or $first -eq 'delete') {
                    return @{ Sub = 'reflog'; Segment = $segment; Reason = "``git reflog $first`` destroys the only record by which a discarded commit could still be found. Reading the reflog is not blocked." }
                }
            }
        }
    }

    return $null
}

function Test-HasAbbreviatedFlag {
    <# git accepts any UNIQUE prefix of a long option, so `--force-w` is --force-with-lease and `--ha` is
       --hard -- measured in a throwaway repo by the security review of #3901, where `git push --force-w`
       printed "(forced update)". -MinLength is the shortest prefix git reads as unique for that command:
       `--force-w` (9) for push, whose `--forc` is ambiguous and errors, and `--ha` (4) for reset. #>
    param([string[]]$Arguments, [string]$Flag, [int]$MinLength)

    foreach ($a in $Arguments) {
        $bare = ([string]$a -split '=')[0]
        if ($bare.Length -ge $MinLength -and $bare.Length -le $Flag.Length -and $Flag.StartsWith($bare, [System.StringComparison]::Ordinal)) { return $true }
    }
    return $false
}

function Get-SafetyRuleViolation {
    <#
    .SYNOPSIS
        The constitution's "never without the owner's explicit permission" git commands. Returns $null,
        or @{ Sub; Reason; Segment } for the first command in this string that breaks one.

    .DESCRIPTION
        THE OWNER CHOSE THIS ROUTE (#3901, November 8, 2026). A plugin cannot ship `deny` or `ask`
        permission rules (a plugin settings.json honours only `agent` and `subagentStatusLine`), so the
        rules sat as a suggestion in specialists-init that a consumer had to apply. Extending this guard
        makes the enforcement ship with the plugin, with no consumer setting to change.

        WHAT IT JUDGES, FOR EVERY THREAD (the hook asks it before its agent_id gate):

          git push    with -f, --force, --force-with-lease, --mirror, or a `+` refspec (`+main`, `HEAD:+main`)
          git reset   with --hard

        THE SAME PARSING AS Get-WorkingCopyViolation, and that is the point of putting it here: only a
        segment LED by git counts, at git's own subcommand position, so a commit message, a heredoc or a
        grep that names the rule is not refused. The one match-anywhere case is the same narrow one too:
        text the command itself pipes into an interpreter.

        NO PROJECT SCOPE, which is where it parts from the working-copy rule. That rule protects one
        checkout from a subagent, so a fixture repo elsewhere is out of its scope. The constitution says
        `git push --force` "on any branch", in any repo, so a `-C` or a `cd` elsewhere exempts nothing.
        Fixture tests are not affected: they run git inside a script file, which no hook reads.

        MEASURED BEFORE IT SHIPPED (November 9, 2026): over the 4593 Bash/PowerShell calls in this repo's
        transcripts, it refused one: a heredoc piped into `python -` that wrote these very test cases, a
        false positive of the match-anywhere case. Re-run after this branch's own reviews (4638 calls), it
        refused eight, and every new one was a reviewer probing this rule: seven scripts that wrote the
        commands as test data and ran them, and one throwaway `mktemp` repo where a force push was tried for
        real. Outside that, the corpus holds no force push or hard reset at all. The refusal names the
        Edit/Write tool for the first class. The second is the price of having no project scope.

        IT GUARDS AGAINST A CARELESS CALL, NOT AN ADVERSARY. It shares Get-GitInvocation's limits with the
        working-copy rule: a wrapper in front of git (`env X=1 git`, `time git`, `sudo git`, `command git`,
        `cmd /c git`, `wsl git`), a compound keyword (`if ...; then git ...; fi`, `for ...; do`), nested
        quoting (`bash -lc`, `bash -c "bash -c \"...\""`), `Start-Process git -ArgumentList`, a git alias
        (`git -c alias.p=push p -f`, or one set with `git config alias.*`), a git held in a variable
        (`& $g push -f`), and another tool moving the ref (`gh api` on `git/refs`) are not read. Each needs a
        detour; the residual limits in this file's header apply as well. An abbreviated long option IS
        read (Test-HasAbbreviatedFlag), because git accepts one and a typo reaches it innocently.

        ON A HOST WITHOUT POWERSHELL IT DOES NOT RUN AT ALL, and on the main thread the hooks.json wrapper
        lets a call through when PowerShell cannot start. It is a backstop against a session's own slip,
        enforced where the hook can run, not a security boundary.

        THE MAIN THREAD STAYS UNGUARDED for everything else that discards work -- `git checkout -f`,
        `git clean -fdx`, `git branch -D`, `git push --delete`, `git update-ref` -- because the
        constitution names only the force push and the hard reset (and rebase, below).

        AND WHAT IT DELIBERATELY DOES NOT JUDGE: `git rebase` "on a shared branch". Whether a branch is
        shared is not in the command string, so a rule here would refuse every local rebase or none. For
        a subagent, Get-WorkingCopyViolation already refuses every rebase.
    #>
    param([string]$Command)

    if (-not $Command) { return $null }

    $pushReason = '`git push` with a force flag or a `+` refspec overwrites history on the remote, and the constitution allows it only with the owner''s explicit permission.'
    $resetReason = '`git reset --hard` discards uncommitted work with no reflog to recover it from, and the constitution allows it only with the owner''s explicit permission.'

    if (Test-CommandExecutesText $Command) {
        $m = [regex]::Match($Command, '(?i)\bgit\s+push\b[^|;&\r\n]*\s(?:-f\b|--force\b|--force-w[a-z-]*|--mirror\b|\+\S|\S*:\+\S)')
        if ($m.Success) { return @{ Sub = 'push'; Segment = $m.Value; Reason = $pushReason } }
        $m = [regex]::Match($Command, '(?i)\bgit\s+reset\b[^|;&\r\n]*\s--ha(?:rd?)?\b')
        if ($m.Success) { return @{ Sub = 'reset'; Segment = $m.Value; Reason = $resetReason } }
    }

    foreach ($segment in (Get-GuardSegments -Command $Command -TextTools $script:WcTextTools)) {
        $git = Get-GitInvocation $segment
        if ($null -eq $git) { continue }

        switch ($git.Sub) {
            'push' {
                # A force refspec carries its `+` at the front (`+main`) or on the destination (`HEAD:+main`).
                $plusRefspec = @($git.Args | Where-Object { ([string]$_) -match '^\+|:\+' }).Count -gt 0
                if ($plusRefspec -or (Test-HasFlag -Arguments $git.Args -Flags @('-f', '--force', '--force-with-lease', '--mirror')) -or
                    (Test-HasAbbreviatedFlag -Arguments $git.Args -Flag '--force-with-lease' -MinLength 9)) {
                    return @{ Sub = 'push'; Segment = $segment; Reason = $pushReason }
                }
            }
            'reset' {
                if ((Test-HasFlag -Arguments $git.Args -Flags @('--hard')) -or
                    (Test-HasAbbreviatedFlag -Arguments $git.Args -Flag '--hard' -MinLength 4)) {
                    return @{ Sub = 'reset'; Segment = $segment; Reason = $resetReason }
                }
            }
        }
    }

    return $null
}

# ---------------------------------------------------------------------------------------------------
# THE TRUNK-COMMIT RULE (#4286): the constitution's "never directly on the trunk", as a refusal.
# ---------------------------------------------------------------------------------------------------

# The subjects the three bounded trunk exceptions write: the fold commit ('fold:'), the release commit
# ('release:'), the major's two preparation commits ('release-prep:') and the release-notes commit, which
# older releases wrote as 'release-notes:' and newer ones as a 'release: vX.Y.Z release notes' subject
# (so it is covered by 'release:'). Measured from this repo's first-parent history when the rule was written:
# every direct trunk commit uses exactly these; 'park:' commits happen on branches only, and a merge commit
# comes from GitHub. Case-sensitive on purpose, like the other flag comparisons in this file.
$script:TrunkCommitSubjectPattern = '^(?:fold|release|release-prep|release-notes):'

function Get-GuardGitLine {
    <# One trimmed line of a git read in $Dir, or '' when git is missing, fails or answers nothing. Never
       throws: the caller fails OPEN on '' (this is a refusal in every consumer, so a wrong one blocks work). #>
    param([string]$Dir, [string[]]$GitArgs)

    $ErrorActionPreference = 'Continue'
    try {
        $out = & git -C $Dir @GitArgs 2>$null
        if ($LASTEXITCODE -ne 0) { return '' }
        return ("$(@($out) | Where-Object { "$_".Trim() } | Select-Object -First 1)").Trim()
    } catch { return '' }
}

function Get-TrunkCommitRepoFacts {
    <#
        The two facts the trunk-commit rule needs about the repo a commit targets: @{ Branch; Trunk }, or
        $null when either cannot be established (not a repo, git unreadable, a detached HEAD, a directory
        that is not there). $null means ALLOW: the rule fails open on every doubt.

        THE TRUNK IS READ THE WAY trunk-sync-lib.ps1 reads it (Invoke-TrunkFastForward): origin/HEAD's
        short name, else 'main'. entry-scaffold-lib's Get-BranchTrunkName adds a consumer seam on top of
        'main' (Get-TrunkBranchName in scripts/repo-config.ps1), but it lives in an 8000-line lib that a
        hook firing on every commit must not load, and the seam would run consumer code inside a refusal.
        A consumer whose trunk is neither origin/HEAD's nor 'main' is therefore simply not covered, which
        is the fail-open direction.
    #>
    param([string]$Dir)

    $d = if ($Dir) { $Dir } else { (Get-Location).Path }
    if (-not (Test-Path -LiteralPath $d -PathType Container)) { return $null }

    $branch = Get-GuardGitLine -Dir $d -GitArgs @('symbolic-ref', '--quiet', '--short', 'HEAD')
    if (-not $branch) { return $null }

    $trunk = (Get-GuardGitLine -Dir $d -GitArgs @('symbolic-ref', '--quiet', '--short', 'refs/remotes/origin/HEAD')) -replace '^origin/', ''
    if (-not $trunk) { $trunk = 'main' }
    return @{ Branch = $branch; Trunk = $trunk }
}

function Remove-CommitTokenQuotes {
    <# Quotes out of one token, wherever they sit: `"fold: x"`, `-m"fold: x"` and `--message="fold: x"` all
       reach git as the same value. An unterminated quote runs to the end of the token. #>
    param([string]$Token)
    $eval = [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $m.Groups[1].Value + $m.Groups[2].Value }
    return [regex]::Replace([string]$Token, '"([^"]*)"?|''([^'']*)''?', $eval)
}

function Get-CommitMessageSource {
    <#
        Where does this `git commit` take its message from? Returns @{ Kind; Value } with Kind one of
          'subject'    -m / --message: Value is the first -m's text (git's subject);
          'file'       -F / --file alone: Value is the path;
          'none'       no message option at all (git would open an editor, or reuse the amended message);
          'unreadable' a source the command text does not show: -C/-c/--reuse-message/--reedit-message,
                       --fixup/--squash, -t/--template, or -F together with -m (git's own answer is not
                       one a guard should guess at).

        THE OPTION WALK IS GIT'S, NOT A SEARCH FOR '-m'. A short cluster is read left to right and the
        first value-taking letter (m F C c t) swallows the rest of the cluster as its value, so `-nm` is
        no-verify plus a message, while `-Fm "fold: x"` is a message FILE named 'm' and `-cm "fold: x"`
        reuses a commit -- both are NOT the subject a lazy `-m` search would credit. S and u take the
        rest of the cluster as an optional value, so `-umm` carries no message. Long options may be
        abbreviated to a unique prefix, and every abbreviation of a source option counts as that option
        (an ambiguous one fails towards 'unreadable'). The first -m is the subject: `-m wip -m "fold: x"`
        is a 'wip' commit with a paragraph. These are the edge cases a store-side guard this rule was
        modelled on measured; the parser is this lib's own.
    #>
    param([string]$After)

    $tokens = @([regex]::Matches([string]$After, '(?:"[^"]*(?:"|$)|''[^'']*(?:''|$)|[^\s"''])+') | ForEach-Object { Remove-CommitTokenQuotes $_.Value })

    $haveM = $false; $firstM = $null; $haveFile = $false; $file = $null; $foreign = $false
    $i = 0
    while ($i -lt $tokens.Count) {
        $t = [string]$tokens[$i]; $i++
        if ($t -ceq '--') { break }

        if ($t -cmatch '^--') {
            $parts = $t -split '=', 2
            $name = $parts[0]
            $val = $null
            if ($parts.Count -eq 2) { $val = $parts[1] }
            if ($name.Length -ge 3 -and '--message'.StartsWith($name, [System.StringComparison]::Ordinal)) {
                if ($null -eq $val -and $i -lt $tokens.Count) { $val = [string]$tokens[$i]; $i++ }
                if (-not $haveM) { $haveM = $true; $firstM = $val }
            } elseif ($name.Length -ge 5 -and '--file'.StartsWith($name, [System.StringComparison]::Ordinal)) {
                if ($null -eq $val -and $i -lt $tokens.Count) { $val = [string]$tokens[$i]; $i++ }
                $haveFile = $true; $file = $val
            } elseif ($name.Length -ge 4) {
                foreach ($long in @('--reuse-message', '--reedit-message', '--fixup', '--squash', '--template')) {
                    if ($long.StartsWith($name, [System.StringComparison]::Ordinal)) { $foreign = $true }
                }
            }
            continue
        }

        if ($t -cmatch '^-[A-Za-z]') {
            for ($k = 1; $k -lt $t.Length; $k++) {
                $c = $t[$k]
                if ('mFCct'.IndexOf($c) -ge 0) {
                    $val = $t.Substring($k + 1)
                    if ($val.Length -eq 0) {
                        if ($i -lt $tokens.Count) { $val = [string]$tokens[$i]; $i++ } else { $val = $null }
                    }
                    if ($c -ceq 'm') { if (-not $haveM) { $haveM = $true; $firstM = $val } }
                    elseif ($c -ceq 'F') { $haveFile = $true; $file = $val }
                    else { $foreign = $true }
                    break
                }
                if ('Su'.IndexOf($c) -ge 0) { break }
            }
        }
    }

    if ($foreign) { return @{ Kind = 'unreadable'; Value = '' } }
    if ($haveM -and $haveFile) { return @{ Kind = 'unreadable'; Value = '' } }
    if ($haveFile) { return @{ Kind = 'file'; Value = [string]$file } }
    if ($haveM) { return @{ Kind = 'subject'; Value = [string]$firstM } }
    return @{ Kind = 'none'; Value = '' }
}

function Get-FirstLineAfterSegment {
    <# The first non-empty line of the raw command AFTER the line that holds $Segment -- the subject of a
       heredoc or a PowerShell here-string that the segment only OPENS (a `$(cat <<` substitution, `-m @'`).
       The segment pipeline strips those bodies, so the text has to come from the raw command. '' when it
       cannot be found. #>
    param([string]$Raw, [string]$Segment)

    $seg = [string]$Segment
    $idx = $Raw.IndexOf($seg, [System.StringComparison]::Ordinal)
    if ($idx -lt 0) { $seg = $seg.TrimEnd(); $idx = $Raw.IndexOf($seg, [System.StringComparison]::Ordinal) }
    if ($idx -lt 0) { return '' }
    $tail = $Raw.Substring($idx + $seg.Length)
    $m = [regex]::Match($tail, '^[^\r\n]*\r?\n(?:[ \t]*\r?\n)*[ \t]*([^\r\n]*)')
    if ($m.Success) { return $m.Groups[1].Value.Trim() }
    return ''
}

function Get-TrunkCommitViolation {
    <#
    .SYNOPSIS
        The constitution's "never directly on the trunk": a `git commit` run while the repo it targets has
        its HEAD on the trunk is refused unless its subject starts with fold:, release:, release-prep: or
        release-notes: -- the three bounded exceptions, which are recognised by subject because nothing
        else about a commit says which kind it is. Returns $null, or @{ Sub; Reason; Segment }.

    .DESCRIPTION
        PURE UP TO ONE INJECTED READ. -ResolveFacts is called with the directory a commit targets and
        returns @{ Branch; Trunk } or $null (default: Get-TrunkCommitRepoFacts, which reads git). A suite
        passes its own, so every case is a string and a hashtable. $null, an empty Branch (detached HEAD)
        or a branch that is not the trunk means ALLOW -- every doubt fails open, because this is a new
        refusal in every consumer and a wrong refusal blocks work. Only a file given by `-F` is read from
        disk.

        THE SAME PARSING AS THE OTHER RULES IN THIS FILE: only a segment LED by git counts, at git's own
        subcommand position, so `echo "git commit -m x"` or a commit message that names the rule is not
        refused. WHICH REPO is read from the invocation's own `-C <path>`, else from the last `cd` /
        `Set-Location` / `pushd` before it in the same command, else -Cwd; `--git-dir` / `--work-tree`
        or a directory that cannot be resolved means allow.

        THE SUBJECT, per Get-CommitMessageSource: the first -m (or --message=) is read, however it is
        quoted or bundled (`-am`, `-nm`, `-m"fold: x"`); `-F <file>` reads the file's first line when
        the file exists (relative to the target directory); a heredoc or here-string that only opens in
        the segment (a `$(cat <<` substitution, `-m @'`) reads the first line after it from the raw
        command; a message source the text does not show (a variable, `-F -`, `-C`, `--fixup`) and a
        commit with NO message (the editor, or `--amend --no-edit`) are refused on the trunk, because a
        trunk commit with no readable allowed subject is not one the rule can let through. `--dry-run`
        commits nothing and passes.

        RESIDUAL LIMITS, STATED: a `git commit` inside a script FILE the command runs (the fold script
        makes the fold commit itself) is not visible, which is also why the exceptions are not in the way;
        a wrapper in front of git (`env`, `sudo`, `time`) and a git alias are not read, as for the other
        rules; and the subject is the guard's reading of the command text, not of the commit git then
        writes, so the rule stops a careless commit on the trunk, not a determined one.
    #>
    param([string]$Command, [string]$Cwd = '', [scriptblock]$ResolveFacts = $null)

    if (-not $Command) { return $null }
    if ($Command -notmatch '(?i)commit') { return $null }

    $dir = ''
    if ($Cwd) { $dir = Resolve-GuardPath -Path $Cwd -Base ''; if (-not $dir) { $dir = $null } }

    foreach ($segment in (Get-GuardSegments -Command $Command -TextTools $script:WcTextTools)) {
        $cd = Get-SegmentCdTarget $segment
        if ($cd) {
            if ($null -ne $dir) { $r = Resolve-GuardPath -Path $cd -Base $dir; $dir = if ($r) { $r } else { $null } }
            continue
        }

        $git = Get-GitInvocation $segment
        if ($null -eq $git -or $git.Sub -ne 'commit') { continue }

        # Where git is told to run, from the text BEFORE the subcommand (a `-C` after it is a commit
        # option). --git-dir / --work-tree name a repo this rule does not read: allow.
        $cm = [regex]::Match($segment, '(?:^|\s)commit(?=\s|$)')
        if (-not $cm.Success) { continue }
        $before = $segment.Substring(0, $cm.Index)
        $after = $segment.Substring($cm.Index + $cm.Length)
        if ($before -match '(?:^|\s)(?:--git-dir|--work-tree)\b') { continue }

        $target = $dir
        foreach ($c in [regex]::Matches($before, '(?:^|\s)-C\s+("[^"]*"|''[^'']*''|\S+)')) {
            if ($null -eq $target) { break }
            $r = Resolve-GuardPath -Path $c.Groups[1].Value -Base $target
            $target = if ($r) { $r } else { $null }
        }
        if ($null -eq $target) { continue }

        if ($after -match '(?:^|\s)--dry-run(?=\s|$)') { continue }

        $facts = if ($ResolveFacts) { & $ResolveFacts $target } else { Get-TrunkCommitRepoFacts -Dir $target }
        if ($null -eq $facts -or -not $facts.Branch -or -not $facts.Trunk) { continue }
        if ($facts.Branch -cne $facts.Trunk) { continue }

        $src = Get-CommitMessageSource -After $after
        $subject = $null
        $why = ''
        switch ($src.Kind) {
            'subject' {
                $v = [string]$src.Value
                if ($v -match '^@$' -or $v -match '<<') { $subject = Get-FirstLineAfterSegment -Raw $Command -Segment $segment }
                elseif ($v -match '^\$' -or $v.Contains('`')) { $why = 'its message comes from a variable or a command substitution' }
                else { $subject = ($v -split '\r?\n')[0] }
            }
            'file' {
                $f = Resolve-GuardPath -Path ([string]$src.Value) -Base $target
                if ($f -and (Test-Path -LiteralPath $f -PathType Leaf)) {
                    $line = Get-Content -LiteralPath $f -TotalCount 20 -ErrorAction SilentlyContinue | Where-Object { "$_".Trim() } | Select-Object -First 1
                    if ($line) { $subject = [string]$line }
                }
                if ($null -eq $subject) { $why = 'its message file cannot be read' }
            }
            'none' { $why = 'it has no -m message, so git would open an editor or reuse the amended one' }
            default { $why = 'its message comes from a source the command text does not show' }
        }

        if ($null -ne $subject -and ($subject.TrimStart() -cmatch $script:TrunkCommitSubjectPattern)) { continue }

        $shown = if ($null -ne $subject -and $subject.Trim()) { "the subject '" + $subject.Trim() + "'" } elseif ($why) { "no readable subject (" + $why + ")" } else { 'an empty subject' }
        return @{
            Sub = 'commit'; Segment = $segment
            Reason = "``git commit`` on the trunk ('$($facts.Trunk)') with $shown. The constitution says never directly on the trunk, always via a branch and a pull request; only the fold, release, release-prep and release-notes commits land here, and they are recognised by a subject starting with ``fold:``, ``release:``, ``release-prep:`` or ``release-notes:``. Open a branch first (the ``new-branch`` skill) and commit there."
        }
    }

    return $null
}
