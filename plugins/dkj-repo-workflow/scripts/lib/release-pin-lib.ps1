<#
.SYNOPSIS
    Which release of the dkj-repo-workflow plugin a scaffolder came from -- the ref every CI runner it
    places is pinned to.

.DESCRIPTION
    Dot-source it:

        . (Join-Path $PSScriptRoot '..\lib\release-pin-lib.ps1')

    ONE ANSWER FOR BOTH SCAFFOLDERS (#4237). adopt-ci-floor pinned its three write runners to this
    release since #2333 and left the read-only runners on main on the #1805 argument (a pinned gate
    goes on enforcing a stale convention). The #4209 rename then moved every script path on main a day
    before any release carried it, and every consumer runner on `ref: main` went red at once while the
    pinned ones kept working. So adopt-workflow-folder's two PR-gate callers and adopt-ci-floor's
    repo-settings runner are pinned now too, and the two scaffolders read the release from here rather
    than from a copy each.

    TWO LAYOUTS, ONE RELATIVE WALK. This lib sits in scripts/lib/ in both places it runs: the plugin
    mirror (two levels up is the plugin root, which holds .claude-plugin/) and the source repo (two
    levels up is the repo root, which holds plugins/dkj-repo-workflow/).
#>

function Get-ScaffoldingPluginVersion {
    <#
        The dkj-repo-workflow plugin's own version (e.g. '6.18.0'), read off its plugin.json, or '' when
        neither layout yields a version of that shape. The caller decides what an empty answer means.
    #>
    foreach ($rel in @('..\..\.claude-plugin\plugin.json', '..\..\plugins\dkj-repo-workflow\.claude-plugin\plugin.json')) {
        $p = Join-Path $PSScriptRoot $rel
        if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { continue }
        try {
            $v = [string]((Get-Content -LiteralPath $p -Raw | ConvertFrom-Json).version)
            if ($v -match '^\d+\.\d+\.\d+$') { return $v }
        } catch { }
    }
    return ''
}

function Get-ScaffoldingReleaseTag {
    <#
        The release tag a scaffolded runner pins to ('v6.18.0'), or 'main' when the version could not be
        read. 'main' is the loud fallback: the caller says so, because a runner on main meets a
        source-side move before the consumer adopts it (#4237).
    #>
    $v = Get-ScaffoldingPluginVersion
    if ($v) { return "v$v" }
    return 'main'
}
