<#
.SYNOPSIS
    Publish a built HTML page to the shared BWJ pages worker -- one Cloudflare Worker serving BOTH
    store repos, with each page held in KV under its own unguessable path token.

.DESCRIPTION
    Issue #1977. The two BWJ stores must publish through ONE worker, and dkj-repo-workflow's own worker
    cannot be that one: build-release-notes-page.ps1 -Worker writes the page into the bundle as a
    literal, and `wrangler deploy` replaces the whole script -- so whichever store deploys last
    erases the other store's page, silently, while both runs report success.

    THE FIX IS THAT THE WORKER CARRIES NO CONTENT. It reads KV, one key per (kind, token). This
    script puts a page there. A redeploy of the worker from either store re-uploads byte-identical
    code and cannot touch what the other store published, which is what makes "the same worker"
    true rather than a race.

    IT DOES NOT BUILD THE PAGE. Building is somebody else's step and stays that way -- the notes
    page is dkj-repo-workflow's build-release-notes-page.ps1 run WITHOUT -Worker, which leaves
    release-notes.html in the page directory this script reads from. This script takes an HTML file
    and publishes it, so a second kind of page needs a builder and no change here.

    WHAT IT WRITES, AND WHERE. Nothing in the repo's tracked tree. The page directory is derived
    from Get-ReleaseNoteRoot exactly as dkj-repo-workflow's builder derives it -- <note root>/../page --
    because that seam already states where this repo keeps its release documents, and a second seam
    would be the same decision written twice. The path tokens live there, one file per kind.

    THE TOKEN IS AN INPUT, NEVER INVENTED. A token made up on the fly does not mean "a new path", it
    means every link already sent now 404s -- while the publish reports success. So a missing token
    is an error with a recovery instruction, and -InitToken is the separate, explicit way to make
    the first one. Same doctrine as dkj-repo-workflow's page token, for the same reason.

    AND HERE THE TOKEN IS ALSO WHAT SEPARATES THE TWO STORES. Both stores answer the same four seam
    values -- one account, one namespace, one worker, one origin -- so the token is the only thing
    that makes one store's URL not the other's. That is why it is per kind and per repo, and why a
    store repo (private, unlike the marketplace this ships from) COMMITS its tokens rather than
    gitignoring them: a tracked token is what survives a lost machine.

    THE API TOKEN IS READ FROM THE ENVIRONMENT AND FROM NOWHERE ELSE. CLOUDFLARE_API_TOKEN, never a
    seam answer and never a file in the repo, because a seam answer is committed by construction.
    It needs Workers KV Storage: Edit on the one namespace and nothing else. WHERE IT IS ABSENT, a
    wrangler login to the seam's account is the second route (#2569): `wrangler kv key put/get
    --remote`, with the same SHA-256 read-back. That login lives in the user's own wrangler config,
    so it is neither a seam answer nor a repo file either.

    IT VERIFIES BY READING THE VALUE BACK, not by believing the upload's own response. That is the
    same lesson dkj-repo-workflow's page carries one layer up -- "verify the bytes the URL serves, never
    the deploy command's output" -- applied where it can actually be automated. The read-back proves the
    write reached KV, and KV is eventually consistent, so an edge that already held the old value may
    keep serving it for up to a minute. THAT HALF IS CHECKED TOO (#4323): unless -NoVerifyServed, the
    run then fetches every page's public URL (cache-buster, no auth header), compares the bytes with
    the ones uploaded, and retries every 10 s for up to a minute. It exits 0 only when the URL serves
    exactly the published page, so a green run means the link can be sent.

    THE NOTES ARE A SET OF PAGES, NOT ONE (#3500). The builder writes an index of cards and, in a
    folder named after it, one page per release, and every card links to its release's own page. So
    a notes publish uploads the whole set -- each release page under '<kind>:<token>/v<x.y.z>', the
    index last under '<kind>:<token>' -- after moving the builder's links from Admin's address onto
    the worker's route (Convert-BwjPageLinks says why the build is not redone for it). Before anything
    is uploaded, every site-absolute link in the set has to be one the worker will serve; a link that
    is not stops the run. That is the measured failure: an index whose every card led to a 404.

    Pure ASCII (repo convention for .ps1).

.PARAMETER Kind
    Which page: 'notes' or 'backlog'. See page-publish-rules.ps1 for what each carries.

.PARAMETER Html
    The built page to publish. Defaults to the kind's own file in the page directory. For 'notes'
    the release pages are read from the folder of the same name beside it.

.PARAMETER LinkBase
    For 'notes': the address the builder's links carry, which this run maps onto the worker's route.
    Defaults to '/release-notes', the builder's own default.
    Refused for a kind that is one page, where there is nothing to map.

.PARAMETER InitToken
    Create this kind's path token when there is none. Refuses to replace one: that is the
    destructive half, and it 404s every link already sent.

.PARAMETER RetireToken
    Close a leaked link (#3506): delete every KV key under this kind's token -- the page and, for
    'notes', every release page under it -- then remove the token file, so -InitToken can mint the
    next one. A fresh token alone does not close the leak: the old keys keep serving to whoever holds
    the old link. With -DryRun it lists the keys and deletes nothing.

.PARAMETER Token
    With -RetireToken: the token to retire, when it is not the one on file -- the case where a fresh
    token was minted before the old keys were deleted. The token file is then left alone.

.PARAMETER EmitWorker
    Write worker.js and (only when absent) wrangler.toml into the page directory, for the one-time
    `npx wrangler deploy` that puts the shared worker up. Deploys nothing itself.

.PARAMETER ShowUrl
    Print this kind's link and stop. Publishes nothing.

.PARAMETER CheckAuth
    Print this kind's link, then prove a route to KV exists -- CLOUDFLARE_API_TOKEN, or a wrangler login to
    the seam's account -- and stop. Publishes nothing. prepare-release runs it days ahead (#4155), so a missing
    login is found before the release day instead of at the publish.

.PARAMETER DryRun
    Do everything except the upload -- resolve the seam, read the page, name the key and the URL.

.PARAMETER All
    Upload every page, whatever this machine's record of the last verified publish says. By default a
    page whose bytes this machine already verified under the same key is skipped (#4160); -All is for
    a key that was changed or deleted in KV from somewhere else.

.PARAMETER NoVerifyServed
    Skip the served-bytes check (#4323). By default, after the upload and its KV read-back, every page of
    the set -- the skipped ones too -- is fetched from its PUBLIC url with a cache-buster and compared
    byte for byte with what was uploaded, every 10 s for up to a minute, and the run fails unless the url
    serves exactly the published page. Meaningless with -DryRun, -ShowUrl, -CheckAuth, -InitToken,
    -RetireToken and -EmitWorker, which never reach it, and ignored there.

.PARAMETER RootOverride
    The repo root, when this is not run from inside the checkout.

.EXAMPLE
    ./publish-page.ps1 -Kind notes
    Publishes the release-notes page the dkj-repo-workflow builder left in the page directory.

.EXAMPLE
    ./publish-page.ps1 -EmitWorker
    Writes the shared worker's bundle and names the deploy command.
#>
[CmdletBinding()]
param(
    [string]$Kind = 'notes',
    [string]$Html,
    [string]$LinkBase,
    [switch]$InitToken,
    [switch]$RetireToken,
    [string]$Token,
    [switch]$EmitWorker,
    [switch]$ShowUrl,
    [switch]$CheckAuth,
    [switch]$DryRun,
    [switch]$All,
    [switch]$NoVerifyServed,
    [string]$RootOverride
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\page-publish-rules.ps1')
. (Join-Path $PSScriptRoot '..\lib\repo-root-lib.ps1')

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# The npx a PRINTED command names. In Windows PowerShell 'npx' resolves to node's npx.ps1, which the
# default execution policy refuses to load; npx.cmd beside it is not subject to the policy (#2651).
# Invoke-BwjNpx runs through cmd.exe and is unaffected -- this is only what a person is told to type.
$npx = if ($env:OS -eq 'Windows_NT') { 'npx.cmd' } else { 'npx' }

# Windows PowerShell 5.1 still negotiates TLS 1.0 by default on some hosts, and api.cloudflare.com
# refuses it. Raised rather than replaced, so nothing a host already enabled is taken away.
try {
    [Net.ServicePointManager]::SecurityProtocol =
        [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch { }

# --- The repo root ---------------------------------------------------------------------------------
# Resolve-BwjRepoRoot, dot-sourced above from repo-root-lib.ps1 (issue #1979's review chain pulled
# this out of a private copy here -- build-backlog-page.ps1 needed the identical function under a
# different name). Still self-contained: the lib lives inside this plugin's own scripts\lib\, so
# dot-sourcing it is not reaching into a second plugin's libs.
$repoRoot = Resolve-BwjRepoRoot -Override $RootOverride

# --- The repo's own answers ------------------------------------------------------------------------
# Read in a CHILD scope with StrictMode explicitly OFF, the same way dkj-repo-workflow's builder reads its
# seam: this script runs under StrictMode Latest while repo-config.ps1 is written on the assumption
# that its callers do not.
$config = & {
    Set-StrictMode -Off
    $answers = @{ NoteRoot = 'releases/notes'; Pages = $null }
    $configPath = Join-Path $args[0] 'scripts\repo-config.ps1'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        throw ("This repo has no scripts\repo-config.ps1, so it has answered neither where its " +
               "release documents live nor which worker it publishes to. Run adopt-dkj-repo-workflow-bwj.")
    }
    . $configPath
    # NOT Get-Command: it parses the name as a wildcard pattern and pays a full PATH scan on every
    # miss -- and a miss is the normal case for an optional seam (source repo issue #1729, which
    # moved every probe in that tree onto this idiom). Written out here rather than dot-sourced from
    # command-probe-lib.ps1, because this plugin's scripts deliberately pull in nothing outside their
    # own folder: a store forwards to them from the plugin cache without a second plugin's libs.
    $defined = { param($Name) [bool](@($ExecutionContext.InvokeCommand.GetCommands($Name, 'Function', $false)).Count) }
    if (& $defined 'Get-ReleaseNoteRoot')  { $answers.NoteRoot = Get-ReleaseNoteRoot }
    if (& $defined 'Get-BwjPagesConfig')   { $answers.Pages    = Get-BwjPagesConfig }
    return $answers
} $repoRoot

$pages = Resolve-BwjPagesConfig -Config $config.Pages

$noteRoot = Join-Path $repoRoot ($config.NoteRoot -replace '/', '\')
$pageDir  = Join-Path (Split-Path -Parent $noteRoot) 'page'
if (-not (Test-Path -LiteralPath $pageDir)) { New-Item -ItemType Directory -Force -Path $pageDir | Out-Null }

Write-Host ""
Write-Host "== publish-page ($($pages.Worker)) ==" -ForegroundColor Cyan
Write-Host "  page dir : $pageDir" -ForegroundColor DarkGray

# --- -EmitWorker: the shared worker's bundle --------------------------------------------------------
if ($EmitWorker -and $RetireToken) { throw "-EmitWorker and -RetireToken are two runs: -EmitWorker exits before a retirement would start." }
if ($EmitWorker) {
    $source = Join-Path $PSScriptRoot '..\..\worker\bwj-pages-worker.js'
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "The worker source is missing from this plugin: $source"
    }
    $workerPath = Join-Path $pageDir 'worker.js'
    Copy-Item -LiteralPath $source -Destination $workerPath -Force
    Write-Host "  worker   : $workerPath (copied from the plugin -- it carries no page content)" -ForegroundColor Green

    # WRITTEN ONLY WHEN ABSENT, the same doctrine dkj-repo-workflow's builder states for its own: a consumer
    # edits this file -- an account id, a custom domain, a route -- and regenerating it every run
    # would silently discard that. A value that has drifted from the seam is reported, not corrected,
    # because which of the two is wrong is not this script's to decide.
    $wranglerPath = Join-Path $pageDir 'wrangler.toml'
    if (-not (Test-Path -LiteralPath $wranglerPath -PathType Leaf)) {
        $wrangler = @"
name = "$($pages.Worker)"
main = "worker.js"
compatibility_date = "2025-04-01"
workers_dev = true

# The pages themselves live here, one key per '<kind>:<token>'. The worker holds no content of its
# own, which is what lets BOTH BWJ store repos deploy this same worker without either one erasing
# the other's page.
[[kv_namespaces]]
binding = "BWJ_PAGES"
id = "$($pages.NamespaceId)"

# No account_id on purpose: one more identifier to keep out of a file, and wrangler resolves the
# account from CLOUDFLARE_ACCOUNT_ID or from the token when it has only one.
"@
        [System.IO.File]::WriteAllText($wranglerPath, $wrangler, $Utf8NoBom)
        Write-Host "  wrangler : $wranglerPath (written -- it is yours from now on, never overwritten)" -ForegroundColor Yellow
    } else {
        $text = [System.IO.File]::ReadAllText($wranglerPath, [System.Text.Encoding]::UTF8)
        $declaredName = [regex]::Match($text, '(?m)^\s*name\s*=\s*"([^"]+)"')
        if ($declaredName.Success -and $declaredName.Groups[1].Value -ne $pages.Worker) {
            Write-Warning ("wrangler.toml deploys '$($declaredName.Groups[1].Value)' while " +
                           "Get-BwjPagesConfig says '$($pages.Worker)'. One of the two is wrong -- " +
                           "this script does not pick. Deploying the wrong name puts a SECOND worker " +
                           "up, which is the one thing the shared design exists to avoid.")
        }
        if ($text -notmatch [regex]::Escape($pages.NamespaceId)) {
            Write-Warning ("wrangler.toml does not bind the namespace Get-BwjPagesConfig names " +
                           "($($pages.NamespaceId)). A worker bound to another namespace answers 404 " +
                           "for every page this script publishes.")
        }
        Write-Host "  wrangler : $wranglerPath (left as it is)" -ForegroundColor DarkGray
    }

    Write-Host ""
    # Two lines, not '&&', which Windows PowerShell 5.1 cannot parse (#2651).
    Write-Host "  Next:  cd `"$pageDir`"" -ForegroundColor Cyan
    Write-Host "         $npx wrangler deploy" -ForegroundColor Cyan
    Write-Host "  This is the SHARED worker: deploying it from either store repo is the same act, and" -ForegroundColor DarkGray
    Write-Host "  neither deploy can disturb a page the other store published -- the pages are in KV." -ForegroundColor DarkGray
    exit 0
}

