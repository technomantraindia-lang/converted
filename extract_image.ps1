Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

$zip = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path 'Website #001.docx'))
$entry = $zip.Entries | Where-Object { $_.FullName -eq 'word/media/image1.png' }
if ($entry) {
    $outPath = Join-Path (Get-Location) 'assets/images/docx_dropdown_menu.png'
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $outPath, $true)
    Write-Host "Extracted image1.png to assets/images/docx_dropdown_menu.png"
}
$zip.Dispose()
