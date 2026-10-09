# Conversion Builder Script for Proventus Value Tech
$mappings = Get-Content -Path 'downloaded_mappings.json' -Raw | ConvertFrom-Json

# 1. Fix CSS files (relativize font and image paths)
$cssFiles = Get-ChildItem -Path 'assets/css' -Filter '*.css'
foreach ($f in $cssFiles) {
    $c = Get-Content -Path $f.FullName -Raw -Encoding utf8
    
    # Fix webfonts paths
    $c = $c -replace 'url\s*\(\s*["'']?\.\./webfonts/([^"'')]+)["'']?\s*\)', 'url("../fonts/$1")'
    $c = $c -replace 'url\s*\(\s*["'']?(?:https?:)?//proventusvaluetech\.com/wp-content/plugins/elementor/assets/lib/eicons/fonts/([^"'')]+)["'']?\s*\)', 'url("../fonts/$1")'
    $c = $c -replace 'url\s*\(\s*["'']?(?:https?:)?//proventusvaluetech\.com/wp-content/plugins/elementor/assets/lib/font-awesome/webfonts/([^"'')]+)["'']?\s*\)', 'url("../fonts/$1")'
    $c = $c -replace 'url\s*\(\s*["'']?(?:https?:)?//proventusvaluetech\.com/wp-content/uploads/[^/]+/[^/]+/([^"'')]+)["'']?\s*\)', 'url("../images/$1")'
    
    Set-Content -Path $f.FullName -Value $c -Encoding utf8
}
Write-Host "Updated all CSS files."

# 2. List of pages to convert
$pages = @(
    @{ Src = 'raw_pages/index.html'; Dest = 'index.html'; Title = 'Preventus Value Tech' },
    @{ Src = 'raw_pages/about-us.html'; Dest = 'about-us.html'; Title = 'About Us - Preventus Value Tech' },
    @{ Src = 'raw_pages/our-team.html'; Dest = 'our-team.html'; Title = 'Our Team - Preventus Value Tech' },
    @{ Src = 'raw_pages/projects.html'; Dest = 'projects.html'; Title = 'Projects - Preventus Value Tech' },
    @{ Src = 'raw_pages/contact-us.html'; Dest = 'contact-us.html'; Title = 'Contact Us - Preventus Value Tech' },
    @{ Src = 'raw_pages/process-design-engineering.html'; Dest = 'process-design-engineering.html'; Title = 'Process Design Engineering - Preventus Value Tech' },
    @{ Src = 'raw_pages/plant-design-engineering.html'; Dest = 'plant-design-engineering.html'; Title = 'Plant Design Engineering - Preventus Value Tech' },
    @{ Src = 'raw_pages/technology-sales.html'; Dest = 'technology-sales.html'; Title = 'Technology Sales - Preventus Value Tech' },
    @{ Src = 'raw_pages/project-feasibility-study.html'; Dest = 'project-feasibility-study.html'; Title = 'Project Feasibility Study - Preventus Value Tech' },
    @{ Src = 'raw_pages/due-diligence.html'; Dest = 'due-diligence.html'; Title = 'Due Diligence - Preventus Value Tech' },
    @{ Src = 'raw_pages/process-audit-and-improvement-project.html'; Dest = 'process-audit-and-improvement-project.html'; Title = 'Process Audit and Improvement Project - Preventus Value Tech' },
    @{ Src = 'raw_pages/turnkey-oec-projects.html'; Dest = 'turnkey-oec-projects.html'; Title = 'Turnkey / OEC Projects - Preventus Value Tech' },
    @{ Src = 'raw_pages/input-material-sourcing.html'; Dest = 'input-material-sourcing.html'; Title = 'Input Material Sourcing - Preventus Value Tech' },
    @{ Src = 'raw_pages/technical-manpower-support.html'; Dest = 'technical-manpower-support.html'; Title = 'Technical Manpower Support - Preventus Value Tech' }
)