# --- Reaching KV ---------------------------------------------------------------------------------------
function Invoke-BwjNpx {
    <#
        Runs `npx --no-install <Arguments>` through cmd.exe, with CLOUDFLARE_ACCOUNT_ID set to the
        seam's account for the child only. Returns ExitCode and Text (stdout + stderr). With
        -StdoutPath, stdout is copied to that file AS BYTES and is not in Text: the read-back is
        hashed, and a PowerShell pipe would decode it with the console code page first.

        --no-install so a machine without wrangler gets a refusal rather than a download.

        EVERY ARGUMENT IS QUOTED, AND '"' AND '%' ARE REFUSED. The line runs through cmd.exe, and a
        path is a legal NTFS name that may carry & | < > ^ ( ) with no space in it. Quoting only on
        whitespace let 'C:\a&cmd&b.html' run a second command (Sebastian, on this branch, exercised
        against a real cmd.exe). Inside double quotes those characters are literal. Two are not:
        '"' ends the quote, and '%' still expands a variable. Windows forbids '"' in a file name
        anyway, so refusing both costs a path nobody has.
    #>
    param(
        [Parameter(Mandatory)][string[]]$Arguments,
        [string]$StdoutPath
    )
    foreach ($a in $Arguments) {
        if ($a -match '["%]') {
            throw "Refusing to hand '$a' to cmd.exe: a '`"' or '%' in an argument is not safe to quote there. Rename the file."
        }
    }
    $quoted = ($Arguments | ForEach-Object { '"' + $_ + '"' }) -join ' '
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $env:ComSpec
    $psi.Arguments = '/d /s /c "npx --no-install ' + $quoted + '"'
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    $psi.EnvironmentVariables['CLOUDFLARE_ACCOUNT_ID'] = $pages.AccountId
    $p = [System.Diagnostics.Process]::Start($psi)
    $errTask = $p.StandardError.ReadToEndAsync()
    $text = ''
    if ($StdoutPath) {
        $fs = [System.IO.File]::Create($StdoutPath)
        try { $p.StandardOutput.BaseStream.CopyTo($fs) } finally { $fs.Dispose() }
    } else {
        $text = $p.StandardOutput.ReadToEnd()
    }
    $p.WaitForExit()
    return [pscustomobject]@{ ExitCode = $p.ExitCode; Text = ($text + $errTask.Result) }
}

