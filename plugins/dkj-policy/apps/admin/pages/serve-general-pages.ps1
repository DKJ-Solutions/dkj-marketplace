<#
.SYNOPSIS
    Serve the plugin's REPOSITORY (#3245) and the GENERAL pages (#3119) on http://localhost:<Port>/ -- Admin on
    '/', then /dev/issues, /dev/release-notes, /dev/sessionstart, /dev/test-gate, /dev/performance, /dev/stopwatch, /dev/logbook and /dev/plugins --
    from the repo this server was started in. Not /brandbook: no admin has served the brand book since #3475, and the
    source repo retired the app itself under #3493.

.DESCRIPTION
    Started by hooks/dev-preview-sessionstart.ps1 in EVERY repo, beside the repo's own dev server where it
    states one, under a cmd.exe that changes into the repo root first, so the working directory IS the repo
    and that cmd.exe's command line is what lets the hook recognise this server as the checkout's own next
    time. A repo whose own server is not PowerShell (Vite, Next.js) gets the same pages this way. The pages
    and their rules are in apps/admin/lib/general-pages-lib.ps1, Admin's page in apps/admin/lib/repo-admin-page.ps1. In
    dkj-policy, which every repo runs, since #3198.

    WHAT EACH PAGE READS, from the repo, on every request unless it says otherwise:
      /dev/issues         `gh issue list`, three calls (the open issues; created and closed in the last 28 days),
                      for --repo <owner/name> parsed from the origin remote when that is on github.com, else
                      for the repo gh finds from the working directory. Kept for -IssuesCacheSeconds; a failed
                      read for 30 s only. A gh that fails or is missing is a warning on the page, never a blank.
      /dev/goals      `gh api graphql`, one call: the open issues labelled goal, their sub-issues (the milestones) and
                      theirs (the tasks), for owner/name from the origin remote (Get-GoalsModel, apps/admin/lib/goals-lib.ps1,
                      #3816). Kept as the issues are; a repo whose origin is not on GitHub, or a gh that fails, is a
                      warning on the page.
      /dev/today      the day plan (#3860): this machine's day file, matched live against the PRs merged and the issues
                      closed today, and the week, from day-plan.ps1 -Status run as a child (Get-TodayModel,
                      apps/admin/lib/today-page-lib.ps1), so the GitHub search behind it has one source. Kept for 60 s, a
                      failed run for 30 s; a gh that fails is a warning on the page, and the plan still shows.
      /dev/release-notes  dkj-policy/releases/page/release-notes.html, dressed in the house style on the way out.
                      Built first, by build-release-notes-page.ps1 (found the way the always-on lib is), where it
                      is absent or older than a file under dkj-policy/releases (#3189): the page is a gitignored
                      snapshot nothing else builds. A 404 text naming why where it cannot be built.
      /dev/handover, /dev/handover/<name>
                      the preview handovers built on this machine for this repo (#3925): the model files a store's
                      builder writes beside the Stopwatch store (Get-HandoverDir, apps/admin/lib/handover-page-lib.ps1),
                      read per request, each page's QR codes drawn here. No card on Admin: the builder prints the link.
      /dev/sessionstart   (also: scripts/dashboard/session-start-snapshot.json, where the repo keeps one -- the last
                      full session-start measurement, its sections shown after the live table's; absent, nothing
                      is added) one card per section, and /dev/sessionstart/<section> that section's own page
                      (Get-SessionStartSections); a slug no section has is a 404.
                      the always-on path, measured in a CHILD process by always-on-budget-lib.ps1, found in
                      the repo's own scripts/lib, else in this plugin's own. Kept for -CacheSeconds.
                      The child first dot-sources the repo's own scripts/repo-config.ps1, the trust the
                      dev-preview hook already gives it, and is bounded at 60 s.
      /dev/test-gate, /dev/test-gate/<list>[/<suite>], /dev/test-gate/measured
                      scripts/tests/suite-durations.json, grouped by suite-groups.json where the repo keeps one, and
                      each suite's own header (Read-TestGateModel, apps/admin/lib/test-gate-lib.ps1, #3470): an overview, a
                      page per group and per suite. Absent, the page says no test gate has been measured in this repo yet.
      /dev/plugins, /dev/plugins/<name>   a card per enabled plugin, and each one's own page: plugin-versions.ps1 -Json, the repo's
                      own copy first, then this plugin's, run in a CHILD process bounded at 30 s (Read-PluginsPageModel,
                      apps/admin/lib/plugins-page-lib.ps1, #3482). A script that fails or is missing is a warning on the page.
      /dev/plugins/dkj-policy/dkj-brandbook[/<section>]
                      the brand book's specimens (assets/dkj-brandbook/specimens.html, read per request): a card per
                      section, and each section's own page (Split-HouseStyleSpecimens, #3563); a slug no section has
                      is a 404. The older /dev/plugins/dkj-solutions/house-style[/<section>] (#3629) and
                      /dev/plugins/dkj-policy/house-style[/<section>] (#3704) are a 301 to it.
      /dev/stopwatch, /dev/stopwatch/<label>[/<run>], /dev/logbook, /dev/logbook/<slug>
                      this repo's timing stores on this machine (%LOCALAPPDATA%\dkj-claude-plugins\repos\<repo>\),
                      which the plugin's UserPromptSubmit and Stop hooks write, and the session transcripts under
                      ~/.claude/projects (Resolve-AdminTimingPage, apps/admin/lib/timing-pages.ps1, #3470). The Stopwatch also
                      shows this repo's other machines' runs and starts a background sync, where the repo opts in
                      with DKJ_STOPWATCH_SHARE=1 (Test-StopwatchShareEnabled: the environment, else the repo's .claude/settings.json).
      /admin, / and /index.html
                      the plugin's admin (Format-PluginRepoAdminHtml), built per request from the state file
                      the hook wrote (%TEMP%\dkj-repo-admin-<leaf>-<hash>.json): the repo's own server as the
                      Product card (mode 'product'), the setup cards (mode 'none'). In every repo: the
                      OwnHub opt-out, which sent '/admin' on to a repo's own admin, went with #3643.
      /dev/repository     Admin's Repository page (Format-PluginRepoRepositoryHtml, #3383): the facts the home page
                      held until the house admin became a grid of card links, and the Issues page's card.
      /refresh        ?page=issues, ?page=goals, ?page=today or ?page=sessionstart drops that page's cache (at most once per
                      -MinRefreshSeconds, and per 60 s for issues) and goes back to the page.
      /api/airsquats  the banner's state as JSON (GET), and POST /api/airsquats/clear ticks its box off (#3438):
                      the machine's file under %LOCALAPPDATA%\dkj-admin, synced with a private gist by a child
                      (sync-airsquats.ps1) where DKJ_ADMIN_AIRSQUATS_GIST opts in (#3439). The one route that
                      takes a POST, served same-origin only.
      /whoami         the hash of the repo root this server was started in (Get-DevPreviewRootHash): the
                      Admin servers ask it before they link here, because an open port does not say whose server it is.
      /house-style.css, /house-theme.js   the canonical copy under assets/dkj-brandbook/ in this
                      plugin's payload (Get-HouseStyleDir), in every repo: the pages keep one look everywhere.
    The repo's name on the pages is owner/name from the origin remote, else the folder's name.

    A TcpListener ON 127.0.0.1, NOT AN HttpListener (#2976): under HttpListener the socket belongs to
    http.sys (PID 4), so the hook's ownership walk could never reach the cmd.exe that names the checkout, and
    every session would start another server on the next port. Loopback only, and a request whose Host is not
    localhost:<Port> or 127.0.0.1:<Port> is refused (DNS rebinding), as is one the browser marks as coming
    from another site -- except a same-site top-level GET navigation (Admin's link, the 303 hop, the
    crumb back), which is a user following a link and is served, and a cross-site one into a document,
    which is how Claude in Chrome opens a page (#3834) (Test-LoopbackCrossSite). GET and HEAD only,
    but for the banner's POST /api/airsquats/clear.

    One request at a time, each answered with Connection: close. A connection whose request head is not
    complete within -ReadTimeoutMs, or is longer than 8 KB, is dropped, and one that never reads its answer
    is cut after 2 s. Every child process (git, gh, the measurement) is bounded, by a process helper of this
    file's own. It runs until the process is stopped.

    Pure ASCII (repo convention for .ps1). The pages and the request rules are in apps/admin/lib/
    general-pages-lib.ps1 and repo-admin-page.ps1, tested by scripts/tests/dev-pages.tests.ps1 and
    dev-preview-sessionstart.tests.ps1 in the source repo.

.PARAMETER Port
    The loopback port to listen on (1024-65535).

.PARAMETER CacheSeconds
    How long one measurement of the always-on path is served before the next request measures again.

.PARAMETER IssuesCacheSeconds
    How long one read of the GitHub issues is served: three gh calls take about 12 s.

.PARAMETER ReadTimeoutMs
    How long a connection may take to send its whole request head (one deadline, not one per read).

.PARAMETER MinRefreshSeconds
    The shortest interval between two re-runs that /refresh can cause.

.PARAMETER RepoRootOverride
    (For tests) The repo root instead of the working directory.

.PARAMETER StopwatchPath
    (For tests) The Stopwatch's store instead of this repo's own under LOCALAPPDATA; a store passed in is never
    shared, so a test neither reads the checkout's refs nor reaches the network.

.PARAMETER LogbookPath
    (For tests) The Logbook's store instead of the one beside the Stopwatch's.

.PARAMETER TranscriptDir
    (For tests) The session transcripts instead of this checkout's own under ~/.claude/projects.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][ValidateRange(1024, 65535)][int]$Port,
    [ValidateRange(0, 86400)][int]$CacheSeconds = 60,
    [ValidateRange(0, 86400)][int]$IssuesCacheSeconds = 300,
    [ValidateRange(100, 60000)][int]$ReadTimeoutMs = 1000,
    [ValidateRange(0, 3600)][int]$MinRefreshSeconds = 10,
    [string]$RepoRootOverride,
    [string]$StopwatchPath,
    [string]$LogbookPath,
    [string]$TranscriptDir
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\general-pages-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\general-pages-state.ps1')
# The request reader, the response writer and the Host and Sec-Fetch-Site rules: one copy in the plugin,
# shared with the source repo's own admin server.
. (Join-Path $PSScriptRoot '..\lib\loopback-server-lib.ps1')
# Admin's page (#3245).
. (Join-Path $PSScriptRoot '..\lib\repo-admin-page.ps1')
# The banner's airsquats state, shared by every admin and every machine (#3438).
. (Join-Path $PSScriptRoot '..\lib\airsquats-lib.ps1')
# The Test gate, the Stopwatch and the Logbook, every repo's pages since #3470.
. (Join-Path $PSScriptRoot '..\lib\test-gate-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\timing-pages.ps1')
# The Plugins page (#3482).
. (Join-Path $PSScriptRoot '..\lib\plugins-page-lib.ps1')
# The Goals page (#3816), and the Today page (#3860).
. (Join-Path $PSScriptRoot '..\lib\goals-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\today-page-lib.ps1')
# The preview handover pages (#3925).
. (Join-Path $PSScriptRoot '..\lib\handover-page-lib.ps1')

$pluginRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..\..')).Path
$root = if ($RepoRootOverride) { [System.IO.Path]::GetFullPath($RepoRootOverride).TrimEnd('\', '/') }
        else { [System.IO.Path]::GetFullPath((Get-Location).Path).TrimEnd('\', '/') }
$styleDir = Get-HouseStyleDir -PluginRoot $pluginRoot
$static = @{
    '/house-style.css' = @{ File = (Join-Path $styleDir 'house-style.css'); Type = 'text/css; charset=utf-8' }
    '/house-theme.js'  = @{ File = (Join-Path $styleDir 'house-theme.js');  Type = 'text/javascript; charset=utf-8' }
}
# The workflow folder is read off this tree (#3870): '.dkj/dkj-policy' once a repo has moved, 'dkj-policy' before.
. (Join-Path $pluginRoot 'scripts\lib\workflow-folder-lib.ps1')
$workflowFolderRel = Get-WorkflowFolderName -RepoRoot $root
$releaseNotesFile = Join-Path $root (($workflowFolderRel -replace '/', '\') + '\releases\page\release-notes.html')

function ConvertTo-ProcessArgument {
    <# One argument as a Windows command line carries it (backslashes before a quote doubled, the whole quoted when it needs it). #>
    param([AllowEmptyString()][string]$Arg)
    if ($Arg -eq '') { return '""' }
    if ($Arg -notmatch '[\s"]') { return $Arg }
    $a = $Arg -replace '(\\+)$', '$1$1'
    $a = $a -replace '(\\*)"', '$1$1\"'
    return '"' + $a + '"'
}

function Invoke-BoundedProcess {
    <#
        Runs -FilePath and waits at most -TimeoutSeconds: @{ Output; ExitCode; TimedOut }. No shell, so no
        quoting layer of cmd.exe; stdout and stderr are both read (a full pipe would stall the child) and
        decoded as UTF-8, the encoding gh and git write, where Windows PowerShell 5.1 would decode through the
        console code page. A child that outlives the bound is killed.
    #>
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$Arguments = @(),
        [int]$TimeoutSeconds = 60,
        [string]$WorkingDirectory = ''
    )
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $FilePath
    $psi.Arguments = (@($Arguments | ForEach-Object { ConvertTo-ProcessArgument $_ }) -join ' ')
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.StandardOutputEncoding = New-Object System.Text.UTF8Encoding($false)
    $psi.StandardErrorEncoding = New-Object System.Text.UTF8Encoding($false)
    if ($WorkingDirectory) { $psi.WorkingDirectory = $WorkingDirectory }
    $p = [System.Diagnostics.Process]::Start($psi)
    try {
        $out = $p.StandardOutput.ReadToEndAsync()
        $err = $p.StandardError.ReadToEndAsync()
        if (-not $p.WaitForExit($TimeoutSeconds * 1000)) {
            try { $p.Kill() } catch { }
            return @{ Output = ''; ExitCode = $null; TimedOut = $true }
        }
        $p.WaitForExit()
        return @{ Output = [string]$out.Result; Error = [string]$err.Result; ExitCode = $p.ExitCode; TimedOut = $false }
    } finally {
        $p.Dispose()
    }
}

function Get-ExecutablePath {
    param([string]$Name)
    $c = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($c) { return [string]$c.Source }
    return ''
}

$script:identity = $null
function Get-RepoIdentity {
    <# @{ Name; Slug }: Slug is owner/name from the origin remote when it is on github.com, else ''; Name is the Slug, else the folder's name. Kept for 60 s. #>
    if ($script:identity -and ((Get-Date) - $script:identity.At).TotalSeconds -lt 60) { return $script:identity }
    $slug = ''
    $git = Get-ExecutablePath 'git'
    if ($git) {
        try {
            $r = Invoke-BoundedProcess -FilePath $git -Arguments @('-C', $root, 'config', '--get', 'remote.origin.url') -TimeoutSeconds 10 -WorkingDirectory $root
            if (-not $r.TimedOut -and $r.ExitCode -eq 0) { $slug = ConvertFrom-GitRemoteUrl -Url ($r.Output.Trim()) }
        } catch { }
    }
    $script:identity = @{ Slug = $slug; Name = $(if ($slug) { $slug } else { Split-Path -Leaf $root }); At = Get-Date }
    return $script:identity
}

function Get-SessionStartSnapshot {
    <# The repo's scripts/dashboard/session-start-snapshot.json, read on every request: one small file. Only some repos keep one, so a missing file is no error and adds nothing to the page. #>
    $path = Join-Path $root 'scripts\dashboard\session-start-snapshot.json'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return @{ Data = $null; Error = '' } }
    try { return @{ Data = (Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json); Error = '' } }
    catch { return @{ Data = $null; Error = 'it is not valid JSON' } }
}

function Get-IssuesModel {
    <#
        The repo's issues from GitHub: every open one, and those created or closed in the last 28 days --
        three gh calls, about 4 s each, so the result is cached for -IssuesCacheSeconds. A search returns at
        most 1,000 issues, which is what bounds the window. A gh failure is a ReadError, never a blank page.
    #>
    $started = Get-Date
    $since = $started.ToUniversalTime().AddDays(-28).ToString('yyyy-MM-dd')
    $fields = 'number,title,state,stateReason,labels,assignees,createdAt,closedAt,url'
    $slug = (Get-RepoIdentity).Slug
    $gh = Get-ExecutablePath 'gh'
    $read = {
        param([string[]]$Extra)
        $argv = @('issue', 'list') + $(if ($slug) { @('--repo', $slug) } else { @() }) + @('--limit', '1000', '--json', $fields) + $Extra
        $q = Invoke-BoundedProcess -FilePath $gh -Arguments $argv -TimeoutSeconds 60 -WorkingDirectory $root
        if ($q.TimedOut) { throw 'gh issue list did not answer within 60 s' }
        if ($q.ExitCode -ne 0) { throw "gh issue list exited $($q.ExitCode)" }
        # 5.1's ConvertFrom-Json emits a JSON array as ONE object, so it is enumerated before it is wrapped.
        $parsed = ConvertFrom-Json -InputObject $q.Output
        return , @($parsed | ForEach-Object { $_ })
    }
    try {
        if (-not $gh) { throw 'gh was not found on the PATH' }
        $open = & $read @('--state', 'open')
        $created = & $read @('--state', 'all', '--search', "created:>=$since")
        $closed = & $read @('--state', 'closed', '--search', "closed:>=$since")
        $model = ConvertFrom-IssueList -Open $open -Recent (@($created) + @($closed)) -Now $started -Days 28
        $err = ''
    } catch {
        $model = $null
        $err = ([string]$_.Exception.Message) -replace '\s+', ' '
    }
    return @{ Model = $model; Error = $err; GeneratedAt = $started.ToString('yyyy-MM-dd HH:mm:ss'); Seconds = ((Get-Date) - $started).TotalSeconds; At = Get-Date }
}

function Get-TodayModel {
    <#
        The day plan's model (#3860): day-plan.ps1 -Status, beside this file, run as a child of the same PowerShell, so
        the page and the skill read GitHub through one search. Its JSON is the model; a run that fails, times out or
        answers with something that is not JSON is a ReadError, never a blank page.
    #>
    $started = Get-Date
    try {
        $script = Join-Path $PSScriptRoot 'day-plan.ps1'
        $exe = (Get-Process -Id $PID).Path
        $q = Invoke-BoundedProcess -FilePath $exe -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $script, '-Status') -TimeoutSeconds 60 -WorkingDirectory $root
        if ($q.TimedOut) { throw 'day-plan.ps1 -Status did not answer within 60 s' }
        if ($q.ExitCode -ne 0) { throw ("day-plan.ps1 -Status exited $($q.ExitCode): " + (([string]$q.Output + ' ' + [string]$q.Error).Trim())) }
        $model = ConvertFrom-Json -InputObject $q.Output
        $err = ''
    } catch {
        $model = $null
        $err = ([string]$_.Exception.Message) -replace '\s+', ' '
    }
    return @{ Model = $model; Error = $err; GeneratedAt = $started.ToString('yyyy-MM-dd HH:mm:ss'); At = Get-Date }
}

function Get-GoalsModel {
    <#
        The repo's goals from GitHub (#3816): the open issues labelled goal with their sub-issues and theirs, in ONE
        `gh api graphql` call (Get-GoalsGraphQuery), cached like the issues. It needs owner/name, so a repo whose
        origin is not on github.com is a ReadError, as a gh failure is -- never a blank page.
    #>
    $started = Get-Date
    $slug = (Get-RepoIdentity).Slug
    $gh = Get-ExecutablePath 'gh'
    try {
        if (-not $gh) { throw 'gh was not found on the PATH' }
        if ($slug -notmatch '\A([^/\s]+)/([^/\s]+)\z') { throw 'the origin remote is not a GitHub repository' }
        $argv = @('api', 'graphql', '-f', ('query=' + (Get-GoalsGraphQuery)), '-f', ('owner=' + $Matches[1]), '-f', ('name=' + $Matches[2]), '-f', ('label=' + (Get-GoalLabel)))
        $q = Invoke-BoundedProcess -FilePath $gh -Arguments $argv -TimeoutSeconds 60 -WorkingDirectory $root
        if ($q.TimedOut) { throw 'gh api graphql did not answer within 60 s' }
        if ($q.ExitCode -ne 0) { throw "gh api graphql exited $($q.ExitCode)" }
        $model = ConvertFrom-GoalsGraph -Data (ConvertFrom-Json -InputObject $q.Output)
        $err = ''
    } catch {
        $model = $null
        $err = ([string]$_.Exception.Message) -replace '\s+', ' '
    }
    return @{ Model = $model; Error = $err; GeneratedAt = $started.ToString('yyyy-MM-dd HH:mm:ss'); At = Get-Date }
}

function Resolve-DkjPolicyScript {
    <# The dkj-policy script at -RelativePath this server runs, or '': the first of Get-DkjPolicyScriptCandidates that exists. #>
    param([Parameter(Mandatory = $true)][string]$RelativePath)
    foreach ($c in @(Get-DkjPolicyScriptCandidates -RepoRoot $root -PluginRoot $pluginRoot -RelativePath $RelativePath)) {
        if (Test-Path -LiteralPath $c -PathType Leaf) { return $c }
    }
    return ''
}

function Resolve-AlwaysOnBudgetLib {
    <# The always-on-budget-lib.ps1 this server measures with, or ''. #>
    return Resolve-DkjPolicyScript -RelativePath 'scripts\lib\always-on-budget-lib.ps1'
}

$script:rnFailure = $null
function Update-ReleaseNotesPage {
    <#
        Builds the release-notes page where Get-ReleaseNotesPageNeed says it is absent or stale (#3189), with
        dkj-policy's own build-release-notes-page.ps1 in a CHILD process, bounded at 60 s: it dot-sources the
        repo's scripts/repo-config.ps1, whose functions must not land in this server's scope. Returns
        @{ Error; NoRelease }: Error is '' when the page on disk is current or was just built, else why it could
        not be built; NoRelease is true where the builder answered that the repo has never cut a release (its
        exit 3, #3580), which is an empty state rather than an error. A failed build is kept for 30 s, so a
        page that cannot build does not re-run it on every request; an older page stays served.
    #>
    $releasesDir = Split-Path -Parent (Split-Path -Parent $releaseNotesFile)
    $pageDir = Split-Path -Parent $releaseNotesFile
    $pageTime = Get-ReleaseNotesBuiltTime -IndexFile $releaseNotesFile
    $newest = $null
    if (Test-Path -LiteralPath $releasesDir -PathType Container) {
        $prefix = $pageDir.TrimEnd('\') + '\'
        $newest = Get-ChildItem -LiteralPath $releasesDir -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { -not $_.FullName.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase) } |
            ForEach-Object { $_.LastWriteTimeUtc } | Sort-Object -Descending | Select-Object -First 1
    }
    if (-not (Get-ReleaseNotesPageNeed -PageTime $pageTime -NewestInputTime $newest)) { return @{ Error = ''; NoRelease = $false } }
    if ($script:rnFailure -and ((Get-Date) - $script:rnFailure.At).TotalSeconds -lt 30) { return $script:rnFailure.Result }

    $err = ''; $noRelease = $false
    $builder = Resolve-DkjPolicyScript -RelativePath 'scripts\release\build-release-notes-page.ps1'
    if (-not $builder) {
        $err = 'build-release-notes-page.ps1 was not found in the repo or in the dkj-policy plugin'
    } else {
        try {
            $run = Invoke-BoundedProcess -FilePath (Join-Path $PSHOME 'powershell.exe') -TimeoutSeconds 60 -WorkingDirectory $root -Arguments @(
                '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $builder, '-RootOverride', $root, '-OutFile', $releaseNotesFile)
            if ($run.TimedOut) { $err = 'the build did not finish within 60 s' }
            elseif ($run.ExitCode -eq 3) { $noRelease = $true }
            elseif ($run.ExitCode -ne 0) {
                $last = @("$($run.Error)`n$($run.Output)" -split "`r?`n" | Where-Object { $_.Trim() }) | Select-Object -First 1
                $err = "the build exited $($run.ExitCode)" + $(if ($last) { ': ' + ($last.Trim() -replace '\s+', ' ') } else { '' })
            }
        } catch { $err = (([string]$_.Exception.Message) -replace '\s+', ' ') }
    }
    $result = @{ Error = $err; NoRelease = $noRelease }
    $script:rnFailure = if ($err -or $noRelease) { @{ Result = $result; At = Get-Date } } else { $null }
    return $result
}

function Get-SessionStartModel {
    <#
        The always-on path, measured the way always-on-sessioncheck measures it. In a CHILD process,
        because the measurement dot-sources repo-config.ps1 and the libs, and their functions must not land
        in this server's scope. The child hands back objects, deserialized; a failure is a ReadError.
    #>
    $started = Get-Date
    try {
        $lib = Resolve-AlwaysOnBudgetLib
        if (-not $lib) {
            return @{ Model = $null; Error = 'always-on-budget-lib.ps1 was not found in the repo or in the dkj-policy plugin'; At = Get-Date }
        }
        # The script is handed over encoded, so no quoting layer touches it; the root and the lib go in the
        # environment of the child. The child prints ONE json line with every non-ASCII character escaped, so the
        # console's code page cannot garble a document path. Bounded at 60 s like the gh and git calls.
        $script = @'
$ErrorActionPreference = 'Stop'
$Root = $env:DKJ_GP_ROOT
$Lib = $env:DKJ_GP_LIB
$cfg = Join-Path $Root 'scripts\repo-config.ps1'
if (Test-Path -LiteralPath $cfg) { try { . $cfg } catch { } }
. $Lib
$baseline = Read-AlwaysOnBaseline -RepoRoot $Root
$m = Get-AlwaysOnMeasurement -RepoRoot $Root -Baseline $baseline
$v = Get-AlwaysOnBudgetVerdict -Measurement $m -Budget (Resolve-AlwaysOnBudget) -Baseline $baseline
$docs = @()
foreach ($d in @($m.Measured)) { $docs += [pscustomobject]@{ Display = [string]$d.Display; Bytes = [int64]$d.Bytes; Source = 'measured' } }
foreach ($d in @($m.Carried)) { $docs += [pscustomobject]@{ Display = [string]$d.Display; Bytes = [int64]$d.Bytes; Source = 'carried' } }
foreach ($d in @($m.Unmeasured)) { $docs += [pscustomobject]@{ Display = [string]$d.Display; Bytes = [int64]0; Source = 'unmeasured' } }
$o = [pscustomobject]@{
    Total = [int64]$v.Total; Budget = [int64]$v.Budget; State = [string]$v.State; Ok = [bool]$v.Ok
    Tokens = [int64](ConvertTo-EstimatedTokens -Bytes $v.Total); Documents = @($docs)
}
$json = $o | ConvertTo-Json -Compress -Depth 4
[Console]::Out.WriteLine('DKJ-GP-RESULT ' + [regex]::Replace($json, '[^\x00-\x7F]', { param($x) '\u{0:x4}' -f [int][char]$x.Value }))
'@
        $env:DKJ_GP_ROOT = $root
        $env:DKJ_GP_LIB = $lib
        try {
            $run = Invoke-BoundedProcess -FilePath (Join-Path $PSHOME 'powershell.exe') -TimeoutSeconds 60 -WorkingDirectory $root -Arguments @(
                '-NoProfile', '-ExecutionPolicy', 'Bypass', '-EncodedCommand', [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($script)))
        } finally {
            Remove-Item Env:\DKJ_GP_ROOT, Env:\DKJ_GP_LIB -ErrorAction SilentlyContinue
        }
        if ($run.TimedOut) { return @{ Model = $null; Error = 'the measurement did not finish within 60 s'; At = Get-Date } }
        $line = @($run.Output -split "`r?`n" | Where-Object { $_.StartsWith('DKJ-GP-RESULT ') }) | Select-Object -Last 1
        if (-not $line) { return @{ Model = $null; Error = 'the measurement returned nothing'; At = Get-Date } }
        $out = @(($line.Substring(14) | ConvertFrom-Json))
        $r = $out[-1]
        # An import through the marketplace clone resolves to an absolute path; the page names it from ~.
        $homeDir = ([string]$env:USERPROFILE).Replace('\', '/').TrimEnd('/')
        foreach ($d in @($r.Documents)) {
            if ($homeDir -and $d.Display.Replace('\', '/').StartsWith($homeDir + '/', [StringComparison]::OrdinalIgnoreCase)) {
                $d.Display = '~' + $d.Display.Replace('\', '/').Substring($homeDir.Length)
            }
        }
        $model = @{
            Total = $r.Total; Budget = $r.Budget; State = $r.State; Ok = $r.Ok; Tokens = $r.Tokens
            Documents = @($r.Documents | ForEach-Object { @{ Display = [string]$_.Display; Bytes = [int64]$_.Bytes; Source = [string]$_.Source } })
            GeneratedAt = $started.ToString('yyyy-MM-dd HH:mm:ss'); Seconds = ((Get-Date) - $started).TotalSeconds
        }
        return @{ Model = $model; Error = ''; At = Get-Date }
    } catch {
        return @{ Model = $null; Error = (([string]$_.Exception.Message) -replace '\s+', ' '); At = Get-Date }
    }
}

function Get-AdminObjectsModel {
    <#
        The repo's domain objects for Admin's navigation (#3818): what Get-AdminObjects in its scripts/repo-config.ps1
        returns. In a CHILD process, as Get-SessionStartModel is, because repo-config.ps1's functions must not land in this
        server's scope; bounded at 20 s. No child at all where repo-config.ps1 does not name the seam, so a repo that
        states none pays nothing. Returns @{ Items; At }: a failure, or a seam that is not there, is an empty list -- the
        navigation simply carries no objects -- and Set-AdminObjects checks every value again.
    #>
    $none = @{ Items = @(); At = Get-Date }
    $cfg = Join-Path $root 'scripts\repo-config.ps1'
    if (-not (Test-Path -LiteralPath $cfg -PathType Leaf)) { return $none }
    try { if (-not (Select-String -LiteralPath $cfg -Pattern '\bfunction\s+Get-AdminObjects\b' -Quiet)) { return $none } } catch { return $none }
    $script = @'
$ErrorActionPreference = 'Stop'
. (Join-Path $env:DKJ_GP_ROOT 'scripts\repo-config.ps1')
$items = @()
foreach ($i in @(Get-AdminObjects | Where-Object { $_ })) { $items += [pscustomobject]@{ Label = [string]$i.Label; Href = [string]$i.Href; Count = $(if ($null -ne $i.Count) { [string]$i.Count } else { '' }) } }
$json = ConvertTo-Json -InputObject @($items) -Compress -Depth 3
[Console]::Out.WriteLine('DKJ-GP-RESULT ' + [regex]::Replace($json, '[^\x00-\x7F]', { param($x) '\u{0:x4}' -f [int][char]$x.Value }))
'@
    $env:DKJ_GP_ROOT = $root
    try {
        $run = Invoke-BoundedProcess -FilePath (Join-Path $PSHOME 'powershell.exe') -TimeoutSeconds 20 -WorkingDirectory $root -Arguments @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass', '-EncodedCommand', [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($script)))
        if ($run.TimedOut) { return $none }
        $line = @($run.Output -split "`r?`n" | Where-Object { $_.StartsWith('DKJ-GP-RESULT ') }) | Select-Object -Last 1
        if (-not $line) { return $none }
        $items = @(($line.Substring(14) | ConvertFrom-Json) | Where-Object { $_ } | ForEach-Object {
            @{ Label = [string]$_.Label; Href = [string]$_.Href; Count = $(if ([string]$_.Count) { [string]$_.Count } else { $null }) } })
        return @{ Items = $items; At = Get-Date }
    } catch {
        return $none
    } finally {
        Remove-Item Env:\DKJ_GP_ROOT -ErrorAction SilentlyContinue
    }
}

$utf8 = New-Object System.Text.UTF8Encoding($false)
$rootHash =Get-DevPreviewRootHash -Root $root
$timing = New-AdminTimingContext -RepoRoot $root -RepoName (Get-RepoIdentity).Name -StopwatchPath $StopwatchPath -LogbookPath $LogbookPath -TranscriptDir $TranscriptDir
$listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $Port)
$listener.Start()
Write-Host "general pages for $((Get-RepoIdentity).Name): http://localhost:$Port/"
$ssCache = $null
$isCache = $null
$glCache = $null
$tdCache = $null
$aoCache = $null

try {
    while ($true) {
        $client = $listener.AcceptTcpClient()
        # A client that sends its head and then never reads must not hold the loop on Write either.
        $client.SendTimeout = 2000
        try {
            $request = Read-LoopbackRequest -Client $client -ReadTimeoutMs $ReadTimeoutMs
            if ($null -eq $request) { continue }
            $stream = $client.GetStream()
            $method, $target = ($request.RequestLine -split ' ')[0, 1]
            $path = ([string]$target -split '\?')[0]

            if (-not (Test-LoopbackHost -HostHeader $request.Host -Port $Port)) {
                Send-LoopbackResponse $stream 403 'Forbidden' 'text/plain; charset=utf-8' ($utf8.GetBytes('Forbidden: this server answers only to localhost.')) -Method $method
                continue
            }
            if (Test-LoopbackCrossSite -SecFetchSite $request.SecFetchSite -SecFetchMode $request.SecFetchMode -Method $method -SecFetchDest $request.SecFetchDest) {
                Send-LoopbackResponse $stream 403 'Forbidden' 'text/plain; charset=utf-8' ($utf8.GetBytes((Format-LoopbackCrossSiteRefusal $request.SecFetchSite $request.SecFetchMode $request.SecFetchDest))) -Method $method
                continue
            }
            if ($path -eq '/api/airsquats' -or $path.StartsWith('/api/airsquats/')) {
                # The banner's state (#3438): before the GET-only rule, since ticking the box is a POST.
                $as = Invoke-AirsquatsApi -Method $method -Path $path -SecFetchSite $request.SecFetchSite
                $asHeaders = if ($as.Allow) { @{ Allow = $as.Allow } } else { @{} }
                Send-LoopbackResponse $stream $as.Status $as.Reason 'application/json; charset=utf-8' ($utf8.GetBytes($as.Body)) $asHeaders -Method $method
                continue
            }
            if ($method -ne 'GET' -and $method -ne 'HEAD') {
                Send-LoopbackResponse $stream 405 'Method Not Allowed' 'text/plain; charset=utf-8' ($utf8.GetBytes('GET only.')) @{ Allow = 'GET, HEAD' } -Method $method
                continue
            }
            if ($path -eq '/whoami') {
                # Whose server this is: the hash of the root it was started in. The Admin servers ask before they link here.
                Send-LoopbackResponse $stream 200 'OK' 'text/plain; charset=utf-8' ($utf8.GetBytes($rootHash)) -Method $method
                continue
            }
            if ($static.ContainsKey($path)) {
                $s = $static[$path]
                $body = [System.IO.File]::ReadAllBytes($s.File)
                Send-LoopbackResponse $stream 200 'OK' $s.Type $body -Method $method
                continue
            }
            # The repo's DefaultTheme (#3390), read per request like Admin, so a session start that changes it
            # reaches the next page without a restart, and every page below opens in it.
            $state = Read-RepoAdminState -Root $root
            Set-GeneralPagesThemeDefault $state.Theme
            # Admin's Product section (#3815) links the product this session started, read per request as the theme is.
            Set-AdminProductUrl $(if ($state.Mode -eq 'product') { $state.Product } else { '' })
            # The repo's domain objects (#3818), from its Get-AdminObjects seam, read at most once a minute.
            if ($null -eq $aoCache -or ((Get-Date) - $aoCache.At).TotalSeconds -ge 60) { $aoCache = Get-AdminObjectsModel }
            Set-AdminObjects -Items $aoCache.Items
            if ($path -eq '/about' -or $path -eq '/artifacts') {
                # Admin is one page (#3289): an old link to About this repo goes on to the home page, which holds it. So does an
                # old link to Artifacts, a page retired with the claude.ai Artifacts themselves (#3772).
                Send-LoopbackResponse $stream 303 'See Other' 'text/plain; charset=utf-8' ([byte[]]@()) @{ Location = '/' } -Method $method
                continue
            }
            if ($path -eq '/' -or $path -eq '/index.html' -or $path -eq '/admin') {
                # THE ADMIN IS THIS SERVER'S (#3245), built per request from the state file, in every repo (#3643).
                $adminMode = if ($state.Mode -eq 'product') { 'product' } else { 'none' }
                $adminHtml = Format-PluginRepoAdminHtml -RepoName (Get-RepoIdentity).Name -Folder (Split-Path -Leaf $root) -Mode $adminMode -ProductUrl $state.Product -PagesUrl "http://localhost:$Port"
                Send-LoopbackResponse $stream 200 'OK' 'text/html; charset=utf-8' ($utf8.GetBytes($adminHtml)) -Method $method
                continue
            }
            if ($path -eq '/dev/repository') {
                # Admin's Repository page (#3383): the facts and the Issues page, which the home page no longer holds.
                $adminMode = if ($state.Mode -eq 'product') { 'product' } else { 'none' }
                $id = Get-RepoIdentity
                $repoHtml = Format-PluginRepoRepositoryHtml -RepoName $id.Name -Folder (Split-Path -Leaf $root) -Slug $id.Slug -Mode $adminMode -ProductUrl $state.Product -PagesUrl "http://localhost:$Port"
                Send-LoopbackResponse $stream 200 'OK' 'text/html; charset=utf-8' ($utf8.GetBytes($repoHtml)) -Method $method
                continue
            }
            if ($path -eq '/refresh') {
                # At most one re-run per -MinRefreshSeconds, however often /refresh is asked for. ?page= names
                # where to go back to, from a fixed list, so the redirect never leaves this server.
                $page = if ([string]$target -match '[?&]page=(sessionstart|issues|goals|today)(&|$)') { $Matches[1] } else { '' }
                if ($page -eq 'sessionstart') {
                    if ($ssCache -and ((Get-Date) - $ssCache.At).TotalSeconds -ge $MinRefreshSeconds) { $ssCache = $null }
                } elseif ($page -eq 'issues') {
                    # At least a minute: a re-read holds this single-threaded loop for about 12 s.
                    if ($isCache -and ((Get-Date) - $isCache.At).TotalSeconds -ge [Math]::Max($MinRefreshSeconds, 60)) { $isCache = $null }
                } elseif ($page -eq 'goals') {
                    if ($glCache -and ((Get-Date) - $glCache.At).TotalSeconds -ge $MinRefreshSeconds) { $glCache = $null }
                } elseif ($page -eq 'today') {
                    if ($tdCache -and ((Get-Date) - $tdCache.At).TotalSeconds -ge $MinRefreshSeconds) { $tdCache = $null }
                }
                Send-LoopbackResponse $stream 303 'See Other' 'text/plain; charset=utf-8' ([byte[]]@()) @{ Location = $(if ($page) { "/dev/$page" } else { '/' }) } -Method $method
                continue
            }
            # THE DEVELOPMENT PAGES LIVE UNDER /dev SINCE #3815 (November 5, 2026): Admin is for managing and Product for
            # using, so the tooling that is neither has a section of its own. A link or bookmark to an old address is
            # moved there with the rest of its path and its query kept (Resolve-AdminLegacyPath).
            $legacy = Resolve-AdminLegacyPath -Target ([string]$target)
            if ($legacy) {
                Send-LoopbackResponse $stream 301 'Moved Permanently' 'text/plain; charset=utf-8' ($utf8.GetBytes('Moved.')) @{ Location = $legacy } -Method $method
                continue
            }
            # The Stopwatch's and the Logbook's routes (#3470): a page, a moved run slug, or a slug no run has.
            $tp = Resolve-AdminTimingPage -Path $path -Context $timing
            if ($null -ne $tp) {
                if ($tp.Status -eq 301) { Send-LoopbackResponse $stream 301 'Moved Permanently' 'text/plain; charset=utf-8' ($utf8.GetBytes('Moved.')) @{ Location = $tp.Location } -Method $method }
                elseif ($tp.Status -eq 404) { Send-LoopbackResponse $stream 404 'Not Found' 'text/plain; charset=utf-8' ($utf8.GetBytes('Not found.')) -Method $method }
                else { Send-LoopbackResponse $stream 200 'OK' 'text/html; charset=utf-8' ($utf8.GetBytes($tp.Html)) -Method $method }
                continue
            }
            # The AI page became the Claude page on /dev/claude (Maikel, November 2, 2026): an old /ai or /ai/claude/... link
            # is moved there, the rest of its path kept.
            if ($path -cmatch '^/ai(?:/claude)?(/.*)?$') {
                $to = '/dev/claude' + $(if ($Matches[1] -and $Matches[1] -ne '/') { $Matches[1] })
                Send-LoopbackResponse $stream 301 'Moved Permanently' 'text/plain; charset=utf-8' ($utf8.GetBytes('Moved.')) @{ Location = $to } -Method $method
                continue
            }
            # The Clock is a section of /dev/performance since November 3, 2026 (Dave), so its old page is moved there.
            if ($path -cmatch '^/dev/clock/?$') {
                Send-LoopbackResponse $stream 301 'Moved Permanently' 'text/plain; charset=utf-8' ($utf8.GetBytes('Moved.')) @{ Location = '/dev/performance' } -Method $method
                continue
            }
            $html = $null
            if ($gp = Format-AdminGroupPageHtml -Href $path -RepoName (Get-RepoIdentity).Name -RepoRoot $root) {
                # A group page (Get-AdminGroups): /dev/performance, its Clock section over the Stopwatch and the Logbook and its
                # Context section over SessionStart (Dave, November 3, 2026); it sits in Claude since November 2, 2026,
                # under the same route.
                $html = $gp
            } elseif ($path -cmatch '^/dev/claude/specialists/lenses/(specialist-\d{2}-\d{2}-lens)/?$') {
                # One specialist lens's page, read from this checkout (Maikel, October 30, 2026); a lens it has not is a 404.
                $html = Format-AdminLensPageHtml -Name $Matches[1] -RepoRoot $root -RepoName (Get-RepoIdentity).Name
                if ($null -eq $html) {
                    Send-LoopbackResponse $stream 404 'Not Found' 'text/plain; charset=utf-8' ($utf8.GetBytes('No lens of that name in this repo.')) -Method $method
                    continue
                }
            } elseif ($path -cmatch '^/dev/claude/rules/([A-Za-z0-9._-]{1,80})/?$') {
                # One .claude/rules file's page, read from this checkout (Maikel, November 3, 2026); a name that folder
                # has no file of is a 404.
                $html = Format-AdminRulePageHtml -Name $Matches[1] -RepoRoot $root -RepoName (Get-RepoIdentity).Name
                if ($null -eq $html) {
                    Send-LoopbackResponse $stream 404 'Not Found' 'text/plain; charset=utf-8' ($utf8.GetBytes('No rule document of that name in this repo.')) -Method $method
                    continue
                }
            } elseif ($path -match '^/dev/test-gate(?:/([a-z0-9-]{1,40})(?:/([A-Za-z0-9._-]{1,120}))?)?/?$') {
                # The overview, a list's page, or one suite's (the owner, October 27, 2026); a path none names is a 404.
                $tgPath = (@($Matches[1], $Matches[2]) | Where-Object { $_ }) -join '/'
                $id = Get-RepoIdentity
                $tg = Read-TestGateModel -RepoRoot $root
                $html = Format-TestGatePageHtml -Model $tg.Model -ReadError $tg.Error -GroupsError $tg.GroupsError -RepoName $id.Name -RepoSlug $id.Slug -Path $tgPath
                if ($null -eq $html) {
                    Send-LoopbackResponse $stream 404 'Not Found' 'text/plain; charset=utf-8' ($utf8.GetBytes('No Test gate page of that name.')) -Method $method
                    continue
                }
            } elseif ($plReq = Resolve-PluginsPageRequest -Path $path) {
                # The overview, or one plugin's page (#3482); a name no enabled plugin has is a 404.
                if ($plReq.Redirect) {
                    # The brand book's older house-style addresses (#3629, #3704), so a link to either still lands.
                    Send-LoopbackResponse $stream 301 'Moved Permanently' 'text/plain; charset=utf-8' ($utf8.GetBytes('Moved.')) @{ Location = $plReq.Redirect } -Method $method
                    continue
                }
                $pl = Read-PluginsPageModel -Script (Resolve-DkjPolicyScript -RelativePath 'scripts\task\plugin-versions.ps1') -RepoRoot $root
                if (-not $plReq.Name) {
                    $html = Format-PluginsPageHtml -Model $pl.Model -ReadError $pl.Error -RepoName (Get-RepoIdentity).Name
                } elseif ($plRow = Find-PluginsPageRow -Model $pl.Model -Name $plReq.Name) {
                    $hsState = if ($plReq.Page -eq 'dkj-brandbook') { Read-RepoAdminState -Root $root } else { $null }
                    $hsTo = if ($hsState -and $hsState.Mode -eq 'product') {
                        Resolve-HouseStyleProductUrl -IsSource (Test-Path -LiteralPath (Join-Path $root 'plugins\dkj-policy\assets\dkj-brandbook\specimens.html') -PathType Leaf) `
                            -ProductUrl $hsState.Product -Section $plReq.Section
                    } else { '' }
                    if ($hsTo) {
                        # The source repo shows them on its product (Maikel, October 31, 2026); a 302, since that
                        # depends on which product this session started.
                        Send-LoopbackResponse $stream 302 'Found' 'text/plain; charset=utf-8' ($utf8.GetBytes('On the product.')) @{ Location = $hsTo } -Method $method
                        continue
                    }
                    if ($plReq.Page -eq 'dkj-brandbook') {
                        # The specimens beside the stylesheet this server already serves (#3493), read per request.
                        $specError = ''; $spec = ''
                        try { $spec = [System.IO.File]::ReadAllText((Join-Path $styleDir 'specimens.html'), $utf8) } catch { $specError = $_.Exception.Message }
                        # The overview, or one section's own page (#3563); a slug no section has is a 404.
                        $html = Format-HouseStyleSpecimensPageHtml -Body $spec -ReadError $specError -RepoName (Get-RepoIdentity).Name -Section $plReq.Section
                        if ($null -eq $html) {
                            Send-LoopbackResponse $stream 404 'Not Found' 'text/plain; charset=utf-8' ($utf8.GetBytes('No house-style section of that name.')) -Method $method
                            continue
                        }
                    } elseif ($plReq.Page) {
                        # One specialist, skill or hook the plugin ships (Dave, November 3, 2026); a slug it has none of is a 404.
                        $plContents = Get-PluginContents -Dir (Resolve-PluginPayloadDir -Row $plRow -Model $pl.Model -RepoRoot $root)
                        $html = Format-PluginItemPageHtml -Row $plRow -Contents $plContents -Kind $plReq.Page -Slug $plReq.Section -RepoName (Get-RepoIdentity).Name -RepoRoot $root
                        if ($null -eq $html) {
                            Send-LoopbackResponse $stream 404 'Not Found' 'text/plain; charset=utf-8' ($utf8.GetBytes('This plugin ships nothing of that name.')) -Method $method
                            continue
                        }
                    } else {
                        $plContents = Get-PluginContents -Dir (Resolve-PluginPayloadDir -Row $plRow -Model $pl.Model -RepoRoot $root)
                        $html = Format-PluginPageHtml -Row $plRow -Model $pl.Model -RepoName (Get-RepoIdentity).Name -Contents $plContents
                    }
                } else {
                    Send-LoopbackResponse $stream 404 'Not Found' 'text/plain; charset=utf-8' ($utf8.GetBytes('No plugin of that name is enabled in this repo.')) -Method $method
                    continue
                }
            } elseif ($path -eq '/settings') {
                # Admin's Settings page (Dave, November 2, 2026): the Theme, drawn in the browser.
                $html = Format-AdminSettingsPageHtml -RepoName (Get-RepoIdentity).Name
            } elseif ($path -eq '/dev/issues') {
                # A failed read is kept for 30 s only, so a passing gh hiccup does not show for five minutes.
                $isAge = if ($isCache) { ((Get-Date) - $isCache.At).TotalSeconds } else { 0 }
                if ($null -eq $isCache -or $isAge -ge $IssuesCacheSeconds -or ($isCache.Error -and $isAge -ge 30)) { $isCache = Get-IssuesModel }
                $html = Format-IssuesPageHtml -Model $isCache.Model -ReadError $isCache.Error -GeneratedAt $isCache.GeneratedAt -Seconds $isCache.Seconds -RepoName (Get-RepoIdentity).Name
            } elseif ($path -cmatch '^/dev/goals/?$') {
                # The goals and their next step (#3816), read as the issues are: kept for -IssuesCacheSeconds, a failed read for 30 s.
                $glAge = if ($glCache) { ((Get-Date) - $glCache.At).TotalSeconds } else { 0 }
                if ($null -eq $glCache -or $glAge -ge $IssuesCacheSeconds -or ($glCache.Error -and $glAge -ge 30)) { $glCache = Get-GoalsModel }
                $html = Format-GoalsPageHtml -Model $glCache.Model -ReadError $glCache.Error -GeneratedAt $glCache.GeneratedAt -RepoName (Get-RepoIdentity).Name
            } elseif ($path -cmatch '^/dev/today/?$') {
                # The day plan (#3860): a day moves faster than the issues, so a minute; a failed run, or one that could not
                # read GitHub, for 30 s. Bounded at 60 s like the other gh reads, since the loop serves nothing meanwhile.
                $tdAge = if ($tdCache) { ((Get-Date) - $tdCache.At).TotalSeconds } else { 0 }
                if ($null -eq $tdCache -or $tdAge -ge 60 -or (($tdCache.Error -or ($tdCache.Model -and $tdCache.Model.error)) -and $tdAge -ge 30) -or $tdCache.At.Date -ne (Get-Date).Date) { $tdCache = Get-TodayModel }
                # A day file edited by hand into something the page cannot draw is a warning on the page: the loop's own
                # catch would close the connection with no answer at all (Sebastian, #3860).
                try { $html = Format-TodayPageHtml -Model $tdCache.Model -ReadError $tdCache.Error -GeneratedAt $tdCache.GeneratedAt -RepoName (Get-RepoIdentity).Name }
                catch { $html = Format-TodayPageHtml -Model $null -ReadError ('the day file could not be drawn: ' + (([string]$_.Exception.Message) -replace '\s+', ' ')) -RepoName (Get-RepoIdentity).Name }
            } elseif ($path -match '^/dev/sessionstart(?:/([a-z-]{1,40}))?$') {
                # The overview, or one section's own page (the owner, October 26, 2026); a slug no section has is a 404.
                $ssSection = [string]$Matches[1]
                if ($null -eq $ssCache -or ((Get-Date) - $ssCache.At).TotalSeconds -ge $CacheSeconds) { $ssCache = Get-SessionStartModel }
                $snap = Get-SessionStartSnapshot
                $html = Format-SessionStartPageHtml -Model $ssCache.Model -ReadError $ssCache.Error -RepoName (Get-RepoIdentity).Name -Snapshot $snap.Data -SnapshotError $snap.Error -Section $ssSection
                if ($null -eq $html) {
                    Send-LoopbackResponse $stream 404 'Not Found' 'text/plain; charset=utf-8' ($utf8.GetBytes('No SessionStart section of that name.')) -Method $method
                    continue
                }
            } elseif ($ho = Resolve-HandoverRequest -Path $path) {
                # A preview handover (#3925), or the list of them. A model that cannot be drawn is a warning on the page,
                # never a closed connection.
                $hoDir = Get-HandoverDir -RepoRoot $root
                if (-not $ho.Name) { $html = Format-HandoverIndexHtml -List (Get-HandoverList -Dir $hoDir) -RepoName (Get-RepoIdentity).Name }
                else {
                    $hoRead = Read-HandoverModel -Dir $hoDir -Name $ho.Name
                    try { $html = Format-HandoverPageHtml -Model $hoRead.Model -ReadError $hoRead.Error -RepoName (Get-RepoIdentity).Name }
                    catch { $html = Format-HandoverPageHtml -Model $null -ReadError ('it could not be drawn: ' + (([string]$_.Exception.Message) -replace '\s+', ' ')) -RepoName (Get-RepoIdentity).Name }
                }
            } elseif ($rn = Resolve-ReleaseNotesRequest -Path $path -IndexFile $releaseNotesFile) {
                # The index, or one release's own page beside it (owner, October 25, 2026).
                $build = Update-ReleaseNotesPage
                if (-not (Test-Path -LiteralPath $releaseNotesFile -PathType Leaf)) {
                    if ($build.NoRelease -and -not $rn.Version) {
                        # Before the first cut the index is an empty state, not a build error (#3580).
                        $html = Format-ReleaseNotesEmptyPageHtml -RepoName (Get-RepoIdentity).Name
                        Send-LoopbackResponse $stream 200 'OK' 'text/html; charset=utf-8' ($utf8.GetBytes($html)) -Method $method
                        continue
                    }
                    $why = if ($build.NoRelease) { 'no release has been cut yet' } else { $build.Error }
                    Send-LoopbackResponse $stream 404 'Not Found' 'text/plain; charset=utf-8' ($utf8.GetBytes("Not built yet: this repo has no $workflowFolderRel/releases/page/release-notes.html, and this server could not build it ($why).")) -Method $method
                    continue
                }
                if (-not (Test-Path -LiteralPath $rn.File -PathType Leaf)) {
                    Send-LoopbackResponse $stream 404 'Not Found' 'text/plain; charset=utf-8' ($utf8.GetBytes("No release v$($rn.Version) carries a note here.")) -Method $method
                    continue
                }
                $html = Format-ReleaseNotesDevPage -Html ([System.IO.File]::ReadAllText($rn.File, $utf8)) -RepoName (Get-RepoIdentity).Name -Release:([bool]$rn.Version)
            }
            if ($null -ne $html) {
                $body = $utf8.GetBytes($html)
                Send-LoopbackResponse $stream 200 'OK' 'text/html; charset=utf-8' $body -Method $method
                continue
            }
            Send-LoopbackResponse $stream 404 'Not Found' 'text/plain; charset=utf-8' ($utf8.GetBytes('Not found.')) -Method $method
        } catch {
            # A dropped or silent connection ends that request, never the server.
        } finally {
            $client.Close()
        }
    }
} finally {
    $listener.Stop()
}
