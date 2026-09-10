Add-Type -AssemblyName System.Drawing

$src = "d:\MediaWaveTech\FarmerChoice\mobile\assets\images\app_icon.png"
$img = [System.Drawing.Image]::FromFile($src)

$sizes = @{
    "mipmap-mdpi" = 48
    "mipmap-hdpi" = 72
    "mipmap-xhdpi" = 96
    "mipmap-xxhdpi" = 144
    "mipmap-xxxhdpi" = 192
}

foreach ($folder in $sizes.Keys) {
    $size = $sizes[$folder]
    $destDir = "d:\MediaWaveTech\FarmerChoice\mobile\android\app\src\main\res\$folder"
    if (!(Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir | Out-Null
    }
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::White)
    $g.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $size, $size)), (New-Object System.Drawing.Rectangle(0, 0, $img.Width, $img.Height)), [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    $destPath = Join-Path $destDir "ic_launcher.png"
    $bmp.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

$img.Dispose()
Write-Host "APP ICONS GENERATED SUCCESSFULLY"
