Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path 'Website #001.docx'))
$entry = $zip.Entries | Where-Object { $_.FullName -eq 'word/document.xml' }
$stream = $entry.Open()
$reader = New-Object System.IO.StreamReader($stream)
$xml = $reader.ReadToEnd()

# Check media images in docx
$mediaEntries = $zip.Entries | Where-Object { $_.FullName -like 'word/media/*' }
Write-Host "Media files in docx: $($mediaEntries.Count)"
foreach ($m in $mediaEntries) {
    Write-Host " - $($m.FullName) ($($m.Length) bytes)"
}

$zip.Dispose()

# Strip XML tags to plain text
$plain = [regex]::Replace($xml, '<w:p[ >]', "`n")
$plain = [regex]::Replace($plain, '<[^>]+>', '')
$plain = [System.Web.HttpUtility]::HtmlDecode($plain)
$plain | Out-File -FilePath 'docx_extracted_text.txt' -Encoding utf8
Write-Host "Extracted docx text saved to docx_extracted_text.txt"
