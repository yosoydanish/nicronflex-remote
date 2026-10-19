# Icone do app Nicronflex Remote: "N" geometrico moderno.
# Uso: make_app_icon.ps1 -Variant a|b|c -OutDir <pasta> [-Sizes 1024,256,...]
param(
  [ValidateSet('a', 'b', 'c')][string]$Variant = 'a',
  [string]$OutDir = (Join-Path $PSScriptRoot 'out'),
  [int[]]$Sizes = @(1024, 512, 256, 192, 128, 96, 64, 48, 32, 24, 16),
  [switch]$Transparent,
  [string]$Prefix = 'app'
)
Add-Type -AssemblyName System.Drawing
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function C([string]$hex, [int]$a = 255) {
  $v = [Convert]::ToInt32($hex.TrimStart('#'), 16)
  [Drawing.Color]::FromArgb($a, ($v -shr 16) -band 255, ($v -shr 8) -band 255, $v -band 255)
}
function RoundRectPath([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
  $p = New-Object Drawing.Drawing2D.GraphicsPath; $d = 2 * $r
  $p.AddArc($x, $y, $d, $d, 180, 90); $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90); $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $p.CloseFigure(); $p
}
function Poly([float[]]$pts, [float]$s) {
  $p = New-Object Drawing.Drawing2D.GraphicsPath
  $arr = for ($i = 0; $i -lt $pts.Length; $i += 2) { [Drawing.PointF]::new($pts[$i] * $s, $pts[$i + 1] * $s) }
  $p.AddPolygon([Drawing.PointF[]]$arr); $p
}
function Grad($c1, $c2, [float]$s, [float]$y1 = 0, [float]$y2 = 1024) {
  New-Object Drawing.Drawing2D.LinearGradientBrush ([Drawing.PointF]::new(0, $y1 * $s)), ([Drawing.PointF]::new(0, $y2 * $s)), $c1, $c2
}

$wineHi = C '#A3232A'; $wineLo = C '#4A070B'
$goldHi = C '#F3D886'; $goldLo = C '#B88A2C'; $goldDark = C '#8C6418'
$cream = C '#FFF6E2'; $creamLo = C '#EADBB8'

foreach ($size in $Sizes) {
  $s = $size / 1024.0
  $bmp = New-Object Drawing.Bitmap $size, $size, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'; $g.PixelOffsetMode = 'HighQuality'

  # Geometria do N (em 1024): mais grosso nos tamanhos pequenos
  $w = if ($size -le 32) { 170 } else { 140 }
  $x0 = if ($size -le 32) { 250 } else { 292 }; $x1 = 1024 - $x0
  $y0 = if ($size -le 32) { 230 } else { 262 }; $y1 = 1024 - $y0
  $left = Poly @($x0, $y0, ($x0 + $w), $y0, ($x0 + $w), $y1, $x0, $y1) $s
  $right = Poly @(($x1 - $w), $y0, $x1, $y0, $x1, $y1, ($x1 - $w), $y1) $s
  $diag = Poly @($x0, $y0, ($x0 + $w), $y0, $x1, $y1, ($x1 - $w), $y1) $s
  $bgPath = RoundRectPath (16 * $s) (16 * $s) (992 * $s) (992 * $s) (230 * $s)

  $small = $size -le 32
  $bgBrush = New-Object Drawing.Drawing2D.LinearGradientBrush ([Drawing.PointF]::new(0, 0)), ([Drawing.PointF]::new($size, $size)), $wineHi, $wineLo
  $hex = { param([float]$r, [float]$cy)
    $pts = foreach ($k in 0..5) { $a = [Math]::PI / 180 * (-90 + 60 * $k); @((512 + $r * [Math]::Cos($a)), ($cy + $r * [Math]::Sin($a))) }
    Poly ([float[]]$pts) $s }
  # N em traco unico com pontas arredondadas
  $drawN = { param($brush, [float]$cx, [float]$cy, [float]$hw, [float]$hh, [float]$stroke)
    $pen = New-Object Drawing.Pen $brush, ([float]($stroke * $s))
    $pen.StartCap = 'Round'; $pen.EndCap = 'Round'; $pen.LineJoin = 'Round'
    $pts = [Drawing.PointF[]]@(
      [Drawing.PointF]::new(($cx - $hw) * $s, ($cy + $hh) * $s), [Drawing.PointF]::new(($cx - $hw) * $s, ($cy - $hh) * $s),
      [Drawing.PointF]::new(($cx + $hw) * $s, ($cy + $hh) * $s), [Drawing.PointF]::new(($cx + $hw) * $s, ($cy - $hh) * $s))
    $g.DrawLines($pen, $pts) }

  switch ($Variant) {
    'a' { # vinho + hexagono dourado vazado + N dourado
      if (-not $Transparent) { $g.FillPath($bgBrush, $bgPath) }
      $gold = Grad $goldHi $goldLo $s 100 924
      if (-not $small) { $g.DrawPath((New-Object Drawing.Pen $gold, ([float](34 * $s))), (& $hex 372 512)) }
      if ($small) { & $drawN $gold 512 512 230 270 150 } else { & $drawN $gold 512 512 140 175 92 }
    }
    'b' { # vinho + hexagono dourado cheio + N vinho
      $g.FillPath($bgBrush, $bgPath)
      $g.FillPath((Grad $goldHi $goldLo $s 140 880), (& $hex $(if ($small) { 450 } else { 390 }) 512))
      $wine = Grad $wineHi $wineLo $s 300 720
      if ($small) { & $drawN $wine 512 512 160 190 120 } else { & $drawN $wine 512 512 138 172 88 }
    }
    'c' { # vinho + N em traco unico, dourado
      $g.FillPath($bgBrush, $bgPath)
      $gold = Grad $goldHi $goldLo $s 220 800
      if ($small) { & $drawN $gold 512 512 240 275 160 } else { & $drawN $gold 512 512 205 255 128 }
    }
  }
  $g.Dispose()
  $bmp.Save((Join-Path $OutDir "$Prefix-$Variant-$size.png")); $bmp.Dispose()
}
"ok $Variant"
