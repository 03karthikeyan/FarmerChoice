Add-Type -AssemblyName System.Drawing

$src = "d:\MediaWaveTech\FarmerChoice\mobile\assets\images\login_hero_bg.png"
$img = [System.Drawing.Image]::FromFile($src)
$w = $img.Width
$h = $img.Height

# 1. Top Hero
$hCrop = [int]($h * 0.44)
$rectHero = New-Object System.Drawing.Rectangle(0, 0, $w, $hCrop)
$bmpHero = New-Object System.Drawing.Bitmap($w, $hCrop)
$gHero = [System.Drawing.Graphics]::FromImage($bmpHero)
$gHero.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gHero.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $w, $hCrop)), $rectHero, [System.Drawing.GraphicsUnit]::Pixel)
$gHero.Dispose()
$bmpHero.Save("d:\MediaWaveTech\FarmerChoice\mobile\assets\images\login_hero_top.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmpHero.Dispose()

# 2. Logo Emblem
$rectLogo = New-Object System.Drawing.Rectangle(295, 30, 260, 235)
$bmpLogo = New-Object System.Drawing.Bitmap(260, 235)
$gLogo = [System.Drawing.Graphics]::FromImage($bmpLogo)
$gLogo.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gLogo.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, 260, 235)), $rectLogo, [System.Drawing.GraphicsUnit]::Pixel)
$gLogo.Dispose()
$bmpLogo.Save("d:\MediaWaveTech\FarmerChoice\mobile\assets\images\farmer_choice_logo.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmpLogo.Dispose()

# 3. App Icon (Square format)
$size = 192
$rectIcon = New-Object System.Drawing.Rectangle(345, 25, 160, 160)
$bmpIcon = New-Object System.Drawing.Bitmap($size, $size)
$gIcon = [System.Drawing.Graphics]::FromImage($bmpIcon)
$gIcon.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gIcon.Clear([System.Drawing.Color]::White)
$gIcon.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $size, $size)), $rectIcon, [System.Drawing.GraphicsUnit]::Pixel)
$gIcon.Dispose()
$bmpIcon.Save("d:\MediaWaveTech\FarmerChoice\mobile\assets\images\app_icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmpIcon.Dispose()

# 4. Scenery Footer
$hFooter = [int]($h * 0.08)
$yFooter = $h - $hFooter
$rectFooter = New-Object System.Drawing.Rectangle(0, $yFooter, $w, $hFooter)
$bmpFooter = New-Object System.Drawing.Bitmap($w, $hFooter)
$gFooter = [System.Drawing.Graphics]::FromImage($bmpFooter)
$gFooter.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gFooter.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $w, $hFooter)), $rectFooter, [System.Drawing.GraphicsUnit]::Pixel)
$gFooter.Dispose()
$bmpFooter.Save("d:\MediaWaveTech\FarmerChoice\mobile\assets\images\scenery_footer.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmpFooter.Dispose()

$img.Dispose()
Write-Host "ALL ASSETS EXTRACTED SUCCESSFULLY"
