<#
.SYNOPSIS
    The "what belongs in git" check (the third chapter of this plugin's CLAUDE.md): which tracked
    folders hold only content and keep paying the branch + PR toll.

.DESCRIPTION
    A folder is a FINDING when all three hold:

    1. every file tracked directly in it is a content file (.md, .json, .ndjson, .csv, .txt, .yaml,
       .yml) -- a folder with one code file in it is code, and its data is read by that code;
    2. it is not tooling or test material (.claude, .dkj, .github, .vscode, node_modules, and any
       tests/test/fixtures/__fixtures__/testdata segment);
    3. at least MinCommits non-merge commits touched it in the last Days days -- the toll the rule is
       about. A content folder nobody edits costs nothing and is not worth a line at every session start.

    A folder the repo keeps in git on purpose is named in Get-GitContentAllowlist in its own
    scripts/repo-config.ps1, each entry @{ Path; Reason }, Path a -like glob against the folder. Content
    a deployed build reads in CI is the standing example (#4332).

    Measured November 19, 2026 over the six DKJ-Solutions app repos at 90 days and 10 commits: it named
    exactly the two folders a hand audit had found (dkj-recipes docs/studio-hellofresh, 44 commits;
    dkj-thumbnail-generator dossier/ai-outpainting, 12), nothing else, in 0.1-1.6 s per repo.

    Pure ASCII (repo convention for .ps1).
#>

$script:GitContentExtensions = @('.md', '.json', '.ndjson', '.csv', '.txt', '.yaml', '.yml')
$script:GitContentSkipPattern = '(^|/)(\.claude|\.dkj|\.github|\.vscode|node_modules|tests?|fixtures|__fixtures__|testdata)(/|$)'

function ConvertFrom-GitQuotedLine {
    <#
        Under core.quotePath=true git wraps a path holding a non-ASCII byte in double quotes and writes
        the byte as an octal escape: "docs/caf\303\251/a.md". The escapes stay (they are ASCII, so the
        wire never meets a code page), the quotes go -- left on, they make the extension '.md"' and hide
        exactly the folder this check exists to find.
    #>
    param([string]$Line)
    if ($Line.Length -ge 2 -and $Line.StartsWith('"') -and $Line.EndsWith('"')) { return $Line.Substring(1, $Line.Length - 2) }
    return $Line
}

function Get-GitContentFolders {
    <#
        The folders whose tracked files are all content files, from a `git ls-files` listing (repo-relative,
        forward slashes). Root-level files are never a folder. Returns a sorted string array.
    #>
    param([AllowEmptyCollection()][string[]]$Files = @())
    $byDir = @{}
    foreach ($f in $Files) {
        if (-not $f) { continue }
        $i = $f.LastIndexOf('/')
        if ($i -lt 0) { continue }
        $d = $f.Substring(0, $i)
        if ($d -match $script:GitContentSkipPattern) { continue }
        $isContent = $script:GitContentExtensions -contains ([System.IO.Path]::GetExtension($f).ToLowerInvariant())
        if (-not $byDir.ContainsKey($d)) { $byDir[$d] = $true }
        if (-not $isContent) { $byDir[$d] = $false }
    }
    return @($byDir.Keys | Where-Object { $byDir[$_] } | Sort-Object)
}

function Measure-GitContentCommits {
    <#
        How many commits touched each folder, from `git log --name-only --format=%x40%x40` output: a line
        '@@' opens a commit, every other non-empty line is a path. A commit counts once per folder.
        Returns a hashtable folder -> count, holding only the folders asked about.
    #>
    param(
        [AllowEmptyCollection()][string[]]$Folders = @(),
        [AllowEmptyCollection()][string[]]$LogLines = @()
    )
    $count = @{}
    foreach ($d in $Folders) { $count[$d] = 0 }
    $seen = @{}
    foreach ($l in $LogLines) {
        if ($l -eq '@@') { $seen = @{}; continue }
        if (-not $l) { continue }
        $i = $l.LastIndexOf('/')
        if ($i -lt 0) { continue }
        $d = $l.Substring(0, $i)
        if ($count.ContainsKey($d) -and -not $seen.ContainsKey($d)) { $count[$d]++; $seen[$d] = $true }
    }
    return $count
}

function Test-GitContentAllowed {
    param([Parameter(Mandatory)][string]$Folder, [AllowEmptyCollection()][object[]]$Allow = @())
    foreach ($a in $Allow) { if ($Folder -like [string]$a.Path) { return $true } }
    return $false
}

function ConvertTo-GitContentAllowlist {
    <#
        The repo's answer to Get-GitContentAllowlist, checked: @{ Ok; Entries; Problem }. Every entry names
        a Path and a Reason -- an exception nobody can explain is one nobody can retire.
    #>
    param($Raw)
    if ($null -eq $Raw) { return @{ Ok = $true; Entries = @(); Problem = $null } }
    $entries = @()
    foreach ($e in @($Raw)) {
        if ($e -isnot [hashtable]) { return @{ Ok = $false; Entries = @(); Problem = 'every Get-GitContentAllowlist entry is a hashtable: @{ Path; Reason }' } }
        if (-not $e.ContainsKey('Path') -or [string]::IsNullOrWhiteSpace([string]$e.Path)) { return @{ Ok = $false; Entries = @(); Problem = 'a Get-GitContentAllowlist entry has no Path' } }
        if (-not $e.ContainsKey('Reason') -or [string]::IsNullOrWhiteSpace([string]$e.Reason)) { return @{ Ok = $false; Entries = @(); Problem = "the Get-GitContentAllowlist entry for '$($e.Path)' has no Reason" } }
        $entries += $e
    }
    return @{ Ok = $true; Entries = $entries; Problem = $null }
}

function Read-GitContentAllowlist {
    <#
        The repo's Get-GitContentAllowlist from its scripts/repo-config.ps1, read in a child scope with
        StrictMode off, the way Read-HouseStyleAllowlist reads its own. No file or no function: empty.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot)
    $configPath = Join-Path $RepoRoot 'scripts/repo-config.ps1'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) { return (ConvertTo-GitContentAllowlist -Raw $null) }
    $raw = & {
        Set-StrictMode -Off
        $null = . $args[0] 6>$null
        if (@($ExecutionContext.InvokeCommand.GetCommands('Get-GitContentAllowlist', 'Function', $false)).Count) { ,@(Get-GitContentAllowlist 6>$null) }
    } $configPath
    return (ConvertTo-GitContentAllowlist -Raw $raw)
}

