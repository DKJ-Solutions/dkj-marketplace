<#
.SYNOPSIS
    Lint the documentation of a consumer repo: dead relative links and anchors, mojibake, the
    -ExecutionPolicy convention, version literals claimed as current, a paragraph pulled into the
    blockquote above it, and (opt-in) the README index and the tests/ table.

.DESCRIPTION
    ONE SHARED COPY. Both BWJ store repos carried their own lint-brain, diverged: one had the blockquote
    check and the gitignore filter, the other had mojibake, the execution-policy check, the stale-version
    check, the tests/ table check, whole-file link matching and bare references. What ships here is the
    union, in English. A fix reaches both stores through a plugin release instead of through two edits.

    IT LINTS THE CONSUMER, NOT THE PLUGIN. -Path is the repo to scan; default: the repo that contains the
    current directory (Resolve-BwjRepoRoot, the way every script in this plugin finds a repo root).
    Everything that differs per repo is read from THAT repo's scripts/repo-config.ps1, through the seams
    below, and every seam has a default for a repo that does not define it. Nothing store-specific is
    written in this file.

    CATEGORIES (the letters are this file's own; the two stores' old letters collided, see the notes in
    the plugin README):

    A. DEAD LINKS AND ANCHORS (error). Every relative Markdown link ](path) or ](path#anchor) in every
       *.md file outside .git/ and node_modules/. The path is resolved from the source file's own
       directory; a missing target is an error. With an #anchor, a heading in the target must produce it
       under GitHub's slug rules (lowercase, each space becomes a hyphen one-for-one, punctuation dropped
       except hyphen and underscore, so an em dash between two spaces yields a DOUBLE hyphen). External
       links (http(s)://, mailto:, tel:, data:) are ignored. Fenced code is skipped in both directions.
       A link is matched over the WHOLE FILE, so a link whose text wraps onto the next line is still one
       link. A bare '<file>.md#<anchor>' in running prose is checked too (the '#' is required, so a plain
       filename is not a reference; a match inside inline backticks is being discussed, not made).
       Frozen release records are exempt from both halves, see Get-ReleaseChangelogNotesRoot below.

    B. MOJIBAKE (error). UTF-8 punctuation written through a CP1252 assumption, which is what Windows
       PowerShell 5.1's Set-Content does by default. Only character PAIRS that cannot occur in real prose
       are matched, so accented text passes untouched.

    C. THE -ExecutionPolicy Bypass CONVENTION (error). A 'powershell' invocation with '-NoProfile' and
       '-File' but no '-ExecutionPolicy' between them cannot run on a machine with the default
       'Restricted' policy. In *.md it looks INSIDE fences only; in *.ps1 inside .EXAMPLE sections only.

    D. A VERSION LITERAL CLAIMED AS CURRENT (error). A bold '**X.Y.Z**' presented in the present tense as
       the version in force ('it loads **1.2.3** now', 'this repo is loaded on **1.2.3**'). A DATED
       mention ('since **1.2.3**') is legitimate. Fenced code, '>' blockquote lines and the record
       documents are exempt.

    E. THE tests/ TABLE AGAINST THE tests/ DIRECTORY (error, OPT-IN). The 'suite | what it pins' table
       under a '### tests/' heading must name every *.tests.ps1 and every row must name a suite that
       exists. Silent where there is no tests directory or no README.

    F. A PARAGRAPH PULLED INTO THE BLOCKQUOTE ABOVE IT (error). With no blank line between a blockquote
       and the paragraph after it, CommonMark's lazy continuation pulls that paragraph INTO the quote: an
       editor shows a line of its own, GitHub renders it inside the citation. The rule is calibrated on
       GitHub's own renderer. A blockquote is ended by a blank line, another '>' line, an ATX heading, a
       fence, a thematic break, a bullet, a numbered item or an HTML block; plain text AND a table row
       ('|...|', which needs a separator row to be a table) do not end it. Deliberately conservative on
       one side: a numbered item always counts as an ender, so that one case is not reported.

    G. INDEX GAPS (warning, OPT-IN heuristic). For every directory with a README.md: is every other
       file or subdirectory mentioned in it by name or link? Skipped: hidden entries, LICENSE and
       CODEOWNERS, version subdirectories ('1.2', '1.2.3', '2.x'), gitignored paths and the branch's own
       document in the workflow folder. Substring match, case-insensitive: a starting point for a look,
       not a verdict.

    THE SEAMS, all optional functions in the scanned repo's scripts/repo-config.ps1 (read in a child scope
    with StrictMode off; an unreadable config degrades to the defaults, never to a crash, because this
    script also runs from a Stop hook):

      Get-ChangelogPath, Get-ReleaseHistoryPath, Get-ReleaseNoteRoot, Get-ReleaseChangelogNotesRoot,
      Get-ReleaseGithubNotesRoot   the workflow's own seams. Record documents for category D are these
                                   five; frozen records for category A are the last two. Each is probed
                                   on its own. A repo that defines none gets NO exemption, so a record
                                   document is scanned like any page: loud on correct history, which is
                                   the safe direction, and never a category silently passing.
      Get-LintBrainOptions         returns a hashtable. Keys, all optional:
                                     IndexGaps  = $true    turns category G on (default off)
                                     TestTable  = @{ Readme = 'scripts/README.md'; Heading = 'tests/';
                                                     TestsDir = 'scripts/tests' }
                                                  turns category E on; omitted keys take the values shown.
                                   Both are off by default because each one invents a promise for a repo
                                   that never made it, and a check that is red on arrival gets bypassed.

    -Quiet prints only the categories that have findings, plus the one summary line. It is the mode the
    Stop hook (lint-changed-hook.ps1) runs, and the summary line is what the hook reads its count from.

    EXIT CODES (usable as a pre-commit/CI hook and as a PR gate):
      0 = no errors (categories A-F empty). Warnings (G) do not change it, except with -WarningsAsErrors.
      1 = at least one error, or (with -WarningsAsErrors) at least one warning.

