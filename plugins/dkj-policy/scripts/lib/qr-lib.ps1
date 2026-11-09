<#
.SYNOPSIS
    A QR code drawn locally, as inline SVG (#3925): the preview handover's per-market card carries one, and the URL it
    encodes never leaves the machine.

.DESCRIPTION
    WHY IT IS WRITTEN HERE AND NOT TAKEN FROM A SERVICE OR A CDN. A preview URL carries preview_theme_id and the admin
    parameters, which is exactly what lets a viewer see an unpublished theme, so a QR-image API that round-trips it hands
    the store's unreleased work to a third party (PREVIEW-portable.md, "And the link is as sensitive as the URLs it
    encodes"). A library loaded from a CDN keeps the URL in the browser, but makes an offline Admin page draw blank
    squares. So the code is encoded here, in PowerShell, and the page carries the result as markup.

    WHAT IT ENCODES: byte mode (the text as UTF-8), error correction level M (15% of the code can be lost), versions 1
    to 15 -- 25 to 77 modules a side, up to 412 bytes, which holds a storefront URL with its preview parameters many
    times over. The smallest version that holds the text is chosen, and the mask with the lowest penalty (ISO/IEC 18004,
    the four rules). A text longer than version 15 holds throws: a code silently cut short would scan as the wrong page.

    Pure: no file, no network, no clock. Pure ASCII (repo convention for .ps1). Tested by scripts/tests/qr-lib.tests.ps1
    in the source repo, which also decodes what it draws.
#>

# Per version 1..15 at level M: the error-correction codewords per block, and the blocks as (count, data codewords).
$script:QrBlocksM = @{
    1  = @{ Ec = 10; Groups = @(, @(1, 16)) }
    2  = @{ Ec = 16; Groups = @(, @(1, 28)) }
    3  = @{ Ec = 26; Groups = @(, @(1, 44)) }
    4  = @{ Ec = 18; Groups = @(, @(2, 32)) }
    5  = @{ Ec = 24; Groups = @(, @(2, 43)) }
    6  = @{ Ec = 16; Groups = @(, @(4, 27)) }
    7  = @{ Ec = 18; Groups = @(, @(4, 31)) }
    8  = @{ Ec = 22; Groups = @(@(2, 38), @(2, 39)) }
    9  = @{ Ec = 22; Groups = @(@(3, 36), @(2, 37)) }
    10 = @{ Ec = 26; Groups = @(@(4, 43), @(1, 44)) }
    11 = @{ Ec = 30; Groups = @(@(1, 50), @(4, 51)) }
    12 = @{ Ec = 22; Groups = @(@(6, 36), @(2, 37)) }
    13 = @{ Ec = 22; Groups = @(@(8, 37), @(1, 38)) }
    14 = @{ Ec = 24; Groups = @(@(4, 40), @(5, 41)) }
    15 = @{ Ec = 24; Groups = @(@(5, 41), @(5, 42)) }
}
$script:QrAlignment = @{
    1 = @(); 2 = @(6, 18); 3 = @(6, 22); 4 = @(6, 26); 5 = @(6, 30); 6 = @(6, 34); 7 = @(6, 22, 38); 8 = @(6, 24, 42)
    9 = @(6, 26, 46); 10 = @(6, 28, 50); 11 = @(6, 30, 54); 12 = @(6, 32, 58); 13 = @(6, 34, 62); 14 = @(6, 26, 46, 66); 15 = @(6, 26, 48, 70)
}
$script:QrMaxVersion = 15

function Get-QrGfTables {
    <# GF(256) under the QR polynomial 0x11D: @{ Exp; Log }. Built once per session. #>
    if ($script:QrGf) { return $script:QrGf }
    $exp = New-Object int[] 512; $log = New-Object int[] 256
    $x = 1
    for ($i = 0; $i -lt 255; $i++) {
        $exp[$i] = $x; $log[$x] = $i
        $x = $x -shl 1
        if ($x -band 0x100) { $x = $x -bxor 0x11D }
    }
    for ($i = 255; $i -lt 512; $i++) { $exp[$i] = $exp[$i - 255] }
    $script:QrGf = @{ Exp = $exp; Log = $log }
    return $script:QrGf
}

function Get-QrErrorCorrection {
    <# The -Count Reed-Solomon codewords for -Data (byte values), as ISO/IEC 18004 computes them. Pure. #>
    param([Parameter(Mandatory = $true)][int[]]$Data, [Parameter(Mandatory = $true)][int]$Count)
    $gf = Get-QrGfTables
    # The generator polynomial, highest power first, its leading 1 left out: the product of (x - a^i), i = 0..Count-1.
    $gen = New-Object int[] ($Count + 1)
    $gen[0] = 1
    for ($i = 0; $i -lt $Count; $i++) {
        for ($j = $i + 1; $j -ge 1; $j--) {
            $prod = if ($gen[$j - 1] -eq 0) { 0 } else { $gf.Exp[$gf.Log[$gen[$j - 1]] + $i] }
            $gen[$j] = $gen[$j] -bxor $prod
        }
    }
    $rem = New-Object int[] $Count
    foreach ($d in $Data) {
        $factor = $d -bxor $rem[0]
        for ($k = 0; $k -lt $Count - 1; $k++) { $rem[$k] = $rem[$k + 1] }
        $rem[$Count - 1] = 0
        if ($factor -ne 0) {
            for ($k = 0; $k -lt $Count; $k++) {
                if ($gen[$k + 1] -ne 0) { $rem[$k] = $rem[$k] -bxor $gf.Exp[$gf.Log[$gen[$k + 1]] + $gf.Log[$factor]] }
            }
        }
    }
    return , $rem
}

function Get-QrVersion {
    <# The smallest version (1..15) at level M that holds -ByteCount bytes in byte mode, or 0 when none does. Pure. #>
    param([Parameter(Mandatory = $true)][int]$ByteCount)
    for ($v = 1; $v -le $script:QrMaxVersion; $v++) {
        $data = 0; foreach ($g in $script:QrBlocksM[$v].Groups) { $data += $g[0] * $g[1] }
        $countBits = if ($v -le 9) { 8 } else { 16 }
        if (4 + $countBits + 8 * $ByteCount -le 8 * $data) { return $v }
    }
    return 0
}

function Get-QrCodewords {
    <# The final codeword sequence for -Bytes at -Version: data split into blocks, each block's error correction, both interleaved. Pure. #>
    param([Parameter(Mandatory = $true)][AllowEmptyCollection()][byte[]]$Bytes, [Parameter(Mandatory = $true)][int]$Version)
    $spec = $script:QrBlocksM[$Version]
    $dataCount = 0; foreach ($g in $spec.Groups) { $dataCount += $g[0] * $g[1] }
    $bits = New-Object System.Collections.Generic.List[int]
    $put = { param([int]$Value, [int]$Length) for ($i = $Length - 1; $i -ge 0; $i--) { $bits.Add(($Value -shr $i) -band 1) } }
    & $put 4 4
    & $put $Bytes.Length $(if ($Version -le 9) { 8 } else { 16 })
    foreach ($b in $Bytes) { & $put ([int]$b) 8 }
    $capacity = 8 * $dataCount
    & $put 0 ([Math]::Min(4, $capacity - $bits.Count))
    while ($bits.Count % 8) { $bits.Add(0) }
    $data = New-Object System.Collections.Generic.List[int]
    for ($i = 0; $i -lt $bits.Count; $i += 8) {
        $v = 0; for ($j = 0; $j -lt 8; $j++) { $v = ($v -shl 1) -bor $bits[$i + $j] }
        $data.Add($v)
    }
    $pad = @(0xEC, 0x11); $p = 0
    while ($data.Count -lt $dataCount) { $data.Add($pad[$p % 2]); $p++ }

    $blocks = @(); $ecs = @(); $at = 0
    foreach ($g in $spec.Groups) {
        for ($n = 0; $n -lt $g[0]; $n++) {
            $block = [int[]]$data.GetRange($at, $g[1]).ToArray()
            $at += $g[1]
            $blocks += , $block
            $ecs += , (Get-QrErrorCorrection -Data $block -Count $spec.Ec)
        }
    }
    $out = New-Object System.Collections.Generic.List[int]
    $longest = ($blocks | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
    for ($i = 0; $i -lt $longest; $i++) { foreach ($b in $blocks) { if ($i -lt $b.Length) { $out.Add($b[$i]) } } }
    for ($i = 0; $i -lt $spec.Ec; $i++) { foreach ($e in $ecs) { $out.Add($e[$i]) } }
    return , ([int[]]$out.ToArray())
}

function Test-QrMask {
    <# Whether mask -Mask flips the module at -Row, -Col. Pure. #>
    param([int]$Mask, [int]$Row, [int]$Col)
    switch ($Mask) {
        0 { return (($Row + $Col) % 2) -eq 0 }
        1 { return ($Row % 2) -eq 0 }
        2 { return ($Col % 3) -eq 0 }
        3 { return (($Row + $Col) % 3) -eq 0 }
        4 { return (([Math]::Floor($Row / 2) + [Math]::Floor($Col / 3)) % 2) -eq 0 }
        5 { return ((($Row * $Col) % 2) + (($Row * $Col) % 3)) -eq 0 }
        6 { return (((($Row * $Col) % 2) + (($Row * $Col) % 3)) % 2) -eq 0 }
        default { return (((($Row + $Col) % 2) + (($Row * $Col) % 3)) % 2) -eq 0 }
    }
}

function Get-QrFormatBits {
    <# The 15 format bits for level M and -Mask, BCH-protected and XOR-masked as the standard writes them. Pure. #>
    param([Parameter(Mandatory = $true)][int]$Mask)
    $data = (0 -shl 3) -bor $Mask   # level M is 00
    $rem = $data
    for ($i = 0; $i -lt 10; $i++) { $rem = ($rem -shl 1) -bxor ((($rem -shr 9) -band 1) * 0x537) }
    return ((($data -shl 10) -bor ($rem -band 0x3FF)) -bxor 0x5412)
}

function Get-QrVersionBits {
    <# The 18 version bits for -Version (7 and up), BCH-protected. Pure. #>
    param([Parameter(Mandatory = $true)][int]$Version)
    $rem = $Version
    for ($i = 0; $i -lt 12; $i++) { $rem = ($rem -shl 1) -bxor ((($rem -shr 11) -band 1) * 0x1F25) }
    return (($Version -shl 12) -bor ($rem -band 0xFFF))
}

function Get-QrPenalty {
    <# The mask penalty of a -Size x -Size matrix (row-major, 1 = dark): the four rules of ISO/IEC 18004. Pure. #>
    param([Parameter(Mandatory = $true)][byte[]]$M, [Parameter(Mandatory = $true)][int]$Size)
    $score = 0
    $lines = New-Object System.Collections.Generic.List[string]
    $sb = New-Object System.Text.StringBuilder
    for ($r = 0; $r -lt $Size; $r++) { [void]$sb.Clear(); for ($c = 0; $c -lt $Size; $c++) { [void]$sb.Append([char](48 + $M[$r * $Size + $c])) }; $lines.Add($sb.ToString()) }
    for ($c = 0; $c -lt $Size; $c++) { [void]$sb.Clear(); for ($r = 0; $r -lt $Size; $r++) { [void]$sb.Append([char](48 + $M[$r * $Size + $c])) }; $lines.Add($sb.ToString()) }
    $runRx = [regex]'0{5,}|1{5,}'
    $finderRx = [regex]'(?=(00001011101|10111010000))'
    foreach ($l in $lines) {
        # $run, not $m: PowerShell names ignore case, so $m would be the [byte[]] parameter $M and the cast would throw.
        foreach ($run in $runRx.Matches($l)) { $score += 3 + ($run.Length - 5) }
        $score += 40 * $finderRx.Matches($l).Count
    }
    $dark = 0
    for ($r = 0; $r -lt $Size; $r++) {
        for ($c = 0; $c -lt $Size; $c++) {
            $v = $M[$r * $Size + $c]
            $dark += $v
            if ($r -lt $Size - 1 -and $c -lt $Size - 1 -and $v -eq $M[$r * $Size + $c + 1] -and $v -eq $M[($r + 1) * $Size + $c] -and $v -eq $M[($r + 1) * $Size + $c + 1]) { $score += 3 }
        }
    }
    $total = $Size * $Size
    $score += 10 * [Math]::Floor([Math]::Abs($dark * 20 - $total * 10) / $total)
    return $score
}

function ConvertTo-QrMatrix {
    <#
        -Text as a QR code: @{ Size; Version; Mask; Modules }, Modules a row-major byte array of Size*Size, 1 = dark,
        without the quiet zone. Throws when the text is empty or longer than version 15 holds. Pure.
    #>
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text)
    if (-not $Text) { throw 'qr-lib: there is no text to encode.' }
    $bytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes($Text)
    $version = Get-QrVersion -ByteCount $bytes.Length
    if (-not $version) { throw "qr-lib: $($bytes.Length) bytes is more than a version-$($script:QrMaxVersion) code holds at level M; a code cut short would scan as the wrong page." }
    $size = 17 + 4 * $version
    $mod = New-Object byte[] ($size * $size)
    $fn = New-Object bool[] ($size * $size)
    $set = { param([int]$r, [int]$c, [int]$dark) $mod[$r * $size + $c] = [byte]$dark; $fn[$r * $size + $c] = $true }

    # Finders with their separators, at three corners.
    foreach ($corner in @(@(0, 0), @(0, ($size - 7)), @(($size - 7), 0))) {
        for ($dr = -1; $dr -le 7; $dr++) {
            for ($dc = -1; $dc -le 7; $dc++) {
                $r = $corner[0] + $dr; $c = $corner[1] + $dc
                if ($r -lt 0 -or $c -lt 0 -or $r -ge $size -or $c -ge $size) { continue }
                $ring = [Math]::Max([Math]::Abs($dr - 3), [Math]::Abs($dc - 3))
                & $set $r $c $(if ($ring -ne 2 -and $ring -ne 4) { 1 } else { 0 })
            }
        }
    }
    # Timing patterns.
    for ($i = 8; $i -lt $size - 8; $i++) { & $set 6 $i $(if ($i % 2 -eq 0) { 1 } else { 0 }); & $set $i 6 $(if ($i % 2 -eq 0) { 1 } else { 0 }) }
    # Alignment patterns, except where they would sit on a finder.
    $pos = @($script:QrAlignment[$version])
    foreach ($ar in $pos) {
        foreach ($ac in $pos) {
            if (($ar -eq 6 -and $ac -eq 6) -or ($ar -eq 6 -and $ac -eq $pos[-1]) -or ($ar -eq $pos[-1] -and $ac -eq 6)) { continue }
            for ($dr = -2; $dr -le 2; $dr++) {
                for ($dc = -2; $dc -le 2; $dc++) {
                    & $set ($ar + $dr) ($ac + $dc) $(if ([Math]::Max([Math]::Abs($dr), [Math]::Abs($dc)) -ne 1) { 1 } else { 0 })
                }
            }
        }
    }
    # The format areas are reserved now and written per mask; the dark module; the version areas.
    for ($i = 0; $i -le 8; $i++) { if (-not $fn[8 * $size + $i]) { & $set 8 $i 0 }; if (-not $fn[$i * $size + 8]) { & $set $i 8 0 } }
    for ($i = 0; $i -lt 8; $i++) { & $set 8 ($size - 1 - $i) 0; & $set ($size - 1 - $i) 8 0 }
    & $set ($size - 8) 8 1
    if ($version -ge 7) {
        $vb = Get-QrVersionBits -Version $version
        for ($i = 0; $i -lt 18; $i++) {
            $bit = ($vb -shr $i) -band 1
            $a = $size - 11 + ($i % 3); $b = [Math]::Floor($i / 3)
            & $set $b $a $bit
            & $set $a $b $bit
        }
    }

    # The data, in the two-column zigzag from the bottom right, skipping the vertical timing column.
    $words = Get-QrCodewords -Bytes $bytes -Version $version
    $total = 8 * $words.Length
    $k = 0
    for ($right = $size - 1; $right -ge 1; $right -= 2) {
        if ($right -eq 6) { $right = 5 }
        $upward = (($right + 1) -band 2) -eq 0
        for ($vert = 0; $vert -lt $size; $vert++) {
            $r = if ($upward) { $size - 1 - $vert } else { $vert }
            for ($j = 0; $j -lt 2; $j++) {
                $c = $right - $j
                if ($fn[$r * $size + $c]) { continue }
                if ($k -lt $total) { $mod[$r * $size + $c] = [byte](($words[$k -shr 3] -shr (7 - ($k -band 7))) -band 1); $k++ }
            }
        }
    }

    # Each mask, its format bits, its penalty; the lowest wins.
    $best = $null; $bestScore = [int]::MaxValue; $bestMask = 0
    for ($mask = 0; $mask -lt 8; $mask++) {
        $m = [byte[]]$mod.Clone()
        for ($r = 0; $r -lt $size; $r++) {
            for ($c = 0; $c -lt $size; $c++) {
                if (-not $fn[$r * $size + $c] -and (Test-QrMask -Mask $mask -Row $r -Col $c)) { $m[$r * $size + $c] = [byte](1 - $m[$r * $size + $c]) }
            }
        }
        $fb = Get-QrFormatBits -Mask $mask
        $bit = { param([int]$i) ($fb -shr $i) -band 1 }
        for ($i = 0; $i -le 5; $i++) { $m[$i * $size + 8] = [byte](& $bit $i) }
        $m[7 * $size + 8] = [byte](& $bit 6)
        $m[8 * $size + 8] = [byte](& $bit 7)
        $m[8 * $size + 7] = [byte](& $bit 8)
        for ($i = 9; $i -lt 15; $i++) { $m[8 * $size + (14 - $i)] = [byte](& $bit $i) }
        for ($i = 0; $i -lt 8; $i++) { $m[8 * $size + ($size - 1 - $i)] = [byte](& $bit $i) }
        for ($i = 8; $i -lt 15; $i++) { $m[($size - 15 + $i) * $size + 8] = [byte](& $bit $i) }
        $m[($size - 8) * $size + 8] = 1
        $score = Get-QrPenalty -M $m -Size $size
        if ($score -lt $bestScore) { $bestScore = $score; $best = $m; $bestMask = $mask }
    }
    return @{ Size = $size; Version = $version; Mask = $bestMask; Modules = $best }
}

function ConvertTo-QrSvg {
    <#
        -Text as an inline <svg> QR code: one path of dark modules inside a four-module quiet zone, drawn in currentColor
        on a rect in the page's own surface colour, so the page's layer sets both through tokens and no colour is typed
        here. -Label is the accessible name. The markup carries no external reference. Pure.
    #>
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text, [string]$Label = 'QR code', [string]$Class = 'qr')
    $q = ConvertTo-QrMatrix -Text $Text
    $n = $q.Size; $quiet = 4; $view = $n + 2 * $quiet
    $d = New-Object System.Text.StringBuilder
    for ($r = 0; $r -lt $n; $r++) {
        $c = 0
        while ($c -lt $n) {
            if ($q.Modules[$r * $n + $c]) {
                $start = $c
                while ($c -lt $n -and $q.Modules[$r * $n + $c]) { $c++ }
                [void]$d.Append('M' + ($start + $quiet) + ' ' + ($r + $quiet) + 'h' + ($c - $start) + 'v1h-' + ($c - $start) + 'z')
            } else { $c++ }
        }
    }
    $lbl = [System.Net.WebUtility]::HtmlEncode($Label)
    $cls = [System.Net.WebUtility]::HtmlEncode($Class)
    return '<svg class="' + $cls + '" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ' + $view + ' ' + $view + '" role="img" aria-label="' + $lbl + '" shape-rendering="crispEdges">' +
        '<rect class="' + $cls + '__bg" width="' + $view + '" height="' + $view + '"/><path fill="currentColor" d="' + $d.ToString() + '"/></svg>'
}