function Invoke-GitContentCheck {
    <#
        The whole check against a checkout: @{ Findings = @(@{ Path; Commits }) sorted by commits, most
        first; Folders = how many content folders were weighed }. git is asked twice, both read-only.
    #>
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [AllowEmptyCollection()][object[]]$Allow = @(),
        [int]$Days = 90,
        [int]$MinCommits = 10
    )
    # quotePath=true keeps the wire ASCII (no code page can corrupt it); ConvertFrom-GitQuotedLine drops the
    # quotes it adds around a non-ASCII path. A non-ASCII name therefore prints with octal escapes.
    $files = @(git -C $RepoRoot -c core.quotePath=true ls-files 2>$null | ForEach-Object { ConvertFrom-GitQuotedLine $_ })
    $folders = @(Get-GitContentFolders -Files $files | Where-Object { -not (Test-GitContentAllowed -Folder $_ -Allow $Allow) })
    $base = @{ Findings = @(); Folders = $folders.Count; Days = $Days; MinCommits = $MinCommits }
    if (-not $folders.Count) { return $base }
    $log = @(git -C $RepoRoot -c core.quotePath=true log --since="$Days days ago" --no-merges --name-only '--format=%x40%x40' 2>$null |
        ForEach-Object { ConvertFrom-GitQuotedLine $_ })
    $count = Measure-GitContentCommits -Folders $folders -LogLines $log
    $base.Findings = @($folders | Where-Object { $count[$_] -ge $MinCommits } |
        ForEach-Object { @{ Path = $_; Commits = $count[$_] } } | Sort-Object { -$_.Commits }, { $_.Path })
    return $base
}