# 3. Process each page
foreach ($p in $pages) {
    if (-not (Test-Path $p.Src)) {
        Write-Host "Skipping missing source: $($p.Src)"
        continue
    }
    
    $html = Get-Content -Path $p.Src -Raw -Encoding utf8
    
    # Replace CSS links using mappings
    foreach ($prop in $mappings.css.PSObject.Properties) {
        $orig = $prop.Name
        $local = $prop.Value
        $html = $html.Replace($orig, $local)
    }
    
    # Replace JS scripts using mappings
    foreach ($prop in $mappings.js.PSObject.Properties) {
        $orig = $prop.Name
        $local = $prop.Value
        $html = $html.Replace($orig, $local)
    }
    
    # Generic CSS and JS pattern replacements for anything not in mapping
    $html = [regex]::Replace($html, 'href=["''](?:https?:)?//proventusvaluetech\.com/wp-content/cache/wpfc-minified/[^/]+/([^"'']+\.css)["'']', 'href="assets/css/$1"')
    $html = [regex]::Replace($html, 'src=["''](?:https?:)?//proventusvaluetech\.com/wp-content/cache/wpfc-minified/[^/]+/([^"'']+\.js)["'']', 'src="assets/js/$1"')
    $html = [regex]::Replace($html, 'href=["''](?:https?:)?//proventusvaluetech\.com/wp-content/uploads/elementor/css/([^"'']+\.css)(?:\?[^"'']*)?["'']', 'href="assets/css/$1"')
    $html = [regex]::Replace($html, 'href=["''](?:https?:)?//proventusvaluetech\.com/wp-content/plugins/elementor/assets/css/([^"'']+\.css)(?:\?[^"'']*)?["'']', 'href="assets/css/$1"')
    $html = [regex]::Replace($html, 'href=["''](?:https?:)?//proventusvaluetech\.com/wp-content/themes/hello-elementor/assets/css/([^"'']+\.css)(?:\?[^"'']*)?["'']', 'href="assets/css/$1"')
    $html = [regex]::Replace($html, 'src=["''](?:https?:)?//proventusvaluetech\.com/wp-includes/js/jquery/([^"'']+\.js)(?:\?[^"'']*)?["'']', 'src="assets/js/$1"')
    $html = [regex]::Replace($html, 'src=["''](?:https?:)?//proventusvaluetech\.com/wp-content/themes/hello-elementor/assets/js/([^"'']+\.js)(?:\?[^"'']*)?["'']', 'src="assets/js/$1"')
    $html = [regex]::Replace($html, 'src=["''](?:https?:)?//proventusvaluetech\.com/wp-content/plugins/elementor/assets/js/([^"'']+\.js)(?:\?[^"'']*)?["'']', 'src="assets/js/$1"')
    
    # Replace Images
    $html = [regex]::Replace($html, '(?:https?:)?//proventusvaluetech\.com/wp-content/uploads/\d{4}/\d{2}/([^"'')\s,>]+)', 'assets/images/$1')
    $html = [regex]::Replace($html, '/wp-content/uploads/\d{4}/\d{2}/([^"'')\s,>]+)', 'assets/images/$1')
    $html = [regex]::Replace($html, '/uploads/\d{4}/\d{2}/([^"'')\s,>]+)', 'assets/images/$1')
    
    # Rewrite Internal Navigation Links
    $html = $html.Replace('href="https://proventusvaluetech.com/"', 'href="index.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com"', 'href="index.html"')
    $html = $html.Replace('href="/"', 'href="index.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/about-us"', 'href="about-us.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/about-us/"', 'href="about-us.html"')
    $html = $html.Replace('href="/about-us"', 'href="about-us.html"')
    $html = $html.Replace('href="/about-us/"', 'href="about-us.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/our-team"', 'href="our-team.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/our-team/"', 'href="our-team.html"')
    $html = $html.Replace('href="/our-team"', 'href="our-team.html"')
    $html = $html.Replace('href="/our-team/"', 'href="our-team.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/projects/"', 'href="projects.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/projects"', 'href="projects.html"')
    $html = $html.Replace('href="/projects/"', 'href="projects.html"')
    $html = $html.Replace('href="/projects"', 'href="projects.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/contact-us"', 'href="contact-us.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/contact-us/"', 'href="contact-us.html"')
    $html = $html.Replace('href="/contact-us"', 'href="contact-us.html"')
    $html = $html.Replace('href="/contact-us/"', 'href="contact-us.html"')
    
    $html = $html.Replace('href="https://proventusvaluetech.com/process-design-engineering/"', 'href="process-design-engineering.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/process-design-engineering"', 'href="process-design-engineering.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/plant-design-engineering/"', 'href="plant-design-engineering.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/plant-design-engineering"', 'href="plant-design-engineering.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/technology-sales/"', 'href="technology-sales.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/technology-sales"', 'href="technology-sales.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/project-feasibility-study/"', 'href="project-feasibility-study.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/project-feasibility-study"', 'href="project-feasibility-study.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/due-diligence/"', 'href="due-diligence.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/due-diligence"', 'href="due-diligence.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/process-audit-and-improvement-project/"', 'href="process-audit-and-improvement-project.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/process-audit-and-improvement-project"', 'href="process-audit-and-improvement-project.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/turnkey-oec-projects/"', 'href="turnkey-oec-projects.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/turnkey-oec-projects"', 'href="turnkey-oec-projects.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/input-material-sourcing/"', 'href="input-material-sourcing.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/input-material-sourcing"', 'href="input-material-sourcing.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/technical-manpower-support/"', 'href="technical-manpower-support.html"')
    $html = $html.Replace('href="https://proventusvaluetech.com/technical-manpower-support"', 'href="technical-manpower-support.html"')
    
    # Wire Lets Talk buttons to contact-us.html
    $html = [regex]::Replace($html, '(<a[^>]*class="[^"]*elementor-button[^"]*"[^>]*href=)["'']#[^"'']*["'']', '$1"contact-us.html"')

    # Remove unused WP discovery/feed tags
    $html = [regex]::Replace($html, '<link rel="alternate" type="application/rss\+xml"[^>]*>', '')
    $html = [regex]::Replace($html, '<link rel="alternate" title="oEmbed[^"]*"[^>]*>', '')
    $html = [regex]::Replace($html, '<link rel="alternate" title="JSON"[^>]*>', '')
    $html = [regex]::Replace($html, '<link rel="https://api\.w\.org/"[^>]*>', '')
    $html = [regex]::Replace($html, '<link rel="EditURI"[^>]*>', '')
    $html = [regex]::Replace($html, '<link rel=''shortlink''[^>]*>', '')
    $html = [regex]::Replace($html, '<script type="speculationrules">[\s\S]*?</script>', '')
    $html = [regex]::Replace($html, '<!-- WP Fastest Cache[^>]*-->', '')
    
    # Inject header navigation fix CSS in <head>
    if ($html -notmatch 'header-navigation-fix\.css') {
        $html = $html.Replace('</head>', '<link rel="stylesheet" href="assets/css/header-navigation-fix.css">' + "`n" + '</head>')
    }
    
    # Ensure custom interactions script is included before </body>
    if ($html -notmatch 'custom-interactions\.js') {
        $html = $html.Replace('</body>', '<script src="assets/js/custom-interactions.js"></script>' + "`n" + '</body>')
    }
    
    Set-Content -Path $p.Dest -Value $html -Encoding utf8
    Write-Host "Re-built page: $($p.Dest)"
}

Write-Host "All 14 pages updated with fixed header & dropdown!"