.PARAMETER Path
    Repo root to scan. Default: the repo containing the current directory.
.PARAMETER WarningsAsErrors
    Let warnings (category G) set exit code 1 too.
.PARAMETER Quiet
    Show only categories with findings, plus the summary line.
.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/maintenance/lint-brain.ps1
.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/maintenance/lint-brain.ps1 -Path C:\path\to\checkout -Quiet
.NOTES
    Pure ASCII (repo convention for .ps1): Windows PowerShell 5.1 reads a BOM-less script as ANSI.
#>
[CmdletBinding()]
param(
    [string]$Path,
    [switch]$WarningsAsErrors,
    [switch]$Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot '..\lib\repo-root-lib.ps1')

# --- Repo root ------------------------------------------------------------------------------------
$RepoRoot = Resolve-BwjRepoRoot -Override $Path

function Get-RelativePath {
    param([string]$FullPath)
    if ($FullPath.StartsWith($RepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        $rel = $FullPath.Substring($RepoRoot.Length).TrimStart('\', '/')
        if ($rel) { return ($rel -replace '\\', '/') }
        return '.'
    }
    return ($FullPath -replace '\\', '/')
}

function Add-Finding {
    param(
        [System.Collections.Generic.List[object]]$List,
        [string]$File,
        [int]$Line,
        [string]$Message
    )
    $List.Add([pscustomobject]@{ File = $File; Line = $Line; Message = $Message })
}

# --- The scanned repo's own answers (the seams) ------------------------------------------------------
function Read-LintBrainSeams {
    # Read in a CHILD scope with StrictMode off: repo-config.ps1 is written on the assumption that its
    # callers are not strict. An unreadable config answers the defaults (see the file header).
    param([string]$Root)
    $none = [pscustomobject]@{ Records = @(); Frozen = @(); Options = @{} }
    $cfg = Join-Path $Root 'scripts\repo-config.ps1'
    if (-not (Test-Path -LiteralPath $cfg -PathType Leaf)) { return $none }
    try {
        return (& {
            Set-StrictMode -Off
            $null = . $cfg
            # A function probe that does not parse the name as a wildcard (the repo-wide idiom).
            $defined = { param($Name) [bool](@($ExecutionContext.InvokeCommand.GetCommands($Name, 'Function', $false)).Count) }
            $read = { param($Name) if (& $defined $Name) { $v = & $Name; if ($v) { return [string]$v } }; return '' }
            $norm = { param($p) if ($p) { (($p -replace '\\', '/').ToLowerInvariant().Trim().TrimStart('.', '/').TrimEnd('/')) } else { '' } }

            $changelogNotes = & $norm (& $read 'Get-ReleaseChangelogNotesRoot')
            $githubNotes    = & $norm (& $read 'Get-ReleaseGithubNotesRoot')
            $records = @(
                (& $norm (& $read 'Get-ChangelogPath'))
                (& $norm (& $read 'Get-ReleaseHistoryPath'))
                (& $norm (& $read 'Get-ReleaseNoteRoot'))
                $changelogNotes
                $githubNotes
            ) | Where-Object { $_ }
            $options = @{}
            if (& $defined 'Get-LintBrainOptions') {
                $o = Get-LintBrainOptions
                if ($o -is [hashtable]) { $options = $o }
            }
            return [pscustomobject]@{
                Records = @($records)
                Frozen  = @(@($changelogNotes, $githubNotes) | Where-Object { $_ })
                Options = $options
            }
        })
    } catch {
        return $none
    }
}

$script:Seams = Read-LintBrainSeams -Root $RepoRoot

function Test-UnderRoots {
    # An exact file, or anything beneath one of the roots. Lower-cased, forward slashes.
    param([string]$RelPath, [string[]]$Roots)
    $p = $RelPath.ToLowerInvariant()
    foreach ($root in @($Roots)) {
        if ($p -eq $root -or $p.StartsWith($root + '/')) { return $true }
    }
    return $false
}

# --- GitHub slug rules ------------------------------------------------------------------------------
function ConvertTo-GithubSlug {
    param([string]$Text)
    $t = $Text.Trim()
    # A Markdown link or image inside a heading renders as its plain text, as GitHub does.
    $t = [regex]::Replace($t, '!\[([^\]]*)\]\([^)]*\)', '$1')
    $t = [regex]::Replace($t, '\[([^\]]*)\]\([^)]*\)', '$1')
    $t = $t.ToLowerInvariant()
    # Everything goes except letters, digits, space, hyphen and underscore.
    $t = [regex]::Replace($t, '[^\p{L}\p{N}\s_-]', '')
    # Each space becomes a hyphen individually -- NOT collapsed: a double space (what is left after a
    # surrounding em dash is stripped) yields a double hyphen, which is GitHub's behaviour.
    $t = $t -replace ' ', '-'
    return $t
}

# Cache: full path (lowercased) -> the slugs it produces, in order of appearance.
$script:HeadingCache = @{}

function Get-FileHeadingSlugs {
    param([string]$FilePath)
    $key = $FilePath.ToLowerInvariant()
    if ($script:HeadingCache.ContainsKey($key)) { return $script:HeadingCache[$key] }

    $slugs = New-Object System.Collections.Generic.List[string]
    if ((Test-Path -LiteralPath $FilePath -PathType Leaf) -and ($FilePath -match '\.md$')) {
        $lines = @(Get-Content -LiteralPath $FilePath -Encoding UTF8)
        $inFence = $false
        $counts = @{}
        foreach ($line in $lines) {
            if ($line -match '^\s*(```|~~~)') { $inFence = -not $inFence; continue }
            if ($inFence) { continue }
            if ($line -match '^(#{1,6})\s+(.+?)\s*#*\s*$') {
                $base = ConvertTo-GithubSlug -Text $Matches[2]
                # GitHub disambiguates a repeated heading with -1, -2, ... on the later ones.
                if ($counts.ContainsKey($base)) {
                    $counts[$base] = $counts[$base] + 1
                    $slugs.Add("$base-$($counts[$base])")
                } else {
                    $counts[$base] = 0
                    $slugs.Add($base)
                }
            }
        }
    }
    $script:HeadingCache[$key] = $slugs
    return $slugs
}

# --- A: dead links and anchors ----------------------------------------------------------------------
function Test-MarkdownLinksInFile {
    param(
        [System.IO.FileInfo]$File,
        [System.Collections.Generic.List[object]]$ErrorList
    )
    $relFile = Get-RelativePath $File.FullName

    # Frozen release records (one file per version, never rewritten) are exempt from BOTH halves: their
    # references are expected to rot as the tree moves, and gating on them is a standing red nobody can
    # clear. The price is that a link written into one is never measured again, which is affordable only
    # while nobody edits those files; if they ever become a place somebody edits, reopen this first.
    if (Test-UnderRoots -RelPath $relFile -Roots $script:Seams.Frozen) { return }

    $lines = @(Get-Content -LiteralPath $File.FullName -Encoding UTF8)
    $inFence = $false

    # Matched over the whole file, not line by line, so a link whose text wraps still counts. Fenced
    # lines are BLANKED rather than dropped, so a line number stays its own index. The target may not
    # contain a newline: a wrapped URL is not a link, and allowing one would let a stray '(' swallow
    # half a document.
    $scan = New-Object string[] $lines.Count
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s*(```|~~~)') { $inFence = -not $inFence; $scan[$i] = ''; continue }
        $scan[$i] = if ($inFence) { '' } else { $lines[$i] }
    }
    $joined = $scan -join "`n"
    $lineStart = New-Object int[] $lines.Count
    $acc = 0
    for ($i = 0; $i -lt $lines.Count; $i++) { $lineStart[$i] = $acc; $acc += $scan[$i].Length + 1 }

    $lineNo = 0
    foreach ($m in [regex]::Matches($joined, '\[[^\]]*\]\(([^)\r\n]+)\)')) {
        # Offset -> line: the last line whose start is at or before the match (matches arrive in order).
        while (($lineNo + 1) -lt $lineStart.Count -and $lineStart[$lineNo + 1] -le $m.Index) { $lineNo++ }
        $line1 = $lineNo + 1

        $target = $m.Groups[1].Value.Trim()
        if ([string]::IsNullOrWhiteSpace($target)) { continue }

        # Drop an optional link title: (path "title") or (path 'title').
        $target = $target -replace '\s+"[^"]*"\s*$', ''
        $target = $target -replace "\s+'[^']*'\s*$", ''
        $target = $target.Trim()
        if ($target.StartsWith('<') -and $target.EndsWith('>')) {
            $target = $target.Substring(1, $target.Length - 2)
        }

        if ($target -match '^(https?://|mailto:|tel:|data:)') { continue }

        $anchor = $null
        $pathPart = $target
        $hashIdx = $target.IndexOf('#')
        if ($hashIdx -ge 0) {
            $pathPart = $target.Substring(0, $hashIdx)
            $anchor = $target.Substring($hashIdx + 1)
        }
        try { $pathPart = [System.Uri]::UnescapeDataString($pathPart) } catch { }

        $baseDir = $File.DirectoryName
        try {
            if ([string]::IsNullOrWhiteSpace($pathPart)) {
                $resolvedTarget = $File.FullName
            } elseif ($pathPart.StartsWith('/')) {
                $resolvedTarget = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $pathPart.TrimStart('/')))
            } else {
                $resolvedTarget = [System.IO.Path]::GetFullPath((Join-Path $baseDir $pathPart))
            }
        } catch {
            # A target that is no valid path (invalid characters, or a non-link the regex caught by
            # accident) is not a file link; skip it rather than let GetFullPath crash the whole lint.
            continue
        }

        if (-not (Test-Path -LiteralPath $resolvedTarget)) {
            Add-Finding -List $ErrorList -File $relFile -Line $line1 -Message "Dead link to '$pathPart'"
            continue
        }

        if ($anchor) {
            $headingFile = $null
            $item = Get-Item -LiteralPath $resolvedTarget
            if ($item.PSIsContainer) {
                $candidate = Join-Path $resolvedTarget 'README.md'
                if (Test-Path -LiteralPath $candidate -PathType Leaf) { $headingFile = $candidate }
            } elseif ($item.Extension -ieq '.md') {
                $headingFile = $resolvedTarget
            }
            if ($headingFile) {
                $slugs = Get-FileHeadingSlugs -FilePath $headingFile
                $decodedAnchor = $anchor
                try { $decodedAnchor = [System.Uri]::UnescapeDataString($anchor) } catch { }
                if (-not ($slugs -contains $decodedAnchor)) {
                    $targetRel = Get-RelativePath $headingFile
                    Add-Finding -List $ErrorList -File $relFile -Line $line1 `
                        -Message "Anchor '#$anchor' not found in $targetRel"
                }
            }
        }
    }

    # The same question for a BARE reference in prose -- 'refer to some-file.md#some-rule' -- which the
    # loop above never sees because it is not link syntax. Only '<something>.md#<anchor>': requiring the
    # '#' keeps an ordinary mention of a filename out. A reference whose FILE resolves nowhere is
    # reported too, not waved through as prose, because that is the shape the real findings took.
    for ($i = 0; $i -lt $scan.Count; $i++) {
        $line = $scan[$i]
        foreach ($m in [regex]::Matches($line, '(?<![\(\[\w-])([A-Za-z0-9_.-]+(?:[\\/][A-Za-z0-9_.-]+)*\.md)#([A-Za-z0-9_-]+)')) {
            $whole = $m.Value
            $before = $line.Substring(0, $m.Index)
            if ($before -match '\]\([^)]*$') { continue }      # inside a link target: covered above

            # An odd number of backticks before the match means it sits inside inline code: the
            # reference is being discussed, not made.
            $ticks = ([regex]::Matches($before, '`')).Count
            if ($ticks % 2 -eq 1) { continue }

            $barePath   = $m.Groups[1].Value
            $bareAnchor = $m.Groups[2].Value

            $candidates = @(
                (Join-Path $File.DirectoryName $barePath),
                (Join-Path $RepoRoot $barePath)
            )
            $found = $null
            foreach ($c in $candidates) {
                try { $full = [System.IO.Path]::GetFullPath($c) } catch { continue }
                if (Test-Path -LiteralPath $full -PathType Leaf) { $found = $full; break }
            }

            if (-not $found) {
                Add-Finding -List $ErrorList -File $relFile -Line ($i + 1) `
                    -Message "Bare reference '$whole' names a file that does not resolve"
                continue
            }

            $slugs = Get-FileHeadingSlugs -FilePath $found
            if (-not ($slugs -contains $bareAnchor)) {
                $targetRel = Get-RelativePath $found
                Add-Finding -List $ErrorList -File $relFile -Line ($i + 1) `
                    -Message "Bare reference '$whole' -- anchor not found in $targetRel"
            }
        }
    }
}

# --- B: mojibake -- UTF-8 written through a CP1252 assumption ----------------------------------------
# Only pairs that cannot occur in real prose:
#   U+00E2 U+20AC  -- what ANY of U+2013..U+2026 (em dash, en dash, curly quotes, ellipsis) turns into
#                     when misread this way; no language writes an a-circumflex before a euro sign.
#   U+00C2 or U+00C3, then U+0080..U+00BF -- a non-breaking space, a degree sign or an accented letter,
#                     misread the same way.
# Ordinary accented text is untouched (an e-acute is U+00E9, which begins neither pair).
# THE PATTERNS ARE BUILT FROM CHARACTER CODES, never typed: this file is ASCII, and a check for mangled
# characters that carried mangled characters of its own would be one careless re-save from matching
# nothing at all.
$script:MojibakePunct = [string][char]0x00E2 + [char]0x20AC
$script:MojibakeLatin = '[' + [char]0x00C2 + [char]0x00C3 + '][' + [char]0x0080 + '-' + [char]0x00BF + ']'

function Test-MojibakeInFile {
    param(
        [System.IO.FileInfo]$File,
        [System.Collections.Generic.List[object]]$ErrorList
    )
    $relFile = Get-RelativePath $File.FullName
    $lines = @(Get-Content -LiteralPath $File.FullName -Encoding UTF8)

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ([string]::IsNullOrEmpty($line)) { continue }

        # One finding per line per shape: four findings for one mangled line teaches a reader to skim.
        if ($line.Contains($script:MojibakePunct)) {
            Add-Finding -List $ErrorList -File $relFile -Line ($i + 1) `
                -Message ("Mojibake U+00E2 U+20AC -- an em dash, en dash, curly quote or ellipsis was " +
                    "written through a CP1252 assumption. Rewrite the file as UTF-8: Set-Content " +
                    "-Encoding utf8, or [System.IO.File]::WriteAllText with a UTF8Encoding.")
        }
        if ($line -match $script:MojibakeLatin) {
            Add-Finding -List $ErrorList -File $relFile -Line ($i + 1) `
                -Message ("Mojibake U+00C2/U+00C3 followed by a Latin-1 code point -- a non-breaking " +
                    "space or an accented letter written through a CP1252 assumption. Rewrite as UTF-8.")
        }
    }
}

# --- C: the -ExecutionPolicy Bypass convention ----------------------------------------------------
# Windows' default effective execution policy is 'Restricted', which refuses to run ANY .ps1, so every
# runnable command in the docs has to carry '-ExecutionPolicy Bypass' between '-NoProfile' and '-File'.
# It reads as a broken script rather than a missing flag, which is why it is a gate.
#   *.md   -- INSIDE fences only (the inverse of A and B): the same string in inline backticks is being
#             DISCUSSED, not offered for copying, and flagging it would be red on arrival.
#   *.ps1  -- INSIDE .EXAMPLE sections of comment-based help only, the copy-paste surface of a script.
$script:ExecPolicyPattern = '(?i)powershell.*?-NoProfile\b(?:(?!-ExecutionPolicy).)*?-File\b'

function Test-ExecPolicyFlagInMarkdown {
    param(
        [System.IO.FileInfo]$File,
        [System.Collections.Generic.List[object]]$ErrorList
    )
    $relFile = Get-RelativePath $File.FullName
    $lines = @(Get-Content -LiteralPath $File.FullName -Encoding UTF8)
    $inFence = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^\s*(```|~~~)') { $inFence = -not $inFence; continue }
        if (-not $inFence) { continue }
        if ($line -match $script:ExecPolicyPattern) {
            Add-Finding -List $ErrorList -File $relFile -Line ($i + 1) `
                -Message ("'-NoProfile ... -File' with no '-ExecutionPolicy Bypass' between them -- on a " +
                    "machine with the default 'Restricted' policy this command cannot run. Write it as " +
                    "'powershell -NoProfile -ExecutionPolicy Bypass -File ...'.")
        }
    }
}

function Test-ExecPolicyFlagInPwshHelp {
    param(
        [System.IO.FileInfo]$File,
        [System.Collections.Generic.List[object]]$ErrorList
    )
    $relFile = Get-RelativePath $File.FullName
    $lines = @(Get-Content -LiteralPath $File.FullName -Encoding UTF8)
    $inExample = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        # A bare comment-based-help keyword line ('.EXAMPLE', '.NOTES', ...) opens or closes an
        # .EXAMPLE region; '#>' ends the help block outright.
        if ($line -match '^\s*\.[A-Za-z]+\s*$') {
            $inExample = ($line -match '^\s*\.EXAMPLE\s*$')
            continue
        }
        if ($line -match '^\s*#>') { $inExample = $false; continue }
        if (-not $inExample) { continue }
        if ($line -match $script:ExecPolicyPattern) {
            Add-Finding -List $ErrorList -File $relFile -Line ($i + 1) `
                -Message ("'-NoProfile ... -File' in a .EXAMPLE with no '-ExecutionPolicy Bypass' " +
                    "between them -- on a machine with the default 'Restricted' policy this command " +
                    "cannot run. Write it as 'powershell -NoProfile -ExecutionPolicy Bypass -File ...'.")
        }
    }
}

# --- D: a bold version literal claimed as the value in force NOW ------------------------------------
# A bare "it is on **X.Y.Z**" claim about a plugin version has no gate and rots silently; it went stale
# unnoticed three times in the store that wrote this check (store issues). The literal alone is never the
# defect: DATED mentions ('since **1.2.3**', 'verified 2026-08-19: CLI **3.94.3**') are legitimate. The
# match needs the literal AND a present-tense marker of currency, in one of two shapes: a temporal
# adverb, or a copula of currency ('is loaded on'). The adverb alone missed the store's own third
# instance ('this repo is loaded on **X**' has no adverb), which is why the second shape exists.
# Deliberately NOT matched: a past-tense copula, a requirement ('needs >= 1.2.3'), a since-clause, a dated
# measurement. Widening to a bare 'runs' was rejected because a requirement and a currency claim are the
# same words in a different tense.
# EXEMPT, each for its own reason: fenced code (a sample), a '>' blockquote line (this house records a
# reversal by quoting the dead claim), and a record document (every claim in it is dated by the heading
# it sits under). The branch's own document is deliberately NOT a record: catching the claim while the
# branch is open is the point, since after the fold it cannot be repaired without rewriting history.
# TO QUOTE THE DEFECT IN LIVE PROSE: use a blockquote, a fence, or quote the sentence without bolding the
# number.
$script:BoldVersionLiteral = '\*\*v?\d+\.\d+\.\d+\*\*'
$script:VersionCurrencyMarkers = @(
    '\b(now|currently|today|nowadays|these days)\b'   # the temporal adverb
    '\b(is|are)\s+(loaded|running|pinned)\b'          # the copula of currency
    '\b(loads|runs)\s+\*\*v?\d'                       # the verb directly in front of the literal
)

function Test-StaleVersionClaimInFile {
    param(
        [System.IO.FileInfo]$File,
        [System.Collections.Generic.List[object]]$ErrorList
    )
    $relFile = Get-RelativePath $File.FullName
    if (Test-UnderRoots -RelPath $relFile -Roots $script:Seams.Records) { return }

    $lines = @(Get-Content -LiteralPath $File.FullName -Encoding UTF8)
    $inFence = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^\s*(```|~~~)') { $inFence = -not $inFence; continue }
        if ($inFence) { continue }
        if ($line -match '^\s*>') { continue }          # a blockquote is a record
        if ($line -notmatch $script:BoldVersionLiteral) { continue }

        foreach ($marker in $script:VersionCurrencyMarkers) {
            if ($line -match $marker) {
                Add-Finding -List $ErrorList -File $relFile -Line ($i + 1) `
                    -Message ("A bold version literal presented as the version in force right now -- a " +
                        "bare version in prose has no gate and rots silently. Drop the present-tense " +
                        "half and point at Get-PluginResolution (scripts/lib/plugin-payload-lib.ps1 in " +
                        "dkj-repo-workflow-bwj), which reports which copy answered and at what version. " +
                        "A DATED claim ('since 1.2.3', '1.2.3 was what this repo loaded then') is fine.")
                break
            }
        }
    }
}

# --- E: the tests/ table against the tests/ directory (opt-in) ----------------------------------------
# A README table of 'suite | what it pins' with no caveat saying it is a selection reads as the
# inventory, and it held nine of fourteen suites in the store that wrote this check. It reads the region
# under the heading, NOT the whole file: a passing mention elsewhere is not an inventory row, and a
# whole-file substring match goes green on the very suite being repaired. Both directions are checked (a
# suite with no row; a row with no suite), because they are the same drift.
# NOT the general directory-README check (category G): that invents a promise for every directory, while
# this measures ONE table that already promises to list them. Silent where there is nothing to measure.
function Test-TestSuiteTableComplete {
    param(
        [string]$Root,
        [hashtable]$Config,
        [System.Collections.Generic.List[object]]$ErrorList
    )
    $readmeRel  = if ($Config.ContainsKey('Readme'))   { [string]$Config.Readme }   else { 'scripts/README.md' }
    $heading    = if ($Config.ContainsKey('Heading'))  { [string]$Config.Heading }  else { 'tests/' }
    $testsRel   = if ($Config.ContainsKey('TestsDir')) { [string]$Config.TestsDir } else { 'scripts/tests' }
    $testsDir = Join-Path $Root ($testsRel -replace '/', '\')
    $readme   = Join-Path $Root ($readmeRel -replace '/', '\')

    if (-not (Test-Path -LiteralPath $testsDir)) { return }
    if (-not (Test-Path -LiteralPath $readme))   { return }

    $suites = @(Get-ChildItem -Path $testsDir -File -Filter '*.tests.ps1' |
        Select-Object -ExpandProperty Name | Sort-Object)
    if ($suites.Count -eq 0) { return }

    $relReadme = Get-RelativePath -FullPath $readme
    $lines     = @(Get-Content -LiteralPath $readme -Encoding UTF8)

    # The region runs from the heading to the next heading of any level. Anchored on the heading rather
    # than on the table, so a table moved out from under it reads as an empty region -- every suite
    # reported -- instead of as nothing to check.
    $headingRx = '^###\s+`?' + [regex]::Escape($heading) + '`?\s*$'
    $start = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match $headingRx) { $start = $i; break }
    }
    if ($start -lt 0) {
        Add-Finding -List $ErrorList -File $relReadme -Line 1 `
            -Message ("No '### $heading' section, so the $($suites.Count) suite(s) in $testsRel are " +
                "documented nowhere in the folder that documents this folder.")
        return
    }

    $tableLine = $start + 1
    $listed    = New-Object 'System.Collections.Generic.List[string]'
    for ($i = $start + 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^#{1,6}\s') { break }
        if ($lines[$i] -match '^\|\s*`([A-Za-z0-9._-]+\.tests\.ps1)`') {
            if ($listed.Count -eq 0) { $tableLine = $i + 1 }
            [void]$listed.Add($Matches[1])
        }
    }

    foreach ($suite in $suites) {
        if ($listed -notcontains $suite) {
            Add-Finding -List $ErrorList -File $relReadme -Line $tableLine `
                -Message ("The tests/ table does not list $testsRel/$suite -- $($suites.Count) " +
                    "suite(s) on disk, $($listed.Count) in the table. The table has no 'selected' " +
                    "caveat, so a missing row reads as a suite that does not exist.")
        }
    }

    foreach ($row in $listed) {
        if ($suites -notcontains $row) {
            Add-Finding -List $ErrorList -File $relReadme -Line $tableLine `
                -Message ("The tests/ table lists ``$row``, which is not in $testsRel -- a row for " +
                    "a suite that is gone sends a reader looking for a file that does not exist.")
        }
    }
}

# --- F: a paragraph pulled into the blockquote above it ----------------------------------------------
# See the file header for the rule. Calibrated on GitHub's own renderer (POST /markdown on whole files,
# the blockquote depth of each candidate measured): it reproduced the 13 real cases found in one store's
# CLAUDE.md with zero false positives over every .md file of that repo. A table row is the worst case:
# it needs a separator row to be a table, so after a '>' line it is plain text and the table breaks in
# two. CONSERVATIVE BY DESIGN: a numbered item only ends a blockquote inside a list, but is always
# counted as an ender here, so '2. text' straight after a quote is not reported -- the right failure
# direction for a gate (a missed case rather than a false block).
function Test-BlockquoteLazyContinuation {
    param(
        [System.IO.FileInfo]$File,
        [System.Collections.Generic.List[object]]$ErrorList
    )
    $relFile = Get-RelativePath $File.FullName
    $lines = @(Get-Content -LiteralPath $File.FullName -Encoding UTF8)
    $inFence = $false

    for ($i = 0; $i -lt $lines.Count - 1; $i++) {
        $line = $lines[$i]
        if ($line -match '^\s*(```|~~~)') { $inFence = -not $inFence; continue }
        if ($inFence) { continue }

        # Only a '>' line WITH content keeps a paragraph open; a bare '>' already ended it.
        if ($line -notmatch '^ {0,3}>') { continue }
        if (($line -replace '^ {0,3}>', '').Trim() -eq '') { continue }

        $next = $lines[$i + 1]
        if ($next.Trim() -eq '') { continue }

        $t = $next -replace '^ {0,3}', ''
        if ($t -match '^>') { continue }                                   # another blockquote line
        if ($t -match '^#{1,6}(\s|$)') { continue }                        # ATX heading
        if ($t -match '^(```|~~~)') { continue }                           # fence
        if ($t -match '^((\*\s*){3,}|(-\s*){3,}|(_\s*){3,})\s*$') { continue }  # thematic break
        if ($t -match '^[-*+](\s|$)') { continue }                         # bullet
        if ($t -match '^\d+[.)](\s|$)') { continue }                       # numbered item
        if ($t -match '^<[a-zA-Z/!]') { continue }                         # HTML block

        $preview = $t.Substring(0, [Math]::Min(60, $t.Length))
        Add-Finding -List $ErrorList -File $relFile -Line ($i + 2) `
            -Message "Paragraph is pulled into the blockquote above it (lazy continuation) -- put a blank line before it: '$preview'"
    }
}

# --- G: index gaps (opt-in warning heuristic) -----------------------------------------------------------
# `git check-ignore` writes "fatal: not a git repository" to stderr when -Path is outside a git repo, and
# in Windows PowerShell 5.1 a stderr redirect on a NATIVE exe wraps each line in an ErrorRecord that is
# terminating under EAP=Stop even when the command itself succeeds. The 2>$null has to stay (the message
# is noise, not a finding), so the preference moves instead of the redirect. $LASTEXITCODE still carries
# the verdict.
function Test-PathGitIgnored {
    param([string]$FullPath)
    $ErrorActionPreference = 'Continue'
    & git -C $RepoRoot check-ignore -q -- $FullPath 2>$null
    return ($LASTEXITCODE -eq 0)
}

function Get-BranchDossierName {
    # The current branch's own document is '<branch>.md' ('/' -> '-') in the workflow folder: transient,
    # and its name cannot be listed in a README ahead of time, so G would report it on every branch.
    # Derived inline, not from a plugin lib: this script stays dependency-light. On the trunk it yields
    # 'main.md', which does not exist there, so the exclusion is inert.
    try {
        # symbolic-ref, not rev-parse: it also answers on a branch with no commit yet, and fails on a
        # detached HEAD, which has no branch document.
        $head = ((& git -C $RepoRoot symbolic-ref --short HEAD 2>$null) -join '').Trim()
        if ($head) { return (($head -replace '/', '-') + '.md') }
    } catch { }
    return ''
}

function Test-IndexGaps {
    param(
        [object[]]$ReadmeFiles,
        [System.Collections.Generic.List[object]]$WarningList
    )
    $standardFiles = @('LICENSE', 'LICENSE.md', 'CODEOWNERS')
    $dossier = Get-BranchDossierName
    # The workflow folder is the one the changelog seam names, else the plugin's own folder name.
    $workflowDirs = @('dkj-repo-workflow')
    $changelogRel = @($script:Seams.Records)[0]
    if ($changelogRel -and $changelogRel -match '/') {
        $workflowDirs += (Split-Path ($changelogRel -replace '/', '\') -Parent | Split-Path -Leaf)
    }

    foreach ($readme in $ReadmeFiles) {
        $dir = $readme.DirectoryName
        $content = Get-Content -LiteralPath $readme.FullName -Raw -Encoding UTF8
        if (-not $content) { $content = '' }
        $inWorkflowDir = ((Split-Path $dir -Leaf) -in $workflowDirs)

        $siblings = Get-ChildItem -Path $dir -Force | Where-Object {
            $_.Name -ne $readme.Name -and
            -not $_.Name.StartsWith('.') -and
            $_.Name -notin $standardFiles -and
            # Version subdirectories: '2.13', '1.2.3' and the major folder '2.x'.
            -not ($_.PSIsContainer -and $_.Name -match '^\d+(\.(\d+|x))+$') -and
            -not ($dossier -and $inWorkflowDir -and $_.Name -eq $dossier) -and
            -not (Test-PathGitIgnored $_.FullName)
        }

        foreach ($sib in $siblings) {
            if ($content -notmatch [regex]::Escape($sib.Name)) {
                Add-Finding -List $WarningList -File (Get-RelativePath $readme.FullName) -Line 0 `
                    -Message "'$($sib.Name)' is not mentioned or linked in this README"
            }
        }
    }
}

