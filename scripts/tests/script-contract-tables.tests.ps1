<#
.SYNOPSIS
    Regression tests for check-script-contract.ps1's two comparisons with the source's blueprint: the
    branch-prefix table (#3886) and the canonical triage-label set (#3960).

.DESCRIPTION
    Split out of script-contract.tests.ps1 (#4430), which keeps the rest of the check and its hook. The
    setup both share is script-contract-fixture.ps1, which says why the file was cut. Both sections run
    the PLUGIN copy of the check, because the comparisons read the blueprint that ships beside it.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/script-contract-tables.tests.ps1

    Pure ASCII (repo convention for .ps1).
#>
# What this suite's live-tree walks read (#3309): the shared-script registry, plus what check-script-contract reads when it is pointed at this checkout.
# gate-selection: walks *.ps1 *.json *.md *.yml
. (Join-Path $PSScriptRoot 'script-contract-fixture.ps1')

try {
    Write-Host "== script-contract-tables.tests: the comparisons with the source's blueprint ==" -ForegroundColor Cyan
    # --- 14. The branch-prefix table is the source's in every DKJ repo (#3886, Dave, November 7, 2026) ----
    # Run against the PLUGIN copy of the check: the table is read from the blueprint that ships beside it,
    # and the scripts\sync copy has no blueprint next to it (nothing to compare with, so it claims nothing).
    Write-Host "`n== script-contract.tests: the branch-prefix table is the source's ==" -ForegroundColor Cyan
    $PluginCheck = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\scripts\sync\check-script-contract.ps1'
    function Invoke-PluginCheck {
        param([string[]]$ScriptArgs)
        $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $PluginCheck @ScriptArgs
        return [pscustomobject]@{ Code = $LASTEXITCODE; Out = ($out -join "`n") }
    }
    $tableLine = "branch-prefix table in scripts\\lib\\branch-info.ps1 differs"
    $docsRow   = "    docs  = @{ Label = `$null;           Type = 'Docs' }"
    Assert-True ($script:RealBranchInfo.Contains($docsRow)) 'fixture builder: the docs row this scenario edits is still where it was'

    $c = New-FixtureConsumer
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-NotMatch $tableLine $r.Out 'the source''s own table: silent'
    Assert-Match 'branch-prefix table in scripts\\lib\\branch-info.ps1 matches' $r.Out 'the source''s own table: reported as matching'

    $differs = $script:RealBranchInfo.Replace($docsRow, "    docs  = @{ Label = 'documentation'; Type = 'Docs' }`n    data  = @{ Label = 'data';          Type = 'Data' }")
    $c = New-FixtureConsumer -BranchInfoContentOverride $differs
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-Equal 1 $r.Code 'a differing table: exit-code 1'
    Assert-Match "\[ERROR\].*$tableLine" $r.Out 'a differing table: reported as [ERROR]'
    Assert-Match 'missing or different: docs' $r.Out 'a differing table: names the source prefix whose label differs'
    Assert-Match 'prefixes the source does not have: data' $r.Out 'a differing table: names the extra prefix'
    Assert-Match 'Repair: replace the prefix table' $r.Out 'a differing table: and the repair'

    $allowsChore = $script:RealBranchInfo.Replace("'^chore(/|`$)'", "'^never-matches-anything`$'")
    Assert-True ($allowsChore -ne $script:RealBranchInfo) 'fixture builder: the chore refusal this scenario removes is still where it was'
    $c = New-FixtureConsumer -BranchInfoContentOverride $allowsChore
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-Match "\[ERROR\].*$tableLine.*'chore/' is allowed" $r.Out 'a table that allows chore/: reported'

    $throwsInfo = $script:RealBranchInfo + "`nfunction Get-BranchInfo { throw 'a consumer bug in this table' }`n"
    $c = New-FixtureConsumer -BranchInfoContentOverride $throwsInfo
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-Equal 0 $r.Code 'a throwing table: the check completes with exit-code 0'
    Assert-Match '\[INFO\].*could not be compared with the source' $r.Out 'a throwing table: degrades to one [INFO] line'
    Assert-NotMatch 'a consumer bug in this table' $r.Out 'a throwing table: the consumer''s own message is never printed'

    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $RepoRoot)
    Assert-NotMatch $tableLine $r.Out 'run on the source repo itself: silent'
    Assert-NotMatch 'branch-prefix table in scripts' $r.Out 'run on the source repo itself: not even a matching line'
    Assert-NotMatch 'was not compared' $r.Out 'run on the source repo itself: and no "not compared" line either'

    # A blueprint that is missing or unreadable is one [INFO] line: never silence, and never a verdict.
    $c = New-FixtureConsumer
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c, '-BlueprintPathOverride', (Join-Path $Fixture 'no-such-blueprint.json'))
    Assert-Equal 0 $r.Code 'missing blueprint: exit-code 0'
    Assert-Match '\[INFO\].*was not compared with the source''s: the blueprint' $r.Out 'missing blueprint: one [INFO] line says so'
    Assert-NotMatch $tableLine $r.Out 'missing blueprint: no verdict'
    $badBp = Join-Path $Fixture 'malformed-blueprint.json'
    [System.IO.File]::WriteAllText($badBp, '{ this is not json')
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c, '-BlueprintPathOverride', $badBp)
    Assert-Equal 0 $r.Code 'malformed blueprint: exit-code 0'
    Assert-Match '\[INFO\].*was not compared with the source''s: the blueprint' $r.Out 'malformed blueprint: one [INFO] line says so'
    $partialBp = Join-Path $Fixture 'partial-blueprint.json'
    [System.IO.File]::WriteAllText($partialBp, '{"records":[]}')
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c, '-BlueprintPathOverride', $partialBp)
    Assert-Match '\[INFO\].*was not compared with the source''s: the blueprint' $r.Out 'blueprint without the three records: the same [INFO] line'

    # A table under another variable name cannot be listed, and the check says so rather than "matches".
    $renamed = $script:RealBranchInfo.Replace('$script:BranchPrefixTable', '$script:MyPrefixes')
    Assert-True ($renamed -ne $script:RealBranchInfo) 'fixture builder: the table variable this scenario renames is still named that'
    $c = New-FixtureConsumer -BranchInfoContentOverride $renamed
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-Equal 0 $r.Code 'a table under another name, same behaviour: exit-code 0'
    Assert-Match '\[INFO\].*own prefix set could not be listed' $r.Out 'a table under another name: says its prefix set could not be listed'
    Assert-NotMatch 'branch-prefix table in scripts\\lib\\branch-info.ps1 matches' $r.Out 'a table under another name: never claims a full match'
    $renamedDiffers = $renamed.Replace("Label = 'bug';           Type = 'Fix'", "Label = 'defect';        Type = 'Fix'")
    Assert-True ($renamedDiffers -ne $renamed) 'fixture builder: the fix row this scenario edits is still where it was'
    $c = New-FixtureConsumer -BranchInfoContentOverride $renamedDiffers
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-Match "\[ERROR\].*$tableLine.*missing or different: fix" $r.Out 'a differing table under another name: still reported for the source''s own prefixes'

    # Nothing of the SOURCE's table may leak into the consumer's probe: this consumer reads
    # $script:BranchPrefixTable without ever assigning it, so it answers only if the source's is still there.
    $reader = @'
