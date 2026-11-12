<#
.SYNOPSIS
    The colour model of the house style (#3235): seventeen tokens per theme, computed from the theme's hue and
    mode, so a theme is never tuned by hand again.

.DESCRIPTION
    Per theme, in the owner's words (issue #3235, October 21, 2026), on a light theme:
      --primary        ONE colour: the most saturated colour of the theme's HSL hue (saturation 100%) that
                       reads at 4.5:1 on all four paper steps, so white (and every paper step) reads on it too.
      --bg-1..5     FIVE colours from white towards a little darker: the page, the card, the line, the stronger
                       border, and one step past it (bg-5, Maikel, November 3, 2026) -- bg-1..4 also the text on a primary fill.
      --primary-muted  a grey of the colour that reads extra well (7:1) on the page.
      --primary-raised, --primary-hover  the primary 15% of the way to bg-1 and to fg-1: two fills a rule reads
                       instead of mixing them with color-mix() (Maikel, November 1, 2026).
    There is no grey for the far end (--muted-inverse was retired, Maikel, November 1, 2026): a theme's colours are
    the 60-30-10 groups and nothing else, and no colour reads at 4.5:1 on both bg-4 and fg-1, so it fitted none.
    The quieter line on an inverted surface takes --bg-4.
      --primary-border the edge of a control (a button, a segmented control, a search or filter field), in the primary group (the 10)
                       beside --primary-muted (the owner, November 12, 2026: every colour token sits in the 60, the 30 or the
                       10, and a new one joins the group it belongs to): a grey of the primary's own hue, as close to the
                       paper as 3:1 on bg-3 allows, WCAG 1.4.11's floor for a control's boundary.
      --fg-1..4        FOUR text colours that read on the page, near black, in very small steps: fg-4 is still
                       very dark, only a little less so than fg-1.
    A dark theme is the mirror: the paper runs from black towards a little lighter and the text is near white. Its
    primary is much lighter than a mirror would give (owner, October 21, 2026): it reaches 9:1 on all four paper
    steps, not 4.55:1, so it is a light tint of the colour rather than the colour at full strength, and the dark paper
    on it, the text on a primary fill, reads at 9:1 too. At 4.55:1 a fill was a vivid band under near-black text.
    And no dark primary is more saturated than OKLCH chroma 0.13 (Roze's, the most saturated of the light tints):
    Cyaan and Geel reach 9:1 at full strength already, so the floor alone left them neon (owner, the same day); above
    the cap the primary is taken again at that chroma, at the lightness where it reaches 9:1. A theme can set a lower
    cap of its own (ChromaMax): Cyaan still read too vivid at 0.13 and takes 0.10, Hemelsblauw's.

    Every threshold is 4.55:1 or 7.05:1 rather than 4.5 and 7, which leaves room for the rounding to #rrggbb.
    Pure ASCII (repo convention for .ps1).
#>

# ---- the twelve themes: id, mode and the HSL hue of the owner's original theme colour ------------------------
function Get-HousePaletteThemes {
    @(
        @{ Id = 'magenta'; Mode = 'light'; Hue = 317 }
        @{ Id = 'purple';  Mode = 'light'; Hue = 270 }
        @{ Id = 'blue';    Mode = 'light'; Hue = 240 }
        @{ Id = 'teal';    Mode = 'light'; Hue = 185 }
        @{ Id = 'ochre';   Mode = 'light'; Hue = 53  }
        @{ Id = 'rust';    Mode = 'light'; Hue = 29  }
        @{ Id = 'pink';    Mode = 'dark';  Hue = 327 }
        @{ Id = 'lilac';   Mode = 'dark';  Hue = 270 }
        @{ Id = 'sky';     Mode = 'dark';  Hue = 240 }
        @{ Id = 'cyan';    Mode = 'dark';  Hue = 185; ChromaMax = 0.10 }   # still too vivid at 0.13 (owner, October 21, 2026)
        @{ Id = 'yellow';  Mode = 'dark';  Hue = 47  }
        @{ Id = 'orange';  Mode = 'dark';  Hue = 23  }
    )
}

# The steps, per mode: OKLCH lightness and chroma of the four paper and the four text colours. Paper-1 and fg-1
# keep the anchors of October 20, 2026 (the edge of white and black); the steps after them are small by design, but
# bg-2 stands a clear step off the page (Maikel, November 1, 2026: it was barely visible in some themes), and
# bg-3 moves along so the card in a group keeps its own step. bg-5 is one step past bg-4, a little lighter on a dark theme and a little darker on a light one (Maikel, November 3, 2026); the primary is still measured against bg-4, so no theme colour moved for it.
function Get-HousePaletteSteps {
    param([ValidateSet('light', 'dark')][string]$Mode)
    if ($Mode -eq 'light') {
        @{ PaperL = @(0.995, 0.965, 0.94, 0.905, 0.87); PaperC = @(0.006, 0.014, 0.028, 0.045, 0.058)
           FgL    = @(0.12, 0.16, 0.20, 0.24);     FgC    = @(0.030, 0.030, 0.028, 0.026); MutedC = 0.03; PrimaryFloor = 4.55 }
    } else {
        @{ PaperL = @(0.13, 0.175, 0.215, 0.26, 0.30); PaperC = @(0.020, 0.024, 0.032, 0.045, 0.055)
           FgL    = @(0.99, 0.955, 0.92, 0.885);   FgC    = @(0.006, 0.010, 0.012, 0.014); MutedC = 0.06; PrimaryFloor = 9.0; PrimaryChromaMax = 0.13 }
    }
}

# ---- colour math ----------------------------------------------------------------------------------------------
function ConvertTo-LinearChannel([double]$c) { if ($c -le 0.04045) { $c / 12.92 } else { [math]::Pow(($c + 0.055) / 1.055, 2.4) } }
function ConvertFrom-LinearChannel([double]$c) { if ($c -le 0.0031308) { 12.92 * $c } else { 1.055 * [math]::Pow($c, 1 / 2.4) - 0.055 } }

function ConvertFrom-HexColor {
    param([string]$Hex)
    $h = $Hex.TrimStart('#')
    # each channel in parentheses: in PowerShell the comma binds tighter than the division
    @(([Convert]::ToInt32($h.Substring(0, 2), 16) / 255.0), ([Convert]::ToInt32($h.Substring(2, 2), 16) / 255.0), ([Convert]::ToInt32($h.Substring(4, 2), 16) / 255.0))
}

function ConvertTo-HexColor {
    param([double[]]$Rgb)
    '#' + (($Rgb | ForEach-Object { '{0:x2}' -f [int][math]::Round(([math]::Min(1.0, [math]::Max(0.0, [double]$_)) * 255.0)) }) -join '')
}

function Get-SrgbMix {
    <# $From moved $Share of the way to $To, per channel in sRGB: what color-mix(in srgb, from (1-share), to) computes,
       so a shade a rule would have mixed is typed into the theme as a token instead (Maikel, November 1, 2026). #>
    param([string]$From, [string]$To, [double]$Share)
    $a = ConvertFrom-HexColor $From; $b = ConvertFrom-HexColor $To
    ConvertTo-HexColor @(0..2 | ForEach-Object { $a[$_] * (1 - $Share) + $b[$_] * $Share })
}

function Get-RelativeLuminance {
    param([string]$Hex)
    $l = ConvertFrom-HexColor $Hex | ForEach-Object { ConvertTo-LinearChannel $_ }
    0.2126 * $l[0] + 0.7152 * $l[1] + 0.0722 * $l[2]
}

function Get-ContrastRatio {
    param([string]$A, [string]$B)
    $la = Get-RelativeLuminance $A; $lb = Get-RelativeLuminance $B
    ([math]::Max($la, $lb) + 0.05) / ([math]::Min($la, $lb) + 0.05)
}

# APCA lightness contrast (SAPC 0.0.98G, the WCAG 3 draft's measure) of $Text on $Background, as its absolute Lc.
# WCAG 2's ratio flatters a mid tone on a near-black page: the dark themes' blue series read 4.4:1 there and only Lc 30,
# where the same slot reads Lc 71 in a light theme. The graph slots are held to Lc on top of the ratio (the owner,
# November 12, 2026: a series must ALWAYS read well on bg-1).
function Get-ApcaContrast {
    param([string]$Text, [string]$Background)
    $y = foreach ($hex in @($Text, $Background)) {
        $c = ConvertFrom-HexColor $hex | ForEach-Object { [math]::Pow($_, 2.4) }
        $v = 0.2126729 * $c[0] + 0.7151522 * $c[1] + 0.0721750 * $c[2]
        if ($v -lt 0.022) { $v += [math]::Pow(0.022 - $v, 1.414) }
        $v
    }
    $t = $y[0]; $b = $y[1]
    if ($b -gt $t) { $s = ([math]::Pow($b, 0.56) - [math]::Pow($t, 0.57)) * 1.14; if ($s -lt 0.1) { return 0.0 }; return ($s - 0.027) * 100 }
    $s = ([math]::Pow($b, 0.65) - [math]::Pow($t, 0.62)) * 1.14
    if ($s -gt -0.1) { return 0.0 }
    - ($s + 0.027) * 100
}

function ConvertFrom-Hsl {
    param([double]$H, [double]$S, [double]$L)
    $c = (1 - [math]::Abs(2 * $L - 1)) * $S
    $hp = ($H % 360) / 60
    $x = $c * (1 - [math]::Abs(($hp % 2) - 1))
    $rgb = switch ([math]::Floor($hp)) { 0 { $c, $x, 0 } 1 { $x, $c, 0 } 2 { 0, $c, $x } 3 { 0, $x, $c } 4 { $x, 0, $c } default { $c, 0, $x } }
    $m = $L - $c / 2
    ConvertTo-HexColor @(($rgb[0] + $m), ($rgb[1] + $m), ($rgb[2] + $m))
}

# OKLab (Bjorn Ottosson, 2020) from and to linear sRGB. The cone responses are $cl/$cm/$cs and the Lab axes
# $okL/$okA/$okB: PowerShell variable names ignore case, so the usual l/L, a/A, b/B pairs would be one variable.
function ConvertTo-OkLch {
    param([string]$Hex)
    $r, $g, $bl = ConvertFrom-HexColor $Hex | ForEach-Object { ConvertTo-LinearChannel $_ }
    $cl = [math]::Pow(0.4122214708 * $r + 0.5363325363 * $g + 0.0514459929 * $bl, 1 / 3)
    $cm = [math]::Pow(0.2119034982 * $r + 0.6806995451 * $g + 0.1073969566 * $bl, 1 / 3)
    $cs = [math]::Pow(0.0883024619 * $r + 0.2817188376 * $g + 0.6299787005 * $bl, 1 / 3)
    $okL = 0.2104542553 * $cl + 0.7936177850 * $cm - 0.0040720468 * $cs
    $okA = 1.9779984951 * $cl - 2.4285922050 * $cm + 0.4505937099 * $cs
    $okB = 0.0259040371 * $cl + 0.7827717662 * $cm - 0.8086757660 * $cs
    $hue = [math]::Atan2($okB, $okA) * 180 / [math]::PI; if ($hue -lt 0) { $hue += 360 }
    @{ L = $okL; C = [math]::Sqrt($okA * $okA + $okB * $okB); H = $hue }
}

function ConvertFrom-OkLchRaw {
    param([double]$L, [double]$C, [double]$H)
    $okA = $C * [math]::Cos($H * [math]::PI / 180); $okB = $C * [math]::Sin($H * [math]::PI / 180)
    $cl = [math]::Pow($L + 0.3963377774 * $okA + 0.2158037573 * $okB, 3)
    $cm = [math]::Pow($L - 0.1055613458 * $okA - 0.0638541728 * $okB, 3)
    $cs = [math]::Pow($L - 0.0894841775 * $okA - 1.2914855480 * $okB, 3)
    @((4.0767416621 * $cl - 3.3077115913 * $cm + 0.2309699292 * $cs),
      (-1.2684380046 * $cl + 2.6097574011 * $cm - 0.3413193965 * $cs),
      (-0.0041960863 * $cl - 0.7034186147 * $cm + 1.7076147010 * $cs))
}

# An OKLCH colour as #rrggbb; out of gamut, the chroma is reduced (lightness and hue held) until it fits.
function ConvertFrom-OkLch {
    param([double]$L, [double]$C, [double]$H)
    $lo = 0.0; $hi = $C
    $lin = ConvertFrom-OkLchRaw $L $hi $H
    if (($lin | Where-Object { $_ -lt -0.0001 -or $_ -gt 1.0001 }).Count -gt 0) {
        for ($i = 0; $i -lt 30; $i++) {
            $mid = ($lo + $hi) / 2
            $t = ConvertFrom-OkLchRaw $L $mid $H
            if (($t | Where-Object { $_ -lt -0.0001 -or $_ -gt 1.0001 }).Count -gt 0) { $hi = $mid } else { $lo = $mid }
        }
        $lin = ConvertFrom-OkLchRaw $L $lo $H
    }
    ConvertTo-HexColor ($lin | ForEach-Object { ConvertFrom-LinearChannel ([math]::Min(1.0, [math]::Max(0.0, [double]$_))) })
}

# The lightness (in [Lo, Hi]) closest to $Toward at which a colour built by $Make still reaches $Ratio against
# $Against -- the colour that recedes furthest while still reading. Contrast falls monotonically towards $Against.
function Find-LightnessAtContrast {
    param([scriptblock]$Make, [string]$Against, [double]$Ratio, [double]$Lo, [double]$Hi, [ValidateSet('high', 'low')][string]$Toward)
    for ($i = 0; $i -lt 40; $i++) {
        $mid = ($Lo + $Hi) / 2
        $ok = (Get-ContrastRatio (& $Make $mid) $Against) -ge $Ratio
        if ($Toward -eq 'high') { if ($ok) { $Lo = $mid } else { $Hi = $mid } }
        else                    { if ($ok) { $Hi = $mid } else { $Lo = $mid } }
    }
    & $Make $(if ($Toward -eq 'high') { $Lo } else { $Hi })
}

# ---- the graph slots: computed per theme, away from the primary and the status hues --------------------------
# (the owner, November 12, 2026: a series colour that looks like the theme's own colour, as the magenta series did in
# the magenta theme, or like a status, as the orange series looked like a warning, reads as that meaning.)
# Distance is OKLab Delta E x100, the dataviz validator's measure; colour-vision deficiency is simulated with the
# Machado, Oliveira and Fernandes (2009) transforms at severity 1.0, the model the validator's thresholds are set for.
function Get-OkLab {
    param([string]$Hex, [ValidateSet('', 'protan', 'deutan')][string]$Kind = '')
    $lin = @(ConvertFrom-HexColor $Hex | ForEach-Object { ConvertTo-LinearChannel $_ })
    if ($Kind) {
        $m = @{ protan = @(@(0.152286, 1.052583, -0.204868), @(0.114503, 0.786281, 0.099216), @(-0.003882, -0.048116, 1.051998))
                deutan = @(@(0.367322, 0.860646, -0.227968), @(0.280085, 0.672501, 0.047413), @(-0.011820, 0.042940, 0.968881)) }[$Kind]
        $lin = @(0..2 | ForEach-Object { [math]::Min(1.0, [math]::Max(0.0, $m[$_][0] * $lin[0] + $m[$_][1] * $lin[1] + $m[$_][2] * $lin[2])) })
    }
    $l = [math]::Pow(0.4122214708 * $lin[0] + 0.5363325363 * $lin[1] + 0.0514459929 * $lin[2], 1 / 3)
    $mm = [math]::Pow(0.2119034982 * $lin[0] + 0.6806995451 * $lin[1] + 0.1073969566 * $lin[2], 1 / 3)
    $s = [math]::Pow(0.0883024619 * $lin[0] + 0.2817188376 * $lin[1] + 0.6299787005 * $lin[2], 1 / 3)
    @((0.2104542553 * $l + 0.7936177850 * $mm - 0.0040720468 * $s), (1.9779984951 * $l - 2.4285922050 * $mm + 0.4505937099 * $s), (0.0259040371 * $l + 0.7827717662 * $mm - 0.8086757660 * $s))
}

function Get-OkLabDeltaE {
    <# OKLab Delta E x100 between two colours; with -Kind, as a protan or deutan reader sees them. #>
    param([string]$A, [string]$B, [ValidateSet('', 'protan', 'deutan')][string]$Kind = '')
    $p = Get-OkLab $A $Kind; $q = Get-OkLab $B $Kind
    100 * [math]::Sqrt([math]::Pow($p[0] - $q[0], 2) + [math]::Pow($p[1] - $q[1], 2) + [math]::Pow($p[2] - $q[2], 2))
}

function Get-OkLabCvdDeltaE { param([string]$A, [string]$B) [math]::Min((Get-OkLabDeltaE $A $B 'protan'), (Get-OkLabDeltaE $A $B 'deutan')) }

function Get-HouseGraphRules {
    <# The floors a graph slot must reach, per theme. #>
    @{ FromPrimary = 18; FromStatus = 15; FromSlot = 15; FromSlotCvd = 6; OnPaper = 3; OnPaperLc = 45 }
}

function Get-HouseGraphLifted {
    <# A pool candidate moved away from the paper -- lighter on dark, darker on light, its OKLCH hue and chroma held
       (chroma reduced where the gamut ends) -- by the least that brings it to OnPaperLc on both bg-1 and bg-3. A
       candidate that already reads is returned unchanged. #>
    param([Parameter(Mandatory)][string]$Hex, [Parameter(Mandatory)]$Palette, [Parameter(Mandatory)][ValidateSet('light', 'dark')][string]$Mode)
    $floor = (Get-HouseGraphRules).OnPaperLc
    $reads = { param($c) (Get-ApcaContrast $c $Palette['--bg-1']) -ge $floor -and (Get-ApcaContrast $c $Palette['--bg-3']) -ge $floor }
    if (& $reads $Hex) { return $Hex }
    $o = ConvertTo-OkLch $Hex
    if ($Mode -eq 'dark') { $lo = $o.L; $hi = 1.0 } else { $lo = 0.0; $hi = $o.L }
    for ($i = 0; $i -lt 30; $i++) {
        $mid = ($lo + $hi) / 2
        $ok = & $reads (ConvertFrom-OkLch $mid $o.C $o.H)
        if ($Mode -eq 'dark') { if ($ok) { $hi = $mid } else { $lo = $mid } } else { if ($ok) { $lo = $mid } else { $hi = $mid } }
    }
    ConvertFrom-OkLch $(if ($Mode -eq 'dark') { $hi } else { $lo }) $o.C $o.H
}

function Get-HouseGraphPool {
    <# The candidates, in order of preference: the first three a theme accepts are its --graph-1..3. Blue, purple-magenta
       and deep teal first, then a wine and a violet for the themes whose primary sits on one of them. None is red, orange,
       yellow or green: those hues are the status colours. Searched with the dataviz validator's measures (November 12,
       2026) so that every theme gets three. The dark pool was searched again for APCA Lc 45 on bg-1 and bg-3 the same
       day: a blue, a pink-magenta far enough from the blue for a protan or deutan reader, a teal, then a mauve, a
       periwinkle, an aqua, a light pink and a light sky for the themes whose pastel primary rules out the first ones. #>
    param([ValidateSet('light', 'dark')][string]$Mode)
    if ($Mode -eq 'light') { @('#2574d1', '#a63aa8', '#007c6e', '#8b0f49', '#5c2f95') }
    else                   { @('#1f8fff', '#ff9ee0', '#00beae', '#c190cc', '#9499fa', '#52fce8', '#ffcafc', '#a2ecff') }
}

function Get-HouseGraphStatus {
    <# The status fills a graph slot must stay away from: positive, negative and warning, the theme overrides of the
       warning included (#b88a00 in rust, #f08a24 in yellow). #>
    param([ValidateSet('light', 'dark')][string]$Mode)
    if ($Mode -eq 'light') { @('#0ca30c', '#d03b3b', '#e0761a', '#b88a00') } else { @('#25b225', '#e66767', '#ffc61a', '#f08a24') }
}

function Get-HouseGraphSlots {
    <# The three graph slots of a theme: the pool walked in order, each candidate first lifted to OnPaperLc on bg-1 and
       bg-3 (Get-HouseGraphLifted), then kept when it stands FromPrimary off the primary, FromStatus off every status
       fill, reads at OnPaper on bg-1 and bg-3, and stands FromSlot (and FromSlotCvd for a protan or deutan reader) off
       every slot already kept. Throws when fewer than three remain. #>
    param([Parameter(Mandatory)]$Palette, [Parameter(Mandatory)][ValidateSet('light', 'dark')][string]$Mode)
    $r = Get-HouseGraphRules; $status = Get-HouseGraphStatus -Mode $Mode
    # every candidate, lifted, that passes on its own; then the first trio in pool order whose members stand apart.
    # A first-come walk kept the first that fit and could not go back, which strands a theme once lifting brings the
    # candidates closer together: the earliest pair can rule out every third while a later pair has room for one.
    $ok = @(foreach ($pc in Get-HouseGraphPool -Mode $Mode) {
        $c = Get-HouseGraphLifted -Hex $pc -Palette $Palette -Mode $Mode
        if ((Get-OkLabDeltaE $c $Palette['--primary']) -lt $r.FromPrimary) { continue }
        if (@($status | Where-Object { (Get-OkLabDeltaE $c $_) -lt $r.FromStatus }).Count) { continue }
        if ((Get-ContrastRatio $c $Palette['--bg-1']) -lt $r.OnPaper -or (Get-ContrastRatio $c $Palette['--bg-3']) -lt $r.OnPaper) { continue }
        $c
    })
    $apart = { param($x, $y) (Get-OkLabDeltaE $x $y) -ge $r.FromSlot -and (Get-OkLabCvdDeltaE $x $y) -ge $r.FromSlotCvd }
    for ($i = 0; $i -lt $ok.Count; $i++) { for ($j = $i + 1; $j -lt $ok.Count; $j++) {
        if (-not (& $apart $ok[$i] $ok[$j])) { continue }
        for ($k = $j + 1; $k -lt $ok.Count; $k++) {
            if ((& $apart $ok[$i] $ok[$k]) -and (& $apart $ok[$j] $ok[$k])) { return @($ok[$i], $ok[$j], $ok[$k]) }
        }
    } }
    throw "no three graph slots stand apart for primary $($Palette['--primary']) ($Mode); $($ok.Count) candidate(s) pass on their own"
}

# ---- the palette ----------------------------------------------------------------------------------------------
function Get-HousePalette {
    <# The seventeen tokens of one theme, as an ordered map of token name to #rrggbb. #>
    param([Parameter(Mandatory)][double]$Hue, [Parameter(Mandatory)][ValidateSet('light', 'dark')][string]$Mode, [double]$ChromaMax = 0)
    $steps = Get-HousePaletteSteps -Mode $Mode
    if ($ChromaMax -gt 0) { $steps.PrimaryChromaMax = $ChromaMax }
    $okHue = (ConvertTo-OkLch (ConvertFrom-Hsl $Hue 1 0.5)).H
    $paper = 0..4 | ForEach-Object { ConvertFrom-OkLch $steps.PaperL[$_] $steps.PaperC[$_] $okHue }
    $fg    = 0..3 | ForEach-Object { ConvertFrom-OkLch $steps.FgL[$_] $steps.FgC[$_] $okHue }

    # the primary: HSL saturation 100%, the lightness closest to 50% that still reaches the mode's floor on the
    # furthest paper step (4.55:1 on light, 9:1 on dark)
    $makePrimary = { param($l) ConvertFrom-Hsl $Hue 1 $l }.GetNewClosure()
    if ($Mode -eq 'light') { $primary = Find-LightnessAtContrast $makePrimary $paper[3] $steps.PrimaryFloor 0 0.5 'high' }
    else                   { $primary = Find-LightnessAtContrast $makePrimary $paper[3] $steps.PrimaryFloor 0.5 1 'low' }
    if ($steps.PrimaryChromaMax -and (ConvertTo-OkLch $primary).C -gt $steps.PrimaryChromaMax) {
        $cap = $steps.PrimaryChromaMax; $capHue = (ConvertTo-OkLch $primary).H
        $makeCapped = { param($l) ConvertFrom-OkLch $l $cap $capHue }.GetNewClosure()
        $primary = Find-LightnessAtContrast $makeCapped $paper[3] $steps.PrimaryFloor 0 1 'low'
    }

    # the grey: as close to its ground as 7:1 allows, so it recedes by colour while still reading extra well
    $mc = $steps.MutedC
    # In the primary's OWN hue (Maikel, November 1, 2026): a dark primary is lightened in HSL, which drifts its OKLCH hue
    # (Lila from 292 to 307), and a grey left at the base hue read blue beside a violet primary.
    $mutedHue = (ConvertTo-OkLch $primary).H
    $makeMuted = { param($l) ConvertFrom-OkLch $l $mc $mutedHue }.GetNewClosure()
    if ($Mode -eq 'light') {
        $muted   = Find-LightnessAtContrast $makeMuted $paper[0] 7.05 0 1 'high'
    } else {
        $muted   = Find-LightnessAtContrast $makeMuted $paper[0] 7.05 0 1 'low'
    }

    $p = [ordered]@{}
    for ($i = 0; $i -lt 5; $i++) { $p["--bg-$($i + 1)"] = $paper[$i] }
    $p['--primary'] = $primary
    $p['--primary-muted'] = $muted
    # the primary's two shades, fills rather than text (Maikel, November 1, 2026): 15% of the way to the page and to
    # the text. A rule reads them; it never derives them with color-mix().
    $p['--primary-raised'] = Get-SrgbMix $primary $paper[0] 0.15
    $p['--primary-hover']  = Get-SrgbMix $primary $fg[0] 0.15
    # the control edge, a member of the primary group (the 10) (owner, November 12, 2026): a grey of the primary's own hue at the muted grey's
    # chroma, as close to the paper as 3:1 on bg-3 allows (WCAG 1.4.11, non-text contrast), so a button, a segmented
    # control or a search field shows its boundary on the page, on a card and on a card in a group. bg-3 and bg-4 stay
    # the quiet lines between surfaces.
    $makeBorder = { param($l) ConvertFrom-OkLch $l $mc $mutedHue }.GetNewClosure()
    if ($Mode -eq 'light') { $p['--primary-border'] = Find-LightnessAtContrast $makeBorder $paper[2] 3.05 0 1 'high' }
    else                   { $p['--primary-border'] = Find-LightnessAtContrast $makeBorder $paper[2] 3.05 0 1 'low' }
    for ($i = 0; $i -lt 4; $i++) { $p["--fg-$($i + 1)"] = $fg[$i] }
    # the three series colours, per theme (the owner, November 12, 2026): away from this theme's primary and the status hues
    $g = Get-HouseGraphSlots -Palette $p -Mode $Mode
    for ($i = 0; $i -lt 3; $i++) { $p["--graph-$($i + 1)"] = $g[$i] }
    $p
}

function Format-HousePaletteDeclarations {
    <# The seventeen tokens as one line of CSS declarations, in the stylesheet's order. #>
    param([Parameter(Mandatory)]$Palette)
    ($Palette.Keys | ForEach-Object { "$($_): $($Palette[$_]);" }) -join ' '
}

function Get-HousePaletteContrast {
    <# The pairings the model promises, each with its ratio and the floor it must reach. #>
    param([Parameter(Mandatory)]$Palette)
    $rows = @()
    foreach ($n in 1..4) { $rows += @{ Pair = "primary on bg-$n"; Ratio = Get-ContrastRatio $Palette['--primary'] $Palette["--bg-$n"]; Floor = 4.5 } }
    foreach ($n in 1..4) { foreach ($k in 1..4) { $rows += @{ Pair = "fg-$n on bg-$k"; Ratio = Get-ContrastRatio $Palette["--fg-$n"] $Palette["--bg-$k"]; Floor = 7 } } }
    $rows += @{ Pair = 'muted on bg-1'; Ratio = Get-ContrastRatio $Palette['--primary-muted'] $Palette['--bg-1']; Floor = 7 }
    $rows += @{ Pair = 'muted on bg-2'; Ratio = Get-ContrastRatio $Palette['--primary-muted'] $Palette['--bg-2']; Floor = 4.5 }
    $rows += @{ Pair = 'muted on bg-4'; Ratio = Get-ContrastRatio $Palette['--primary-muted'] $Palette['--bg-4']; Floor = 4.5 }
    $rows += @{ Pair = 'bg-4 on fg-1'; Ratio = Get-ContrastRatio $Palette['--bg-4'] $Palette['--fg-1']; Floor = 7 }
    foreach ($n in 1..3) { foreach ($k in @(1, 3)) { $rows += @{ Pair = "graph-$n on bg-$k"; Ratio = Get-ContrastRatio $Palette["--graph-$n"] $Palette["--bg-$k"]; Floor = 3 } } }
    $lc = (Get-HouseGraphRules).OnPaperLc
    foreach ($n in 1..3) { foreach ($k in @(1, 3)) { $rows += @{ Pair = "graph-$n on bg-$k (APCA)"; Ratio = Get-ApcaContrast $Palette["--graph-$n"] $Palette["--bg-$k"]; Floor = $lc; Unit = 'Lc' } } }
    foreach ($n in 1..3) { $rows += @{ Pair = "primary-border on bg-$n"; Ratio = Get-ContrastRatio $Palette['--primary-border'] $Palette["--bg-$n"]; Floor = 3 } }
    $rows += @{ Pair = 'bg-1 on muted'; Ratio = Get-ContrastRatio $Palette['--bg-1'] $Palette['--primary-muted']; Floor = 4.5 }
    $rows
}
