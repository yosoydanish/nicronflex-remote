# Gera os arquivos finais de marca do Nicronflex Remote e copia para o projeto.
param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
Add-Type -AssemblyName System.Drawing
$here = $PSScriptRoot
$out = Join-Path $here 'out\final'
New-Item -ItemType Directory -Force -Path $out | Out-Null

& (Join-Path $here 'make_app_icon.ps1') -Variant a -OutDir $out -Sizes 1024, 512, 432, 324, 256, 216, 192, 162, 144, 128, 108, 96, 72, 64, 48, 32, 24, 16 | Out-Null
& (Join-Path $here 'make_app_icon.ps1') -Variant a -OutDir $out -Sizes 1024 -Transparent -Prefix fg | Out-Null
$tagline = 'SEGURAN' + [char]0xC7 + 'A ELETR' + [char]0xD4 + 'NICA'

function Save-Ico([string]$path, [int[]]$sizes) {
  $pngs = foreach ($s in $sizes) { , [IO.File]::ReadAllBytes((Join-Path $out "app-a-$s.png")) }
  $ms = New-Object IO.MemoryStream; $bw = New-Object IO.BinaryWriter $ms
  $bw.Write([uint16]0); $bw.Write([uint16]1); $bw.Write([uint16]$sizes.Count)
  $offset = 6 + 16 * $sizes.Count
  for ($i = 0; $i -lt $sizes.Count; $i++) {
    $s = $sizes[$i]; $b = if ($s -ge 256) { 0 } else { $s }
    $bw.Write([byte]$b); $bw.Write([byte]$b); $bw.Write([byte]0); $bw.Write([byte]0)
    $bw.Write([uint16]1); $bw.Write([uint16]32); $bw.Write([uint32]$pngs[$i].Length); $bw.Write([uint32]$offset)
    $offset += $pngs[$i].Length
  }
  foreach ($p in $pngs) { $bw.Write($p) }
  $bw.Flush(); [IO.File]::WriteAllBytes($path, $ms.ToArray())
}

function Resize-To([string]$srcPng, [int]$size, [string]$dst) {
  $src = [Drawing.Image]::FromFile($srcPng)
  $bmp = New-Object Drawing.Bitmap $size, $size, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [Drawing.Graphics]::FromImage($bmp); $g.InterpolationMode = 'HighQualityBicubic'; $g.PixelOffsetMode = 'HighQuality'
  $g.DrawImage($src, 0, 0, $size, $size); $g.Dispose(); $src.Dispose()
  $bmp.Save($dst); $bmp.Dispose()
}

# --- Windows / geral ---
Save-Ico (Join-Path $Repo 'res\icon.ico') @(16, 24, 32, 48, 64, 128, 256)
Save-Ico (Join-Path $Repo 'res\tray-icon.ico') @(16, 24, 32, 48)
Save-Ico (Join-Path $Repo 'flutter\windows\runner\resources\app_icon.ico') @(16, 24, 32, 48, 64, 128, 256)
Copy-Item (Join-Path $out 'app-a-1024.png') (Join-Path $Repo 'res\icon.png') -Force
Copy-Item (Join-Path $out 'app-a-1024.png') (Join-Path $Repo 'res\mac-icon.png') -Force
Copy-Item (Join-Path $out 'app-a-32.png') (Join-Path $Repo 'res\32x32.png') -Force
Copy-Item (Join-Path $out 'app-a-64.png') (Join-Path $Repo 'res\64x64.png') -Force
Copy-Item (Join-Path $out 'app-a-128.png') (Join-Path $Repo 'res\128x128.png') -Force
Copy-Item (Join-Path $out 'app-a-256.png') (Join-Path $Repo 'res\128x128@2x.png') -Force
Copy-Item (Join-Path $here 'icon.svg') (Join-Path $Repo 'res\scalable.svg') -Force
Copy-Item (Join-Path $here 'icon.svg') (Join-Path $Repo 'flutter\assets\icon.svg') -Force
Copy-Item (Join-Path $out 'app-a-256.png') (Join-Path $Repo 'flutter\assets\icon.png') -Force