# Which route reaches KV this run: CLOUDFLARE_API_TOKEN, else a wrangler login to the seam's account.
# A function so a publish and a retirement (#3506) authenticate the one way; it sets $useWrangler and
# $apiToken at script scope, which Publish-BwjKvValue and the retirement read.
function Connect-BwjKv {
    $script:apiToken = $env:CLOUDFLARE_API_TOKEN
    $script:useWrangler = [string]::IsNullOrWhiteSpace($script:apiToken)
    if ($script:useWrangler) {
        # A WRANGLER LOGIN TO THIS ACCOUNT IS THE SECOND ROUTE (issue #2569). It is neither a seam answer
        # nor a file in the repo, which is what the rule about the token protects, and it is how a machine
        # that deployed the worker is usually authenticated. The proof is the same: read the value back
        # and compare SHA-256. Test-BwjWranglerSession explains why the account id, not the exit code,
        # decides.
        $who = Invoke-BwjNpx -Arguments @('wrangler', 'whoami')
        if (-not (Test-BwjWranglerSession -WhoamiText $who.Text -ExitCode $who.ExitCode -AccountId $pages.AccountId)) {
            throw ("CLOUDFLARE_API_TOKEN is not set, and '$npx wrangler whoami' shows no login to account " +
                   "$($pages.AccountId). Either route publishes: (1) CLOUDFLARE_API_TOKEN in the environment " +
                   "-- never a seam answer, never a file in the repo, because both of those are committed by " +
                   "construction; it needs 'Workers KV Storage: Edit' on this account and nothing more -- or " +
                   "(2) '$npx wrangler login' as a user who can reach this account.")
        }
        Write-Host "  auth     : wrangler login to account $($pages.AccountId) (CLOUDFLARE_API_TOKEN is not set)" -ForegroundColor DarkGray
    }
}

