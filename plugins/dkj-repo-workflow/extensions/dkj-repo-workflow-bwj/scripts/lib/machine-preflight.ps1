<#
.SYNOPSIS
    Shared machine preflight: is this profile equipped to run this repo's Shopify gates?
.DESCRIPTION
    Dot-source this file from a script in this plugin's scripts/task/ or from a suite:

        . (Join-Path $PSScriptRoot 'machine-preflight.ps1')

    Provides Test-ShopifyCliPresent and Get-ShopifyCliRepairLines.

    WHAT THIS IS FOR, AND WHY IT IS A LIB RATHER THAN A THIRD COPY OF AN IF-STATEMENT
    Several places in a store have to answer "is the Shopify CLI reachable from this profile?" and act
    on it -- a store's pre-task sync at step 0, start-task.ps1 before it creates anything, and the
    suite case that open-pr and the cut run before they push. Several copies of the repair text is
    several copies free to drift, and the repair text is the whole value: a refusal that does not say how to clear itself is
    a wall.

    THE PATH HALF, MEASURED ON A PROFILE THAT HAD NEVER RUN THE CLI (a store issue)
    'npm i -g @shopify/cli@latest' succeeded -- 26 packages, 4 seconds, and 'npm ls -g --depth=0'
    then listed @shopify/cli@4.7.0. 'shopify' STILL did not resolve. npm's global bin
    (%APPDATA%\npm) was not on that profile's user PATH at all: node came from the Program Files
    installer, whose machine PATH entry covers node and npm themselves but not what npm installs
    globally. So "install the CLI" is TWO steps on a profile that has never had a global npm package,
    and a repair line naming only the first sends the reader back to the same refusal with nothing
    changed. Both steps are in Get-ShopifyCliRepairLines for that reason.

    WHAT THIS DELIBERATELY DOES NOT CHECK: whether the CLI is AUTHENTICATED. That leg is interactive
    -- it opens a browser -- so a non-interactive gate cannot test it without hanging, which is the
    exact failure a store issue measured (a push that hung on a GUI prompt). Presence is testable and absence is the common case; auth
    announces itself loudly the first time a real command runs.

    No Set-StrictMode here: dot-sourcing would modify the calling script's strict mode.
    Pure ASCII (repo convention for .ps1): Windows PowerShell 5.1 reads a BOM-less script as ANSI.
#>

function Test-ShopifyCliPresent {
    <#
    .SYNOPSIS
        True when 'shopify' resolves on this process's PATH.
    .DESCRIPTION
        Get-Command rather than Test-Path against a guessed location: npm's global bin is not at a
        fixed path (it moves with 'npm config set prefix'), and what every caller actually needs to
        know is whether the name resolves for the process that is about to invoke it.

        NOTE FOR THE CALLER: this reads the CURRENT process's PATH. A PATH entry added to the user
        environment after this process started is not visible here -- the reader has to restart the
        shell. The repair lines say so.

        A RESOLUTION IS NOT AN INVOCATION (a store issue). npm writes three shims: 'shopify' (a sh script
        with no extension), 'shopify.cmd' and 'shopify.ps1'. An interrupted install leaves the last two
        under staging names ('.shopify.cmd-pFQdlKWQ') while the first is already in place, and
        Get-Command resolves that extensionless file as an Application -- measured -- that
        PowerShell then cannot run. So an Application only counts when its extension is in PATHEXT,
        which is the set Windows will actually execute; a .ps1 shim resolves as an ExternalScript and
        counts as it is.
    #>
    $pathExt = @(($env:PATHEXT -split ';') | Where-Object { $_ } | ForEach-Object { $_.ToLowerInvariant() })
    $runnable = @(Get-Command shopify -All -ErrorAction SilentlyContinue | Where-Object {
        $_.CommandType -ne 'Application' -or
        $pathExt -contains ([System.IO.Path]::GetExtension($_.Source)).ToLowerInvariant()
    })
    return ($runnable.Count -gt 0)
}

function Get-ShopifyCliRepairLines {
    <#
    .SYNOPSIS
        The repair for a missing Shopify CLI, as lines a caller can print in its own colours.
    .PARAMETER Store
        The store to name in the authenticate step. Defaults to the repo's store, from its seam.
    .DESCRIPTION
        Lines rather than one string, because the callers frame them differently: a pre-task sync
        prints them Cyan under a red REFUSED banner, start-task folds them into a Write-Error
        here-string, and a suite prints them Yellow after a failed assert.
    #>
    param([string]$Store)

    # THE STORE COMES FROM THE SEAM WHERE THERE IS ONE. Get-ShopifyStoreDomain in the repo's
    # scripts/repo-config.ps1 is its single answer to "which store", and the live-theme guard reads it on
    # every command -- so a second source of truth for a value that already has one is a defect. It is
    # resolved lazily rather than by dot-sourcing repo-config here, which would put every Get-Shopify*
    # function into the caller's scope for the sake of one string. THE LAST RESORT IS A PLACEHOLDER, NEVER
    # A DOMAIN: this file ships to every store, and a literal here would name one store's domain in the
    # other store's refusal.
    if (-not $Store) {
        $Store = if (Get-Command Get-ShopifyStoreDomain -ErrorAction SilentlyContinue) {
            Get-ShopifyStoreDomain
        } else {
            '<your-store>.myshopify.com'
        }
    }

    return @(
        "  1. Install it:",
        "       npm i -g @shopify/cli@latest",
        "",
        "  2. Put npm's global bin on PATH -- 'npm i -g' does NOT do this on a profile that has never",
        "     had one. 'npm config get prefix' names the folder; on Windows that is usually %APPDATA%\npm.",
        "     Add it to the USER PATH (not the machine PATH), then RESTART the shell: a running process",
        "     does not pick up an environment change made after it started.",
        "",
        "  3. Authenticate -- this leg is interactive and opens a browser, so a person runs it:",
        "       shopify theme list --store $Store"
    )
}
