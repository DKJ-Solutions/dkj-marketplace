<#
.SYNOPSIS
    Capture the evidence of a failed storefront fetch: status code, x-request-id, time and URL.

.DESCRIPTION
    Dot-source this file and call Get-FetchFailureEvidence in the catch of an Invoke-WebRequest.
    Shipped by dkj-subagents-shopify beside which-theme.ps1 (#4289); a later storefront check reuses it
    from here (#4290).

    WHY (the measured reason): a collection page returned an occasional HTTP 500 on preview themes and
    nobody had kept the x-request-id of that response. Without that id Shopify cannot trace the error,
    so the cause could not be proven afterwards. A 500 also carries no Shopify.theme marker in its
    HTML: the URL (with preview_theme_id) is the only trace of WHICH theme was requested. So the tooling
    records this itself, at the moment a page fails.

    Two shapes of the error, depending on the PowerShell version:
      - Windows PowerShell 5.1: System.Net.WebException, .Response is an HttpWebResponse
        (.StatusCode, .Headers['x-request-id']).
      - PowerShell 7: HttpResponseException, .Response is an HttpResponseMessage
        (.StatusCode, .Headers.TryGetValues).

    Get-FetchFailureEvidence is PURE and never throws: with no HTTP response (DNS, time-out)
    StatusCode is $null. For tests without a network there is Get-FetchFailureEvidenceFromParts, which
    the ErrorRecord branch uses itself.

    Pure ASCII (repo convention for .ps1).
#>

function Get-FetchFailureEvidenceFromParts {
    <#
    .SYNOPSIS
        Build the evidence object from a status code and a headers object (the testable core).
    .PARAMETER StatusCode
        HTTP status code, or $null when there was no response. An enum (HttpStatusCode) is fine too.
    .PARAMETER Headers
        Hashtable/dictionary, WebHeaderCollection or HttpResponseHeaders. Header names are
        case-insensitive.
    .PARAMETER Url
        The requested URL.
    #>
    param(
        $StatusCode,
        $Headers,
        [string]$Url
    )
    $code = $null
    try { if ($null -ne $StatusCode) { $code = [int]$StatusCode } } catch { $code = $null }

    $requestId = $null
    try {
        if ($null -ne $Headers) {
            $value = $null
            if ($Headers -is [System.Collections.IDictionary]) {
                foreach ($key in $Headers.Keys) {
                    if ([string]$key -ieq 'x-request-id') { $value = $Headers[$key]; break }
                }
            }
            elseif ($Headers.PSObject.Methods['TryGetValues']) {
                $out = $null
                if ($Headers.TryGetValues('x-request-id', [ref]$out)) { $value = $out }
            }
            else {
                # WebHeaderCollection: the indexer is case-insensitive and gives $null when absent.
                $value = $Headers['x-request-id']
            }
            if ($null -ne $value) {
                # The header comes from the server, so it is untrusted text: strip control and format
                # characters and cap the length, HERE and not in the caller, so no later caller can
                # forget it.
                $text = (@($value) | ForEach-Object { [string]$_ }) -join ','
                $text = [regex]::Replace($text, '\p{C}', ' ').Trim()
                if ($text.Length -gt 128) { $text = $text.Substring(0, 128) }
                if ($text) { $requestId = $text }
            }
        }
    }
    catch { $requestId = $null }

    [pscustomobject]@{
        StatusCode = $code
        RequestId  = $requestId
        TimeUtc    = [datetime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
        Url        = $Url
    }
}

function Get-FetchFailureEvidence {
    <#
    .SYNOPSIS
        Pull status code, x-request-id, UTC time and URL out of a caught fetch error. Never throws.
    .PARAMETER ErrorRecord
        The ErrorRecord ($_ in the catch), or the exception itself.
    .PARAMETER Url
        The requested URL (the error does not always carry it).
    #>
    param(
        $ErrorRecord,
        [string]$Url
    )
    try {
        $ex = $ErrorRecord
        if ($ErrorRecord -is [System.Management.Automation.ErrorRecord]) { $ex = $ErrorRecord.Exception }
        $response = $null
        if ($null -ne $ex -and $ex.PSObject.Properties['Response']) { $response = $ex.Response }
        if ($null -eq $response) {
            return Get-FetchFailureEvidenceFromParts -StatusCode $null -Headers $null -Url $Url
        }
        return Get-FetchFailureEvidenceFromParts -StatusCode $response.StatusCode -Headers $response.Headers -Url $Url
    }
    catch {
        return [pscustomobject]@{
            StatusCode = $null
            RequestId  = $null
            TimeUtc    = [datetime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
            Url        = $Url
        }
    }
}
