<#
.SYNOPSIS
    Expand-CommaList: the one place this plugin splits a list argument on commas after the fact
    (moved here with check-jsonld from a store repo, #4290).

.DESCRIPTION
    THE TRAP. Running `powershell -File <script> -Path a,b,c` binds the WHOLE list as ONE string: with
    -File every argument is a bare string and PowerShell does not split on commas. Only the parser
    does that, and the parser is there only for -Command or a direct call. Every invocation form the
    docs show is exactly the form this hits, so a script that offers a list parameter has to split it
    itself.

    WHY THIS DESERVES A GUARD AND NOT A DOC LINE. Measured in a store with two storefront paths:

        -Path '/collections/some-collection','/products/some-product'

    One target came out, with a comma in its path. Shopify resolved that nonsense URL to the PRODUCT
    page, so the script reported "3 block(s) tested over 1 page(s), all valid" with exit code 0, over a
    page nobody had asked for, while the collection page was never fetched. An earlier measurement hit
    a snapshot script the same way: eight paths arrived as one string, a check that looks at the first
    path segment accepted it, and the run ended green with zero files compared.

    The failure direction is the expensive side of the asymmetry: a false failure blocks and gets
    noticed, a false green is silent. For a script that EXISTS to prove something you cannot see, a
    silent green is the worst thing it can produce.

    SPLITTING IS THE SHARED PART, THE SHAPE CHECK IS NOT. A theme file path never holds a comma, so
    splitting is always safe there. A STOREFRONT path can hold one in a query string
    ('/collections/all?filter=a,b'), which falls apart into '/collections/all?filter=a' and 'b'; that
    second fragment must be refused LOUDLY rather than glued onto a domain. So a caller that needs a
    shape check keeps it itself, right after the split: this function does not know what a valid
    element is and must not start guessing.

    THERE IS ONE DEFINITION. A second copy does not fail, it WORKS, next to the first, until the two
    drift apart. shopify-check-jsonld.tests.ps1 pins the behaviour and refuses a second definition.

    Pure ASCII: Windows PowerShell 5.1 reads a BOM-less script as ANSI.
#>

function Expand-CommaList {
    <#
    .SYNOPSIS
        Split a list argument on commas after the fact, trim, drop empty elements. Pure, no I/O.
    .PARAMETER Value
        The list as PowerShell bound it -- under -File possibly one string with commas in it. An empty
        collection and an empty string are allowed and give an empty result, the right answer for an
        optional filter argument.
    #>
    param([Parameter(Mandatory = $true)][AllowEmptyCollection()][AllowEmptyString()][string[]]$Value)
    return @($Value |
        ForEach-Object { $_ -split ',' } |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ })
}