function Get-BranchPrefix { param([string]$Branch) return ($Branch -split '/')[0] }
function Get-BranchInfo {
    param([string]$Branch)
    $p = Get-BranchPrefix -Branch $Branch
    $k = [bool]($script:BranchPrefixTable -and $script:BranchPrefixTable.ContainsKey($p))
    [pscustomobject]@{ IsKnown = $k; Label = $(if ($k) { $script:BranchPrefixTable[$p].Label }); Type = $(if ($k) { $script:BranchPrefixTable[$p].Type }) }
}
function Test-BranchName { param([string]$Branch) [pscustomobject]@{ IsValid = ($Branch -notmatch '^chore'); Reason = $null; IsKnown = $false } }
function Get-BranchTypes { return @('Feat', 'Fix', 'Docs', 'Chore') }
'@
    $c = New-FixtureConsumer -BranchInfoContentOverride $reader
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-Match "\[ERROR\].*$tableLine.*missing or different: docs, feat, fix" $r.Out 'a consumer reading a table it never assigns: reported, because the source''s table is NOT in its scope'

    # A consumer without Test-BranchName: the missing function is its own [ERROR]; the chore refusal is not claimed either way.
    $c = New-FixtureConsumer -StripFromBranchInfo @('Test-BranchName')
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-Match "'Test-BranchName' missing" $r.Out 'no Test-BranchName: the missing function is reported'
    Assert-NotMatch $tableLine $r.Out 'no Test-BranchName: and the table is not accused of allowing chore/'

    # A differing Get-BranchTypes is compared too, in order.
    $types = $script:RealBranchInfo.Replace("@('Feat', 'Fix', 'Docs', 'Chore')", "@('Feat', 'Fix', 'Docs', 'Chore', 'Data')")
    Assert-True ($types -ne $script:RealBranchInfo) 'fixture builder: the type list this scenario edits is still where it was'
    $c = New-FixtureConsumer -BranchInfoContentOverride $types
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-Match "\[ERROR\].*$tableLine.*Get-BranchTypes returns a different list" $r.Out 'a differing Get-BranchTypes: reported'
    $reordered = $script:RealBranchInfo.Replace("@('Feat', 'Fix', 'Docs', 'Chore')", "@('Fix', 'Feat', 'Docs', 'Chore')")
    $c = New-FixtureConsumer -BranchInfoContentOverride $reordered
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-Match "\[ERROR\].*$tableLine.*Get-BranchTypes returns a different list" $r.Out 'a reordered Get-BranchTypes: reported, because the order is the release-notes order'

    # The echo filter is anchored: a prefix with a trailing newline is not a plain word.
    $c = New-FixtureConsumer -BranchInfoContentOverride $differs
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-Match 'prefixes the source does not have: data \(1 in all\)' $r.Out 'the echo filter: a plain extra prefix is named and counted'

    # Get-BranchInfo derives its prefix INLINE since #3888, so its blueprint text runs without
    # Get-BranchPrefix (no record carries that one); the check evaluates the records as shipped, with no
    # stub of its own. The inline rule and Get-BranchPrefix are now two statements of one rule in one
    # file, and this holds them to the same answer.
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($PluginCheck, [ref]$null, [ref]$null)
    $stub = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Get-BranchPrefix' }, $true) | Select-Object -First 1
    Assert-True ($null -eq $stub) 'the check carries no Get-BranchPrefix stub -- the records evaluate as shipped (#3888)'
    . $BranchInfoSrc
    foreach ($name in @('feat/x', 'fix/y/z', 'docs/a-b', 'chore/c', 'feat-x', 'main', 'plain', '/lead', 'a/')) {
        Assert-Equal (Get-BranchPrefix -Branch $name) (Get-BranchInfo -Branch $name).Prefix "Get-BranchInfo's inline prefix agrees with Get-BranchPrefix for '$name'"
    }

    # --- 15. A consumer's copied Get-TriageLabels must still carry the canonical set (#3960, Dave, November 10, 2026) ---
    # Against the PLUGIN copy for the same reason as 14: the canonical set is read from the shipped blueprint.
    Write-Host "`n== script-contract.tests: Get-TriageLabels carries the canonical set ==" -ForegroundColor Cyan
    $triageErr = "Get-TriageLabels in scripts\\repo-config\.ps1 lacks"
    $triageOk  = "Get-TriageLabels in scripts\\repo-config\.ps1 carries every canonical triage label"
    # The function AND its top-level $script:TriageLabels, so a replacement cannot read this repo's own set.
    $withoutFn = Remove-PsFunction -Content $script:RealRepoConfig -FunctionName 'Get-TriageLabels'
    Assert-True ($withoutFn -ne $script:RealRepoConfig) 'fixture builder: the Get-TriageLabels this scenario replaces is still in repo-config.ps1'
    $withoutTriage = [regex]::Replace($withoutFn, '(?ms)^\$script:TriageLabels = @\(.*?^\)\r?$', '')
    Assert-True (($withoutTriage -ne $withoutFn) -and ($withoutTriage -notmatch '\$script:TriageLabels')) 'fixture builder: the $script:TriageLabels assignment is stripped too'
    function New-TriageConsumer { param([string]$Body) New-FixtureConsumer -RepoConfigContentOverride ($withoutTriage + "`nfunction Get-TriageLabels {`n$Body`n}`n") }

    $c = New-FixtureConsumer
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-Match "\[OK\].*$triageOk" $r.Out 'the source''s own set: reported as carrying every canonical label'
    Assert-NotMatch $triageErr $r.Out 'the source''s own set: no finding'

    # The measured instance: the set as a consumer adopted it before the renames.
    $stale = @"
    @(
        [pscustomobject]@{ Name = 'prio-1'; Color = 'C5DEF5'; Description = 'x' }
        [pscustomobject]@{ Name = 'prio-2'; Color = 'FFE033'; Description = 'x' }
        [pscustomobject]@{ Name = 'prio-3'; Color = 'F9A825'; Description = 'x' }
        [pscustomobject]@{ Name = 'prio-4'; Color = 'B60205'; Description = 'x' }
        [pscustomobject]@{ Name = 'dossier'; Color = '5319E7'; Description = 'x' }
        [pscustomobject]@{ Name = 'needs-decision'; Color = 'D93F0B'; Description = 'x' }
        [pscustomobject]@{ Name = 'awaiting-recurrence'; Color = 'BFD4F2'; Description = 'x' }
    )
