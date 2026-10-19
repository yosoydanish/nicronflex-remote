# Gera os icones do Nicronflex Remote a partir do logotipo original.
param(
  [string]$Source = 'C:\Users\Daniel\Downloads\ANYDESK\NicronflexRemote\marca\logo-original-nicronflex.png',
  [string]$OutDir = (Join-Path $PSScriptRoot 'out')
)
Add-Type -AssemblyName System.Drawing
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function Remove-White([Drawing.Bitmap]$img, [Drawing.Rectangle]$r) {
  $o = New-Object Drawing.Bitmap $r.Width, $r.Height, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
  for ($y = 0; $y -lt $r.Height; $y++) {
    for ($x = 0; $x -lt $r.Width; $x++) {
      $c = $img.GetPixel($r.X + $x, $r.Y + $y)
      $m = [Math]::Min($c.R, [Math]::Min($c.G, $c.B))
      $a = (255 - $m) / 255.0
      if ($a -lt 0.04) { $o.SetPixel($x, $y, [Drawing.Color]::Transparent); continue }
      $f = { param($v) [int][Math]::Max(0, [Math]::Min(255, ($v - (1 - $a) * 255) / $a)) }
      $o.SetPixel($x, $y, [Drawing.Color]::FromArgb([int]($a * 255), (& $f $c.R), (& $f $c.G), (& $f $c.B)))
    }
  }
  return $o
}

function New-Canvas([int]$size) {
  $bmp = New-Object Drawing.Bitmap $size, $size, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'; $g.InterpolationMode = 'HighQualityBicubic'; $g.PixelOffsetMode = 'HighQuality'
  return @($bmp, $g)
}

function Add-RoundRect($g, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r, $brush) {
  $p = New-Object Drawing.Drawing2D.GraphicsPath
  $d = 2 * $r
  $p.AddArc($x, $y, $d, $d, 180, 90); $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90); $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $p.CloseFigure(); $g.FillPath($brush, $p)
}

function Draw-Fit($g, $img, [float]$cx, [float]$cy, [float]$maxW, [float]$maxH) {
  $s = [Math]::Min($maxW / $img.Width, $maxH / $img.Height)
  $w = $img.Width * $s; $h = $img.Height * $s
  $g.DrawImage($img, [Drawing.RectangleF]::new($cx - $w / 2, $cy - $h / 2, $w, $h))
}

$src = [Drawing.Bitmap]::FromFile($Source)
# Aguia (acima do texto) e escudo (centro dourado), com margem
$eagle = Remove-White $src ([Drawing.Rectangle]::new(111, 74, 312, 157))
$eagle.Save((Join-Path $OutDir 'eagle.png'))

# Escudo: pixels dourados no centro da aguia
$minX = 9999; $minY = 9999; $maxX = 0; $maxY = 0
for ($y = 74; $y -lt 231; $y++) { for ($x = 200; $x -lt 330; $x++) {
  $c = $src.GetPixel($x, $y)
  if ($c.R -gt 150 -and $c.G -gt 110 -and $c.B -lt 120 -and ($c.R - $c.B) -gt 60) {
    if ($x -lt $minX) { $minX = $x }; if ($x -gt $maxX) { $maxX = $x }; if ($y -lt $minY) { $minY = $y }; if ($y -gt $maxY) { $maxY = $y } } } }
$shield = Remove-White $src ([Drawing.Rectangle]::new($minX - 3, $minY - 3, $maxX - $minX + 7, $maxY - $minY + 7))
$shield.Save((Join-Path $OutDir 'shield.png'))
"escudo: x $minX-$maxX y $minY-$maxY"

$cream1 = [Drawing.Color]::FromArgb(255, 255, 253, 247); $cream2 = [Drawing.Color]::FromArgb(255, 243, 233, 210)
$wine1 = [Drawing.Color]::FromArgb(255, 142, 27, 32); $wine2 = [Drawing.Color]::FromArgb(255, 90, 11, 14)

