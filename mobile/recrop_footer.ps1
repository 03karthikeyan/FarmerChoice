Add-Type -AssemblyName System.Drawing

$src = "d:\MediaWaveTech\FarmerChoice\mobile\assets\images\login_hero_bg.png"
$img = [System.Drawing.Image]::FromFile($src)
$w = $img.Width
$h = $img.Height

# Exact crop of bottom scenery (green hills, trees, house, rolling fields)
$yStart = [int]($h * 0.905)
$hFooter = $h - $yStart

$rectFooter = New-Object System.Drawing.Rectangle(0, $yStart, $w, $hFooter)
$bmpFooter = New-Object System.Drawing.Bitmap($w, $hFooter)
$gFooter = [System.Drawing.Graphics]::FromImage($bmpFooter)
$gFooter.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gFooter.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gFooter.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

$gFooter.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $w, $hFooter)), $rectFooter, [System.Drawing.GraphicsUnit]::Pixel)
$gFooter.Dispose()

$dest = "d:\MediaWaveTech\FarmerChoice\mobile\assets\images\scenery_footer.png"
$bmpFooter.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
$bmpFooter.Dispose()

$img.Dispose()
Write-Host "SCENERY FOOTER CROPPED SUCCESSFULLY ($w x $hFooter)"