# --- Logotipo da tela inicial: aguia + nome (600x120, exibido em ate 300x60) ---
$eagle = [Drawing.Image]::FromFile((Join-Path $here 'out\eagle.png'))
foreach ($v in @(@{ n = 'logo_light.png'; t = '#6B0F12'; s = '#9C7A26' }, @{ n = 'logo_dark.png'; t = '#F6E7C1'; s = '#D9B85E' }, @{ n = 'logo.png'; t = '#6B0F12'; s = '#9C7A26' })) {
  $bmp = New-Object Drawing.Bitmap 600, 120, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'; $g.InterpolationMode = 'HighQualityBicubic'; $g.TextRenderingHint = 'AntiAliasGridFit'
  $eh = 104; $ew = [int]($eagle.Width * $eh / $eagle.Height)
  $g.DrawImage($eagle, 0, 8, $ew, $eh)
  $tc = [Drawing.ColorTranslator]::FromHtml($v.t); $sc = [Drawing.ColorTranslator]::FromHtml($v.s)
  $g.DrawString('Nicronflex Remote', (New-Object Drawing.Font 'Segoe UI Semibold', 38, ([Drawing.GraphicsUnit]::Pixel)), (New-Object Drawing.SolidBrush $tc), [float]($ew + 14), [float]22)
  $g.DrawString($tagline,(New-Object Drawing.Font 'Segoe UI', 17, ([Drawing.GraphicsUnit]::Pixel)), (New-Object Drawing.SolidBrush $sc), [float]($ew + 18), [float]72)
  $g.Dispose(); $bmp.Save((Join-Path $Repo "flutter\assets\$($v.n)")); $bmp.Dispose()
}
$eagle.Dispose()

# --- Android ---
$res = Join-Path $Repo 'flutter\android\app\src\main\res'
$dens = @{ 'mdpi' = 1; 'hdpi' = 1.5; 'xhdpi' = 2; 'xxhdpi' = 3; 'xxxhdpi' = 4 }
foreach ($d in $dens.Keys) {
  $f = $dens[$d]; $dir = Join-Path $res "mipmap-$d"
  Copy-Item (Join-Path $out ("app-a-{0}.png" -f [int](48 * $f))) (Join-Path $dir 'ic_launcher.png') -Force
  Copy-Item (Join-Path $out ("app-a-{0}.png" -f [int](48 * $f))) (Join-Path $dir 'ic_launcher_round.png') -Force
  # Primeiro plano adaptativo (108dp): hexagono + N centralizados na area segura, fundo transparente
  $fs = [int](108 * $f)
  $bmp = New-Object Drawing.Bitmap $fs, $fs, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [Drawing.Graphics]::FromImage($bmp); $g.InterpolationMode = 'HighQualityBicubic'; $g.PixelOffsetMode = 'HighQuality'
  $src = [Drawing.Image]::FromFile((Join-Path $out 'fg-a-1024.png'))
  $inner = [int]($fs * 0.80)
  $g.DrawImage($src, [int](($fs - $inner) / 2), [int](($fs - $inner) / 2), $inner, $inner)
  $g.Dispose(); $src.Dispose()
  $bmp.Save((Join-Path $dir 'ic_launcher_foreground.png')); $bmp.Dispose()
  # Icone de notificacao: silhueta branca
  $ns = [int](24 * $f)
  $bmp = New-Object Drawing.Bitmap $ns, $ns, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode = 'AntiAlias'
  $k = $ns / 24.0
  $pen = New-Object Drawing.Pen ([Drawing.Color]::White), ([float](2.2 * $k * 1.0))
  $hex = foreach ($i in 0..5) { $a = [Math]::PI / 180 * (-90 + 60 * $i); [Drawing.PointF]::new(12 * $k + 10.6 * $k * [Math]::Cos($a), 12 * $k + 10.6 * $k * [Math]::Sin($a)) }
  $g.DrawPolygon($pen, [Drawing.PointF[]]$hex)
  $np = New-Object Drawing.Pen ([Drawing.Color]::White), ([float](2.8 * $k)); $np.StartCap = 'Round'; $np.EndCap = 'Round'; $np.LineJoin = 'Round'
  $g.DrawLines($np, [Drawing.PointF[]]@([Drawing.PointF]::new(8.6 * $k, 16.4 * $k), [Drawing.PointF]::new(8.6 * $k, 7.6 * $k), [Drawing.PointF]::new(15.4 * $k, 16.4 * $k), [Drawing.PointF]::new(15.4 * $k, 7.6 * $k)))
  $g.Dispose(); $bmp.Save((Join-Path $dir 'ic_stat_logo.png')); $bmp.Dispose()
}
"ok"
