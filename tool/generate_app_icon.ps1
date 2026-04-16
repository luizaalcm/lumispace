$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

function New-RoundedRectPath {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [float]$Radius
    )

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $Radius * 2

    $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
    $path.AddArc($X + $Width - $diameter, $Y, $diameter, $diameter, 270, 90)
    $path.AddArc($X + $Width - $diameter, $Y + $Height - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($X, $Y + $Height - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function Draw-GlowCircle {
    param(
        [System.Drawing.Graphics]$Graphics,
        [float]$CenterX,
        [float]$CenterY,
        [float]$Diameter,
        [System.Drawing.Color]$CenterColor,
        [System.Drawing.Color]$OuterColor
    )

    $rect = New-Object System.Drawing.RectangleF(
        ($CenterX - ($Diameter / 2)),
        ($CenterY - ($Diameter / 2)),
        $Diameter,
        $Diameter
    )

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse($rect)
    $brush = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
    $brush.CenterColor = $CenterColor
    $brush.SurroundColors = [System.Drawing.Color[]]@($OuterColor)
    $Graphics.FillEllipse($brush, $rect)
    $brush.Dispose()
    $path.Dispose()
}

function Draw-StarGlow {
    param(
        [System.Drawing.Graphics]$Graphics,
        [float]$CenterX,
        [float]$CenterY,
        [float]$OuterRadius,
        [float]$InnerRadius,
        [System.Drawing.Color]$Color
    )

    $points = New-Object 'System.Collections.Generic.List[System.Drawing.PointF]'
    for ($i = 0; $i -lt 8; $i++) {
        $angle = (-90 + ($i * 45)) * [Math]::PI / 180
        $radius = if ($i % 2 -eq 0) { $OuterRadius } else { $InnerRadius }
        $x = $CenterX + ([Math]::Cos($angle) * $radius)
        $y = $CenterY + ([Math]::Sin($angle) * $radius)
        $points.Add((New-Object System.Drawing.PointF($x, $y)))
    }

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddPolygon($points.ToArray())
    $brush = New-Object System.Drawing.SolidBrush($Color)
    $Graphics.FillPath($brush, $path)
    $brush.Dispose()
    $path.Dispose()
}

function Resize-Image {
    param(
        [string]$SourcePath,
        [int]$Size,
        [string]$DestinationPath
    )

    $source = [System.Drawing.Image]::FromFile($SourcePath)
    $bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.DrawImage($source, 0, 0, $Size, $Size)
    $bitmap.Save($DestinationPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
    $source.Dispose()
}

$root = Resolve-Path "$PSScriptRoot\.."
$previewDir = Join-Path $root 'assets\icon'
$androidRes = Join-Path $root 'android\app\src\main\res'
$iosIconDir = Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset'

New-Item -ItemType Directory -Force -Path $previewDir | Out-Null

$basePath = Join-Path $previewDir 'lumispace_app_icon_1024.png'
$previewPath = Join-Path $previewDir 'lumispace_app_icon_preview.png'

$size = 1024
$bitmap = New-Object System.Drawing.Bitmap($size, $size)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$graphics.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))

$outerGlow = New-Object System.Drawing.RectangleF(36, 36, 952, 952)
$glowBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    ([System.Drawing.Rectangle]::Round($outerGlow)),
    [System.Drawing.Color]::FromArgb(90, 243, 220, 255),
    [System.Drawing.Color]::FromArgb(110, 255, 236, 248),
    45
)
$graphics.FillEllipse($glowBrush, $outerGlow)
$glowBrush.Dispose()

$cardPath = New-RoundedRectPath -X 110 -Y 110 -Width 804 -Height 804 -Radius 170
$cardBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    ([System.Drawing.Rectangle]::new(110, 110, 804, 804)),
    [System.Drawing.Color]::FromArgb(255, 88, 48, 190),
    [System.Drawing.Color]::FromArgb(255, 179, 156, 255),
    45
)
$graphics.FillPath($cardBrush, $cardPath)
$cardBrush.Dispose()

$overlayBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    ([System.Drawing.Rectangle]::new(110, 110, 804, 804)),
    [System.Drawing.Color]::FromArgb(110, 255, 255, 255),
    [System.Drawing.Color]::FromArgb(60, 168, 214, 255),
    135
)
$graphics.FillPath($overlayBrush, $cardPath)
$overlayBrush.Dispose()

$borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, 255, 248, 255), 8)
$graphics.DrawPath($borderPen, $cardPath)
$borderPen.Dispose()
$cardPath.Dispose()

Draw-GlowCircle -Graphics $graphics -CenterX 512 -CenterY 512 -Diameter 560 `
    -CenterColor ([System.Drawing.Color]::FromArgb(32, 255, 255, 255)) `
    -OuterColor ([System.Drawing.Color]::FromArgb(0, 255, 255, 255))
Draw-GlowCircle -Graphics $graphics -CenterX 512 -CenterY 512 -Diameter 390 `
    -CenterColor ([System.Drawing.Color]::FromArgb(55, 255, 255, 255)) `
    -OuterColor ([System.Drawing.Color]::FromArgb(0, 255, 255, 255))

$haloPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(58, 255, 255, 255), 18)
$graphics.DrawEllipse($haloPen, 260, 260, 504, 504)
$haloPen.Color = [System.Drawing.Color]::FromArgb(72, 255, 255, 255)
$haloPen.Width = 10
$graphics.DrawEllipse($haloPen, 330, 330, 364, 364)
$haloPen.Dispose()

Draw-StarGlow -Graphics $graphics -CenterX 512 -CenterY 512 -OuterRadius 255 -InnerRadius 105 `
    -Color ([System.Drawing.Color]::FromArgb(118, 255, 255, 255))
Draw-StarGlow -Graphics $graphics -CenterX 512 -CenterY 512 -OuterRadius 210 -InnerRadius 92 `
    -Color ([System.Drawing.Color]::FromArgb(88, 255, 250, 255))

Draw-GlowCircle -Graphics $graphics -CenterX 512 -CenterY 512 -Diameter 265 `
    -CenterColor ([System.Drawing.Color]::FromArgb(255, 255, 251, 245)) `
    -OuterColor ([System.Drawing.Color]::FromArgb(70, 255, 247, 250))
Draw-GlowCircle -Graphics $graphics -CenterX 512 -CenterY 512 -Diameter 170 `
    -CenterColor ([System.Drawing.Color]::FromArgb(255, 255, 254, 250)) `
    -OuterColor ([System.Drawing.Color]::FromArgb(0, 255, 255, 255))

$miniSpark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(150, 255, 255, 255))
$graphics.FillEllipse($miniSpark, 768, 248, 18, 18)
$graphics.FillEllipse($miniSpark, 730, 300, 9, 9)
$miniSpark.Dispose()

$bitmap.Save($basePath, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$bitmap.Dispose()

Resize-Image -SourcePath $basePath -Size 256 -DestinationPath $previewPath

$androidTargets = @{
    'mipmap-mdpi\ic_launcher.png'   = 48
    'mipmap-hdpi\ic_launcher.png'   = 72
    'mipmap-xhdpi\ic_launcher.png'  = 96
    'mipmap-xxhdpi\ic_launcher.png' = 144
    'mipmap-xxxhdpi\ic_launcher.png' = 192
}

foreach ($target in $androidTargets.GetEnumerator()) {
    $destination = Join-Path $androidRes $target.Key
    Resize-Image -SourcePath $basePath -Size $target.Value -DestinationPath $destination
}

$iosTargets = @{
    'Icon-App-20x20@1x.png' = 20
    'Icon-App-20x20@2x.png' = 40
    'Icon-App-20x20@3x.png' = 60
    'Icon-App-29x29@1x.png' = 29
    'Icon-App-29x29@2x.png' = 58
    'Icon-App-29x29@3x.png' = 87
    'Icon-App-40x40@1x.png' = 40
    'Icon-App-40x40@2x.png' = 80
    'Icon-App-40x40@3x.png' = 120
    'Icon-App-60x60@2x.png' = 120
    'Icon-App-60x60@3x.png' = 180
    'Icon-App-76x76@1x.png' = 76
    'Icon-App-76x76@2x.png' = 152
    'Icon-App-83.5x83.5@2x.png' = 167
    'Icon-App-1024x1024@1x.png' = 1024
}

foreach ($target in $iosTargets.GetEnumerator()) {
    $destination = Join-Path $iosIconDir $target.Key
    Resize-Image -SourcePath $basePath -Size $target.Value -DestinationPath $destination
}

Write-Output "Generated: $basePath"
Write-Output "Preview: $previewPath"