# --- The kind, the token and the URL ----------------------------------------------------------------
if (-not (Test-BwjPageKind -Kind $Kind)) {
    $known = (Get-BwjPageKinds | ForEach-Object { "$($_.Kind) -- $($_.What)" }) -join "`n           "
    throw "'$Kind' is not a kind this worker routes. The kinds are:`n           $known"
}

$tokenPath = Join-Path $pageDir (Get-BwjPageTokenFileName -Kind $Kind)

# --- -RetireToken: close a leaked link (#3506) ---------------------------------------------------------
# A FRESH TOKEN ALONE DOES NOT CLOSE A LEAK. The next publish goes to a new URL, and every key under the
# old token goes on serving the old content to whoever holds the old link. So retiring is deleting
# those keys, and only then the token file, so -InitToken can mint the next one.
# -Token IS THE SAME VARIABLE as the $token the publish path assigns below -- PowerShell names are
# case-insensitive -- so it is refused here unless this block consumes it and exits.
if ($Token -and -not $RetireToken) { throw "-Token names the token -RetireToken retires; on its own it does nothing." }
if ($RetireToken) {
    if ($InitToken) { throw "-RetireToken and -InitToken are two runs: retire first, then mint the next token." }
    $onFile = $null
    if (Test-Path -LiteralPath $tokenPath -PathType Leaf) {
        $onFile = ([System.IO.File]::ReadAllText($tokenPath, [System.Text.Encoding]::UTF8)).Trim()
    }
    $retired = if ($Token) { $Token.Trim() } else { $onFile }
    if (-not $retired) {
        throw ("There is no token for '$Kind' at $tokenPath to retire. Name the leaked one with -Token " +
               "<32 hex> -- it is the last part of the leaked link.")
    }
    $prefix    = Get-BwjPageKeyPrefix -Kind $Kind -Token $retired
    $isOnFile  = ($retired -ceq $onFile)
    Write-Host "  retire   : every key under $prefix$(if ($isOnFile) { ' (the token on file)' } else { ' (not the token on file, which is left alone)' })" -ForegroundColor Yellow

    Connect-BwjKv
    $retireHeaders = @{ Authorization = "Bearer $apiToken" }
    function Get-BwjRetireKeys {
        # A listing that cannot be read throws rather than answering 'none': 'no keys left' is the one
        # answer that would let a leaked token look retired.
        if ($useWrangler) {
            $listPath = Join-Path ([System.IO.Path]::GetTempPath()) ("bwj-page-list-" + [guid]::NewGuid().ToString('N') + '.tmp')
            try {
                $list = Invoke-BwjNpx -Arguments (Get-BwjPageWranglerListArgs -Prefix $prefix -NamespaceId $pages.NamespaceId) -StdoutPath $listPath
                if ($list.ExitCode -ne 0) { throw "Listing $prefix through wrangler failed (exit $($list.ExitCode)): $($list.Text.Trim())" }
                $names = ConvertFrom-BwjWranglerKeyList -Text ([System.IO.File]::ReadAllText($listPath, [System.Text.Encoding]::UTF8))
            } finally {
                Remove-Item -LiteralPath $listPath -Force -ErrorAction SilentlyContinue
            }
        } else {
            $names = New-Object System.Collections.Generic.List[string]
            $cursor = $null
            do {
                $uri = Get-BwjPageKvKeysApiUrl -AccountId $pages.AccountId -NamespaceId $pages.NamespaceId -Prefix $prefix -Cursor $cursor
                try { $page = Invoke-RestMethod -Method Get -Uri $uri -Headers $retireHeaders -TimeoutSec 120 }
                catch { throw "Listing $prefix through the KV API failed: $($_.Exception.Message)" }
                $ok = $page.PSObject.Properties['success']
                if ($null -eq $ok -or -not $ok.Value) { throw "Cloudflare refused the listing of ${prefix}." }
                foreach ($item in @($page.result)) { $names.Add([string]$item.name) }
                $cursor = $null
                $info = $page.PSObject.Properties['result_info']
                if ($null -ne $info -and $info.Value -and $info.Value.PSObject.Properties['cursor']) { $cursor = [string]$info.Value.cursor }
            } while ($cursor)
            $names = $names.ToArray()
        }
        return @(Select-BwjTokenKeys -Names @($names) -Kind $Kind -Token $retired)
    }

    $keys = @(Get-BwjRetireKeys)
    # The index first: it is the page the leaked link opens on, so it stops serving soonest.
    $keys = @($keys | Sort-Object { $_ -ne $prefix }, { $_ })
    Write-Host "  keys     : $($keys.Count) under $prefix" -ForegroundColor DarkGray
    foreach ($k in $keys) { Write-Host "             $k" -ForegroundColor DarkGray }

    if ($DryRun) {
        Write-Host ""
        Write-Host "  -DryRun: nothing was deleted, and the token file is as it was." -ForegroundColor Yellow
        exit 0
    }

    foreach ($k in $keys) {
        if ($useWrangler) {
            $del = Invoke-BwjNpx -Arguments (Get-BwjPageWranglerArgs -Action delete -Key $k -NamespaceId $pages.NamespaceId)
            if ($del.ExitCode -ne 0) { throw "Deleting $k through wrangler failed (exit $($del.ExitCode)): $($del.Text.Trim()). Run -RetireToken again; it is safe to repeat." }
        } else {
            $valueUrl = Get-BwjPageKvApiUrl -AccountId $pages.AccountId -NamespaceId $pages.NamespaceId -Key $k
            try { $del = Invoke-RestMethod -Method Delete -Uri $valueUrl -Headers $retireHeaders -TimeoutSec 120 }
            catch { throw "Deleting $k through the KV API failed: $($_.Exception.Message). Run -RetireToken again; it is safe to repeat." }
            $ok = $del.PSObject.Properties['success']
            if ($null -eq $ok -or -not $ok.Value) { throw "Cloudflare refused to delete ${k}. Run -RetireToken again; it is safe to repeat." }
        }
        Write-Host "  deleted  : $k" -ForegroundColor DarkGray
    }

    # THE LISTING AGAIN IS THE PROOF, as the read-back is for a publish. KV listings are eventually
    # consistent too, so a key that still shows is reported and the token file is KEPT: the run is
    # repeated, and the next one starts from the same token.
    $left = @(Get-BwjRetireKeys)
    if ($left.Count) {
        throw ("$($left.Count) key(s) still list under ${prefix}: " + ($left -join ', ') + ". KV listings can lag " +
               "for up to a minute -- run -RetireToken again" + $(if (-not $isOnFile) { " -Token $retired" } else { '' }) +
               ". The token file was left in place so it can.")
    }
    Write-Host "  verified : no key lists under $prefix any more" -ForegroundColor Green
    if ($isOnFile) {
        Remove-Item -LiteralPath $tokenPath -Force
        Write-Host "  token    : $tokenPath (removed)" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "  The leaked link answers 404 once each edge's copy expires -- up to a minute." -ForegroundColor DarkGray
    if ($isOnFile) {
        Write-Host "  Next: -InitToken for a fresh path, publish again, COMMIT the new token file, and send the" -ForegroundColor Cyan
        Write-Host "  new link to whoever should still have it." -ForegroundColor Cyan
    }
    exit 0
}

if ($InitToken) {
    if (Test-Path -LiteralPath $tokenPath -PathType Leaf) {
        throw ("A path token for '$Kind' already exists at $tokenPath. This script does not replace " +
               "one: the URL carrying it has been sent, so a new token means every existing link " +
               "404s. If its link has leaked, -RetireToken deletes the keys under it and then this file; " +
               "deleting the file alone leaves the old link serving.")
    }
    # THE GUARD ABOVE ASKS 'IS THERE A TOKEN HERE', WHICH IS THE WRONG QUESTION AFTER A FOLDER MOVE.
    # The page directory is derived and gitignored, so repointing the note root strands the token
    # where nothing points at it any more -- and then the check above finds nothing and mints a
    # second one happily. See Find-BwjStrayPageToken for the measurement behind that.
    $strays = @(Find-BwjStrayPageToken -Root $repoRoot -Kind $Kind -ExpectedPath $tokenPath)
    if ($strays.Count) {
        throw ("There is no token for '$Kind' at $tokenPath, but this tree already holds one: " +
               ($strays -join ', ') + ". That is almost certainly the live one, left behind by a move " +
               "of the folder this directory is derived from -- git cannot carry an ignored file along. " +
               "MOVE it here rather than minting a second token, which 404s every link already sent.")
    }
    $token = New-BwjPageToken
    [System.IO.File]::WriteAllText($tokenPath, $token, $Utf8NoBom)
    Write-Host "  token    : $tokenPath (created)" -ForegroundColor Yellow
    Write-Host "  url      : $(Get-BwjPageUrl -BaseUrl $pages.BaseUrl -Kind $Kind -Token $token)" -ForegroundColor Green
    Write-Host ""
    Write-Host "  COMMIT THIS FILE. A store repo is private, and a tracked token is what survives a" -ForegroundColor DarkGray
    Write-Host "  lost machine -- without it nothing anywhere remembers the URL you just created." -ForegroundColor DarkGray
    exit 0
}

if (-not (Test-Path -LiteralPath $tokenPath -PathType Leaf)) {
    # ONE SEARCH BEFORE THE REFUSAL IS PRINTED, because the likeliest reason it is missing HERE is
    # that it is somewhere else -- see Find-BwjStrayPageToken.
    $strays = @(Find-BwjStrayPageToken -Root $repoRoot -Kind $Kind -ExpectedPath $tokenPath)
    $lead = ''
    if ($strays.Count) {
        $lead = ("This tree already holds one, at " + ($strays -join ', ') + " -- almost certainly " +
                 "left behind by a move of the folder this directory is derived from. MOVE that file " +
                 "here; everything else in this directory rebuilds in a second and it does not. ")
    }
    throw ("The path token for '$Kind' is missing: $tokenPath. " + $lead + "This script does NOT " +
           "invent one -- the " +
           "path is the only lock on the page, so a fresh token means every link already sent 404s " +
           "while this run reports success. Three ways back, in the order worth trying: (1) restore " +
           "the 32 hex characters from the URL you have; (2) if the page is still up, the token is " +
           "readable from the KV namespace's key list in the Cloudflare dashboard, which holds " +
           "'${Kind}:<token>' for every page ever published; (3) only once both are exhausted, " +
           "-InitToken for a fresh path.")
}
$token = ([System.IO.File]::ReadAllText($tokenPath, [System.Text.Encoding]::UTF8)).Trim()
$key   = Get-BwjPageKvKey -Kind $Kind -Token $token
$url   = Get-BwjPageUrl -BaseUrl $pages.BaseUrl -Kind $Kind -Token $token

if ($ShowUrl) {
    Write-Host "  url      : $url" -ForegroundColor Green
    exit 0
}

# THE LOGIN, PROVED AHEAD OF THE DAY (#4155). Measured at a consumer's v3.1.0: the publish refused on release
# day for want of a login, a fact that was true and checkable days before. Connect-BwjKv is the publish's own
# check, so this cannot disagree with it; a refusal throws, and the caller reads the non-zero exit.
if ($CheckAuth) {
    Write-Host "  url      : $url" -ForegroundColor Green
    Connect-BwjKv
    Write-Host '  auth     : a route to KV is ready' -ForegroundColor Green
    exit 0
}

# --- The page, or the set of pages --------------------------------------------------------------------
if (-not $Html) {
    $default = @{ notes = 'release-notes.html'; backlog = 'minor-backlog.html' }
    $Html = Join-Path $pageDir $default[$Kind]
}
if (-not (Test-Path -LiteralPath $Html -PathType Leaf)) {
    throw ("The page to publish is missing: $Html. Build it first -- '$Kind' is built by " +
           "$((Get-BwjPageKinds | Where-Object { $_.Kind -eq $Kind }).What) -- or name another file " +
           "with -Html. This script publishes a page; it does not build one.")
}
$Html = (Resolve-Path -LiteralPath $Html).Path

# Each upload is one KV value: its key, the file it comes from, and -- for a paged kind -- the text with
# its links moved onto the route. The release pages come first and the index LAST, the order the builder
# writes them in and for the same reason: a run that fails part-way leaves the old index in place, and
# every page it points at still exists.
$uploads = New-Object System.Collections.Generic.List[object]
if (Test-BwjPageKindPaged -Kind $Kind) {
    if (-not $LinkBase) { $LinkBase = Get-BwjNotesLinkBase }
    $route      = "/$Kind/$token"
    $releaseDir = Join-Path (Split-Path -Parent $Html) ([System.IO.Path]::GetFileNameWithoutExtension($Html))
    $files = @()
    if (Test-Path -LiteralPath $releaseDir -PathType Container) {
        $files = @(Get-ChildItem -LiteralPath $releaseDir -Filter 'v*.html' -File |
                   Where-Object { Test-BwjPageRelease -Release $_.BaseName } | Sort-Object Name)
    }
    $releases = @($files | ForEach-Object { $_.BaseName })
    $set = @($files) + @(Get-Item -LiteralPath $Html)
    for ($i = 0; $i -lt $set.Count; $i++) {
        $f = $set[$i]
        $isIndex = ($i -eq $set.Count - 1)   # the index is last, by construction
        $text = Convert-BwjPageLinks -Html ([System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)) `
                                     -FromBase $LinkBase -ToBase $route
        $dead = @(Find-BwjDeadPageLinks -Html $text -Route $route -Releases $releases)
        if ($dead.Count) {
            $shown = ($dead | Select-Object -First 5) -join ', '
            throw ("$($f.Name) links to $($dead.Count) address(es) the worker will not serve once this set is " +
                   "published: $shown. Its cards would lead to a 404 while this run reported success (#3500). " +
                   "Rebuild the notes so the index and $releaseDir come from the same run, or name the " +
                   "address the build links to with -LinkBase (the builder's own -LinkBase).")
        }
        $pageKey = if ($isIndex) { $key } else { Get-BwjPageKvKey -Kind $Kind -Token $token -Release $f.BaseName }
        # Url: the public address the served-bytes check fetches -- '<route>' for the index, '<route>/v<x.y.z>'
        # for a release page, the shape the worker's ROUTE takes. ContentHash is filled in the upload loop.
        $pageUrl = if ($isIndex) { $url } else { $url + '/' + $f.BaseName }
        $uploads.Add([pscustomobject]@{ Key = $pageKey; From = $f.FullName; Text = $text; Path = $null; Url = $pageUrl; ContentHash = $null })
    }
} else {
    if ($LinkBase) { throw "-LinkBase applies to a set of pages, and '$Kind' is one page: there are no links to map." }
    $uploads.Add([pscustomobject]@{ Key = $key; From = $Html; Text = $null; Path = $Html; Url = $url; ContentHash = $null })
}

# The served-bytes check's pace (#4323): script-level so a change is one line, not a parameter nobody sets.
$servedIntervalSeconds = 10
$servedDeadlineSeconds = 60

$totalBytes = 0
foreach ($u in $uploads) {
    $size = if ($null -ne $u.Text) { $Utf8NoBom.GetByteCount($u.Text) } else { (Get-Item -LiteralPath $u.From).Length }
    $null = Test-BwjPageSize -Bytes $size
    $totalBytes += $size
}

Write-Host "  page     : $Html ($([math]::Round($totalBytes / 1KB)) KB)" -ForegroundColor DarkGray
Write-Host "  key      : $key" -ForegroundColor DarkGray
if ($uploads.Count -gt 1) {
    Write-Host "  releases : $($uploads.Count - 1) page(s), each under $key/v<x.y.z>" -ForegroundColor DarkGray
}
Write-Host "  url      : $url" -ForegroundColor Green

if ($DryRun) {
    Write-Host ""
    Write-Host "  -DryRun: nothing was uploaded." -ForegroundColor Yellow
    exit 0
}

# --- The upload, and the read-back that is the actual proof -------------------------------------------
Connect-BwjKv
$headers = @{ Authorization = "Bearer $apiToken" }

function Publish-BwjKvValue {
    <#
        Upload one file to one key and read it back, by whichever route this run authenticated on.
        Throws unless KV holds the exact bytes of the file (SHA-256).
    #>
    param(
        [Parameter(Mandatory)][string]$Key,
        [Parameter(Mandatory)][string]$Path
    )
    $hash = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    $verifyPath = Join-Path ([System.IO.Path]::GetTempPath()) ("bwj-page-verify-" + [guid]::NewGuid().ToString('N') + '.tmp')
    try {
        if ($useWrangler) {
            $put = Invoke-BwjNpx -Arguments (Get-BwjPageWranglerArgs -Action put -Key $Key -NamespaceId $pages.NamespaceId -Path $Path)
            if ($put.ExitCode -ne 0) {
                throw "The upload of $Key through wrangler failed (exit $($put.ExitCode)): $($put.Text.Trim())"
            }
            $get = Invoke-BwjNpx -Arguments (Get-BwjPageWranglerArgs -Action get -Key $Key -NamespaceId $pages.NamespaceId) -StdoutPath $verifyPath
            if ($get.ExitCode -ne 0) {
                throw ("The upload of $Key was accepted but the read-back through wrangler failed (exit $($get.ExitCode)): " +
                       "$($get.Text.Trim()). Nothing proves what the URL serves -- fetch it before sending the link.")
            }
        } else {
            $valueUrl = Get-BwjPageKvApiUrl -AccountId $pages.AccountId -NamespaceId $pages.NamespaceId -Key $Key
            try {
                $put = Invoke-RestMethod -Method Put -Uri $valueUrl -Headers $headers -InFile $Path `
                                         -ContentType 'text/plain; charset=utf-8' -TimeoutSec 120
            } catch {
                # The message can carry the response body, which is Cloudflare's and safe; the token is only
                # ever in the request headers, which are not echoed here.
                throw "The upload of $Key to KV failed: $($_.Exception.Message)"
            }
            # READ DEFENSIVELY, because this runs under StrictMode Latest and the object comes off the
            # network. A response without a 'success' field is not a success -- it is a shape nobody here
            # has seen, and dying on a missing property would report it as a PowerShell fault.
            $reported = $put.PSObject.Properties['success']
            if ($null -eq $reported -or -not $reported.Value) {
                $why = 'the response carried no success field'
                $errs = $put.PSObject.Properties['errors']
                if ($null -ne $errs -and $errs.Value) { $why = ((@($errs.Value) | ForEach-Object { $_.message }) -join '; ') }
                throw "Cloudflare refused the upload of ${Key}: $why"
            }
            # -UseBasicParsing is not optional here. Without it Windows PowerShell hands the body to the
            # Internet Explorer engine to build a DOM -- and the body is a whole HTML page, which is exactly
            # the case that fails on a host where IE was never first-run. That would break the script's
            # own correctness proof after the upload has already landed.
            Invoke-WebRequest -Method Get -Uri $valueUrl -Headers $headers -OutFile $verifyPath `
                              -UseBasicParsing -TimeoutSec 120 | Out-Null
        }
        # THE READ-BACK IS THE PROOF, not the accepted upload. An accepted upload and a stored value are
        # different facts, and this is the one place the difference can be settled without a reader.
        $back = (Get-FileHash -LiteralPath $verifyPath -Algorithm SHA256).Hash
        if ($back -ne $hash) {
            throw ("KV answered $Key with different bytes than were uploaded (SHA-256 $back against $hash). " +
                   "The page at the URL is NOT the file that was just built -- do not send the link on.")
        }
    } finally {
        # THE FAILURE TO CLEAN UP IS REPORTED RATHER THAN SWALLOWED. This file is a copy of the page, and
        # in a store repo the page is private content sitting in a world-readable temp directory.
        Remove-Item -LiteralPath $verifyPath -Force -ErrorAction SilentlyContinue
        if (Test-Path -LiteralPath $verifyPath) {
            Write-Warning ("A copy of the published page could not be removed and is still at " +
                           "$verifyPath. Delete it: this page is not public, and that directory is.")
        }
    }
}

# WHAT THIS MACHINE LAST VERIFIED, read once (#4160). A page whose bytes were verified under the same key
# is skipped, so a release day uploads its own page and the index instead of every page again. The record
# holds key DIGESTS, never keys (a key carries the token), and an unreadable one is simply empty.
$recordPath = Get-BwjPagePublishRecordPath -AccountId $pages.AccountId -NamespaceId $pages.NamespaceId
$record = @{}
if (-not $All -and (Test-Path -LiteralPath $recordPath -PathType Leaf)) {
    $record = ConvertFrom-BwjPagePublishRecord -Json ([System.IO.File]::ReadAllText($recordPath, [System.Text.Encoding]::UTF8))
}
function Save-BwjPagePublishRecord {
    # Written after EACH verified page, so a failure halfway keeps what already landed. A record that
    # cannot be written costs the next run a full upload, never a wrong skip, so it is a warning.
    try {
        $dir = Split-Path -Parent $recordPath
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
        $ordered = [ordered]@{}
        foreach ($k in @($record.Keys | Sort-Object)) { $ordered[$k] = $record[$k] }
        [System.IO.File]::WriteAllText($recordPath, (ConvertTo-Json -InputObject $ordered -Compress), $Utf8NoBom)
    } catch {
        Write-Warning "The record of verified pages could not be written ($($_.Exception.GetType().Name)); the next publish uploads every page again."
    }
}

# A paged kind's pages carry their rewritten links, so they are written once to a private folder of
# their own and uploaded from there; the folder goes in the finally, warned about if it stays.
$stage = $null
$skipped = 0
try {
    $n = 0
    foreach ($u in $uploads) {
        $n++
        if ($null -eq $u.Path) {
            if (-not $stage) {
                $stage = Join-Path ([System.IO.Path]::GetTempPath()) ("bwj-page-stage-" + [guid]::NewGuid().ToString('N'))
                New-Item -ItemType Directory -Force -Path $stage | Out-Null
            }
            $u.Path = Join-Path $stage ([System.IO.Path]::GetFileName($u.From))
            [System.IO.File]::WriteAllText($u.Path, $u.Text, $Utf8NoBom)
        }
        $contentHash = (Get-FileHash -LiteralPath $u.Path -Algorithm SHA256).Hash
        # Kept on the upload, set for a skipped page too: the stage folder is gone after this loop and the
        # served-bytes check (#4323) still compares what each URL serves with these bytes.
        $u.ContentHash = $contentHash
        if (Test-BwjPageUnchanged -Record $record -Key $u.Key -ContentHash $contentHash) { $skipped++; continue }
        # A line per page: through a wrangler login each one is two npx calls, so a long history runs for
        # minutes, and a failure names its key while this line shows which ones already landed.
        if ($uploads.Count -gt 1) { Write-Host "  upload   : $n/$($uploads.Count) $($u.Key)" -ForegroundColor DarkGray }
        Publish-BwjKvValue -Key $u.Key -Path $u.Path
        $record[(Get-BwjSha256Hex -Text $u.Key)] = $contentHash.ToUpperInvariant()
        Save-BwjPagePublishRecord
    }
} finally {
    if ($stage) {
        Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path -LiteralPath $stage) {
            Write-Warning ("Copies of the published pages could not be removed and are still at $stage. " +
                           "Delete them: these pages are not public, and that directory is.")
        }
    }
}
Write-Host "  verified : KV holds the same $([math]::Round($totalBytes / 1KB)) KB, $($uploads.Count) page(s), that were built (SHA-256 matches)" -ForegroundColor Green
if ($skipped -gt 0) {
    Write-Host "  skipped  : $skipped page(s) this machine already verified with these exact bytes (-All uploads them anyway)" -ForegroundColor DarkGray
}

# --- What the public URL serves (#4323) ---------------------------------------------------------------
# THE READ-BACK ABOVE PROVES KV, NOT THE URL. An edge that still holds the previous page, a worker bound
# to another namespace, or a route that 404s all pass the read-back, and a store consumer wrapped this
# fetch around the publish locally because nothing shared did it (#4323). So every
# page in the set -- the skipped ones too, because the URL must serve them whatever this machine's record
# says -- is fetched from its public address with a cache-buster and compared byte for byte with what was
# uploaded (the link-rewritten, BOM-less bytes, never the raw build). A page that differs, answers an
# error or 404s is fetched again every $servedIntervalSeconds until $servedDeadlineSeconds are up.
if ($NoVerifyServed) {
    Write-Host "  served   : not checked (-NoVerifyServed) -- fetch the URL before sending the link" -ForegroundColor Yellow
} else {
    $servedPath = Join-Path ([System.IO.Path]::GetTempPath()) ("bwj-page-served-" + [guid]::NewGuid().ToString('N') + '.tmp')
    try {
        $pending = New-Object System.Collections.Generic.List[object]
        foreach ($u in $uploads) { $pending.Add($u) }
        $lastState = @{}
        $deadline = (Get-Date).AddSeconds($servedDeadlineSeconds)
        while ($true) {
            $stillWrong = New-Object System.Collections.Generic.List[object]
            foreach ($u in $pending) {
                $state = $null
                Remove-Item -LiteralPath $servedPath -Force -ErrorAction SilentlyContinue
                try {
                    # No Authorization header: this is the public URL, as a reader reaches it. -UseBasicParsing
                    # for the same reason the read-back above gives -- the body is a whole HTML page.
                    Invoke-WebRequest -Method Get -Uri (Get-BwjServedCheckUrl -Url $u.Url -Buster ([guid]::NewGuid().ToString('N'))) `
                                      -OutFile $servedPath -UseBasicParsing -TimeoutSec 60 | Out-Null
                    $served = (Get-FileHash -LiteralPath $servedPath -Algorithm SHA256).Hash
                    if ($served -ne $u.ContentHash) {
                        $state = "different bytes (SHA-256 $served against $($u.ContentHash))"
                    }
                } catch {
                    # Read defensively under StrictMode: only a web exception carries a Response.
                    $status = $null
                    $resp = $_.Exception.PSObject.Properties['Response']
                    if ($null -ne $resp -and $null -ne $resp.Value) { try { $status = [int]$resp.Value.StatusCode } catch { } }
                    $state = if ($status) { "HTTP $status" } else { "no answer ($($_.Exception.Message))" }
                }
                if ($state) { $lastState[$u.Url] = $state; $stillWrong.Add($u) }
            }
            $pending = $stillWrong
            if ($pending.Count -eq 0) { break }
            if ((Get-Date).AddSeconds($servedIntervalSeconds) -gt $deadline) {
                $lines = ($pending | ForEach-Object { "  - $($_.Url): $($lastState[$_.Url])" }) -join "`n"
                throw ("$($pending.Count) page(s) still differ from what was published after $servedDeadlineSeconds s:`n$lines`n" +
                       "KV already holds the right bytes (the read-back above proved it), so this is edge propagation or a " +
                       "worker or route problem, not a failed upload. Do NOT send the link yet. Run the publish again " +
                       "(pages this machine already verified are skipped, so it only repeats the check) " +
                       "once the cause is cleared; -NoVerifyServed skips this check.")
            }
            Write-Host "  waiting  : $($pending.Count) page(s) not served yet, fetching again in $servedIntervalSeconds s" -ForegroundColor DarkGray
            Start-Sleep -Seconds $servedIntervalSeconds
        }
    } finally {
        # Reported rather than swallowed, for the same reason as the read-back's copy: the page is private.
        Remove-Item -LiteralPath $servedPath -Force -ErrorAction SilentlyContinue
        if (Test-Path -LiteralPath $servedPath) {
            Write-Warning ("A copy of the served page could not be removed and is still at " +
                           "$servedPath. Delete it: this page is not public, and that directory is.")
        }
    }
    Write-Host "  served   : the URL serves the same bytes, $($uploads.Count) page(s) (SHA-256 matches)" -ForegroundColor Green
}

Write-Host ""
Write-Host "  $url" -ForegroundColor Cyan
Write-Host "  The path is the ONLY lock on this page: no login, anyone with the link can read." -ForegroundColor DarkGray
$closeOut = Format-BwjPageCloseOut -Kind $Kind -Url $url
if ($closeOut) { Write-Host ""; Write-Host $closeOut -ForegroundColor Cyan }
exit 0
