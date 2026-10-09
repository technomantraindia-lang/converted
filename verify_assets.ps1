# Verification script to ensure all assets exist locally
$htmlFiles = Get-ChildItem -Path '.' -Filter '*.html' -File

$allValid = $true
$missingAssets = @()

foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding utf8
    
    # Check CSS links
    $cssMatches = [regex]::Matches($content, 'href=["''](assets/css/[^"'']+)["'']')
    foreach ($m in $cssMatches) {
        $path = $m.Groups[1].Value
        if (-not (Test-Path $path)) {
            Write-Host "Missing CSS in $($file.Name): $path" -ForegroundColor Red
            $allValid = $false
            $missingAssets += $path
        }
    }
    
    # Check JS scripts
    $jsMatches = [regex]::Matches($content, 'src=["''](assets/js/[^"'']+)["'']')
    foreach ($m in $jsMatches) {
        $path = $m.Groups[1].Value
        if (-not (Test-Path $path)) {
            Write-Host "Missing JS in $($file.Name): $path" -ForegroundColor Red
            $allValid = $false
            $missingAssets += $path
        }
    }
    
    # Check Images
    $imgMatches = [regex]::Matches($content, '(?:src|srcset|background(?:-image)?:\s*url\()=?["'']?(assets/images/[^"'')\s,>]+)')
    foreach ($m in $imgMatches) {
        $path = $m.Groups[1].Value
        if (-not (Test-Path $path)) {
            Write-Host "Missing Image in $($file.Name): $path" -ForegroundColor Red
            $allValid = $false
            $missingAssets += $path
        }
    }
}

if ($allValid) {
    Write-Host "SUCCESS: All CSS, JS, and Image references across all HTML pages exist locally!" -ForegroundColor Green
} else {
    Write-Host "Missing $($missingAssets.Count) assets." -ForegroundColor Yellow
}
