# Garbled text (mojibake) check for all Kannada simulation HTML files.
# Detects UTF-8-interpreted-as-Latin-1 patterns (e.g. à²... à³...). Exit 0 = all clean, 1 = any file has mojibake.

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$outDir = Join-Path $repoRoot "kannada_simulations"

# Mojibake: à (U+00E0) or similar Latin-1 followed by ² (U+00B2) or ³ (U+00B3) and continuation bytes (e.g. à, º, etc.)
# Pattern: sequence of 3-byte UTF-8 decoded as Latin-1: often à²X à²Y or à³X (Kannada UTF-8 bytes)
$mojibakePattern = [regex]'à²[à-ÿ]?|à³[à-ÿ]?|à[²³][\u00A0-\u00FF]{0,2}'
# Simpler: any run of Latin-1 supplement that looks like mojibake (à followed by digits/superscripts and more)
$mojibakeRun = [regex]'à[²³][àº¹²³¼-ÿ\u00A0-\u00FF]{1,}'

$files = Get-ChildItem -Path $outDir -Filter "*_kn.html" | Sort-Object Name
$totalSegments = 0
$filesWithMojibake = 0
$results = [System.Collections.ArrayList]::new()

foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $name = $f.Name

    # Body only (GT1)
    $bodyOnly = $content -replace '(?s)<script.*?</script>', ' '
    $bodyOnly = $bodyOnly -replace '(?s)<style.*?</style>', ' '
    $bodyHits = [regex]::Matches($bodyOnly, $mojibakeRun)
    $bodyCount = $bodyHits.Count

    # Script block (GT2)
    $scriptBlocks = [regex]::Matches($content, '(?s)<script.*?</script>')
    $scriptContent = ($scriptBlocks | ForEach-Object { $_.Value }) -join "`n"
    $scriptHits = [regex]::Matches($scriptContent, $mojibakeRun)
    $scriptCount = $scriptHits.Count

    $fileTotal = $bodyCount + $scriptCount
    $totalSegments += $fileTotal
    if ($fileTotal -gt 0) { $filesWithMojibake++ }

    [void]$results.Add([PSCustomObject]@{
        File       = $name
        BodyHits   = $bodyCount
        ScriptHits = $scriptCount
        Total      = $fileTotal
        Clean      = ($fileTotal -eq 0)
    })
}

# Report
$reportPath = Join-Path $scriptDir "garbled-check-report.txt"
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("Garbled text (mojibake) check - " + (Get-Date -Format "yyyy-MM-dd HH:mm"))
[void]$sb.AppendLine("Pattern: à²/à³ runs (UTF-8 Kannada misinterpreted as Latin-1)")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("Per file:")
foreach ($r in $results) {
    $status = if ($r.Clean) { "CLEAN" } else { "HITS" }
    [void]$sb.AppendLine("$status | Body:$($r.BodyHits) Script:$($r.ScriptHits) | $($r.File)")
}
[void]$sb.AppendLine("")
$cleanCount = ($results | Where-Object { $_.Clean }).Count
[void]$sb.AppendLine("Coverage: $cleanCount / $($files.Count) files clean (0 mojibake)")
[void]$sb.AppendLine("Total mojibake segments: $totalSegments")
[void]$sb.AppendLine("Files with mojibake: $filesWithMojibake")
[System.IO.File]::WriteAllText($reportPath, $sb.ToString(), [System.Text.Encoding]::UTF8)

Write-Host "Garbled check: $cleanCount / $($files.Count) files clean; $totalSegments total mojibake segments" -ForegroundColor $(if ($filesWithMojibake -eq 0) { 'Green' } else { 'Yellow' })
Write-Host "Report: $reportPath" -ForegroundColor Gray
if ($filesWithMojibake -gt 0) { exit 1 }
exit 0