# Icone principal (aguia sobre creme), tamanhos grandes
foreach ($size in 1024, 512, 256, 192, 128, 96, 64, 48) {
  $bmp, $g = New-Canvas $size
  $m = $size * 0.03
  $br = New-Object Drawing.Drawing2D.LinearGradientBrush ([Drawing.PointF]::new(0, 0)), ([Drawing.PointF]::new(0, $size)), $cream1, $cream2
  Add-RoundRect $g $m $m ($size - 2 * $m) ($size - 2 * $m) ($size * 0.21) $br
  Draw-Fit $g $eagle ($size / 2) ($size * 0.5) ($size * 0.86) ($size * 0.70)
  $g.Dispose(); $bmp.Save((Join-Path $OutDir "icon-$size.png")); $bmp.Dispose()
}

# Icone pequeno (escudo original sobre vinho)
foreach ($size in 256, 64, 48, 32, 24, 16) {
  $bmp, $g = New-Canvas $size
  $m = [Math]::Max(1, $size * 0.03)
  $br = New-Object Drawing.Drawing2D.LinearGradientBrush ([Drawing.PointF]::new(0, 0)), ([Drawing.PointF]::new(0, $size)), $wine1, $wine2
  Add-RoundRect $g $m $m ($size - 2 * $m) ($size - 2 * $m) ($size * 0.21) $br
  Draw-Fit $g $shield ($size / 2) ($size / 2) ($size * 0.72) ($size * 0.80)
  $g.Dispose(); $bmp.Save((Join-Path $OutDir "small-$size.png")); $bmp.Dispose()
}
# Icone do app: "N" dourado sobre vinho
$goldA = [Drawing.Color]::FromArgb(255, 240, 210, 122); $goldB = [Drawing.Color]::FromArgb(255, 176, 138, 44)
$fontName = @('Palatino Linotype', 'Book Antiqua', 'Georgia') | Where-Object { (New-Object Drawing.FontFamily $_ -ErrorAction SilentlyContinue) } | Select-Object -First 1
foreach ($size in 1024, 512, 256, 192, 128, 96, 64, 48, 32, 24, 16) {
  $bmp, $g = New-Canvas $size
  $g.TextRenderingHint = 'AntiAliasGridFit'
  $m = [Math]::Max(0.5, $size * 0.03)
  $br = New-Object Drawing.Drawing2D.LinearGradientBrush ([Drawing.PointF]::new(0, 0)), ([Drawing.PointF]::new(0, $size)), $wine1, $wine2
  Add-RoundRect $g $m $m ($size - 2 * $m) ($size - 2 * $m) ($size * 0.21) $br
  if ($size -ge 48) {
    $inset = $size * 0.075
    $pen = New-Object Drawing.Pen ([Drawing.Color]::FromArgb(150, 201, 168, 76)), ([float]($size * 0.012))
    $p = New-Object Drawing.Drawing2D.GraphicsPath
    $r = $size * 0.16; $d = 2 * $r; $w = $size - 2 * $inset
    $p.AddArc($inset, $inset, $d, $d, 180, 90); $p.AddArc($inset + $w - $d, $inset, $d, $d, 270, 90)
    $p.AddArc($inset + $w - $d, $inset + $w - $d, $d, $d, 0, 90); $p.AddArc($inset, $inset + $w - $d, $d, $d, 90, 90)
    $p.CloseFigure(); $g.DrawPath($pen, $p)
  }
  $path = New-Object Drawing.Drawing2D.GraphicsPath
  $fam = New-Object Drawing.FontFamily $fontName
  $path.AddString('N', $fam, [int][Drawing.FontStyle]::Bold, [float]($size * $(if ($size -le 32) { 0.90 } else { 0.70 })), [Drawing.PointF]::new(0, 0), [Drawing.StringFormat]::GenericTypographic)
  $bb = $path.GetBounds()
  $mx = New-Object Drawing.Drawing2D.Matrix
  $mx.Translate([float]($size / 2 - ($bb.X + $bb.Width / 2)), [float]($size / 2 - ($bb.Y + $bb.Height / 2)))
  $path.Transform($mx)
  $gb = New-Object Drawing.Drawing2D.LinearGradientBrush ([Drawing.PointF]::new(0, $size * 0.2)), ([Drawing.PointF]::new(0, $size * 0.8)), $goldA, $goldB
  $g.FillPath($gb, $path)
  $g.Dispose(); $bmp.Save((Join-Path $OutDir "app-$size.png")); $bmp.Dispose()
}
"fonte do N: $fontName"

$src.Dispose(); $eagle.Dispose(); $shield.Dispose()
"ok: $OutDir"