# --- Run --------------------------------------------------------------------------------------------
$CatA_Errors = New-Object System.Collections.Generic.List[object]
$CatB_Errors = New-Object System.Collections.Generic.List[object]
$CatC_Errors = New-Object System.Collections.Generic.List[object]
$CatD_Errors = New-Object System.Collections.Generic.List[object]
$CatE_Errors = New-Object System.Collections.Generic.List[object]
$CatF_Errors = New-Object System.Collections.Generic.List[object]
$CatG_Warnings = New-Object System.Collections.Generic.List[object]

$options = $script:Seams.Options

# @() is not decoration: under StrictMode Latest a pipeline that yields exactly ONE file hands back a bare
# FileInfo, and '.Count' on it throws instead of returning 1.
$mdFiles = @(Get-ChildItem -Path $RepoRoot -Recurse -File -Filter '*.md' |
    Where-Object { $_.FullName -notmatch '[\\/](\.git|node_modules)[\\/]' })

# Category C also reads .ps1 comment-based help.
$ps1Files = @(Get-ChildItem -Path $RepoRoot -Recurse -File -Filter '*.ps1' |
    Where-Object { $_.FullName -notmatch '[\\/](\.git|node_modules)[\\/]' })

foreach ($file in $mdFiles) {
    Test-MarkdownLinksInFile      -File $file -ErrorList $CatA_Errors
    Test-MojibakeInFile           -File $file -ErrorList $CatB_Errors
    Test-ExecPolicyFlagInMarkdown -File $file -ErrorList $CatC_Errors
    Test-StaleVersionClaimInFile  -File $file -ErrorList $CatD_Errors
    Test-BlockquoteLazyContinuation -File $file -ErrorList $CatF_Errors
}

