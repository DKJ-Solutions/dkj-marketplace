<#
.SYNOPSIS
    The brand book's colour tokens against a Figma file's variables (#4038): print the model, the read script or
    the sync script for the Figma MCP's use_figma, or compare what Figma returned with the stylesheet.

.DESCRIPTION
    The repo is the source and Figma the mirror; nothing here writes the stylesheet. The model is in
    ../lib/figma-tokens-lib.ps1, and the skill page (skills/figma-tokens/SKILL.md) is the procedure.

      -Emit model     (default) the collections, modes and values the Figma file should hold, as JSON
      -Emit read-js   the Plugin API script that returns what the file holds, in the same shape
      -Emit sync-js   the Plugin API script that writes the model into the file (creates and overwrites,
                      never deletes)
      -Compare <f>    reads the JSON the read script returned (saved to file <f>) and reports every missing,
                      extra and differing collection, mode and value. Exit 1 on drift, 0 when in sync.

    Pure ASCII (repo convention for .ps1).

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File figma-tokens.ps1 -Emit read-js
    powershell -NoProfile -ExecutionPolicy Bypass -File figma-tokens.ps1 -Compare figma-variables.json
#>
[CmdletBinding()]
param(
    [ValidateSet('model', 'read-js', 'sync-js')][string]$Emit = 'model',
    [string]$Compare = '',
    [string]$StylePath = ''
)
$ErrorActionPreference = 'Stop'
# resolved here, not as the parameter's default: under [CmdletBinding()] $PSScriptRoot is still empty there in 5.1
if (-not $StylePath) { $StylePath = Join-Path $PSScriptRoot '..\..\..\..\assets\dkj-brandbook\house-style.css' }
. (Join-Path $PSScriptRoot '..\lib\figma-tokens-lib.ps1')

$model = Get-FigmaTokenModel -StylePath $StylePath

if ($Compare) {
    $actual = ConvertFrom-FigmaTokenJson -Json ([System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $Compare).Path))
    $findings = @(Compare-FigmaTokenModel -Expected $model -Actual $actual)
    $vars = ($model | ForEach-Object { $_.variables.Count } | Measure-Object -Sum).Sum
    if ($findings.Count -eq 0) {
        Write-Host "[OK] Figma matches the stylesheet: $($model.Count) collection(s), $vars variable(s), every theme's value."
        exit 0
    }
    foreach ($f in $findings) { Write-Host ("  [DRIFT] " + (Format-FigmaTokenFinding $f)) }
    Write-Host "[DRIFT] $($findings.Count) difference(s) between Figma and the stylesheet. The stylesheet is the source: sync Figma from it (-Emit sync-js), or file an issue on the brand book if the Figma value is the one wanted."
    exit 1
}

switch ($Emit) {
    'model'   { ConvertTo-FigmaTokenJson -Model $model }
    'read-js' { Get-FigmaTokenReadScript -Model $model }
    'sync-js' { Get-FigmaTokenSyncScript -Model $model }
}
