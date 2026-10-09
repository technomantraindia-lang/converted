# Script to download all assets, CSS, JS, Images, and Fonts
$baseUrl = 'https://proventusvaluetech.com'

# Read manifest
$manifest = Get-Content -Path 'assets_manifest.json' -Raw | ConvertFrom-Json

# Helper to normalize URL
function Get-AbsoluteUrl($url) {
    if ($url.StartsWith('//')) { return "https:$url" }
    if ($url.StartsWith('/')) { return "$baseUrl$url" }
    if ($url.StartsWith('http')) { return $url }
    return "$baseUrl/$url"
}

# Download CSS
Write-Host "Downloading CSS files..."
$cssMapping = @{}
$cssIndex = 1
foreach ($cssUrl in $manifest.css) {
    $fullUrl = Get-AbsoluteUrl $cssUrl
    $uri = [System.Uri]$fullUrl
    $fileName = [System.IO.Path]::GetFileName($uri.AbsolutePath)
    if (-not $fileName -or $fileName -eq '') { $fileName = "style_$cssIndex.css" }
    $localPath = "assets/css/$fileName"
    
    # ensure unique name if collisions
    $counter = 1
    while (Test-Path $localPath) {
        $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        $ext = [System.IO.Path]::GetExtension($fileName)
        $localPath = "assets/css/${nameWithoutExt}_$counter$ext"
        $counter++
    }
    
    try {
        Invoke-WebRequest -Uri $fullUrl -UserAgent 'Mozilla/5.0' -UseBasicParsing -OutFile $localPath
        $cssMapping[$cssUrl] = $localPath.Replace('\', '/')
        Write-Host "Downloaded CSS: $fileName"
    } catch {
        Write-Host "Failed to download CSS $($fullUrl): $_"
    }
    $cssIndex++
}

# Download JS
Write-Host "Downloading JS files..."
$jsMapping = @{}
$jsIndex = 1
foreach ($jsUrl in $manifest.js) {
    $fullUrl = Get-AbsoluteUrl $jsUrl
    $uri = [System.Uri]$fullUrl
    $fileName = [System.IO.Path]::GetFileName($uri.AbsolutePath)
    if (-not $fileName -or $fileName -eq '') { $fileName = "script_$jsIndex.js" }
    $localPath = "assets/js/$fileName"
    
    $counter = 1
    while (Test-Path $localPath) {
        $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        $ext = [System.IO.Path]::GetExtension($fileName)
        $localPath = "assets/js/${nameWithoutExt}_$counter$ext"
        $counter++
    }
    
    try {
        Invoke-WebRequest -Uri $fullUrl -UserAgent 'Mozilla/5.0' -UseBasicParsing -OutFile $localPath
        $jsMapping[$jsUrl] = $localPath.Replace('\', '/')
        Write-Host "Downloaded JS: $fileName"
    } catch {
        Write-Host "Failed to download JS $($fullUrl): $_"
    }
    $jsIndex++
}

# Download Images
Write-Host "Downloading Images..."
$imgMapping = @{}
$imgIndex = 1
foreach ($imgUrl in $manifest.images) {
    $fullUrl = Get-AbsoluteUrl $imgUrl
    $uri = [System.Uri]$fullUrl
    $fileName = [System.IO.Path]::GetFileName($uri.AbsolutePath)
    if (-not $fileName -or $fileName -eq '') { $fileName = "image_$imgIndex.png" }
    $localPath = "assets/images/$fileName"
    
    # If file already exists with same name and content, map it
    if (Test-Path $localPath) {
        $imgMapping[$imgUrl] = $localPath.Replace('\', '/')
        continue
    }
    
    try {
        Invoke-WebRequest -Uri $fullUrl -UserAgent 'Mozilla/5.0' -UseBasicParsing -OutFile $localPath
        $imgMapping[$imgUrl] = $localPath.Replace('\', '/')
        Write-Host "Downloaded Image: $fileName"
    } catch {
        Write-Host "Failed to download Image $($fullUrl): $_"
    }
    $imgIndex++
}

# Search in downloaded CSS for fonts and background images
$downloadedCss = Get-ChildItem -Path 'assets/css' -Filter '*.css'
$extraUrls = @()
foreach ($f in $downloadedCss) {
    $content = Get-Content -Path $f.FullName -Raw -Encoding utf8
    $fontMatches = [regex]::Matches($content, 'url\s*\(\s*["'']?([^"'')]+)["'']?\s*\)')
    foreach ($m in $fontMatches) {
        $u = $m.Groups[1].Value
        if ($u -notmatch '^data:' -and $u -notmatch '^#') {
            $extraUrls += $u
        }
    }
}
$extraUrls = $extraUrls | Select-Object -Unique
Write-Host "Found $($extraUrls.Count) extra asset URLs inside CSS"

foreach ($u in $extraUrls) {
    $fullUrl = $u
    if ($fullUrl.StartsWith('//')) { $fullUrl = "https:$fullUrl" }
    elseif ($fullUrl.StartsWith('/')) { $fullUrl = "$baseUrl$fullUrl" }
    elseif ($fullUrl -notmatch '^https?://') {
        # relative to elementor or fonts
        $fullUrl = "$baseUrl/wp-content/plugins/elementor/assets/lib/font-awesome/webfonts/$u"
    }
    
    $uri = [System.Uri]$fullUrl
    $fileName = [System.IO.Path]::GetFileName($uri.AbsolutePath)
    if ($fileName -match '\.(woff2?|ttf|eot|svg|otf)(\?.*)?$') {
        $cleanFileName = $fileName.Split('?')[0]
        $localPath = "assets/fonts/$cleanFileName"
        if (-not (Test-Path $localPath)) {
            try {
                Invoke-WebRequest -Uri $fullUrl -UserAgent 'Mozilla/5.0' -UseBasicParsing -OutFile $localPath
                Write-Host "Downloaded Font: $cleanFileName"
            } catch {
                # try alternative path
                try {
                    $altUrl = "https://proventusvaluetech.com/wp-content/plugins/elementor/assets/lib/eicons/fonts/$cleanFileName"
                    Invoke-WebRequest -Uri $altUrl -UserAgent 'Mozilla/5.0' -UseBasicParsing -OutFile $localPath
                    Write-Host "Downloaded Font from alt: $cleanFileName"
                } catch {
                    Write-Host "Failed to download font $fullUrl"
                }
            }
        }
    }
}

# Save URL mappings
@{
    css = $cssMapping
    js = $jsMapping
    images = $imgMapping
} | ConvertTo-Json -Depth 5 | Out-File -FilePath 'downloaded_mappings.json' -Encoding utf8

Write-Host "All assets downloaded and mapping saved to downloaded_mappings.json"