foreach ($file in $ps1Files) {
    Test-ExecPolicyFlagInPwshHelp -File $file -ErrorList $CatC_Errors
}

# Once per run: E is a claim about a directory against a table, so it has no per-file loop to sit in.
$testTable = $null
if ($options.ContainsKey('TestTable')) {
    $testTable = if ($options.TestTable -is [hashtable]) { $options.TestTable } else { @{} }
    Test-TestSuiteTableComplete -Root $RepoRoot -Config $testTable -ErrorList $CatE_Errors
}

$indexGapsOn = [bool]($options.ContainsKey('IndexGaps') -and $options.IndexGaps)
if ($indexGapsOn) {
    $readmeFiles = @($mdFiles | Where-Object { $_.Name -ceq 'README.md' })
    Test-IndexGaps -ReadmeFiles $readmeFiles -WarningList $CatG_Warnings
}

# --- Report -------------------------------------------------------------------------------------------
function Write-FindingsSection {
    param(
        [string]$Title,
        [System.Collections.Generic.List[object]]$List,
        [string]$Color,
        [string]$CleanText
    )
    if ($Quiet -and $List.Count -eq 0) { return }
    Write-Host ""
    Write-Host "== $Title ==" -ForegroundColor Cyan
    if ($List.Count -eq 0) {
        Write-Host "  $CleanText" -ForegroundColor Green
        return
    }
    foreach ($f in ($List | Sort-Object File, Line, Message)) {
        $loc = if ($f.Line -gt 0) { "$($f.File):$($f.Line)" } else { "$($f.File)" }
        Write-Host "  [$loc] $($f.Message)" -ForegroundColor $Color
    }
}

