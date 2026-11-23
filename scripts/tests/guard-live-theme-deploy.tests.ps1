<#
.SYNOPSIS
    Tests for guard-live-theme.ps1's rule 5 routes onto a Git-connected live theme's deploy branch
    (#4329) and its merged-only live push (#3758, group 10).

.DESCRIPTION
    Split out of guard-live-theme.tests.ps1 (#4430), which keeps groups 1 to 9, the session check and
    rule 5's git push (#3014). The setup both share is guard-live-theme-fixture.ps1, which says why the
    file was cut.

    Each case feeds a realistic hook payload to the guard on stdin and asserts the exit code
    (2 = blocked, 0 = allowed), or the refusal text where the wording is the property. No mocking: the
    guard is invoked as the harness invokes it.

    Pure ASCII (repo convention for .ps1).
#>. (Join-Path $PSScriptRoot 'guard-live-theme-fixture.ps1')

try {
    Write-Host "== guard-live-theme-deploy.tests: the deploy-branch routes and the merged-only live push ==" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $Fixture | Out-Null

    # THE FIXTURES THIS PART SHARES WITH PART 1, rebuilt here in the state part 1 leaves them in: the
    # Git-connected repo with HEAD on the deploy branch, a worktree-lane stand-in on a work branch, and
    # the placeholder and narrowed answers to the deploy-branch seam.
    $conn = New-FixtureRepo -Label 'conn' -ConfigBody $deployCfg
    Invoke-FixtureGitIn $conn init -q
    Invoke-FixtureGitIn $conn symbolic-ref HEAD refs/heads/live
    $lane = Join-Path $Fixture 'conn-lane'
    New-Item -ItemType Directory -Force -Path $lane | Out-Null
    Invoke-FixtureGitIn $lane init -q
    Invoke-FixtureGitIn $lane symbolic-ref HEAD refs/heads/feat/y
    $connPlaceholder = New-FixtureRepo -Label 'conn-placeholder' -ConfigBody "function Get-ShopifyLiveDeployBranch { return 'VUL-IN: the deploy branch' }"
    $connNarrow = New-FixtureRepo -Label 'conn-narrow' -ConfigBody "function Get-ShopifyLiveDeployBranch { return 'live' }${LF}function Get-ShopifyLivePushMarker { return 'SWB-LIVE-PUSH-AUTHORIZED' }"
    # --- rule 5, the other routes onto the deploy branch (#4329) --------------------------------------
    # The owner reversed #3014's "the promotion PR is deliberately ungated": a PR based on the deploy
    # branch, a writing gh api call on it and a local write while it is checked out each need the marker.
    Write-Host "rule 5 -- the promotion PR, gh api and local writes onto the deploy branch (#4329)" -ForegroundColor Cyan
    $c2 = New-FixtureRepo -Label 'conn-routes' -ConfigBody $deployCfg
    Invoke-FixtureGitIn $c2 init -q
    Invoke-FixtureGitIn $c2 symbolic-ref HEAD refs/heads/main
    $mk5 = '# LIVE-PUSH-AUTHORIZED'

    $routeBlocked = @(
        @{ n = 'pr create --base live';               c = 'gh pr create --base live --head main --title x' },
        @{ n = 'pr create --base=live';               c = 'gh pr create --base=live --title x' },
        @{ n = 'pr create -B live';                   c = 'gh pr create -B live --title x' },
        @{ n = 'pr create -Blive';                    c = 'gh pr create -Blive --title x' },
        @{ n = 'pr create -B=live';                   c = 'gh pr create -B=live' },
        @{ n = 'pr create quoted value';              c = 'gh pr create --base "live" --title x' },
        @{ n = 'pr create single-quoted =value';      c = "gh pr create --base='live'" },
        @{ n = 'pr create refs/heads/live';           c = 'gh pr create --base refs/heads/live' },
        @{ n = 'pr create different case';            c = 'gh pr create --base LIVE' },
        @{ n = 'pr edit --base live';                 c = 'gh pr edit 12 --base live' },
        @{ n = 'pr create base from a variable';      c = 'gh pr create --base $B' },
        @{ n = 'pr create base from a substitution';  c = 'gh pr create --base $(echo live)' },
        @{ n = 'pr create base in backticks';         c = 'gh pr create --base `echo live`' },
        @{ n = 'pr create after another command';     c = 'git status && gh pr create --base live' },
        @{ n = 'pr create wrapped in bash -c';        c = 'bash -c "gh pr create --base live"' },
        @{ n = 'api POST git/refs/heads/live';        c = 'gh api -X POST repos/o/r/git/refs/heads/live' },
        @{ n = 'api PATCH git/refs/heads/live';       c = 'gh api --method PATCH repos/o/r/git/refs/heads/live -f sha=abc' },
        @{ n = 'api -XDELETE';                        c = 'gh api -XDELETE repos/o/r/git/refs/heads/live' },
        @{ n = 'api --method=put, lowercase';         c = 'gh api --method=put repos/o/r/git/refs/heads/live' },
        @{ n = 'api git/refs with ref= field';        c = 'gh api repos/o/r/git/refs -f ref=refs/heads/live -f sha=abc' },
        @{ n = 'api git/refs with bare-name ref';     c = 'gh api repos/o/r/git/refs --raw-field ref=live -f sha=abc' },
        @{ n = 'api branches/live/rename';            c = 'gh api -X POST repos/o/r/branches/live/rename -f new_name=old' },
        @{ n = 'api branches/live/protection PUT';    c = 'gh api -X PUT repos/o/r/branches/live/protection --input p.json' },
        @{ n = 'api rename onto the deploy name';     c = 'gh api repos/o/r/branches/main/rename -f new_name=live' },
        @{ n = 'api merges with base=live';           c = 'gh api repos/o/r/merges -f base=live -f head=main' },
        @{ n = 'api implicit POST, branch= field';    c = 'gh api repos/o/r/anything --field branch=live' },
        @{ n = 'api pulls PATCH base=live';           c = 'gh api -X PATCH repos/o/r/pulls/3 -f base=live' },
        @{ n = 'api --input on git/refs';             c = 'gh api repos/o/r/git/refs --input body.json' },
        @{ n = 'api field value from a variable';     c = 'gh api repos/o/r/git/refs -f ref=$R' },
        @{ n = 'api path with a leading slash';       c = 'gh api -X DELETE /repos/o/r/git/refs/heads/Live' }
    )
    foreach ($case in $routeBlocked) {
        Assert-Equal 2 (Invoke-Guard -Command $case.c -Root $c2) "deploy route blocked: $($case.n)"
        Assert-Equal 0 (Invoke-Guard -Command "$($case.c) $mk5" -Root $c2) "deploy route authorised by the marker: $($case.n)"
    }

    $routeAllowed = @(
        @{ n = 'pr create --base main';               c = 'gh pr create --base main --title x' },
        @{ n = 'pr create with no base';              c = 'gh pr create --title "go live" --body "live"' },
        @{ n = 'pr create base that only contains it'; c = 'gh pr create --base feat/live-preview' },
        @{ n = 'pr edit title only';                  c = 'gh pr edit 12 --title "promote to live"' },
        @{ n = 'pr merge stays ungated';              c = 'gh pr merge 12 --merge' },
        @{ n = 'pr merge --admin on the deploy PR';   c = 'gh pr merge 12 --merge --admin' },
        @{ n = 'pr view';                             c = 'gh pr view 12 --json baseRefName' },
        @{ n = 'api GET branches/live';               c = 'gh api repos/o/r/branches/live' },
        @{ n = 'api explicit GET with a field';       c = 'gh api -X GET repos/o/r/branches/live -f per_page=1' },
        @{ n = 'api GET git/refs/heads/live';         c = 'gh api repos/o/r/git/refs/heads/live' },
        @{ n = 'api write on branches/main/...';      c = 'gh api -X POST repos/o/r/branches/main/rename -f new_name=trunk' },
        @{ n = 'api write on git/refs/heads/main';    c = 'gh api -X PATCH repos/o/r/git/refs/heads/main -f sha=abc' },
        @{ n = 'api create ref for another branch';   c = 'gh api repos/o/r/git/refs -f ref=refs/heads/feat/x -f sha=abc' },
        @{ n = 'api branch that only starts with it'; c = 'gh api -X DELETE repos/o/r/git/refs/heads/live2' },
        @{ n = 'api issue comment mentioning live';   c = 'gh api repos/o/r/issues/1/comments -f body="push to live"' },
        @{ n = 'a mention in echo';                   c = 'echo "gh pr create --base live"' },
        @{ n = 'a mention in a heredoc';              c = "cat > notes.md <<'EOF'${LF}gh pr create --base live${LF}gh api -X DELETE repos/o/r/git/refs/heads/live${LF}EOF" },
        @{ n = 'a mention in a grep';                 c = "grep -n 'gh pr create --base live' docs/*.md" },
        @{ n = 'a mention after the comment mark';    c = 'gh pr create --base main # --base live' },
        @{ n = 'gh issue create naming it';           c = 'gh issue create --title "pr create --base live"' }
    )
    foreach ($case in $routeAllowed) { Assert-Equal 0 (Invoke-Guard -Command $case.c -Root $c2) "deploy route allowed: $($case.n)" }

    # Local writes while HEAD is the deploy branch. HEAD is main here, so every one passes first.
    $localWrites = @('git commit -m x', 'git commit --amend --no-edit', 'git merge main', 'git cherry-pick abc', 'git revert abc', 'git am p.patch', 'git rebase main', 'git pull')
    foreach ($w in $localWrites) { Assert-Equal 0 (Invoke-Guard -Command $w -Root $c2) "local write on HEAD=main passes: $w" }
    Invoke-FixtureGitIn $c2 symbolic-ref HEAD refs/heads/live
    foreach ($w in $localWrites) {
        Assert-Equal 2 (Invoke-Guard -Command $w -Root $c2) "local write on HEAD=live blocked: $w"
        Assert-Equal 0 (Invoke-Guard -Command "$w $mk5" -Root $c2) "local write on HEAD=live authorised by the marker: $w"
    }
    foreach ($r in @('git status', 'git log --oneline', 'git diff', 'git fetch origin', 'git checkout main', 'git branch -a', 'git merge-base main live', 'git stash list', 'git add -A')) {
        Assert-Equal 0 (Invoke-Guard -Command $r -Root $c2) "read-only or non-writing git on HEAD=live passes: $r"
    }
    Assert-Equal 2 (Invoke-Guard -Command 'git status && git commit -m x' -Root $c2) 'local write on HEAD=live: after a harmless command'
    Assert-Equal 2 (Invoke-Guard -Command 'git -c user.name=x commit -m x' -Root $c2) 'local write on HEAD=live: with -c config in front'
    Assert-Equal 0 (Invoke-Guard -Command 'echo "git commit -m x"' -Root $c2) 'local write: a mention in echo is not a commit'
    Assert-Equal 0 (Invoke-Guard -Command 'git grep -n commit' -Root $c2) 'local write: git grep is not a commit'
    Invoke-FixtureGitIn $c2 symbolic-ref HEAD refs/heads/main
    # 'Elsewhere' makes HEAD unknowable, so the write subcommands are refused even on a clean trunk.
    Assert-Equal 2 (Invoke-Guard -Command 'git -C x commit -m y' -Root $c2) 'local write: git -C x commit is refused, HEAD cannot be told'
    Assert-Equal 2 (Invoke-Guard -Command 'git --git-dir=x/.git merge main' -Root $c2) 'local write: --git-dir merge is refused'
    Assert-Equal 2 (Invoke-Guard -Command 'cd sub && git commit -m y' -Root $c2) 'local write: after a cd the commit is refused'
    Assert-Equal 0 (Invoke-Guard -Command 'cd sub && git status' -Root $c2) 'local write: but a read after a cd passes'
    Assert-Equal 0 (Invoke-Guard -Command 'git -C x commit -m y # LIVE-PUSH-AUTHORIZED' -Root $c2) 'local write: git -C x commit with the marker passes'
    # No readable HEAD: refused for the write subcommands, passes for a read.
    $c3 = New-FixtureRepo -Label 'conn-routes-nogit' -ConfigBody $deployCfg
    Assert-Equal 2 (Invoke-Guard -Command 'git commit -m x' -Root $c3) 'local write: HEAD cannot be read -> refused'
    Assert-Equal 0 (Invoke-Guard -Command 'git status' -Root $c3) 'local write: HEAD cannot be read, a read still passes'

    # HEAD is read from the payload cwd: a lane on a work branch commits while the project root sits on live.
    Invoke-FixtureGitIn $c2 symbolic-ref HEAD refs/heads/live
    Invoke-FixtureGitIn $lane symbolic-ref HEAD refs/heads/feat/y
    $prevDir = $env:CLAUDE_PROJECT_DIR
    $env:CLAUDE_PROJECT_DIR = $c2
    try {
        (& $cwdPayload 'git commit -m x' $lane) | & powershell -NoProfile -ExecutionPolicy Bypass -File $Guard 2>&1 | Out-Null
        Assert-Equal 0 $LASTEXITCODE 'local write: a commit from a lane on a work branch passes, though the project root sits on the deploy branch'
    } finally {
        if ($null -eq $prevDir) { Remove-Item Env:\CLAUDE_PROJECT_DIR -ErrorAction SilentlyContinue } else { $env:CLAUDE_PROJECT_DIR = $prevDir }
    }

    # One plain 'git -C <dir>' is read where it lands rather than refused: the root sits on live here.
    Assert-Equal 0 (Invoke-Guard -Command "git -C `"$lane`" commit -m x" -Root $c2) 'local write: git -C into a checkout on a work branch passes, though the root sits on the deploy branch'
    Invoke-FixtureGitIn $lane symbolic-ref HEAD refs/heads/live
    Assert-Equal 2 (Invoke-Guard -Command "git -C `"$lane`" commit -m x" -Root $c2) 'local write: git -C into a checkout ON the deploy branch is blocked'
    Invoke-FixtureGitIn $lane symbolic-ref HEAD refs/heads/feat/y
    Assert-Equal 2 (Invoke-Guard -Command "git -C `"$lane`" -C sub commit -m x" -Root $c2) 'local write: two -C cannot be placed and is refused'
    Assert-Equal 2 (Invoke-Guard -Command 'git -C $D commit -m x' -Root $c2) 'local write: a -C the shell expands is refused'

    # The seam unanswered, a placeholder, or no config: none of this exists.
    $unans = New-FixtureRepo -Label 'conn-routes-unanswered' -ConfigBody "function Get-ShopifyLiveThemeId { return '$LIVE' }"
    Invoke-FixtureGitIn $unans init -q
    Invoke-FixtureGitIn $unans symbolic-ref HEAD refs/heads/live
    foreach ($c in @('gh pr create --base live', 'gh pr edit 3 --base live', 'gh api -X POST repos/o/r/git/refs/heads/live', 'gh api repos/o/r/git/refs -f ref=refs/heads/live', 'git commit -m x', 'git merge main', 'git -C x commit -m y')) {
        Assert-Equal 0 (Invoke-Guard -Command $c -Root $unans) "seam unanswered: not gated: $c"
        Assert-Equal 0 (Invoke-Guard -Command $c -Root $connPlaceholder) "seam placeholder: not gated: $c"
    }

    # A configured marker narrows these routes exactly as it narrows the push.
    Assert-Equal 2 (Invoke-Guard -Command 'gh pr create --base live # LIVE-PUSH-AUTHORIZED' -Root $connNarrow) 'deploy route: the default marker no longer authorises where the repo names its own'
    Assert-Equal 0 (Invoke-Guard -Command 'gh pr create --base live # SWB-LIVE-PUSH-AUTHORIZED' -Root $connNarrow) 'deploy route: the repo marker authorises'

    # The refusal names the branch, says why, and says how to authorise.
    $refusal = Get-GuardRefusal -Command 'gh pr create --base live' -Root $c2
    Assert-True ($refusal -match "'live'") 'deploy route: the refusal names the deploy branch'
    Assert-True ($refusal -match 'live deploy') 'deploy route: and says the promotion is a live deploy'
    Assert-True ($refusal -match '# LIVE-PUSH-AUTHORIZED') 'deploy route: and tells how to authorise'

    # Degraded (no lib): a PR with a base, or a gh api naming the deploy branch, needs the marker.
    Assert-Equal 2 (Invoke-DegradedGuard -Command 'gh pr create --base main' -Root $conn).Code 'no lib: gh pr create with a base is blocked -- the base cannot be read'
    Assert-Equal 2 (Invoke-DegradedGuard -Command 'gh pr edit 3 -B main' -Root $conn).Code 'no lib: gh pr edit -B is blocked too'
    Assert-Equal 0 (Invoke-DegradedGuard -Command 'gh pr create --base main # LIVE-PUSH-AUTHORIZED' -Root $conn).Code 'no lib: and the marker authorises it'
    Assert-Equal 0 (Invoke-DegradedGuard -Command 'gh pr create --title x' -Root $conn).Code 'no lib: a PR with no base flag passes'
    Assert-Equal 2 (Invoke-DegradedGuard -Command 'gh api -X POST repos/o/r/git/refs/heads/live' -Root $conn).Code 'no lib: gh api naming the deploy branch is blocked'
    Assert-Equal 0 (Invoke-DegradedGuard -Command 'gh api repos/o/r/branches/main' -Root $conn).Code 'no lib: gh api not naming it passes'
    Assert-Equal 0 (Invoke-DegradedGuard -Command 'gh pr create --base live' -Root $unans).Code 'no lib, seam unanswered: gh is untouched'

    # --- group 10: an authorised live push carries only what the trunk holds (#3758) --------------
    # Measured in a consumer: two UNMERGED pull requests went to live with '--only' and the marker, and
    # live then held work the trunk did not. The marker says somebody meant to push to live; this group
    # asserts that it no longer decides WHAT -- every file must be what origin/<trunk> holds.
    Write-Host "group 10 -- merged only: an authorised live push is held to origin/<trunk> (#3758)" -ForegroundColor Cyan
    $m = New-FixtureRepo -Label 'merged' -ConfigBody "function Get-ShopifyLiveThemeId { return '$LIVE' }"
    Initialize-MergedFixture -Root $m
    $push = "shopify theme push --store x.myshopify.com --theme $LIVE --allow-live"
    $mk = '# LIVE-PUSH-AUTHORIZED'
    $css = Join-Path $m 'assets\x.css'

    Assert-Equal 0 (Invoke-Guard -Command "$push --only assets/x.css $mk" -Root $m) 'merged: a file equal to origin/main passes'
    Assert-Equal 0 (Invoke-Guard -Command "$push --only=assets/x.css $mk" -Root $m) 'merged: and in the --only=<file> spelling'
    Assert-Equal 0 (Invoke-Guard -Command "$push -o assets/x.css -o layout/theme.liquid $mk" -Root $m) 'merged: and with the short flag, several files'
    Assert-Equal 0 (Invoke-Guard -Command "$push $mk" -Root $m) 'merged: a whole-theme push from a clean checkout equal to origin/main passes'
    Assert-Equal 0 (Invoke-Guard -Command "$push --only assets/gone.css $mk" -Root $m) 'merged: a deletion of a file the trunk does not hold either passes'

    # LINE ENDINGS ARE NOT A DIFFERENCE, read the way sync-main reads them.
    [System.IO.File]::WriteAllText($css, "body { color: red; }`r`n", $Utf8NoBom)
    Assert-Equal 0 (Invoke-Guard -Command "$push --only assets/x.css $mk" -Root $m) 'merged: the same content with CRLF endings passes'

    # An uncommitted edit, pushed from the trunk itself: the case a branch test would miss.
    [System.IO.File]::WriteAllText($css, "body { color: blue; }`n", $Utf8NoBom)
    Assert-Equal 2 (Invoke-Guard -Command "$push --only assets/x.css $mk" -Root $m) 'refused: an uncommitted edit on the trunk'
    Assert-Equal 2 (Invoke-Guard -Command "$push $mk" -Root $m) 'refused: and a whole-theme push over it'
    $refusal = Get-GuardRefusal -Command "$push --only assets/x.css $mk" -Root $m
    Assert-True ($refusal -match 'assets/x\.css: differs from origin/main') 'refused: the refusal names the file and what it differs from'
    Assert-True ($refusal -match 'Merge first') 'refused: and says to merge first'
    Invoke-FixtureGitIn $m checkout -q -- assets/x.css

    # The measured case: work committed on a branch that is not merged.
    Invoke-FixtureGitIn $m checkout -q -b fix/401-unmerged
    [System.IO.File]::WriteAllText($css, "body { color: green; }`n", $Utf8NoBom)
    [System.IO.File]::WriteAllText((Join-Path $m 'assets\new.css'), "a {}`n", $Utf8NoBom)
    Invoke-FixtureGitIn $m add -A
    Invoke-FixtureGitIn $m commit -q -m 'unmerged work'
    Assert-Equal 2 (Invoke-Guard -Command "$push --only assets/x.css $mk" -Root $m) 'refused: a file changed on an unmerged branch'
    Assert-Equal 2 (Invoke-Guard -Command "$push --only assets/new.css $mk" -Root $m) 'refused: a file the trunk does not hold at all'
    Assert-Equal 2 (Invoke-Guard -Command "$push $mk" -Root $m) 'refused: a whole-theme push from a commit ahead of origin/main'
    Assert-Equal 0 (Invoke-Guard -Command "$push --only layout/theme.liquid $mk" -Root $m) 'merged: but a file that branch did not touch passes -- content, not the checked-out branch'
    Invoke-FixtureGitIn $m checkout -q main
    Invoke-FixtureGitIn $m branch -q -D fix/401-unmerged

    # A deletion of merged work: the file is absent here and present on the trunk.
    Remove-Item -LiteralPath $css -Force
    Assert-Equal 2 (Invoke-Guard -Command "$push --only assets/x.css $mk" -Root $m) 'refused: an --only of a file the trunk holds but this checkout lacks -- it would delete merged work from live'
    Invoke-FixtureGitIn $m checkout -q -- assets/x.css

    [System.IO.File]::WriteAllText((Join-Path $m 'assets\stray.css'), "a {}`n", $Utf8NoBom)
    Assert-Equal 2 (Invoke-Guard -Command "$push $mk" -Root $m) 'refused: a whole-theme push with an untracked file in the root'
    Remove-Item -LiteralPath (Join-Path $m 'assets\stray.css') -Force

    # A change git status cannot see: skip-worktree hides it from the whole-root check.
    Invoke-FixtureGitIn $m update-index --skip-worktree assets/x.css
    [System.IO.File]::WriteAllText($css, "body { color: blue; }`n", $Utf8NoBom)
    Assert-Equal 2 (Invoke-Guard -Command "$push $mk" -Root $m) 'refused: a whole-theme push over a skip-worktree file'
    Invoke-FixtureGitIn $m update-index --no-skip-worktree assets/x.css
    Invoke-FixtureGitIn $m checkout -q -- assets/x.css

    # A second live push in the same command is measured too: the first no longer ends the run.
    [System.IO.File]::WriteAllText($css, "body { color: blue; }`n", $Utf8NoBom)
    Assert-Equal 2 (Invoke-Guard -Command "$push --only layout/theme.liquid $mk${LF}$push --only assets/x.css $mk" -Root $m) 'refused: an unmerged file in a SECOND push on the same command, after a first that passes'
    Invoke-FixtureGitIn $m checkout -q -- assets/x.css

    # What cannot be read is refused -- the direction this guard fails in.
    $unreadable = @(
        @{ n = 'a pattern in --only';                 c = "$push --only 'assets/*.css' $mk" },
        @{ n = 'a directory in --only';               c = "$push --only assets $mk" },
        @{ n = 'a shell variable';                    c = "$push --only `$F $mk" },
        @{ n = 'an environment from the toml';        c = "$push --environment production --only assets/x.css $mk" },
        @{ n = 'a short -e';                          c = "$push -e production --only assets/x.css $mk" },
        @{ n = 'a directory change first';            c = "cd sub && $push --only assets/x.css $mk" },
        @{ n = 'SHOPIFY_FLAG_ONLY on the line';       c = "SHOPIFY_FLAG_ONLY=assets/new.css $push $mk" },
        @{ n = 'a path outside the theme root';       c = "$push --only ../other/x.css $mk" },
        # Review of #3758: each of these was read as harmless in the first cut.
        @{ n = 'Push-Location first';                 c = "Push-Location sub; $push --only assets/x.css $mk" },
        @{ n = 'cd.. with no space';                  c = "cd..; $push --only assets/x.css $mk" },
        @{ n = 'a value given as -o=<value> is read'; c = "$push --only layout/theme.liquid -o=assets/*.css $mk" },
        @{ n = 'a non-ASCII name';                    c = "$push --only assets/caf" + [char]0x00E9 + ".css $mk" },
        @{ n = 'a second bare word after --only';     c = "$push --only layout/theme.liquid assets/*.css $mk" }
    )
    foreach ($case in $unreadable) { Assert-Equal 2 (Invoke-Guard -Command $case.c -Root $m) "refused: $($case.n)" }

    # No origin/<trunk> to compare with: fetch first. And no git checkout at all.
    Invoke-FixtureGitIn $m update-ref -d refs/remotes/origin/main
    Assert-True ((Get-GuardRefusal -Command "$push --only assets/x.css $mk" -Root $m) -match "git fetch origin") 'refused: with no origin/main the refusal says to fetch'
    Invoke-FixtureGitIn $m update-ref refs/remotes/origin/main HEAD
    $notGit = New-FixtureRepo -Label 'not-git' -ConfigBody "function Get-ShopifyLiveThemeId { return '$LIVE' }"
    Assert-Equal 2 (Invoke-Guard -Command "$push $mk" -Root $notGit) 'refused: a theme root that is not a git checkout'

    # The trunk comes from Get-TrunkBranchName, the seam push-preview and live-preflight read.
    $dev = New-FixtureRepo -Label 'trunk-develop' -ConfigBody "function Get-ShopifyLiveThemeId { return '$LIVE' }${LF}function Get-TrunkBranchName { return 'develop' }"
    Initialize-MergedFixture -Root $dev -Trunk 'develop'
    Assert-Equal 0 (Invoke-Guard -Command "$push --only assets/x.css $mk" -Root $dev) 'trunk seam: measured against origin/develop where the repo names it'
    $badTrunk = New-FixtureRepo -Label 'trunk-bad' -ConfigBody "function Get-ShopifyLiveThemeId { return '$LIVE' }${LF}function Get-TrunkBranchName { return 'VUL IN' }"
    Initialize-MergedFixture -Root $badTrunk
    Assert-Equal 2 (Invoke-Guard -Command "$push --only assets/x.css $mk" -Root $badTrunk) 'trunk seam: an answer that is not a branch name refuses rather than falling back to main'

    # Degraded, the push cannot be read, so the marker alone no longer authorises it.
    Assert-Equal 2 (Invoke-DegradedGuard -Command "$push --only assets/x.css $mk" -Root $m).Code 'no lib: an authorised live push is refused -- what it carries cannot be read'

    # And the rest of rule 3 is untouched: a preview push is not measured at all.
    [System.IO.File]::WriteAllText($css, "body { color: blue; }`n", $Utf8NoBom)
    Assert-Equal 0 (Invoke-Guard -Command 'shopify theme push --store x.myshopify.com --theme 987654321 --only assets/x.css' -Root $m) 'untouched: a preview push of unmerged work'
} finally {
    Remove-Item -Recurse -Force -LiteralPath $Fixture -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Summary: $script:pass passed, $script:fail failed" -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
$fixtureBroken = Write-FixtureGitSummary -Subject 'guard-live-theme.ps1'
if ($script:fail -gt 0) { exit 1 }
if ($fixtureBroken) { exit 1 }
exit 0
