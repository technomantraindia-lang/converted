# PowerShell script to analyze site and download all assets & pages
$ErrorActionPreference = 'SilentlyContinue'

$baseUrl = 'https://proventusvaluetech.com'

# Create asset directories
New-Item -ItemType Directory -Force -Path 'assets/css' | Out-Null
New-Item -ItemType Directory -Force -Path 'assets/js' | Out-Null
New-Item -ItemType Directory -Force -Path 'assets/images' | Out-Null
New-Item -ItemType Directory -Force -Path 'assets/fonts' | Out-Null
New-Item -ItemType Directory -Force -Path 'raw_pages' | Out-Null

$html = Get-Content -Path 'homepage_raw.html' -Raw -Encoding utf8

# Save homepage to raw_pages
Set-Content -Path 'raw_pages/index.html' -Value $html -Encoding utf8

# Extract all links
$linkPattern = 'href=["''](https?://proventusvaluetech\.com[^"'']+|/[^"'']+)["'']'
$pageLinks = @()
$matches = [regex]::Matches($html, $linkPattern)
foreach ($m in $matches) {
    $url = $m.Groups[1].Value
    if ($url -notmatch '\.(css|js|png|jpg|jpeg|gif|svg|webp|woff|woff2|ttf|eot|ico|xml|rss)(\?.*)?$' -and $url -notmatch '#') {
        if ($url.StartsWith('/')) {
            $url = $baseUrl + $url
        }
        $pageLinks += $url
    }
}
$pageLinks = $pageLinks | Select-Object -Unique

Write-Host "Discovered internal page links:"
$pageLinks | ForEach-Object { Write-Host " - $_" }

# Save discovered links to JSON
$pageLinks | ConvertTo-Json | Out-File -FilePath 'discovered_pages.json' -Encoding utf8

# Download all subpages
foreach ($pageUrl in $pageLinks) {
    if ($pageUrl -ne "$baseUrl/" -and $pageUrl -ne "$baseUrl") {
        $slug = $pageUrl.TrimEnd('/').Split('/')[-1]
        if (-not $slug) { $slug = "home" }
        $destFile = "raw_pages/$slug.html"
        Write-Host "Downloading subpage: $pageUrl -> $destFile"
        try {
            Invoke-WebRequest -Uri $pageUrl -UserAgent 'Mozilla/5.0' -UseBasicParsing | Select-Object -ExpandProperty Content | Out-File -FilePath $destFile -Encoding utf8
        } catch {
            Write-Host "Failed to download $pageUrl : $_"
        }
    }
}

# Now collect all CSS, JS, and image URLs from all raw_pages
$allRawFiles = Get-ChildItem -Path 'raw_pages' -Filter '*.html'
$allCssUrls = @()
$allJsUrls = @()
$allImgUrls = @()

foreach ($file in $allRawFiles) {
    $c = Get-Content -Path $file.FullName -Raw -Encoding utf8
    
    # CSS
    $cssMatches = [regex]::Matches($c, '(?:href|src)=["''](https?://[^"'']+\.css(?:\?[^"'']*)?|//[^"'']+\.css(?:\?[^"'']*)?|/[^"'']+\.css(?:\?[^"'']*)?)["'']')
    foreach ($m in $cssMatches) { $allCssUrls += $m.Groups[1].Value }
    
    # JS
    $jsMatches = [regex]::Matches($c, 'src=["''](https?://[^"'']+\.js(?:\?[^"'']*)?|//[^"'']+\.js(?:\?[^"'']*)?|/[^"'']+\.js(?:\?[^"'']*)?)["'']')
    foreach ($m in $jsMatches) { $allJsUrls += $m.Groups[1].Value }
    
    # Images
    $imgMatches = [regex]::Matches($c, '(?:src|href|content|srcset|background(?:-image)?:\s*url\()=?["'']?(https?://[^"'')\s>]+\.(?:png|jpg|jpeg|gif|svg|webp|ico)(?:\?[^"'')\s>]*)?|/[^"'')\s>]+\.(?:png|jpg|jpeg|gif|svg|webp|ico)(?:\?[^"'')\s>]*)?)')
    foreach ($m in $imgMatches) { $allImgUrls += $m.Groups[1].Value }
}

$allCssUrls = $allCssUrls | Select-Object -Unique
$allJsUrls = $allJsUrls | Select-Object -Unique
$allImgUrls = $allImgUrls | Select-Object -Unique

Write-Host "Total CSS URLs: $($allCssUrls.Count)"
Write-Host "Total JS URLs: $($allJsUrls.Count)"
Write-Host "Total Image URLs: $($allImgUrls.Count)"

$manifest = @{
    css = $allCssUrls
    js = $allJsUrls
    images = $allImgUrls
}
$manifest | ConvertTo-Json -Depth 5 | Out-File -FilePath 'assets_manifest.json' -Encoding utf8