if (-not $Quiet) {
    Write-Host "lint-brain -- consistency checks over this repo's documentation" -ForegroundColor White
    Write-Host "Repo root: $RepoRoot"
    Write-Host "Scanned: $($mdFiles.Count) markdown file(s), $($ps1Files.Count) .ps1 file(s)."
}

$scanned = "none -- $($mdFiles.Count) markdown file(s) scanned."
Write-FindingsSection -Title 'A. Dead links and anchors (error)' -List $CatA_Errors -Color Red -CleanText $scanned
Write-FindingsSection -Title 'B. Mojibake (error)' -List $CatB_Errors -Color Red -CleanText $scanned
Write-FindingsSection -Title 'C. -ExecutionPolicy Bypass convention (error)' -List $CatC_Errors -Color Red `
    -CleanText "none -- $($mdFiles.Count) markdown file(s) and $($ps1Files.Count) .ps1 file(s) scanned."
Write-FindingsSection -Title 'D. Version literals claimed as current (error)' -List $CatD_Errors -Color Red -CleanText $scanned
if ($null -ne $testTable) {
    Write-FindingsSection -Title 'E. The tests/ table against the tests/ directory (error)' -List $CatE_Errors -Color Red `
        -CleanText 'none -- every suite has a row, and every row a suite.'
}
Write-FindingsSection -Title 'F. Paragraph pulled into the blockquote above it (error)' -List $CatF_Errors -Color Red `
    -CleanText 'none.'
if ($indexGapsOn) {
    Write-FindingsSection -Title 'G. Index gaps (warning)' -List $CatG_Warnings -Color Yellow -CleanText 'none.'
}

$byCategory = [ordered]@{
    A = $CatA_Errors.Count; B = $CatB_Errors.Count; C = $CatC_Errors.Count
    D = $CatD_Errors.Count; E = $CatE_Errors.Count; F = $CatF_Errors.Count
}
$totalErrors   = 0
foreach ($n in $byCategory.Values) { $totalErrors += $n }
$totalWarnings = $CatG_Warnings.Count
$failed        = ($totalErrors -gt 0) -or ($WarningsAsErrors -and $totalWarnings -gt 0)

# THE SUMMARY LINE IS A CONTRACT: lint-changed-hook.ps1 reads '<n> error(s)' and the '(A: 1, F: 2)' list
# from it, so the hook needs one run and no second pass over the tree.
$parts = @(foreach ($k in $byCategory.Keys) { if ($byCategory[$k] -gt 0) { "${k}: $($byCategory[$k])" } })
$where = if ($parts.Count -gt 0) { " ($($parts -join ', '))" } else { '' }
$verdict = if ($failed) { 'FAIL' } else { 'PASS' }
$summaryColor = if ($failed) { 'Red' } elseif ($totalWarnings -gt 0) { 'Yellow' } else { 'Green' }
Write-Host ""
Write-Host "${verdict}: $totalErrors error(s)$where, $totalWarnings warning(s)." -ForegroundColor $summaryColor

if ($failed) { exit 1 }
exit 0
