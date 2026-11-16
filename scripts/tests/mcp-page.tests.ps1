<#
.SYNOPSIS
    Tests for plugins/dkj-policy/apps/admin/lib/mcp-page-lib.ps1 -- Admin's MCP connections page (#4173): reading
    `claude mcp list`'s text into rows (source, host only, state), the cache file the page reads instead of running the
    health check, and the page itself.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Continue'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $RepoRoot 'plugins\dkj-policy\apps\admin\lib\general-pages-lib.ps1')
. (Join-Path $RepoRoot 'plugins\dkj-policy\apps\admin\lib\dev-preview-rules.ps1')
. (Join-Path $RepoRoot 'plugins\dkj-policy\apps\admin\lib\mcp-page-lib.ps1')

$script:pass = 0
$script:fail = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else            { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}
trap { $script:fail++; Write-Host "  [FAIL] unhandled terminating error: $_" -ForegroundColor Red; continue }
function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    Assert-True ("$Expected" -eq "$Actual") ($Name + $(if ("$Expected" -ne "$Actual") { " (expected '$Expected', got '$Actual')" } else { '' }))
}

# The shape measured November 16, 2026, the check marks written as code points (the script layer is ASCII).
$ok = [string][char]0x2714; $off = [string][char]0x2298
$text = @(
    ('Checking MCP server health' + [char]0x2026), '',
    "claude.ai Claude Docs: https://api.anthropic.com/mcp/v1/acct-123/docs - $ok Connected",
    'claude.ai Slack: https://mcp.slack.com/acct/T999 - ! Needs authentication',
    "claude.ai Gmail: https://gmailmcp.googleapis.com/x - $off Disabled for this project (re-enable via /mcp)",
    "plugin:context7:context7: npx -y @upstash/context7-mcp@1.0.0 - $ok Connected",
    ('local-db: "C:\Users\someone\tools\db-mcp.exe" --token secret - ' + [char]0x2717 + ' Failed to connect'),
    'repo-tool: node server.js - ? Something new'
) -join "`r`n"
$rows = @(ConvertFrom-McpListOutput -Text $text -ProjectNames @('repo-tool'))

Write-Host '-- reading claude mcp list' -ForegroundColor Cyan
Assert-Equal 6 $rows.Count 'one row per server line; the header and the blank line are none'
Assert-Equal 'Claude Docs|claude.ai|api.anthropic.com|connected' (($rows[0].Name, $rows[0].Source, $rows[0].Host, $rows[0].State) -join '|') 'a claude.ai connector loses its prefix, keeps its host only, and reads as connected'
Assert-Equal 'auth' $rows[1].State 'needs authentication is its own state'
Assert-Equal 'disabled' $rows[2].State 'a server this project disabled reads as disabled'
Assert-Equal 'context7/context7|plugin|npx|connected' (($rows[3].Name, $rows[3].Source, $rows[3].Host, $rows[3].State) -join '|') 'a plugin server is named <plugin>/<server>, its colons kept out of the target, and a command keeps its file name only'
Assert-Equal 'local-db|user|db-mcp.exe|failed' (($rows[4].Name, $rows[4].Source, $rows[4].Host, $rows[4].State) -join '|') 'a server in the user config that failed: a quoted command path keeps its file name only'
Assert-Equal 'project|unknown|? Something new' (($rows[5].Source, $rows[5].State, $rows[5].Raw) -join '|') 'a name the repo''s .mcp.json declares is a project server, and a state with no name keeps its own words'
$all = ($rows | ForEach-Object { $_.Host + ' ' + $_.Raw }) -join ' '
Assert-True ($all -notmatch 'acct|T999|someone|secret|/mcp/') 'no path, account id, argument or user folder survives the parse: hosts only (#4173)'
Assert-Equal 0 @(ConvertFrom-McpListOutput -Text 'No MCP servers configured. Use `claude mcp add` to add a server.').Count 'no server configured is no row'

