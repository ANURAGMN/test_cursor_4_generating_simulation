# Learnability check: can a Kannada student learn from the HTML?
# L1=heading in Kannada, L2=learning block present, L3=min Kannada text, L4=explanatory paragraph. Exit 0 = all pass.

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$outDir = Join-Path $repoRoot "kannada_simulations"

$kannadaChar = [regex]'[\u0C80-\u0CFF]'
$minKannadaChars = 80   # minimum instructional Kannada characters for L3
$minParagraphKannada = 20  # minimum Kannada in one paragraph-like block for L4

# Learning block patterns: class or id that typically holds concept/takeaway/learning content
$learningBlockPattern = [regex]'(?i)(class|id)=["''][^"'']*(concept-card|takeaway|learning-text|detail-text|method-info|info-panel|info-text|process-text|concept-title|concept-text|method-title|method-text|result-text|working-text|table-title)'

$files = Get-ChildItem -Path $outDir -Filter "*_kn.html" | Sort-Object Name
$results = [System.Collections.ArrayList]::new()
$l1Pass = 0; $l2Pass = 0; $l3Pass = 0; $l4Pass = 0

foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $name = $f.Name

    $bodyOnly = $content -replace '(?s)<script.*?</script>', ' '
    $bodyOnly = $bodyOnly -replace '(?s)<style.*?</style>', ' '

    # L1: at least one h1 or h2 with Kannada
    $l1 = $false
    foreach ($tag in @('h1', 'h2')) {
        $m = [regex]::Match($bodyOnly, "<${tag}[^>]*>([^<]{1,}?)</${tag}>", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($m.Success -and $m.Groups[1].Value -match $kannadaChar) { $l1 = $true; break }
    }
    if ($l1) { $l1Pass++ }

    # L2: at least one learning block (concept/takeaway/learning/detail/method-info etc.)
    $l2 = $bodyOnly -match $learningBlockPattern
    if ($l2) { $l2Pass++ }

    # L3: total Kannada character count in body >= threshold
    $kannadaMatches = [regex]::Matches($bodyOnly, $kannadaChar)
    $kannadaCount = $kannadaMatches.Count
    $l3 = $kannadaCount -ge $minKannadaChars
    if ($l3) { $l3Pass++ }

    # L4: at least one paragraph-like segment with >= minParagraphKannada Kannada chars
    $l4 = $false
    $paraPatterns = @(
        '<p[^>]*>([^<]+)</p>',
        'class="[^"]*concept-text[^"]*"[^>]*>([^<]+)<',
        'class="[^"]*method-text[^"]*"[^>]*>([^<]+)<',
        'class="[^"]*detail-text[^"]*"[^>]*>([^<]+)<',
        'class="[^"]*info-text[^"]*"[^>]*>([^<]+)<'
    )
    foreach ($pat in $paraPatterns) {
        $ms = [regex]::Matches($bodyOnly, $pat, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        foreach ($mm in $ms) {
            $seg = $mm.Groups[1].Value
            $kc = ([regex]::Matches($seg, $kannadaChar)).Count
            if ($kc -ge $minParagraphKannada) { $l4 = $true; break }
        }
        if ($l4) { break }
    }
    if ($l4) { $l4Pass++ }

    $learnabilityPass = $l1 -and $l2 -and $l3
    [void]$results.Add([PSCustomObject]@{
        File    = $name
        L1      = $l1
        L2      = $l2
        L3      = $l3
        L4      = $l4
        KnCount = $kannadaCount
        Pass    = $learnabilityPass
    })
}

# Report
$reportPath = Join-Path $scriptDir "learnability-check-report.txt"
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("Learnability check (can a Kannada student learn from the HTML?) - " + (Get-Date -Format "yyyy-MM-dd HH:mm"))
[void]$sb.AppendLine("L1=heading in Kannada | L2=learning block | L3=Kannada chars>=" + $minKannadaChars + " | L4=explanatory paragraph")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("Per file (L1 L2 L3 L4 | KannadaChars | Pass):")
foreach ($r in $results) {
    $status = if ($r.Pass) { "PASS" } else { "FAIL" }
    [void]$sb.AppendLine("$status | L1:$($r.L1) L2:$($r.L2) L3:$($r.L3) L4:$($r.L4) | $($r.KnCount) | $($r.File)")
}
[void]$sb.AppendLine("")
$passCount = ($results | Where-Object { $_.Pass }).Count
[void]$sb.AppendLine("Learnability coverage: $passCount / $($files.Count) files pass (L1 and L2 and L3)")
[void]$sb.AppendLine("L1 (Kannada heading): $l1Pass / $($files.Count)")
[void]$sb.AppendLine("L2 (learning block):  $l2Pass / $($files.Count)")
[void]$sb.AppendLine("L3 (min Kannada):    $l3Pass / $($files.Count)")
[void]$sb.AppendLine("L4 (paragraph):      $l4Pass / $($files.Count)")
[System.IO.File]::WriteAllText($reportPath, $sb.ToString(), [System.Text.Encoding]::UTF8)

Write-Host "Learnability: $passCount / $($files.Count) files pass (Kannada student can learn); L1:$l1Pass L2:$l2Pass L3:$l3Pass L4:$l4Pass" -ForegroundColor $(if ($passCount -eq $files.Count) { 'Green' } else { 'Cyan' })
Write-Host "Report: $reportPath" -ForegroundColor Gray
if ($passCount -lt $files.Count) { exit 1 }
exit 0