"@
    $c = New-TriageConsumer -Body $stale
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-Equal 1 $r.Code 'a stale copy: exit-code 1'
    Assert-Match "\[ERROR\].*$triageErr 13 of the 17 canonical triage labels" $r.Out 'a stale copy: [ERROR] with the count'
    Assert-Match "$triageErr.*awaiting-decision-dev" $r.Out 'a stale copy: names awaiting-decision-dev among the missing'
    Assert-NotMatch "$triageErr[^\r\n]*needs-decision" $r.Out 'a stale copy: never echoes its own retired names'
    Assert-Match "$triageErr.*Repair: replace the function" $r.Out 'a stale copy: and the repair'

    # A superset in its own colours is the consumer's own: silent.
    # Built on this repo's own $script:TriageLabels, which $withoutFn keeps, recoloured and with one extra.
    $superset = "function Get-TriageLabels {`n" +
        "    @(`$script:TriageLabels | ForEach-Object { [pscustomobject]@{ Name = `$_.Name; Color = '000000'; Description = 'mine' } }) +`n" +
        "        [pscustomobject]@{ Name = 'customer-request'; Color = '123456'; Description = 'x' }`n}`n"
    $c = New-FixtureConsumer -RepoConfigContentOverride ($withoutFn + "`n" + $superset)
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-Match "\[OK\].*$triageOk" $r.Out 'a superset in other colours: reported as carrying every canonical label'
    Assert-NotMatch $triageErr $r.Out 'a superset in other colours: no finding'

    $c = New-FixtureConsumer -StripFromRepoConfig @('Get-TriageLabels')
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-NotMatch 'Get-TriageLabels in scripts\\repo-config\.ps1' $r.Out 'no Get-TriageLabels: nothing compared, the built-in fallback IS the set'

    $c = New-TriageConsumer -Body "    throw 'a consumer bug in these labels'"
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-NotMatch $triageErr $r.Out 'a throwing Get-TriageLabels: no verdict'
    Assert-Match '\[INFO\].*triage labels in scripts\\repo-config\.ps1 could not be compared' $r.Out 'a throwing Get-TriageLabels: one [INFO] line'
    Assert-NotMatch 'a consumer bug in these labels' $r.Out 'a throwing Get-TriageLabels: the consumer''s own message is never printed'

    # Nothing of the SOURCE's set may leak into the probe: this consumer only reads $script:TriageLabels.
    $c = New-TriageConsumer -Body '    @($script:TriageLabels)'
    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c)
    Assert-Match "\[ERROR\].*$triageErr 17 of the 17" $r.Out 'a consumer reading a set it never assigns: reported, because the source''s set is NOT in its scope'

    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $c, '-BlueprintPathOverride', (Join-Path $Fixture 'no-such-blueprint.json'))
    Assert-Match '\[INFO\].*triage labels in scripts\\repo-config\.ps1 were not compared' $r.Out 'missing blueprint: one [INFO] line, no verdict'
    Assert-NotMatch $triageErr $r.Out 'missing blueprint: no [ERROR] for the labels'

    $r = Invoke-PluginCheck @('-ConsumerPathOverride', $RepoRoot)
    Assert-NotMatch 'Get-TriageLabels in scripts\\repo-config\.ps1' $r.Out 'run on the source repo itself: silent'
    Assert-NotMatch 'triage labels in scripts\\repo-config\.ps1' $r.Out 'run on the source repo itself: and no "not compared" line either'
} finally {
    if (Test-Path -LiteralPath $Fixture) { Remove-Item -Recurse -Force -LiteralPath $Fixture -ErrorAction SilentlyContinue }
}

Write-Host "`nResult: $($script:pass) pass, $($script:fail) fail." -ForegroundColor $(if ($script:fail -gt 0) { 'Red' } else { 'Green' })
if ($script:fail -gt 0) { exit 1 }
exit 0
