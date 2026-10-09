# Download any remaining images and assets from all raw_pages
$baseUrl = 'https://proventusvaluetech.com'

$rawFiles = Get-ChildItem -Path 'raw_pages' -Filter '*.html'
$allImgUrls = @()

foreach ($file in $rawFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding utf8
    $matches = [regex]::Matches($content, '(?:src|href|content|srcset|background(?:-image)?:\s*url\()=?["'']?(https?://proventusvaluetech\.com/wp-content/uploads/[^"'')\s>]+\.(?:png|jpg|jpeg|gif|svg|webp|ico)|/wp-content/uploads/[^"'')\s>]+\.(?:png|jpg|jpeg|gif|svg|webp|ico))')
    foreach ($m in $matches) {
        $u = $m.Groups[1].Value
        if ($u.StartsWith('/')) { $u = "$baseUrl$u" }
        $allImgUrls += $u
    }
}

$allImgUrls = $allImgUrls | Select-Object -Unique
Write-Host "Found $($allImgUrls.Count) unique upload images across all pages"

foreach ($imgUrl in $allImgUrls) {
    $uri = [System.Uri]$imgUrl
    $fileName = [System.IO.Path]::GetFileName($uri.AbsolutePath)
    $localPath = "assets/images/$fileName"
    
    if (-not (Test-Path $localPath)) {
        try {
            Invoke-WebRequest -Uri $imgUrl -UserAgent 'Mozilla/5.0' -UseBasicParsing -OutFile $localPath
            Write-Host "Downloaded: $fileName"
        } catch {
            Write-Host "Failed to download $imgUrl : $_"
        }
    }
}