Write-Host '-- the cache' -ForegroundColor Cyan
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('mcp-page-tests-' + [guid]::NewGuid().ToString('N'))
try {
    $env:DKJ_ADMIN_STATE_DIR = $tmp
    $path = Get-McpCachePath -Root 'C:\x\repo'
    Assert-True ($path.StartsWith($tmp) -and $path -match 'mcp-[0-9a-f]{8}\.json$' -and $path -eq (Get-McpCachePath -Root 'c:\X\Repo')) 'one cache file per checkout in the Admin folder, named by the checkout''s own tag'
    Assert-True ($null -eq (Read-McpCache -Path $path)) 'no cache yet reads as none'
    Write-McpCache -Path $path -Rows $rows -GeneratedAt '2026-11-16 12:00:00' -Seconds 15.13 -ReadError ''
    $c = Read-McpCache -Path $path
    Assert-True ($c.Rows.Count -eq 6 -and $c.Rows[0].Host -eq 'api.anthropic.com' -and $c.GeneratedAt -eq '2026-11-16 12:00:00' -and [double]$c.Seconds -eq 15.1) 'a written cache reads back, rows and all'
    Assert-True ([System.IO.File]::ReadAllText($path) -notmatch 'https?://') 'the file on disk holds no URL'
    [System.IO.File]::WriteAllText($path, 'not json')
    Assert-True ($null -eq (Read-McpCache -Path $path)) 'a cache that is not JSON reads as none'
    New-Item -ItemType Directory -Path (Join-Path $tmp 'repo') -Force | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $tmp 'repo\.mcp.json'), '{ "mcpServers": { "a": {}, "b": {} } }')
    Assert-Equal 'a,b' ((Get-McpProjectNames -RepoRoot (Join-Path $tmp 'repo')) -join ',') 'the project servers are the .mcp.json''s mcpServers keys'
    Assert-Equal 0 @(Get-McpProjectNames -RepoRoot $tmp).Count 'no .mcp.json, no project server'
} finally {
    Remove-Item Env:\DKJ_ADMIN_STATE_DIR -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host '-- the page' -ForegroundColor Cyan
$empty = Format-AdminMcpPageHtml -Cache $null -RepoName 'o/r'
Assert-True ($empty -match '<h1>MCP connections</h1>' -and $empty -match '<a href="/dev/claude">Claude</a>' -and $empty -match 'class="empty-state"' -and $empty -match 'href="/refresh\?page=mcp"') 'with no cache the page sits under Claude and offers the one button that reads'
$page = Format-AdminMcpPageHtml -Cache @{ Rows = $rows; GeneratedAt = '2026-11-16 12:00:00'; Seconds = 15.1; Error = '' } -RepoName 'o/r'
Assert-Equal 6 ([regex]::Matches($page, '<tr><td class="col-start">')).Count 'one table row per server'
Assert-True ($page.IndexOf('Claude Docs') -lt $page.IndexOf('context7/context7') -and $page.IndexOf('context7/context7') -lt $page.IndexOf('repo-tool') -and $page.IndexOf('repo-tool') -lt $page.IndexOf('local-db')) 'rows run claude.ai, plugin, project, user'
Assert-True ($page -match 'badge--good">Connected' -and $page -match 'badge--warn">Needs authentication' -and $page -match 'badge--bad">Failed' -and $page -match 'Switched off</td>') 'each state is a badge, and a disabled server is switched off in this repo'
Assert-True ($page -match 'Last read 2026-11-16 12:00:00 in 15\.1 s' -and $page -notmatch 'https?://(?!github)') 'the footer says when it was read, and the page shows no connector URL'
$failed = Format-AdminMcpPageHtml -Cache @{ Rows = @(); GeneratedAt = '2026-11-16 12:00:00'; Seconds = 0.2; Error = 'claude was not found on the PATH' }
Assert-True ($failed -match 'role="alert">The last read failed: claude was not found on the PATH' -and $failed -match 'No MCP server is configured') 'a failed read says so instead of going blank'
Assert-True ([bool](Get-AdminIconSvg -Name 'mcp')) 'the page''s card has an icon Admin draws'

Write-Host ''
Write-Host "mcp-page: $script:pass passed, $script:fail failed"
if ($script:fail) { exit 1 }
exit 0
