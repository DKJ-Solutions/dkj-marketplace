<#
.SYNOPSIS
    Every function a shipped TEMPLATE calls is one it defines, one PowerShell provides, or one it
    guards with Get-Command before calling.

.DESCRIPTION
    Dependency-free: no Pester, only PowerShell. Exit 0 if everything passes, 1 on a failure.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/template-selfcontained.tests.ps1

    WHY A TEMPLATE AND NOT EVERY SCRIPT. A template is copied wholesale into a consumer's .github/
    and run there by CI. It dot-sources none of this repo's libraries -- it cannot, because none of
    them travel with it -- so a call to a helper it does not define is unresolvable by construction.
    Every other .ps1 here loads scripts/lib/*, and flagging their imported functions would be noise.

    AND THE BWJ CI SCRIPTS, WITH THE LIBS THEY LOAD. dkj-repo-workflow-bwj's scripts/ci/asana-*.ps1 run
    from a pinned checkout (#4351) whose sparse-checkout fetches scripts/lib beside them, and since
    #4366 each dot-sources its lib from there. They stay in this suite, because the sweep half of a
    script is still the half no event run reaches: what the libs they load define is counted as
    defined (-AlsoDefinedIn, resolved by following each Join-Path $PSScriptRoot '<file>.ps1' they
    name), and nothing else is.

    WHAT IT COST TO NOT HAVE THIS, inbound #1556. A rename in fa3a4e55 turned Get-IssueClosure into
    Get-IssueLinkState and updated the event call site but not the sweep's, and the sweep is the half
    that only reaches the call WHEN IT HAS SOMETHING TO SAY. So the consumer's Actions tab filled with
    green event runs and green empty sweeps, and the first sweep with real work to do died on it --
    taking the prio-label and stage sweeps down with it, since Invoke-ReconcileMode aborts at the
    first crash. Nothing executes the template end to end during its own release, which is why a
    parse-time check is the only thing that could have caught it here rather than there.

    THE Get-Command GUARD IS THE DECLARATION OF AN EXTERNAL SEAM, and reading it is what keeps this
    check free of an allowlist. The retired asana-mirror.ps1 (its subject until October 5, 2026; the suite came back with asana-closed-message.ps1, #2818) legitimately called Get-AsanaStageMap and
    Get-GithubStatusMap, which live in the CONSUMER's scripts/repo-config.ps1 and are dot-sourced at
    run time -- and it tests for each with `Get-Command -Name '<name>'` immediately before calling it,
    because a consumer that defines neither must still get a working run. That guard is already the
    template's own discipline; this check simply believes it. A hand-maintained exemption list would
    go stale the first time a seam was added, in exactly the silent direction.

    ONLY HYPHENATED NAMES ARE JUDGED. `gh` and `git` are external executables whose presence says
    nothing about the template's correctness, and resolving them would make the suite fail on a
    machine that merely lacks the CLI. Every function this defect class can produce is Verb-Noun.

    Pure ASCII (repo convention for .ps1).
#>

# What this suite's live-tree walks read (#3309): the templates under plugins/.
# gate-selection: walks plugins/*.ps1
$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path

$script:pass = 0
$script:fail = 0

function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    if ($Expected -eq $Actual) {
        $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green
    } else {
        $script:fail++; Write-Host "  [FAIL] $Name`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red
    }
}

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) {
        $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green
    } else {
        $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red
    }
}

function Get-UnresolvedTemplateCall {
    <#
        The names a script calls that nothing can answer: not defined in the file, not a command this
        PowerShell has, and not guarded by a Get-Command test in the file itself. Returns a sorted
        array of names -- empty is the passing answer. Never throws on a parse error; a file that does
        not parse returns $null, which the caller reports as its own failure rather than as zero
        findings.
    #>
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        # Files the script loads at run time; what they define counts as defined (#4366).
        [string[]]$AlsoDefinedIn = @()
    )

    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
        (Resolve-Path -LiteralPath $Path).Path, [ref]$null, [ref]$errors)
    if ($errors -and $errors.Count -gt 0) { return $null }

    $defined = @($ast.FindAll({
        param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) |
        ForEach-Object { $_.Name })
    foreach ($lib in $AlsoDefinedIn) {
        $libAst = [System.Management.Automation.Language.Parser]::ParseFile($lib, [ref]$null, [ref]$null)
        $defined += @($libAst.FindAll({
            param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) |
            ForEach-Object { $_.Name })
    }

    $commands = @($ast.FindAll({
        param($n) $n -is [System.Management.Automation.Language.CommandAst] }, $true))

    # The seams the file declares by testing for them. A `Get-Command -Name 'X'` anywhere in the file
    # covers X everywhere in it: the guard and the call it protects are frequently in different
    # functions, and pairing them would be a dataflow analysis for no extra safety.
    $guarded = @($commands | Where-Object { $_.GetCommandName() -eq 'Get-Command' } | ForEach-Object {
        $_.CommandElements | Where-Object {
            $_ -is [System.Management.Automation.Language.StringConstantExpressionAst] } |
            ForEach-Object { $_.Value }
    })

    $called = @($commands | ForEach-Object { $_.GetCommandName() } |
        Where-Object { $_ -and $_ -like '*-*' } | Sort-Object -Unique)

    # `,@(...)`, not `@(...)`: PowerShell unrolls a returned empty array to nothing, so a clean file
    # would hand the caller $null -- indistinguishable from the parse failure above, and in the
    # direction that turns a passing template into a reported one.
    return ,@($called | Where-Object {
        $defined -notcontains $_ -and
        $guarded -notcontains $_ -and
        -not (Get-Command -Name $_ -ErrorAction SilentlyContinue)
    })
}

function Get-LoadedLibClosure {
    <#
        Every file a script names as Join-Path $PSScriptRoot '<relative>.ps1' -- the shape both a direct
        '. (Join-Path ...)' and a path held in a variable and then dot-sourced take -- followed into each
        named file in turn. Returns full paths; a named file that does not exist is returned too, so the
        caller can report it rather than count it as nothing to load.
    #>
    param([Parameter(Mandatory = $true)][string]$Path)
    $seen = New-Object System.Collections.Generic.List[string]
    $queue = New-Object System.Collections.Generic.Queue[string]
    $queue.Enqueue((Resolve-Path -LiteralPath $Path).Path)
    while ($queue.Count -gt 0) {
        $file = $queue.Dequeue()
        if (-not (Test-Path -LiteralPath $file)) { continue }
        $dir = Split-Path -Parent $file
        foreach ($m in [regex]::Matches([System.IO.File]::ReadAllText($file), "Join-Path \`$PSScriptRoot '([^']+\.ps1)'")) {
            $full = [System.IO.Path]::GetFullPath((Join-Path $dir ($m.Groups[1].Value -replace '/', '\')))
            if (-not $seen.Contains($full)) { $seen.Add($full); $queue.Enqueue($full) }
        }
    }
    return ,@($seen)
}

Write-Host "== template-selfcontained ==" -ForegroundColor Cyan

# --- the checker itself, on fixtures -------------------------------------------------------------
# Asserted before the tree, so a green run on the real templates is evidence rather than a tautology:
# a checker that found nothing anywhere would pass the section below in silence.
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("tmpl-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp -Force | Out-Null
try {
    $bad = Join-Path $tmp 'bad.ps1'
    Set-Content -LiteralPath $bad -Encoding ASCII -Value @(
        'function Invoke-Thing { Get-VanishedHelper -Repo x }'
        'Invoke-Thing')
    Assert-Equal 'Get-VanishedHelper' ((Get-UnresolvedTemplateCall -Path $bad) -join ',') `
        'a call to a helper nothing defines is reported -- inbound #1556 in miniature'

    $good = Join-Path $tmp 'good.ps1'
    Set-Content -LiteralPath $good -Encoding ASCII -Value @(
        'function Invoke-Thing { Get-Item . | Out-Null; Invoke-Helper }'
        'function Invoke-Helper { }'
        'Invoke-Thing')
    Assert-Equal '' ((Get-UnresolvedTemplateCall -Path $good) -join ',') `
        'a helper the file defines, and a real cmdlet, are both resolved'

    $seam = Join-Path $tmp 'seam.ps1'
    Set-Content -LiteralPath $seam -Encoding ASCII -Value @(
        '. "$PSScriptRoot/repo-config.ps1"'
        "if (Get-Command -Name 'Get-RepoSeam' -ErrorAction SilentlyContinue) { Get-RepoSeam }")
    Assert-Equal '' ((Get-UnresolvedTemplateCall -Path $seam) -join ',') `
        'a seam the file guards with Get-Command is declared external, not missing'

    $split = Join-Path $tmp 'split.ps1'
    Set-Content -LiteralPath $split -Encoding ASCII -Value @(
        "function Test-Seam { return [bool](Get-Command -Name 'Get-RepoSeam' -ErrorAction SilentlyContinue) }"
        'function Use-Seam { if (Test-Seam) { Get-RepoSeam } }'
        'Use-Seam')
    Assert-Equal '' ((Get-UnresolvedTemplateCall -Path $split) -join ',') `
        'and the guard covers the call even from another function -- file-wide, by design'

    $broken = Join-Path $tmp 'broken.ps1'
    Set-Content -LiteralPath $broken -Encoding ASCII -Value 'function Oops { '
    Assert-True ($null -eq (Get-UnresolvedTemplateCall -Path $broken)) `
        'a file that does not parse returns $null, so it can never read as zero findings'

    $libDir = Join-Path $tmp 'lib'
    New-Item -ItemType Directory -Path $libDir -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $libDir 'inner.ps1') -Encoding ASCII -Value 'function Get-InnerHelper { }'
    Set-Content -LiteralPath (Join-Path $libDir 'outer.ps1') -Encoding ASCII -Value @(
        ". (Join-Path `$PSScriptRoot 'inner.ps1')"
        'function Get-OuterHelper { }')
    $loads = Join-Path $tmp 'loads.ps1'
    Set-Content -LiteralPath $loads -Encoding ASCII -Value @(
        "`$lib = Join-Path `$PSScriptRoot 'lib/outer.ps1'"
        '. $lib'
        'Get-OuterHelper; Get-InnerHelper; Get-VanishedHelper')
    $closure = Get-LoadedLibClosure -Path $loads
    Assert-Equal 'inner.ps1,outer.ps1' (@($closure | ForEach-Object { Split-Path -Leaf $_ } | Sort-Object) -join ',') `
        'the loaded-lib closure follows a lib into the lib it loads (#4366)'
    Assert-Equal 'Get-VanishedHelper' ((Get-UnresolvedTemplateCall -Path $loads -AlsoDefinedIn $closure) -join ',') `
        'what the loaded libs define is resolved, and a call nothing defines is still reported'
    Assert-Equal 'Get-InnerHelper,Get-OuterHelper,Get-VanishedHelper' ((Get-UnresolvedTemplateCall -Path $loads) -join ',') `
        'and without -AlsoDefinedIn the same calls are unresolved, so the closure is what resolves them'
} finally {
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

# --- every template this repo ships --------------------------------------------------------------
$templates = @(Get-ChildItem -Path (Join-Path $RepoRoot 'plugins') -Recurse -Filter '*.ps1' -File |
    Where-Object { $_.DirectoryName -like '*\templates' } | Sort-Object FullName)

# AND THE BWJ CI SCRIPTS (#4351, #4366). The three Asana scripts left templates/ for scripts/ci/ when a
# store stopped copying them and started fetching them from a pinned checkout, and since #4366 they load
# the bwj libs fetched beside them. The defect class this suite exists for still applies -- a renamed
# helper the sweep alone calls -- so they stay, held against their own definitions plus their libs'.
$bwjCi = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\extensions\dkj-repo-workflow-bwj\scripts\ci'
$ciScripts = @(Get-ChildItem -Path $bwjCi -Filter 'asana-*.ps1' -File -ErrorAction SilentlyContinue | Sort-Object FullName)
Assert-True ($ciScripts.Count -ge 3) "the BWJ CI scripts are found ($($ciScripts.Count))"
$templates += $ciScripts

# The glob is asserted, not assumed. A templates/ folder that is renamed or moved would otherwise turn
# this whole suite into a no-op that keeps reporting green.
Assert-True ($templates.Count -ge 1) "at least one shipped template is found ($($templates.Count))"

foreach ($t in $templates) {
    $rel = $t.FullName.Substring($RepoRoot.Length + 1).Replace('\', '/')
    $alsoDefined = @()
    if ($t.DirectoryName -eq $bwjCi) {
        $alsoDefined = Get-LoadedLibClosure -Path $t.FullName
        $missing = @($alsoDefined | Where-Object { -not (Test-Path -LiteralPath $_) })
        Assert-Equal '' ($missing -join ', ') "$($t.Name) loads only libs that exist"
        $alsoDefined = @($alsoDefined | Where-Object { Test-Path -LiteralPath $_ })
    }
    $unresolved = Get-UnresolvedTemplateCall -Path $t.FullName -AlsoDefinedIn $alsoDefined
    # `$null -eq`, never `$null -ne`: with a COLLECTION on the left, PowerShell's comparison operators
    # filter instead of comparing, so `$null -ne @()` yields an empty array -- which is $false, and a
    # clean template would report itself as unparseable.
    $parsed = -not ($null -eq $unresolved)
    Assert-True $parsed "$rel parses"
    if ($parsed) {
        Assert-Equal '' ($unresolved -join ', ') "$rel calls nothing it cannot answer for"
    }
}

# --- done ----------------------------------------------------------------------------------------
Write-Host ""
if ($script:fail -gt 0) {
    Write-Host "FAILS: $($script:fail) failed, $($script:pass) passed." -ForegroundColor Red
    exit 1
}
Write-Host "OK: all $($script:pass) asserts passed." -ForegroundColor Green
exit 0
